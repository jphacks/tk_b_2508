import { Block, CreateBlockInput, UpdateBlockInput } from '../entities/Block';

export interface IBlockRepository {
  getByProjectId(projectId: string): Promise<Block[]>;
  getById(id: string): Promise<Block>;
  create(input: CreateBlockInput): Promise<Block>;
  update(input: UpdateBlockInput): Promise<Block>;
  delete(id: string): Promise<void>;
  addImage(blockId: string, imageUrl: string): Promise<Block>;
}
