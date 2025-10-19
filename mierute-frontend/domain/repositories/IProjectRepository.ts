import { Project, CreateProjectInput, UpdateProjectInput } from '../entities/Project';

export interface IProjectRepository {
  getAll(companyId: string): Promise<Project[]>;
  getById(id: string): Promise<Project>;
  create(input: CreateProjectInput): Promise<Project>;
  update(input: UpdateProjectInput): Promise<Project>;
  delete(id: string): Promise<void>;
}
