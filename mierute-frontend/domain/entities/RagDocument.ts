export interface RagDocument {
  id: string;
  projectId: string;
  storageUrl: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateRagDocumentInput {
  projectId: string;
  storageUrl: string;
}
