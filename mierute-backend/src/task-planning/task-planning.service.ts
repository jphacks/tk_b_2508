import { Injectable } from '@nestjs/common';
import { OpenAIService } from '../common/openai/openai.service';
import { BlockService } from '../block/block.service';
import { ProjectService } from '../project/project.service';
import {
  TaskPlanningRequestDto,
  TaskPlanningResponseDto,
  Task,
  SavedBlock,
} from '../dto/task-planning.dto';
import { CreateBlockDto } from '../dto/block.dto';

@Injectable()
export class TaskPlanningService {
  constructor(
    private readonly openaiService: OpenAIService,
    private readonly blockService: BlockService,
    private readonly projectService: ProjectService,
  ) {}

  async createTaskPlan(
    dto: TaskPlanningRequestDto,
  ): Promise<TaskPlanningResponseDto> {
    try {
      // GPTでタスクプランを生成
      const planResponse = await this.openaiService.generateTaskPlan(dto.prompt);
      
      // 各タスクをblockとして保存
      const savedBlocks: SavedBlock[] = [];
      const blockIds: string[] = [];

      for (const task of planResponse.tasks) {
        const createBlockDto: CreateBlockDto = {
          checkpoint: task.checkpoint,
          achievement: task.achievement,
          projectId: dto.projectId,
        };

        const blockResponse = await this.blockService.createBlock(createBlockDto);
        
        savedBlocks.push({
          block_id: blockResponse.id,
          title: task.title,
          checkpoint: task.checkpoint,
          achievement: task.achievement,
        });

        blockIds.push(blockResponse.id);
      }

      // プロジェクトのblock_order_idsを更新
      await this.updateProjectBlockOrder(dto.projectId, blockIds);

      return {
        ...planResponse,
        saved_blocks: savedBlocks,
        projectId: dto.projectId,
      };
    } catch (error) {
      console.error('Error in task planning:', error);
      throw new Error('Failed to generate and save task plan');
    }
  }

  private async updateProjectBlockOrder(
    projectId: string,
    newBlockIds: string[],
  ): Promise<void> {
    try {
      const project = await this.projectService.findProjectById(projectId);
      const updatedBlockOrder = [...(project.block_order_ids || []), ...newBlockIds];
      
      await this.projectService.updateProject(projectId, {
        block_order_ids: updatedBlockOrder,
      });
    } catch (error) {
      console.error('Error updating project block order:', error);
      throw new Error('Failed to update project block order');
    }
  }
}