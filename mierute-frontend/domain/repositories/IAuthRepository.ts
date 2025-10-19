import { User } from 'firebase/auth';

export interface SignUpParams {
  email: string;
  password: string;
}

export interface SignInParams {
  email: string;
  password: string;
}

export interface IAuthRepository {
  signUp(params: SignUpParams): Promise<User>;
  signIn(params: SignInParams): Promise<User>;
  signOut(): Promise<void>;
  getCurrentUser(): User | null;
  onAuthStateChanged(callback: (user: User | null) => void): () => void;
}
