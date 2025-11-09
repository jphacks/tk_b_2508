export interface Block {
  id: string;
  checkpoint: string;
  achievement: string;
  projectId: string;
  img_url?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateBlockInput {
  checkpoint: string;
  achievement: string;
  projectId: string;
  img_url?: string;
}

export interface UpdateBlockInput {
  id: string;
  checkpoint?: string;
  achievement?: string;
  img_url?: string;
}
