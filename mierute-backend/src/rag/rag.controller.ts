import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
} from '@nestjs/common';
import { RagService } from './rag.service';
import {
  CreateRagDocumentDto,
  RagDocumentResponseDto,
} from '../dto/rag.dto';

@Controller('api/projects')
export class RagController {
  constructor(private readonly ragService: RagService) {}

  /**
   * GET /api/projects/:project_id/rag
   * Get all RAG documents for a specific project
   */
  @Get(':project_id/rag')
  async getRagDocumentsByProject(
    @Param('project_id') projectId: string,
  ): Promise<RagDocumentResponseDto[]> {
    return this.ragService.findRagDocumentsByProjectId(projectId);
  }

  /**
   * POST /api/projects/:project_id/rag_document
   * Create a new RAG document for a specific project
   */
  @Post(':project_id/rag_document')
  @HttpCode(HttpStatus.CREATED)
  async createRagDocument(
    @Param('project_id') projectId: string,
    @Body() createRagDocumentDto: CreateRagDocumentDto,
  ): Promise<RagDocumentResponseDto> {
    // Ensure the projectId from the URL matches the DTO
    // Override DTO projectId with URL parameter to enforce consistency
    const dtoWithProjectId = {
      ...createRagDocumentDto,
      projectId: projectId,
    };

    return this.ragService.createRagDocument(dtoWithProjectId);
  }
}
