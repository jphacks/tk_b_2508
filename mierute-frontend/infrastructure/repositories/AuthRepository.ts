import {
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signOut as firebaseSignOut,
  User,
  onAuthStateChanged as firebaseOnAuthStateChanged,
} from 'firebase/auth';
import { auth } from '@/lib/firebase';
import { IAuthRepository, SignInParams, SignUpParams } from '@/domain/repositories/IAuthRepository';

export class AuthRepository implements IAuthRepository {
  async signUp(params: SignUpParams): Promise<User> {
    if (!auth) throw new Error('Firebase auth not initialized');

    // Create Firebase user
    const userCredential = await createUserWithEmailAndPassword(
      auth,
      params.email,
      params.password
    );
    return userCredential.user;
  }

  async signIn(params: SignInParams): Promise<User> {
    if (!auth) throw new Error('Firebase auth not initialized');

    const userCredential = await signInWithEmailAndPassword(
      auth,
      params.email,
      params.password
    );
    return userCredential.user;
  }

  async signOut(): Promise<void> {
    if (!auth) throw new Error('Firebase auth not initialized');
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
