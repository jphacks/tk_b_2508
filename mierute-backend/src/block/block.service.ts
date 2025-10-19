import { Injectable, NotFoundException, Inject, forwardRef } from '@nestjs/common';
import { FirestoreService } from '../common/firebase/firestore.service';
import { CreateBlockDto, UpdateBlockDto, BlockResponseDto } from '../dto/block.dto';
import { ProjectService } from '../project/project.service';

@Injectable()
export class BlockService {
  private readonly collectionName = 'blocks';

  constructor(
    private readonly firestoreService: FirestoreService,
    @Inject(forwardRef(() => ProjectService))
    private readonly projectService: ProjectService,
  ) {}

  async createBlock(createBlockDto: CreateBlockDto): Promise<BlockResponseDto> {
    const blockId = await this.firestoreService.create(
      this.collectionName,
      createBlockDto,
    );

    const block = await this.firestoreService.findOne(this.collectionName, blockId);
    
    // Projectのblock_order_idsに新しいblockIdを追加
    if (createBlockDto.projectId) {
      await this.projectService.addBlockToOrder(createBlockDto.projectId, blockId);
    }
    
    return this.mapToResponseDto(block);
  }

  async findAllBlocks(): Promise<BlockResponseDto[]> {
    const blocks = await this.firestoreService.findAll(this.collectionName);
    return blocks.map(block => this.mapToResponseDto(block));
  }

  async findBlockById(id: string): Promise<BlockResponseDto> {
    const block = await this.firestoreService.findOne(this.collectionName, id);

    if (!block) {
      throw new NotFoundException(`Block with ID ${id} not found`);
    }

    return this.mapToResponseDto(block);
  }

  async findBlocksByProjectId(projectId: string): Promise<BlockResponseDto[]> {
    try {
      console.log(`Finding blocks for projectId: ${projectId}`);
      
      // 1. プロジェクト情報を取得してblock_order_idsを取得
      const project = await this.projectService.findProjectById(projectId);
      const blockOrderIds = project.block_order_ids || [];
      
      // 2. ブロックを取得
      const blocks = await this.firestoreService.findAll(this.collectionName, {
        where: [
          {
            field: 'project_id',
            operator: '==',
            value: projectId,
          },
        ],
      });

      console.log(`Found ${blocks.length} blocks for projectId: ${projectId}`);
      
      // 3. block_order_idsの順序に並び替え
      const blockDtos = blocks.map(block => this.mapToResponseDto(block));
      const sortedBlocks = this.sortBlocksByOrder(blockDtos, blockOrderIds);
      
      return sortedBlocks;
    } catch (error) {
      console.error(`Error finding blocks for projectId ${projectId}:`, error);
      throw new NotFoundException(`Failed to find blocks for project ${projectId}: ${error.message}`);
    }
  }

  async updateBlock(id: string, updateBlockDto: UpdateBlockDto): Promise<BlockResponseDto> {
    const existingBlock = await this.firestoreService.findOne(this.collectionName, id);

    if (!existingBlock) {
      throw new NotFoundException(`Block with ID ${id} not found`);
    }

    await this.firestoreService.update(this.collectionName, id, updateBlockDto);

    const updatedBlock = await this.firestoreService.findOne(this.collectionName, id);
    return this.mapToResponseDto(updatedBlock);
  }

  async deleteBlock(id: string): Promise<void> {
    const existingBlock = await this.firestoreService.findOne(this.collectionName, id);

    if (!existingBlock) {
      throw new NotFoundException(`Block with ID ${id} not found`);
    }

    // Projectのblock_order_idsからblockIdを削除
    if (existingBlock.projectId) {
      await this.projectService.removeBlockFromOrder(existingBlock.projectId, id);
    }

    await this.firestoreService.delete(this.collectionName, id);
  }

  private sortBlocksByOrder(blocks: BlockResponseDto[], blockOrderIds: string[]): BlockResponseDto[] {
    // block_order_idsに含まれるブロックを順序通りに並べる
    const orderedBlocks: BlockResponseDto[] = [];
    
    // 1. block_order_idsの順序でブロックを追加
    for (const blockId of blockOrderIds) {
      const block = blocks.find(b => b.id === blockId);
      if (block) {
        orderedBlocks.push(block);
      }
    }
    
    // 2. block_order_idsに含まれないブロックを末尾に追加
    const remainingBlocks = blocks.filter(block => !blockOrderIds.includes(block.id));
    orderedBlocks.push(...remainingBlocks);
    
    return orderedBlocks;
  }

  private mapToResponseDto(block: any): BlockResponseDto {
    return {
      id: block.id as string,
      checkpoint: block.checkpoint as string,
      achievement: block.achievement as string,
      projectId: block.projectId as string,
      img_url: block.img_url || null, // undefinedをnullに変換してJSONに確実に含める
      createdAt: block.createdAt as string,
      updatedAt: block.updatedAt as string,
    };
  }
}
