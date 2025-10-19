import { IProjectRepository } from '../repositories/IProjectRepository';
import { Project, CreateProjectInput, UpdateProjectInput } from '../entities/Project';

export class ProjectUseCase {
  constructor(private projectRepository: IProjectRepository) {}

  async getAllProjects(companyId: string): Promise<Project[]> {
    return await this.projectRepository.getAll(companyId);
  }

  async getProjectById(id: string): Promise<Project> {
    return await this.projectRepository.getById(id);
  }

  async createProject(input: CreateProjectInput): Promise<Project> {
    return await this.projectRepository.create(input);
  }

  async updateProject(input: UpdateProjectInput): Promise<Project> {
    return await this.projectRepository.update(input);
  }

  async deleteProject(id: string): Promise<void> {
    return await this.projectRepository.delete(id);
  }

  async updateBlockOrder(projectId: string, blockOrderIds: string[]): Promise<Project> {
    return await this.projectRepository.update({ id: projectId, blockOrderIds });
  }
}
