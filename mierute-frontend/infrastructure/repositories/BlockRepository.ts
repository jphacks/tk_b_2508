import { apiClient } from '@/lib/api-client';
import { IBlockRepository } from '@/domain/repositories/IBlockRepository';
import { Block, CreateBlockInput, UpdateBlockInput } from '@/domain/entities/Block';

export class BlockRepository implements IBlockRepository {
  async getByProjectId(projectId: string): Promise<Block[]> {
    const response = await apiClient.get<Block[]>(`/blocks/project/${projectId}`);
    return response.data.map(this.mapToBlock);
  }

  async getById(id: string): Promise<Block> {
    const response = await apiClient.get<Block>(`/blocks/${id}`);
    return this.mapToBlock(response.data);
  }

  async create(input: CreateBlockInput): Promise<Block> {
    const response = await apiClient.post<Block>('/blocks', input);
    return this.mapToBlock(response.data);
  }

  async update(input: UpdateBlockInput): Promise<Block> {
    const { id, ...data } = input;
    const response = await apiClient.put<Block>(`/blocks/${id}`, data);
    return this.mapToBlock(response.data);
  }

  async delete(id: string): Promise<void> {
    await apiClient.delete(`/blocks/${id}`);
  }

  async addImage(blockId: string, imageUrl: string): Promise<Block> {
    const response = await apiClient.post<Block>(`/blocks/${blockId}/add_image`, { image_url: imageUrl });
    return this.mapToBlock(response.data);
  }

  private mapToBlock(data: any): Block {
    return {
      ...data,
      createdAt: new Date(data.createdAt),
      updatedAt: new Date(data.updatedAt),
    };
  }
}
