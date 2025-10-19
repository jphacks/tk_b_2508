import { Injectable } from '@nestjs/common';
import { FirestoreService } from '../common/firebase/firestore.service';
import {
  CreateRagDocumentDto,
  RagDocumentResponseDto,
} from '../dto/rag.dto';

@Injectable()
export class RagService {
  private readonly collectionName = 'rag_documents';

  constructor(private readonly firestoreService: FirestoreService) {}

  async createRagDocument(
    createRagDocumentDto: CreateRagDocumentDto,
  ): Promise<RagDocumentResponseDto> {
    const documentId = await this.firestoreService.create(
      this.collectionName,
      createRagDocumentDto,
    );

    const document = await this.firestoreService.findOne(
      this.collectionName,
      documentId,
    );

    return this.mapToResponseDto(document);
  }

  async findRagDocumentsByProjectId(
    projectId: string,
  ): Promise<RagDocumentResponseDto[]> {
    const documents = await this.firestoreService.findAll(this.collectionName, {
      where: [
        {
          field: 'project_id',
          operator: '==',
          value: projectId,
        },
      ],
    });

    return documents.map((doc) => this.mapToResponseDto(doc));
  }

  private mapToResponseDto(document: any): RagDocumentResponseDto {
    return {
      id: document.id,
      projectId: document.projectId,
      storage_url: document.storage_url,
      createdAt: document.createdAt,
      updatedAt: document.updatedAt,
    };
  }
}
