import { apiClient } from '@/lib/api-client';
import { IRagDocumentRepository } from '@/domain/repositories/IRagDocumentRepository';
import { RagDocument, CreateRagDocumentInput } from '@/domain/entities/RagDocument';

export class RagDocumentRepository implements IRagDocumentRepository {
  async getByProjectId(projectId: string): Promise<RagDocument[]> {
    const response = await apiClient.get<{ storage_url: string; id?: string; created_at?: string; updated_at?: string }[]>(
      `/projects/${projectId}/rag`
    );
    return response.data.map(this.mapToRagDocument);
  }

  async create(input: CreateRagDocumentInput): Promise<RagDocument> {
    const response = await apiClient.post<{ storage_url: string; id?: string; created_at?: string; updated_at?: string }>(
      `/projects/${input.projectId}/rag_document`,
      { storage_url: input.storageUrl }
    );
    return this.mapToRagDocument(response.data);
  }

  private mapToRagDocument(data: any): RagDocument {
    return {
      id: data.id || '',
      projectId: data.project_id || '',
      storageUrl: data.storage_url,
      createdAt: data.created_at ? new Date(data.created_at) : new Date(),
      updatedAt: data.updated_at ? new Date(data.updated_at) : new Date(),
    };
  }
}
