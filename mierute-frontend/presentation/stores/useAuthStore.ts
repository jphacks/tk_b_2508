import { create } from 'zustand';
import { User } from 'firebase/auth';
import { authUseCase } from '@/lib/di-container';
import { SignInParams, SignUpParams, SignUpCompanyParams } from '@/domain/repositories/IAuthRepository';
import { User as DomainUser } from '@/domain/entities/User';

interface AuthState {
  user: User | null;
  userInfo: DomainUser | null;
  loading: boolean;
  error: string | null;
  isInitialized: boolean;

  // Actions
  initialize: () => void;
  signUp: (params: SignUpParams) => Promise<void>;
  signUpCompany: (params: SignUpCompanyParams) => Promise<void>;
  signIn: (params: SignInParams) => Promise<void>;
  signOut: () => Promise<void>;
  clearError: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  userInfo: null,
  loading: false,
  error: null,
  isInitialized: false,

  initialize: () => {
    authUseCase.onAuthStateChanged((user) => {
      // Restore userInfo from localStorage if user is logged in
      let userInfo: DomainUser | null = null;
      if (user && typeof window !== 'undefined') {
        const storedUserInfo = localStorage.getItem('userInfo');
        if (storedUserInfo) {
          try {
            userInfo = JSON.parse(storedUserInfo);
          } catch (error) {
            console.error('Failed to parse userInfo from localStorage:', error);
          }
        }
      }

      set({ user, userInfo, isInitialized: true });

      // Save user ID to localStorage when auth state changes
      if (typeof window !== 'undefined') {
        if (user?.uid) {
          localStorage.setItem('userId', user.uid);
        } else {
          localStorage.removeItem('userId');
          localStorage.removeItem('userInfo');
        }
      }
    });
  },

  signUp: async (params: SignUpParams) => {
    set({ loading: true, error: null });
    try {
      const user = await authUseCase.signUp(params);
      const userInfo = authUseCase.getUserInfo();

      // Save userInfo to localStorage
      if (typeof window !== 'undefined' && userInfo) {
        localStorage.setItem('userInfo', JSON.stringify(userInfo));
      }

      set({ user, userInfo, loading: false });
    } catch (error: any) {
      set({
        error: error.message || 'Sign up failed',
        loading: false
      });
      throw error;
    }
  },

  signUpCompany: async (params: SignUpCompanyParams) => {
    set({ loading: true, error: null });
    try {
      const user = await authUseCase.signUpCompany(params);
      const userInfo = authUseCase.getUserInfo();

      // Save userInfo to localStorage
      if (typeof window !== 'undefined' && userInfo) {
        localStorage.setItem('userInfo', JSON.stringify(userInfo));
      }

      set({ user, userInfo, loading: false });
    } catch (error: any) {
      set({
        error: error.message || 'Company sign up failed',
        loading: false
      });
      throw error;
    }
  },

  signIn: async (params: SignInParams) => {
    set({ loading: true, error: null });
    try {
      const user = await authUseCase.signIn(params);
      const userInfo = authUseCase.getUserInfo();

      // Save user ID and userInfo to localStorage
      if (typeof window !== 'undefined') {
        if (user?.uid) {
          localStorage.setItem('userId', user.uid);
        }
        if (userInfo) {
          localStorage.setItem('userInfo', JSON.stringify(userInfo));
        }
      }

      set({ user, userInfo, loading: false });
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
      set({ user: null, userInfo: null, loading: false });

      // Remove user ID and userInfo from localStorage
      if (typeof window !== 'undefined') {
        localStorage.removeItem('userId');
        localStorage.removeItem('userInfo');
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
