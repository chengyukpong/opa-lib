import { describe, it, expect } from 'vitest';
import { useCase } from '../src/usecase';

describe('cicd-coverage', () => {
  const usecase = useCase('cicd-coverage');

  it('eval predefined + dynamic', async () => {
    expect(await usecase.allow('ts-pass')).toBe(true);
    expect(await usecase.allow('ts-fail')).toBe(false);

    expect(
      await usecase.allow({
        repo: 'acme/web',
        language: 'typescript',
        coverage_pct: 90,
      }),
    ).toBe(true);
  });

  it('evalAll', async () => {
    await expect(usecase.evalAll()).resolves.toHaveLength(5);
  });
});
