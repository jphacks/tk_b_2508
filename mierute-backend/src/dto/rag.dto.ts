import { IsNotEmpty, IsString } from 'class-validator';

export class CreateRagDocumentDto {
  @IsString()
  @IsNotEmpty()
  projectId: string;

  @IsString()
  @IsNotEmpty()
  storage_url: string;
}

export class RagDocumentResponseDto {
  id: string;
  projectId: string;
  storage_url: string;
  createdAt: string;
  updatedAt: string;
}
