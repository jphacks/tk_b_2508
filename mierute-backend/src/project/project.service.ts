import { Injectable, NotFoundException } from '@nestjs/common';
import { FirestoreService } from '../common/firebase/firestore.service';
import {
  CreateProjectDto,
  UpdateProjectDto,
  ProjectResponseDto,
} from '../dto/project.dto';

@Injectable()
export class ProjectService {
  private readonly collectionName = 'projects';

  constructor(private readonly firestoreService: FirestoreService) {}

  async createProject(
    createProjectDto: CreateProjectDto,
  ): Promise<ProjectResponseDto> {
    const projectId = await this.firestoreService.create(
      this.collectionName,
      createProjectDto,
    );

    const project = await this.firestoreService.findOne(
      this.collectionName,
      projectId,
    );
    return this.mapToResponseDto(project);
  }

  async findAllProjects(): Promise<ProjectResponseDto[]> {
    const projects = await this.firestoreService.findAll(this.collectionName);
    return projects.map((project) => this.mapToResponseDto(project));
  }

  async findProjectsByCompanyId(companyId: string): Promise<ProjectResponseDto[]> {
    const projects = await this.firestoreService.findAll(this.collectionName, {
      where: [
        {
          field: 'companyId',
          operator: '==',
          value: companyId,
        },
      ],
    });
    return projects.map((project) => this.mapToResponseDto(project));
  }

  async findProjectById(id: string): Promise<ProjectResponseDto> {
    const project = await this.firestoreService.findOne(
      this.collectionName,
      id,
    );

    if (!project) {
      throw new NotFoundException(`Project with ID ${id} not found`);
    }

    return this.mapToResponseDto(project);
  }

  async updateProject(
    id: string,
    updateProjectDto: UpdateProjectDto,
  ): Promise<ProjectResponseDto> {
    const existingProject = await this.firestoreService.findOne(
      this.collectionName,
      id,
    );

    if (!existingProject) {
      throw new NotFoundException(`Project with ID ${id} not found`);
    }

    await this.firestoreService.update(
      this.collectionName,
      id,
      updateProjectDto,
    );

    const updatedProject = await this.firestoreService.findOne(
      this.collectionName,
      id,
    );
    return this.mapToResponseDto(updatedProject);
  }

  async deleteProject(id: string): Promise<void> {
    const existingProject = await this.firestoreService.findOne(
      this.collectionName,
      id,
    );

    if (!existingProject) {
      throw new NotFoundException(`Project with ID ${id} not found`);
    }

    await this.firestoreService.delete(this.collectionName, id);
  }

  async addBlockToOrder(projectId: string, blockId: string): Promise<void> {
    const project = await this.firestoreService.findOne(
      this.collectionName,
      projectId,
    );

    if (!project) {
      throw new NotFoundException(`Project with ID ${projectId} not found`);
    }

    const currentBlockOrderIds = project.block_order_ids || [];
    if (!currentBlockOrderIds.includes(blockId)) {
      currentBlockOrderIds.push(blockId);
      await this.firestoreService.update(this.collectionName, projectId, {
        block_order_ids: currentBlockOrderIds,
      });
    }
  }

  async removeBlockFromOrder(projectId: string, blockId: string): Promise<void> {
    const project = await this.firestoreService.findOne(
      this.collectionName,
      projectId,
    );

    if (!project) {
      throw new NotFoundException(`Project with ID ${projectId} not found`);
    }

    const currentBlockOrderIds = project.block_order_ids || [];
    const filteredBlockOrderIds = currentBlockOrderIds.filter(id => id !== blockId);
    
    if (currentBlockOrderIds.length !== filteredBlockOrderIds.length) {
      await this.firestoreService.update(this.collectionName, projectId, {
        block_order_ids: filteredBlockOrderIds,
      });
    }
  }

  async reorderBlocks(projectId: string, blockOrderIds: string[]): Promise<ProjectResponseDto> {
    const project = await this.firestoreService.findOne(
      this.collectionName,
      projectId,
    );

    if (!project) {
      throw new NotFoundException(`Project with ID ${projectId} not found`);
    }

    await this.firestoreService.update(this.collectionName, projectId, {
      block_order_ids: blockOrderIds,
    });

    const updatedProject = await this.firestoreService.findOne(
      this.collectionName,
      projectId,
    );
    return this.mapToResponseDto(updatedProject);
  }

  private mapToResponseDto(project: any): ProjectResponseDto {
    return {
      id: project.id as string,
      name: project.name as string,
      block_order_ids: project.block_order_ids as string[],
      company_id: project.company_id as string,
      createdAt: project.createdAt as string,
      updatedAt: project.updatedAt as string,
    };
  }
}
