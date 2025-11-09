import {
  signInWithCustomToken,
  signOut as firebaseSignOut,
  User,
  onAuthStateChanged as firebaseOnAuthStateChanged,
} from 'firebase/auth';
import { auth } from '@/lib/firebase';
import { IAuthRepository, SignInParams, SignUpParams, SignUpCompanyParams } from '@/domain/repositories/IAuthRepository';
import { authApi } from '@/infrastructure/api/auth.api';
import { User as DomainUser } from '@/domain/entities/User';

export class AuthRepository implements IAuthRepository {
  // Store user info from backend (user_type, name, etc.)
  private userInfo: DomainUser | null = null;

  async signUp(params: SignUpParams): Promise<User> {
    if (!auth) throw new Error('Firebase auth not initialized');

    // Call backend API to register user
    const response = await authApi.register({
      email: params.email,
      password: params.password,
      name: params.name,
    });

    // Store user info for later use
    this.userInfo = response.user;

    // Sign in to Firebase with custom token
    const userCredential = await signInWithCustomToken(auth, response.token);
    return userCredential.user;
  }

  async signUpCompany(params: SignUpCompanyParams): Promise<User> {
    if (!auth) throw new Error('Firebase auth not initialized');

    // Call backend API to register company user
    const response = await authApi.registerCompany({
      email: params.email,
      password: params.password,
      company_id: params.company_id,
      name: params.name,
    });

    // Store user info for later use
    this.userInfo = response.user;

    // Sign in to Firebase with custom token
    const userCredential = await signInWithCustomToken(auth, response.token);
    return userCredential.user;
  }

  getUserInfo(): DomainUser | null {
    return this.userInfo;
  }

  async signIn(params: SignInParams): Promise<User> {
    if (!auth) throw new Error('Firebase auth not initialized');

    // Call backend API to login
    const response = await authApi.login({
      email: params.email,
      password: params.password,
    });

    // Store user info for later use
    this.userInfo = response.user;

    // Sign in to Firebase with custom token
    const userCredential = await signInWithCustomToken(auth, response.token);
    return userCredential.user;
  }

  async signOut(): Promise<void> {
    if (!auth) throw new Error('Firebase auth not initialized');
    this.userInfo = null;
    await firebaseSignOut(auth);
  }

  getCurrentUser(): User | null {
    return auth?.currentUser || null;
  }

  onAuthStateChanged(callback: (user: User | null) => void): () => void {
    if (!auth) return () => {};
    return firebaseOnAuthStateChanged(auth, callback);
  }
}
