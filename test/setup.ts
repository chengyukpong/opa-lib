import { useCase } from '../src/usecase';

// Register useCase globally so tests can call useCase(...) directly without explicit import
(globalThis as any).useCase = useCase;
