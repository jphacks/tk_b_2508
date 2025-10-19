export interface Project {
  id: string;
  name: string;
  blockOrderIds?: string[];
  companyId: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateProjectInput {
  name: string;
  companyId: string;
}

export interface UpdateProjectInput {
  id: string;
  name?: string;
  blockOrderIds?: string[];
}
