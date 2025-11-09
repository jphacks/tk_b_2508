import { User } from 'firebase/auth';
import { User as DomainUser } from '@/domain/entities/User';

export interface SignUpParams {
  email: string;
  password: string;
  name?: string;
}

export interface SignUpCompanyParams {
  email: string;
  password: string;
  company_id: string;
  name?: string;
}

export interface SignInParams {
  email: string;
  password: string;
}

export interface IAuthRepository {
  signUp(params: SignUpParams): Promise<User>;
  signUpCompany(params: SignUpCompanyParams): Promise<User>;
  signIn(params: SignInParams): Promise<User>;
  signOut(): Promise<void>;
  getCurrentUser(): User | null;
  getUserInfo(): DomainUser | null;
  onAuthStateChanged(callback: (user: User | null) => void): () => void;
}
