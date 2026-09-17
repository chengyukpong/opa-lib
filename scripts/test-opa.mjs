import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const baseDir = process.cwd();
const opaBin = process.platform === 'win32'
  ? path.join(baseDir, 'opa.exe')
  : path.join(baseDir, 'opa');

const useCasesDir = path.join(baseDir, 'use-cases');
const useCases = fs.readdirSync(useCasesDir).filter(f =>
  fs.statSync(path.join(useCasesDir, f)).isDirectory()
);

console.log(`Running native OPA tests across ${useCases.length} use cases...\n`);

let totalPassed = 0;
let totalFailed = 0;

for (const uc of useCases) {
  const ucDir = path.join(useCasesDir, uc);
  const policiesDir = path.join(ucDir, 'policies');
  const dataDir = path.join(ucDir, 'data');

  const args = ['test', '-v'];

  if (fs.existsSync(policiesDir)) {
    args.push(path.relative(baseDir, policiesDir).replace(/\\/g, '/'));
  }
  if (fs.existsSync(dataDir)) {
    const dataFiles = fs.readdirSync(dataDir).filter(f => f.endsWith('.json') || f.endsWith('.yaml'));
    for (const df of dataFiles) {
      args.push(path.relative(baseDir, path.join(dataDir, df)).replace(/\\/g, '/'));
    }
  }

  console.log(`\n=== Use Case: ${uc} ===`);
  const result = spawnSync(opaBin, args, { stdio: 'inherit', cwd: baseDir });

  if (result.status === 0) {
    totalPassed++;
  } else {
    totalFailed++;
  }
}

console.log(`\n========================================`);
console.log(`Summary: ${totalPassed} passed, ${totalFailed} failed`);
process.exit(totalFailed > 0 ? 1 : 0);
