import { IsString, IsArray, IsNotEmpty } from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';

export class CreateProjectDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsArray()
  @IsString({ each: true })
  block_order_ids: string[];

  @IsString()
  @IsNotEmpty()
  company_id: string;
}

export class UpdateProjectDto extends PartialType(CreateProjectDto) {}

export class ReorderBlocksDto {
  @IsArray()
  @IsString({ each: true })
  block_order_ids: string[];
}

export class ProjectResponseDto {
  id: string;
  name: string;
  block_order_ids: string[];
  company_id: string;
  createdAt: string;
  updatedAt: string;
}
