export interface Company {
  id: string;
  company: string;
  email: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateCompanyInput {
  company: string;
  email: string;
  password: string;
}
