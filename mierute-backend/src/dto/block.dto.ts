import { IsString, IsNotEmpty, IsOptional, IsUrl, IsArray } from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';

export class CreateBlockDto {
  @IsString()
  @IsNotEmpty()
  checkpoint: string;

  @IsString()
  @IsNotEmpty()
  achievement: string;

  @IsString()
  @IsNotEmpty()
  projectId: string;

  @IsOptional()
  @IsString()
  color?: string;

  @IsOptional()
  @IsArray()
  @IsUrl({}, { each: true })
  reference_urls?: string[];
}

export class UpdateBlockDto extends PartialType(CreateBlockDto) {}

export class BlockResponseDto {
  id: string;
  checkpoint: string;
  achievement: string;
  projectId: string;
  color?: string;
  reference_urls?: string[];
  createdAt: string;
  updatedAt: string;
}
