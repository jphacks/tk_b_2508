import { IAuthRepository, SignInParams, SignUpParams, SignUpCompanyParams } from '../repositories/IAuthRepository';
import { User } from 'firebase/auth';
import { User as DomainUser } from '../entities/User';

export class AuthUseCase {
  constructor(private authRepository: IAuthRepository) {}

  async signUp(params: SignUpParams): Promise<User> {
    return await this.authRepository.signUp(params);
  }

  async signUpCompany(params: SignUpCompanyParams): Promise<User> {
    return await this.authRepository.signUpCompany(params);
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

  getUserInfo(): DomainUser | null {
    return this.authRepository.getUserInfo();
  }

  onAuthStateChanged(callback: (user: User | null) => void): () => void {
    return this.authRepository.onAuthStateChanged(callback);
  }
}
