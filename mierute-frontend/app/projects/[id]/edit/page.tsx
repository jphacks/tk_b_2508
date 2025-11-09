'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { useAuth } from '@/presentation/hooks/useAuth';
import { useProjectStore } from '@/presentation/stores/useProjectStore';
import { useBlockStore } from '@/presentation/stores/useBlockStore';
import BlockItem from '@/presentation/components/BlockItem';
import BlockConnector from '@/presentation/components/BlockConnector';
import AddBlockModal from '@/presentation/components/AddBlockModal';
import BlockEditSidebar from '@/presentation/components/BlockEditSidebar';
import RagDocumentSidebar from '@/presentation/components/RagDocumentSidebar';
import toast from 'react-hot-toast';

export default function EditProjectPage() {
  const params = useParams();
  const router = useRouter();
  const projectId = params.id as string;

  const { isAuthenticated, isInitialized } = useAuth();
  const { selectedProject, fetchProjectById } = useProjectStore();
  const { blocks, fetchBlocks, createBlock, updateBlock, deleteBlock } = useBlockStore();

  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [isEditSidebarOpen, setIsEditSidebarOpen] = useState(false);
  const [isRagSidebarOpen, setIsRagSidebarOpen] = useState(false);
  const [selectedBlock, setSelectedBlock] = useState<typeof blocks[0] | null>(null);

  useEffect(() => {
    if (isInitialized && !isAuthenticated) {
      router.push('/login');
    }
  }, [isAuthenticated, isInitialized, router]);

  useEffect(() => {
    if (projectId) {
      fetchProjectById(projectId);
      fetchBlocks(projectId);
    }
  }, [projectId, fetchProjectById, fetchBlocks]);

  const handleAddBlock = async (checkpoint: string, achievement: string, img_url?: string) => {
    try {
      await createBlock({
        checkpoint,
        achievement,
        projectId,
        img_url,
      });

      toast.success('ブロックを追加しました');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'ブロック追加に失敗しました';
      toast.error(message);
    }
  };

  const handleUpdateBlock = async (id: string, checkpoint: string, achievement: string, img_url?: string) => {
    try {
      await updateBlock({ id, checkpoint, achievement, img_url });
      toast.success('ブロックを更新しました');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'ブロック更新に失敗しました';
      toast.error(message);
    }
  };

  const handleBlockClick = (block: typeof blocks[0]) => {
    setSelectedBlock(block);
    setIsEditSidebarOpen(true);
  };

  const handleDeleteBlock = async (id: string) => {
    try {
      await deleteBlock(id);
      toast.success('ブロックを削除しました');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'ブロック削除に失敗しました';
      toast.error(message);
    }
  };

  if (!isInitialized) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2" style={{ borderColor: '#57CAEA' }}></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-cyan-50 via-blue-50 to-orange-50">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
          <button
            onClick={() => router.push('/projects')}
            className="flex items-center text-gray-600 hover:text-gray-800 transition-colors"
          >
            <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
            </svg>
            戻る
          </button>
          <h1 className="text-xl font-bold text-gray-800">
            {selectedProject?.name || 'マニュアル編集'}
          </h1>
          <button
            onClick={() => setIsRagSidebarOpen(true)}
            className="flex items-center gap-2 px-4 py-2 text-white rounded-lg transition-colors shadow-md"
            style={{ backgroundColor: '#57CAEA' }}
            onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#4AB8D8'}
            onMouseLeave={(e) => e.currentTarget.style.backgroundColor = '#57CAEA'}
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            RAG資料
          </button>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Blocks List */}
        {blocks.length === 0 ? (
          <>
            <div className="text-center py-12 bg-white rounded-xl shadow-md">
              <p className="text-gray-500 text-lg">ブロックがありません</p>
              <p className="text-gray-400 text-sm mt-2">下の + ボタンから最初のブロックを追加してください</p>
            </div>
            <BlockConnector
              onAddBlock={() => setIsAddModalOpen(true)}
            />
          </>
        ) : (
          <div>
            {blocks.map((block, index) => (
              <div key={`${block.id}-${index}`}>
                <BlockItem
                  block={block}
                  onClick={handleBlockClick}
                  onDelete={handleDeleteBlock}
                />
                {/* Add connector after each block */}
                <BlockConnector
                  onAddBlock={() => setIsAddModalOpen(true)}
                />
              </div>
            ))}
          </div>
        )}

        {/* Modals and Sidebars */}
        <AddBlockModal
          isOpen={isAddModalOpen}
          onClose={() => setIsAddModalOpen(false)}
          onAdd={handleAddBlock}
          projectId={projectId}
        />

        <BlockEditSidebar
          isOpen={isEditSidebarOpen}
          block={selectedBlock}
          onClose={() => {
            setIsEditSidebarOpen(false);
            setSelectedBlock(null);
          }}
          onSave={handleUpdateBlock}
          onDelete={handleDeleteBlock}
        />

        <RagDocumentSidebar
          isOpen={isRagSidebarOpen}
          projectId={projectId}
          onClose={() => setIsRagSidebarOpen(false)}
        />
      </main>
    </div>
  );
}
