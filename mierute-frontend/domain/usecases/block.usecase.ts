import { IBlockRepository } from '../repositories/IBlockRepository';
import { Block, CreateBlockInput, UpdateBlockInput } from '../entities/Block';

export class BlockUseCase {
  constructor(private blockRepository: IBlockRepository) {}

  async getBlocksByProjectId(projectId: string): Promise<Block[]> {
    return await this.blockRepository.getByProjectId(projectId);
  }

  async getBlockById(id: string): Promise<Block> {
    return await this.blockRepository.getById(id);
  }

  async createBlock(input: CreateBlockInput): Promise<Block> {
    return await this.blockRepository.create(input);
  }

  async updateBlock(input: UpdateBlockInput): Promise<Block> {
    return await this.blockRepository.update(input);
  }

  async deleteBlock(id: string): Promise<void> {
    return await this.blockRepository.delete(id);
  }

  async addImageToBlock(blockId: string, imageUrl: string): Promise<Block> {
    return await this.blockRepository.addImage(blockId, imageUrl);
  }
}
