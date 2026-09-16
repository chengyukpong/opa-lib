import fs from 'node:fs';
import path from 'node:path';
import { spawn } from 'node:child_process';

export interface TestCase {
  name?: string;
  description?: string;
  input: Record<string, any>;
  expected?: any;
}

export interface InputSet {
  id: string;
  name?: string;
  description?: string;
  cases: Record<string, TestCase>;
}

export interface UseCaseMeta {
  id: string;
  title?: string;
  description?: string;
  tags?: string[];
  query: string;
}

export interface EvalResult {
  id: string;
  name?: string;
  input: Record<string, any>;
  expected?: any;
  actual: any;
  passed: boolean;
}

export interface UseCaseOptions {
  baseDir?: string;
  opaPath?: string;
}

export class UseCaseInstance {
  readonly id: string;
  readonly baseDir: string;
  readonly opaPath: string;
  readonly meta: UseCaseMeta;
  readonly policyPath: string;
  readonly dataPath: string;
  readonly inputSets: InputSet[] = [];
  readonly cases: Map<string, TestCase> = new Map();

  constructor(id: string, options: UseCaseOptions = {}) {
    this.id = id;
    this.baseDir = options.baseDir || process.cwd();
    this.opaPath = options.opaPath || (process.platform === 'win32'
      ? path.join(this.baseDir, 'opa.exe')
      : path.join(this.baseDir, 'opa'));

    const useCaseDir = path.join(this.baseDir, 'policies', 'use-cases', id);
    const metaPath = path.join(useCaseDir, 'meta.json');
    if (!fs.existsSync(metaPath)) {
      throw new Error(`Use case metadata not found at ${metaPath}`);
    }

    this.meta = JSON.parse(fs.readFileSync(metaPath, 'utf-8'));
    this.policyPath = path.join(useCaseDir, 'policy.rego');
    this.dataPath = path.join(useCaseDir, 'data.json');

    const inputSetsDir = path.join(this.baseDir, 'policies', 'input-sets', id);
    if (fs.existsSync(inputSetsDir)) {
      const files = fs.readdirSync(inputSetsDir).filter(f => f.endsWith('.json'));
      for (const file of files) {
        const filePath = path.join(inputSetsDir, file);
        const content = JSON.parse(fs.readFileSync(filePath, 'utf-8')) as InputSet;
        this.inputSets.push(content);
        if (content.cases && typeof content.cases === 'object') {
          for (const [caseId, caseDef] of Object.entries(content.cases)) {
            this.cases.set(caseId, caseDef);
          }
        }
      }
    }
  }

  async eval(input: Record<string, any>, query?: string): Promise<any> {
    const targetQuery = query || this.meta.query;
    const relPolicy = path.relative(this.baseDir, this.policyPath).replace(/\\/g, '/');
    const relData = path.relative(this.baseDir, this.dataPath).replace(/\\/g, '/');
    const args = [
      'eval',
      '-d', relPolicy,
      '-d', relData,
      '--stdin-input',
      '-f', 'json',
      targetQuery,
    ];

    return new Promise((resolve, reject) => {
      const child = spawn(this.opaPath, args, {
        cwd: this.baseDir,
        stdio: ['pipe', 'pipe', 'pipe'],
      });

      let stdout = '';
      let stderr = '';

      child.stdout.on('data', (data) => {
        stdout += data.toString();
      });

      child.stderr.on('data', (data) => {
        stderr += data.toString();
      });

      child.on('error', (err) => {
        reject(new Error(`Failed to spawn OPA binary at ${this.opaPath}: ${err.message}`));
      });

      child.on('close', (code) => {
        if (code !== 0) {
          return reject(new Error(`OPA eval exited with code ${code}: ${stderr}`));
        }
        try {
          const parsed = JSON.parse(stdout);
          if (parsed.result && parsed.result.length > 0) {
            const firstExpr = parsed.result[0].expressions?.[0];
            resolve(firstExpr ? firstExpr.value : undefined);
          } else {
            resolve(undefined);
          }
        } catch (err: any) {
          reject(new Error(`Failed to parse OPA output: ${err.message}. Output was: ${stdout}`));
        }
      });

      child.stdin.write(JSON.stringify(input));
      child.stdin.end();
    });
  }

  async allow(caseIdOrInput: string | Record<string, any>): Promise<any> {
    if (typeof caseIdOrInput === 'string') {
      const testCase = this.cases.get(caseIdOrInput);
      if (!testCase) {
        throw new Error(`Test case '${caseIdOrInput}' not found in usecase '${this.id}'`);
      }
      return this.eval(testCase.input);
    }
    return this.eval(caseIdOrInput);
  }

  async evalAll(): Promise<EvalResult[]> {
    const results: EvalResult[] = [];
    for (const [id, testCase] of this.cases.entries()) {
      const actual = await this.eval(testCase.input);
      results.push({
        id,
        name: testCase.name,
        input: testCase.input,
        expected: testCase.expected,
        actual,
        passed: testCase.expected !== undefined ? actual === testCase.expected : true,
      });
    }
    return results;
  }
}

export function useCase(id: string, options?: UseCaseOptions): UseCaseInstance {
  return new UseCaseInstance(id, options);
}
