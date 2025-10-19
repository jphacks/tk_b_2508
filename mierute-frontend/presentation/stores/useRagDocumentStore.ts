import { create } from 'zustand';
import { RagDocument, CreateRagDocumentInput } from '@/domain/entities/RagDocument';
import { ragDocumentUseCase } from '@/lib/di-container';
import { StorageService } from '@/infrastructure/services/storage.service';

// Lazy instantiation to avoid server-side execution
const getStorageService = () => {
  if (typeof window === 'undefined') {
    throw new Error('StorageService can only be used on the client side');
  }
  return new StorageService();
};

interface RagDocumentState {
  ragDocuments: RagDocument[];
  loading: boolean;
  error: string | null;
  uploading: boolean;

  // Actions
  fetchRagDocuments: (projectId: string) => Promise<void>;
  uploadAndCreateRagDocument: (projectId: string, file: File) => Promise<RagDocument>;
  clearError: () => void;
}

export const useRagDocumentStore = create<RagDocumentState>((set, get) => ({
  ragDocuments: [],
  loading: false,
  error: null,
  uploading: false,

  fetchRagDocuments: async (projectId: string) => {
    set({ loading: true, error: null });
    try {
      const ragDocuments = await ragDocumentUseCase.getRagDocumentsByProjectId(projectId);
      set({ ragDocuments, loading: false });
    } catch (error: any) {
      set({
        error: error.message || 'RAG資料の取得に失敗しました',
        loading: false
      });
    }
  },

  uploadAndCreateRagDocument: async (projectId: string, file: File) => {
    set({ uploading: true, error: null });
    try {
      // Upload file to Firebase Storage
      const storageService = getStorageService();
      const storageUrl = await storageService.uploadRagDocument(projectId, file);

      // Create RAG document record in backend
      const ragDocument = await ragDocumentUseCase.createRagDocument({
        projectId,
        storageUrl
      });

      set(state => ({
        ragDocuments: [...state.ragDocuments, ragDocument],
        uploading: false
      }));

      return ragDocument;
    } catch (error: any) {
      set({
        error: error.message || 'RAG資料のアップロードに失敗しました',
        uploading: false
      });
      throw error;
    }
  },

  clearError: () => set({ error: null }),
}));
