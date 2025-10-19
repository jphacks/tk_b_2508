import { create } from 'zustand';
import { User } from 'firebase/auth';
import { authUseCase } from '@/lib/di-container';
import { SignInParams, SignUpParams } from '@/domain/repositories/IAuthRepository';

interface AuthState {
  user: User | null;
  loading: boolean;
  error: string | null;
  isInitialized: boolean;

  // Actions
  initialize: () => void;
  signUp: (params: SignUpParams) => Promise<void>;
  signIn: (params: SignInParams) => Promise<void>;
  signOut: () => Promise<void>;
  clearError: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  loading: false,
  error: null,
  isInitialized: false,

  initialize: () => {
    authUseCase.onAuthStateChanged((user) => {
      set({ user, isInitialized: true });
      
      // Save user ID to localStorage when auth state changes
      if (typeof window !== 'undefined') {
        if (user?.uid) {
          localStorage.setItem('userId', user.uid);
        } else {
          localStorage.removeItem('userId');
        }
      }
    });
  },

  signUp: async (params: SignUpParams) => {
    set({ loading: true, error: null });
    try {
      const user = await authUseCase.signUp(params);
      set({ user, loading: false });
    } catch (error: any) {
      set({
        error: error.message || 'Sign up failed',
        loading: false
      });
      throw error;
    }
  },

  signIn: async (params: SignInParams) => {
    set({ loading: true, error: null });
    try {
      const user = await authUseCase.signIn(params);
      set({ user, loading: false });
      
      // Save user ID to localStorage
      if (typeof window !== 'undefined' && user?.uid) {
        localStorage.setItem('userId', user.uid);
      }
    } catch (error: any) {
      set({
        error: error.message || 'Sign in failed',
        loading: false
      });
      throw error;
    }
  },

  signOut: async () => {
    set({ loading: true, error: null });
    try {
      await authUseCase.signOut();
      set({ user: null, loading: false });
      
      // Remove user ID from localStorage
      if (typeof window !== 'undefined') {
        localStorage.removeItem('userId');
      }
    } catch (error: any) {
      set({
        error: error.message || 'Sign out failed',
        loading: false
      });
      throw error;
    }
  },

  clearError: () => set({ error: null }),
}));
