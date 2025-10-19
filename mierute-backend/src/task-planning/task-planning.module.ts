import { Module } from '@nestjs/common';
import { TaskPlanningController } from './task-planning.controller';
import { TaskPlanningService } from './task-planning.service';
import { OpenAIModule } from '../common/openai/openai.module';
import { BlockModule } from '../block/block.module';
import { ProjectModule } from '../project/project.module';

@Module({
  imports: [OpenAIModule, BlockModule, ProjectModule],
  controllers: [TaskPlanningController],
  providers: [TaskPlanningService],
})
export class TaskPlanningModule {}