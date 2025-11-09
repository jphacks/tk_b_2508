import { useState, useEffect, useRef } from 'react';
import { Block } from '@/domain/entities/Block';
import toast from 'react-hot-toast';

interface BlockEditSidebarProps {
  isOpen: boolean;
  block: Block | null;
  onClose: () => void;
  onSave: (id: string, checkpoint: string, achievement: string, img_url?: string) => void;
  onDelete: (id: string) => void;
}

export default function BlockEditSidebar({ isOpen, block, onClose, onSave, onDelete }: BlockEditSidebarProps) {
  const [checkpoint, setCheckpoint] = useState('');
  const [achievement, setAchievement] = useState('');
  const [selectedImage, setSelectedImage] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [uploading, setUploading] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (block) {
      setCheckpoint(block.checkpoint);
      setAchievement(block.achievement || '');
      setPreviewUrl(block.img_url || null);
    }
  }, [block]);

  useEffect(() => {
    if (selectedImage) {
      const objectUrl = URL.createObjectURL(selectedImage);
      setPreviewUrl(objectUrl);
      return () => URL.revokeObjectURL(objectUrl);
    }
  }, [selectedImage]);

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      if (!file.type.startsWith('image/')) {
        toast.error('画像ファイルのみアップロード可能です');
        return;
      }
      setSelectedImage(file);
    }
  };


  if (!isOpen || !block) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!checkpoint.trim()) return;

    try {
      setUploading(true);
      let uploadedImageUrl: string | undefined;

      // Upload image if selected
      if (selectedImage) {
        const { StorageService } = await import('@/infrastructure/services/storage.service');
        const storageService = new StorageService();
        uploadedImageUrl = await storageService.uploadBlockImage(block.id, selectedImage);
      }

      onSave(block.id, checkpoint, achievement, uploadedImageUrl || block.img_url);
      onClose();
      setSelectedImage(null);
      if (fileInputRef.current) {
        fileInputRef.current.value = '';
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : '保存に失敗しました';
      toast.error(message);
    } finally {
      setUploading(false);
    }
  };

  const handleDelete = () => {
    if (confirm('このブロックを削除しますか？')) {
      onDelete(block.id);
      onClose();
    }
  };

  return (
    <>
      {/* Sidebar */}
      <div
        className={`fixed top-0 right-0 h-full w-full max-w-2xl bg-white shadow-2xl z-50 transform transition-transform duration-300 ease-in-out ${
          isOpen ? 'translate-x-0' : 'translate-x-full'
        }`}
      >
        {/* Header */}
        <div className="px-6 py-4 flex justify-between items-center" style={{ backgroundColor: '#57CAEA' }}>
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-white rounded-lg flex items-center justify-center">
              <svg className="w-6 h-6" style={{ color: '#57CAEA' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
              </svg>
            </div>
            <h2 className="text-xl font-bold text-white">ブロックを編集</h2>
          </div>
          <button
            onClick={onClose}
            className="text-white hover:bg-white hover:bg-opacity-20 rounded-lg p-2 transition-colors"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        {/* Body */}
        <form onSubmit={handleSubmit} className="p-6 space-y-6 h-[calc(100%-80px)] overflow-y-auto">
          <div>
            <label htmlFor="edit-checkpoint" className="block text-sm font-semibold text-gray-700 mb-2">
              チェックポイント <span className="text-red-500">*</span>
            </label>
            <input
              id="edit-checkpoint"
              type="text"
              value={checkpoint}
              onChange={(e) => setCheckpoint(e.target.value)}
              placeholder="例: 店舗の鍵を開ける"
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:ring-2 transition-all"
              style={{ '--tw-ring-color': '#57CAEA' } as React.CSSProperties}
              onFocus={(e) => e.currentTarget.style.borderColor = '#57CAEA'}
              autoFocus
              required
            />
            <p className="mt-2 text-sm text-gray-500">このブロックで実行する作業内容を入力してください</p>
          </div>

          <div>
            <label htmlFor="edit-achievement" className="block text-sm font-semibold text-gray-700 mb-2">
              達成条件 <span className="text-red-500">*</span>
            </label>
            <textarea
              id="edit-achievement"
              value={achievement}
              onChange={(e) => setAchievement(e.target.value)}
              placeholder="例: 鍵が正しく開いていることを確認する"
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:ring-2 transition-all resize-none"
              style={{ '--tw-ring-color': '#57CAEA' } as React.CSSProperties}
              onFocus={(e) => e.currentTarget.style.borderColor = '#57CAEA'}
              rows={3}
              required
            />
            <p className="mt-2 text-sm text-gray-500">作業が完了したと判断する条件を入力してください</p>
          </div>

          {/* Image Upload Section */}
          <div className="border-t-2 border-gray-200 pt-6">
            <label className="block text-sm font-semibold text-gray-700 mb-2">
              画像リファレンス（任意）
            </label>

            {block.img_url && !selectedImage ? (
              <div className="space-y-2">
                <div className="w-full h-64 flex items-center justify-center bg-gray-50 rounded-lg border-2 border-gray-200">
                  <img
                    src={block.img_url}
                    alt="Block Reference"
                    className="max-w-full max-h-full object-contain rounded-lg"
                  />
                </div>
                <p className="text-sm text-gray-500">登録済みの画像</p>
              </div>
            ) : previewUrl && selectedImage ? (
              <div className="space-y-2">
                <div className="w-full h-64 flex items-center justify-center bg-gray-50 rounded-lg border-2 border-gray-200">
                  <img
                    src={previewUrl}
                    alt="Preview"
                    className="max-w-full max-h-full object-contain rounded-lg"
                  />
                </div>
                <p className="text-sm text-gray-500">選択済みの画像（保存時にアップロードされます）</p>
              </div>
            ) : (
              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                onChange={handleImageChange}
                className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold cursor-pointer"
                style={{
                  '--file-bg': '#57CAEA20',
                  '--file-text': '#57CAEA',
                  '--file-hover-bg': '#57CAEA30'
                } as React.CSSProperties}
              />
            )}
            <p className="mt-2 text-sm text-gray-500">ブロックの参考画像をアップロードできます</p>
          </div>

          {/* Actions */}
          <div className="flex flex-col gap-3 pt-4">
            <button
              type="submit"
              disabled={uploading}
              className="w-full px-6 py-3 text-white rounded-lg font-medium transition-colors shadow-lg disabled:bg-gray-300 disabled:cursor-not-allowed"
              style={{ backgroundColor: '#57CAEA' }}
              onMouseEnter={(e) => !uploading && (e.currentTarget.style.backgroundColor = '#4AB8D8')}
              onMouseLeave={(e) => !uploading && (e.currentTarget.style.backgroundColor = '#57CAEA')}
            >
              {uploading ? 'アップロード中...' : '保存'}
            </button>
            <button
              type="button"
              onClick={handleDelete}
              className="w-full px-6 py-3 bg-red-600 text-white rounded-lg hover:bg-red-700 font-medium transition-colors shadow-lg"
            >
              削除
            </button>
            <button
              type="button"
              onClick={onClose}
              className="w-full px-6 py-3 border-2 border-gray-300 rounded-lg hover:bg-gray-50 font-medium transition-colors"
            >
              キャンセル
            </button>
          </div>
        </form>
      </div>
    </>
  );
}
