import { create } from 'zustand';
import { Block, CreateBlockInput, UpdateBlockInput } from '@/domain/entities/Block';
import { blockUseCase } from '@/lib/di-container';
import { StorageService } from '@/infrastructure/services/storage.service';

// Lazy instantiation to avoid server-side execution
const getStorageService = () => {
  if (typeof window === 'undefined') {
    throw new Error('StorageService can only be used on the client side');
  }
  return new StorageService();
};

interface BlockState {
  blocks: Block[];
  loading: boolean;
  error: string | null;
  uploadingImage: boolean;

  // Actions
  fetchBlocks: (projectId: string) => Promise<void>;
  createBlock: (input: CreateBlockInput) => Promise<Block>;
  updateBlock: (input: UpdateBlockInput) => Promise<void>;
  deleteBlock: (id: string) => Promise<void>;
  uploadAndAddImage: (blockId: string, file: File) => Promise<void>;
  clearError: () => void;
}

export const useBlockStore = create<BlockState>((set, get) => ({
  blocks: [],
  loading: false,
  error: null,
  uploadingImage: false,

  fetchBlocks: async (projectId: string) => {
    set({ loading: true, error: null });
    try {
      const blocks = await blockUseCase.getBlocksByProjectId(projectId);
      // 重複IDを除去
      const uniqueBlocks = blocks.filter((block, index, self) => 
        index === self.findIndex(b => b.id === block.id)
      );
      set({ blocks: uniqueBlocks, loading: false });
    } catch (error: any) {
      set({
        error: error.message || 'Failed to fetch blocks',
        loading: false
      });
    }
  },

  createBlock: async (input: CreateBlockInput) => {
    set({ loading: true, error: null });
    try {
      const block = await blockUseCase.createBlock(input);
      set(state => ({
        // 重複IDをチェックして追加
        blocks: state.blocks.some(b => b.id === block.id) 
          ? state.blocks 
          : [...state.blocks, block],
        loading: false
      }));
      return block;
    } catch (error: any) {
      set({
        error: error.message || 'Failed to create block',
        loading: false
      });
      throw error;
    }
  },

  updateBlock: async (input: UpdateBlockInput) => {
    set({ loading: true, error: null });
    try {
      const updatedBlock = await blockUseCase.updateBlock(input);
      set(state => ({
        blocks: state.blocks.map(b => b.id === input.id ? updatedBlock : b),
        loading: false
      }));
    } catch (error: any) {
      set({
        error: error.message || 'Failed to update block',
        loading: false
      });
      throw error;
    }
  },

  deleteBlock: async (id: string) => {
    set({ loading: true, error: null });
    try {
      await blockUseCase.deleteBlock(id);
      set(state => ({
        blocks: state.blocks.filter(b => b.id !== id),
        loading: false
      }));
    } catch (error: any) {
      set({
        error: error.message || 'Failed to delete block',
        loading: false
      });
      throw error;
    }
  },

  uploadAndAddImage: async (blockId: string, file: File) => {
    set({ uploadingImage: true, error: null });
    try {
      // Upload file to Firebase Storage
      const storageService = getStorageService();
      const imageUrl = await storageService.uploadBlockImage(blockId, file);

      // Add image to block via API
      const updatedBlock = await blockUseCase.addImageToBlock(blockId, imageUrl);

      set(state => ({
        blocks: state.blocks.map(b => b.id === blockId ? updatedBlock : b),
        uploadingImage: false
      }));
    } catch (error: any) {
      set({
        error: error.message || '画像のアップロードに失敗しました',
        uploadingImage: false
      });
      throw error;
    }
  },

  clearError: () => set({ error: null }),
}));
