import { describe, it, expect } from 'vitest';
import { useCase } from '../src/usecase';

describe('openshift-image-registry', () => {
  const usecase = useCase('openshift-image-registry');

  it('eval predefined + dynamic', async () => {
    expect(await usecase.allow('internal-ok')).toBe(true);
    expect(await usecase.allow('docker-hub-deny')).toBe(false);

    expect(
      await usecase.allow({
        image: 'registry.internal.acme/custom-service:2.0.0',
        namespace: 'prod',
      }),
    ).toBe(true);
  });

  it('evalAll', async () => {
    await expect(usecase.evalAll()).resolves.toHaveLength(6);
  });
});
