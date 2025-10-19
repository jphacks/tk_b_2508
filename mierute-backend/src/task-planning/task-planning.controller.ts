import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  BadRequestException,
  InternalServerErrorException,
} from '@nestjs/common';
import { TaskPlanningService } from './task-planning.service';
import {
  TaskPlanningRequestDto,
  TaskPlanningResponseDto,
} from '../dto/task-planning.dto';

@Controller('api/task-planning')
export class TaskPlanningController {
  constructor(private readonly taskPlanningService: TaskPlanningService) {}

  @Post()
  @HttpCode(HttpStatus.OK)
  async createTaskPlan(
    @Body() dto: TaskPlanningRequestDto,
  ): Promise<TaskPlanningResponseDto> {
    try {
      return await this.taskPlanningService.createTaskPlan(dto);
    } catch (error) {
      console.error('Error in task planning controller:', error);
      throw new InternalServerErrorException(
        'Failed to generate task plan',
      );
    }
  }
}