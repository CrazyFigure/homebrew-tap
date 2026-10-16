// 只从项目的正式 Release 更新清单：两种架构齐全后才下载、核验并原子替换元数据。
import { createHash } from 'node:crypto';
import { appendFile, readFile, rename, writeFile } from 'node:fs/promises';

const caskPath = new URL('../Casks/noteboard.rb', import.meta.url);
const current = await readFile(caskPath, 'utf8');
const versionPattern = /^  version "(\d+\.\d+\.\d+)"$/m;
const armPattern = /^  sha256 arm:   "([a-f0-9]{64})",$/m;
const intelPattern = /^         intel: "([a-f0-9]{64})"$/m;
const oldVersion = current.match(versionPattern)?.[1];
const oldArm = current.match(armPattern)?.[1];
const oldIntel = current.match(intelPattern)?.[1];
if (!oldVersion || !oldArm || !oldIntel) throw new Error('Cask 格式不符，停止更新以避免误写');

// API 令牌只发送给 GitHub API；附件下载使用公开地址，不携带仓库写入凭证。
const headers = { Accept: 'application/vnd.github+json', 'User-Agent': 'NoteBoard-Homebrew-Tap' };
if (process.env.GITHUB_TOKEN) headers.Authorization = `Bearer ${process.env.GITHUB_TOKEN}`;
const response = await fetch('https://api.github.com/repos/CrazyFigure/NoteBoard/releases/latest', {
  headers, signal: AbortSignal.timeout(30_000),
});
if (!response.ok) throw new Error(`读取 Release 失败：HTTP ${response.status}`);
const release = await response.json();
const version = /^v(\d+\.\d+\.\d+)$/.exec(release.tag_name)?.[1];
if (!version || release.draft || release.prerelease) throw new Error('最新 Release 不是受支持的正式版本');

// 分段比较版本，防止旧 Release 被标记 latest 时将用户降级。
const parts = version.split('.').map(BigInt);
const oldParts = oldVersion.split('.').map(BigInt);
const firstDifference = parts.findIndex((part, index) => part !== oldParts[index]);
if (firstDifference >= 0 && parts[firstDifference] < oldParts[firstDifference]) {
  throw new Error(`拒绝降级：${oldVersion} -> ${version}`);
}
const base = `https://github.com/CrazyFigure/NoteBoard/releases/download/v${version}/`;
const assets = ['aarch64', 'x64'].map((arch) => {
  const name = `NoteBoard_${version}_${arch}.dmg`;
  return release.assets.find((asset) => asset.name === name && asset.browser_download_url === base + name);
});
if (assets.some((asset) => !asset)) {
  console.log('两个 macOS 附件尚未全部上传，保留现有版本，等待下次检查');
  process.exit(0);
}

// 下载大小与时间都有上限；逐块计算哈希，避免把整个 DMG 堆积到内存。
async function verifyAsset(asset) {
  const maxBytes = 256 * 1024 * 1024;
  if (!Number.isSafeInteger(asset.size) || asset.size <= 0 || asset.size > maxBytes) {
    throw new Error(`附件大小不符合预期：${asset.name}`);
  }
  const expected = /^sha256:([a-f0-9]{64})$/.exec(asset.digest)?.[1];
  if (!expected) throw new Error(`GitHub 未提供有效的 SHA-256：${asset.name}`);
  const download = await fetch(asset.browser_download_url, { signal: AbortSignal.timeout(120_000) });
  if (!download.ok || !download.body) throw new Error(`下载失败：${asset.name} HTTP ${download.status}`);
  const hash = createHash('sha256');
  let bytes = 0;
  for await (const chunk of download.body) {
    bytes += chunk.byteLength;
    if (bytes > maxBytes || bytes > asset.size) throw new Error(`附件超出声明大小：${asset.name}`);
    hash.update(chunk);
  }
  const actual = hash.digest('hex');
  if (bytes !== asset.size || actual !== expected) throw new Error(`附件完整性验证失败：${asset.name}`);
  return actual;
}
const [arm, intel] = await Promise.all(assets.map(verifyAsset));
if (version === oldVersion && (arm !== oldArm || intel !== oldIntel)) {
  throw new Error('同版本附件哈希已改变，拒绝自动覆盖，请人工核对发布资产');
}
const next = current.replace(versionPattern, `  version "${version}"`)
  .replace(armPattern, `  sha256 arm:   "${arm}",`)
  .replace(intelPattern, `         intel: "${intel}"`);
const changed = next !== current;
if (changed) {
  const temporary = new URL('./noteboard.rb.tmp', caskPath);
  await writeFile(temporary, next, 'utf8');
  await rename(temporary, caskPath);
}
if (process.env.GITHUB_OUTPUT) {
  await appendFile(process.env.GITHUB_OUTPUT, `changed=${changed}\nversion=${version}\n`);
}
console.log(`${changed ? '已更新' : '已核验，版本未变化'}：NoteBoard ${version}（两个 DMG）`);
