import { IRagDocumentRepository } from '../repositories/IRagDocumentRepository';
import { RagDocument, CreateRagDocumentInput } from '../entities/RagDocument';

export class RagDocumentUseCase {
  constructor(private ragDocumentRepository: IRagDocumentRepository) {}

  async getRagDocumentsByProjectId(projectId: string): Promise<RagDocument[]> {
    return await this.ragDocumentRepository.getByProjectId(projectId);
  }

  async createRagDocument(input: CreateRagDocumentInput): Promise<RagDocument> {
    return await this.ragDocumentRepository.create(input);
  }
}
