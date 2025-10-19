import { apiClient } from '@/lib/api-client';
import { IProjectRepository } from '@/domain/repositories/IProjectRepository';
import { Project, CreateProjectInput, UpdateProjectInput } from '@/domain/entities/Project';

export class ProjectRepository implements IProjectRepository {
  async getAll(companyId: string): Promise<Project[]> {
    const userId = typeof window !== 'undefined' ? localStorage.getItem('userId') : companyId;
    console.log('ProjectRepository getAll - companyId:', companyId);
    console.log('ProjectRepository getAll - userId from localStorage:', userId);
    console.log('ProjectRepository getAll - sending request to:', `/projects?companyId=${userId}`);
    
    const response = await apiClient.get<Project[]>(`/projects?companyId=${userId}`);
    return response.data.map(this.mapToProject);
  }

  async getById(id: string): Promise<Project> {
    const response = await apiClient.get<Project>(`/projects/${id}`);
    return this.mapToProject(response.data);
  }

  async create(input: CreateProjectInput): Promise<Project> {
    const response = await apiClient.post<Project>('/projects', input);
    return this.mapToProject(response.data);
  }

  async update(input: UpdateProjectInput): Promise<Project> {
    const { id, ...data } = input;
    const response = await apiClient.put<Project>(`/projects/${id}`, data);
    return this.mapToProject(response.data);
  }

  async delete(id: string): Promise<void> {
    await apiClient.delete(`/projects/${id}`);
  }

  private mapToProject(data: any): Project {
    return {
      ...data,
      createdAt: new Date(data.createdAt),
      updatedAt: new Date(data.updatedAt),
    };
  }
}
