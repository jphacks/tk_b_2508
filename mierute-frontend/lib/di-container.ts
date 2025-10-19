// Dependency Injection Container
import { AuthRepository } from '@/infrastructure/repositories/AuthRepository';
import { ProjectRepository } from '@/infrastructure/repositories/ProjectRepository';
import { BlockRepository } from '@/infrastructure/repositories/BlockRepository';
import { RagDocumentRepository } from '@/infrastructure/repositories/RagDocumentRepository';
import { AuthUseCase } from '@/domain/usecases/auth.usecase';
import { ProjectUseCase } from '@/domain/usecases/project.usecase';
import { BlockUseCase } from '@/domain/usecases/block.usecase';
import { RagDocumentUseCase } from '@/domain/usecases/ragDocument.usecase';

// Repositories
const authRepository = new AuthRepository();
const projectRepository = new ProjectRepository();
const blockRepository = new BlockRepository();
const ragDocumentRepository = new RagDocumentRepository();

// Use Cases
export const authUseCase = new AuthUseCase(authRepository);
export const projectUseCase = new ProjectUseCase(projectRepository);
export const blockUseCase = new BlockUseCase(blockRepository);
export const ragDocumentUseCase = new RagDocumentUseCase(ragDocumentRepository);
