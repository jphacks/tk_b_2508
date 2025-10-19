export interface Block {
  id: string;
  checkpoint: string;
  condition: string;
  projectId: string;
  imageUrl?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateBlockInput {
  checkpoint: string;
  condition: string;
  projectId: string;
}

export interface UpdateBlockInput {
  id: string;
  checkpoint?: string;
  condition?: string;
}
