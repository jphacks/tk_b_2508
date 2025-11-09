import { useEffect } from 'react';
import { useAuthStore } from '../stores/useAuthStore';

export const useAuth = () => {
  const { initialize, isInitialized, user, userInfo, loading, error, signIn, signUp, signUpCompany, signOut, clearError } = useAuthStore();

  useEffect(() => {
    if (!isInitialized) {
      initialize();
    }
  }, [initialize, isInitialized]);

  return {
    user,
    userInfo,
    loading,
    error,
    isInitialized,
    isAuthenticated: !!user,
    signIn,
    signUp,
    signUpCompany,
    signOut,
    clearError,
  };
};
