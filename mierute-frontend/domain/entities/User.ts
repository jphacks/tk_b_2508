export type UserType = 'personal' | 'company';

export interface User {
  uid: string;
  email: string;
  name?: string;
  user_type: UserType;
  company_id?: string;
  company_name?: string;
}
