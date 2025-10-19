import { IsString, IsNotEmpty, IsOptional, IsUrl } from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';

export class CreateBlockDto {
  @IsString()
  @IsNotEmpty()
  checkpoint: string;

  @IsString()
  @IsNotEmpty()
  achivement: string;

  @IsString()
  @IsNotEmpty()
  projectId: string;

  @IsOptional()
  @IsString()
  @IsUrl()
  img_url?: string;
}

export class UpdateBlockDto extends PartialType(CreateBlockDto) {}

export class BlockResponseDto {
  id: string;
  checkpoint: string;
  achivement: string;
  projectId: string;
  img_url?: string;
  createdAt: string;
  updatedAt: string;
}