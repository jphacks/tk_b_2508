import { useEffect } from 'react';
import { useAuthStore } from '../stores/useAuthStore';

export const useAuth = () => {
  const { initialize, isInitialized, user, loading, error, signIn, signUp, signOut, clearError } = useAuthStore();

  useEffect(() => {
    if (!isInitialized) {
      initialize();
    }
  }, [initialize, isInitialized]);

  return {
    user,
    loading,
    error,
    isInitialized,
    isAuthenticated: !!user,
    signIn,
    signUp,
    signOut,
    clearError,
  };
};
