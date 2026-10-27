import fs from 'fs';
import path from 'path';
import JSZip from 'jszip';
import { FLUTTER_FILES } from '../src/data/flutterCodebase';

const ASSET_NAMES = [
  'greedy_box.png',
  'fortune_dragon.png',
  'slot_tiger.png',
  'queen_of_bounty.png',
  'yummy.png',
  'mahjong_ways_2.png',
  'luck_77.png',
  'gates_of_olympus.png',
  'fortune_tiger.png',
];

const IGNORED_DIRS = new Set([
  '.gradle',
  'build',
  '.dart_tool',
  '.idea',
  'captures',
  '.git',
  '.cache',
  'node_modules',
  '__pycache__',
]);

const IGNORED_FILES = new Set([
  '.DS_Store',
  'local.properties',
  '.flutter-plugins',
  '.flutter-plugins-dependencies',
  '.packages',
  'Thumbs.db',
  '*.tmp',
]);


async function exportFlutterMaster() {
  console.log('Synchronizing Flutter Master Codebase (Fresh Start Android V2 - 2026)...');

  const rootFlutterDir = path.resolve('sultan_voic_flutter');
  if (!fs.existsSync(rootFlutterDir)) {
    fs.mkdirSync(rootFlutterDir, { recursive: true });
  }

  const zip = new JSZip();

  // 1. Write and zip all FLUTTER_FILES
  for (const file of FLUTTER_FILES) {
    const diskPath = path.join(rootFlutterDir, file.path);
    const diskDir = path.dirname(diskPath);
    if (!fs.existsSync(diskDir)) {
      fs.mkdirSync(diskDir, { recursive: true });
    }
    fs.writeFileSync(diskPath, file.content, 'utf8');
    zip.file(file.path, file.content);
  }
  console.log(`Synced ${FLUTTER_FILES.length} core Flutter & Android files.`);

  // 2. Copy and zip all 9 real PNG assets
  const publicAssetsDir = fs.existsSync(path.resolve('assets/images'))
    ? path.resolve('assets/images')
    : path.resolve('public/assets/images');
  const targetFlutterAssetsDir = path.join(rootFlutterDir, 'assets/images');
  if (!fs.existsSync(targetFlutterAssetsDir)) {
    fs.mkdirSync(targetFlutterAssetsDir, { recursive: true });
  }

  for (const assetName of ASSET_NAMES) {
    const srcAsset = path.join(publicAssetsDir, assetName);
    const destAsset = path.join(targetFlutterAssetsDir, assetName);

    if (fs.existsSync(srcAsset)) {
      const buf = fs.readFileSync(srcAsset);
      fs.writeFileSync(destAsset, buf);
      zip.file(`assets/images/${assetName}`, buf);
    } else {
      console.warn(`Source asset not found: ${srcAsset}`);
    }
  }
  console.log(`Synced 9 real game image assets.`);

  // 3. Recursively add directory helper with strict cache exclusion
  const addDirRecursively = (dirPath: string, zipPrefix: string) => {
    if (!fs.existsSync(dirPath)) return;
    const entries = fs.readdirSync(dirPath);
    for (const entry of entries) {
      if (IGNORED_DIRS.has(entry) || IGNORED_FILES.has(entry)) continue;
      const fullPath = path.join(dirPath, entry);
      const relZipPath = path.join(zipPrefix, entry).replace(/\\/g, '/');
      const stat = fs.statSync(fullPath);
      if (stat.isDirectory()) {
        addDirRecursively(fullPath, relZipPath);
      } else {
        const fileBuf = fs.readFileSync(fullPath);
        zip.file(relZipPath, fileBuf);
      }
    }
  };

  // Add android folder
  addDirRecursively(path.join(rootFlutterDir, 'android'), 'android');

  // Add .github workflows
  addDirRecursively(path.join(rootFlutterDir, '.github'), '.github');

  // Add supabase schemas
  addDirRecursively(path.join(rootFlutterDir, 'supabase'), 'supabase');

  // Add root configs
  const extraFiles = ['codemagic.yaml', 'analysis_options.yaml', 'README.md'];
  for (const f of extraFiles) {
    const fPath = path.join(rootFlutterDir, f);
    if (fs.existsSync(fPath)) {
      zip.file(f, fs.readFileSync(fPath, 'utf8'));
    }
  }

  // 4. Generate master ZIP bundle in /public and at root
  console.log('Generating clean, lightweight ZIP archive (0 cache, 100% Android V2)...');
  const zipBuffer = await zip.generateAsync({
    type: 'nodebuffer',
    compression: 'DEFLATE',
    compressionOptions: { level: 9 },
  });

  const zipTargets = [
    path.resolve('public/sultan_voic_flutter_github_ready.zip'),
    path.resolve('public/sultan_voic_app.zip'),
    path.resolve('public/sultan_voic_v2_2026.zip'),
    path.resolve('sultan_voic_flutter_github_ready.zip'),
    path.resolve('sultan_voic_app.zip'),
  ];

  for (const target of zipTargets) {
    fs.writeFileSync(target, zipBuffer);
    console.log(` - ${target} (${(zipBuffer.length / 1024 / 1024).toFixed(2)} MB)`);
  }
}

exportFlutterMaster().catch((err) => {
  console.error('Export failed:', err);
  process.exit(1);
});
