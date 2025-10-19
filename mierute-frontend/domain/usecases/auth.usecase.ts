import { IAuthRepository, SignInParams, SignUpParams } from '../repositories/IAuthRepository';
import { User } from 'firebase/auth';

export class AuthUseCase {
  constructor(private authRepository: IAuthRepository) {}

  async signUp(params: SignUpParams): Promise<User> {
    return await this.authRepository.signUp(params);
  }

  async signIn(params: SignInParams): Promise<User> {
    return await this.authRepository.signIn(params);
  }

  async signOut(): Promise<void> {
    return await this.authRepository.signOut();
  }

  getCurrentUser(): User | null {
    return this.authRepository.getCurrentUser();
  }

  onAuthStateChanged(callback: (user: User | null) => void): () => void {
    return this.authRepository.onAuthStateChanged(callback);
  }
}
