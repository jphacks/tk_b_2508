import { RagDocument, CreateRagDocumentInput } from '../entities/RagDocument';

export interface IRagDocumentRepository {
  getByProjectId(projectId: string): Promise<RagDocument[]>;
  create(input: CreateRagDocumentInput): Promise<RagDocument>;
}
