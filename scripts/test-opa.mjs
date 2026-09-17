import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const baseDir = process.cwd();
const opaBin = process.platform === 'win32'
  ? path.join(baseDir, 'opa.exe')
  : path.join(baseDir, 'opa');

// Extract CLI flags passed from command line (e.g. --coverage, --bench, etc.)
const userArgs = process.argv.slice(2);
const hasCoverage = userArgs.includes('--coverage') || userArgs.includes('-c');
const hasBench = userArgs.includes('--bench');

const useCasesDir = path.join(baseDir, 'use-cases');
const useCases = fs.readdirSync(useCasesDir).filter(f =>
  fs.statSync(path.join(useCasesDir, f)).isDirectory()
);

const modeLabel = hasCoverage ? 'coverage' : hasBench ? 'benchmarking' : 'testing';
console.log(`Running native OPA ${modeLabel} across ${useCases.length} use case(s)...\n`);

let totalPassed = 0;
let totalFailed = 0;

for (const uc of useCases) {
  const ucDir = path.join(useCasesDir, uc);
  const policiesDir = path.join(ucDir, 'policies');
  const dataDir = path.join(ucDir, 'data');

  const args = ['test'];

  // Add user args first or defaults
  if (userArgs.length > 0) {
    args.push(...userArgs);
  } else {
    args.push('-v');
  }

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
  const displayCmd = `${path.basename(opaBin)} ${args.join(' ')}`;
  console.log(`$ ${displayCmd}\n`);

  let result;
  if (hasCoverage) {
    result = spawnSync(opaBin, args, { stdio: ['inherit', 'pipe', 'inherit'], cwd: baseDir, encoding: 'utf-8' });
    if (result.stdout) {
      try {
        const parsed = JSON.parse(result.stdout);
        const cleanFiles = {};
        if (parsed.files) {
          for (const [filePath, fileData] of Object.entries(parsed.files)) {
            cleanFiles[filePath] = {
              covered_lines: fileData.covered_lines ?? 0,
              not_covered_lines: fileData.not_covered_lines ?? 0,
              coverage: fileData.coverage ?? 0,
            };
          }
        }
        const cleanReport = {
          files: cleanFiles,
          covered_lines: parsed.covered_lines ?? 0,
          not_covered_lines: parsed.not_covered_lines ?? 0,
          coverage: parsed.coverage ?? 0,
        };
        console.log(JSON.stringify(cleanReport, null, 2));
      } catch {
        console.log(result.stdout);
      }
    }
  } else {
    result = spawnSync(opaBin, args, { stdio: 'inherit', cwd: baseDir });
  }

  if (result.status === 0) {
    totalPassed++;
  } else {
    totalFailed++;
  }
}

console.log(`\n========================================`);
console.log(`Summary: ${totalPassed} passed, ${totalFailed} failed`);
process.exit(totalFailed > 0 ? 1 : 0);

