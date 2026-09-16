import { describe, it, expect } from 'vitest';
import { useCase } from '../src/usecase';

describe('rbac-api', () => {
  const usecase = useCase('rbac-api');

  it('eval predefined + dynamic', async () => {
    expect(await usecase.allow('admin-delete')).toBe(true);
    expect(await usecase.allow('viewer-update')).toBe(false);

    expect(
      await usecase.allow({
        subject: { user_id: 'u-admin', roles: ['admin'], tenant: 'acme' },
        action: 'create',
        resource: { tenant: 'acme', owner_id: 'u-other', type: 'invoice' },
      }),
    ).toBe(true);
  });

  it('evalAll', async () => {
    await expect(usecase.evalAll()).resolves.toHaveLength(6);
  });
});
