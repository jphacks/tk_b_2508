import { IsString, IsNotEmpty } from 'class-validator';

export class TaskPlanningRequestDto {
  @IsString()
  @IsNotEmpty()
  prompt: string;

  @IsString()
  @IsNotEmpty()
  projectId: string;
}

export interface Task {
  id: string;
  title: string;
  description: string;
  checkpoint: string;
  achivement: string;
  estimatedTime?: string;
  priority?: 'high' | 'medium' | 'low';
  dependencies?: string[];
}

export interface SavedBlock {
  block_id: string;
  title: string;
  checkpoint: string;
  achivement: string;
}

export class TaskPlanningResponseDto {
  plan: string;
  tasks: Task[];
  totalEstimatedTime?: string;
  summary: string;
  saved_blocks: SavedBlock[];
  projectId: string;
}