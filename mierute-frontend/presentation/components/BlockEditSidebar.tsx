import { useState, useEffect, useRef } from 'react';
import { Block } from '@/domain/entities/Block';
import { useBlockStore } from '@/presentation/stores/useBlockStore';
import toast from 'react-hot-toast';

interface BlockEditSidebarProps {
  isOpen: boolean;
  block: Block | null;
  onClose: () => void;
  onSave: (id: string, checkpoint: string, condition: string) => void;
  onDelete: (id: string) => void;
}

export default function BlockEditSidebar({ isOpen, block, onClose, onSave, onDelete }: BlockEditSidebarProps) {
  const { uploadingImage, uploadAndAddImage } = useBlockStore();
  const [checkpoint, setCheckpoint] = useState('');
  const [condition, setCondition] = useState('');
  const [selectedImage, setSelectedImage] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (block) {
      setCheckpoint(block.checkpoint);
      setCondition(block.condition || '');
      setPreviewUrl(block.imageUrl || null);
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

  const handleImageUpload = async () => {
    if (!selectedImage || !block) {
      toast.error('画像を選択してください');
      return;
    }

    try {
      await uploadAndAddImage(block.id, selectedImage);
      toast.success('画像を追加しました');
      setSelectedImage(null);
      if (fileInputRef.current) {
        fileInputRef.current.value = '';
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : '画像のアップロードに失敗しました';
      toast.error(message);
    }
  };

  if (!isOpen || !block) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (checkpoint.trim()) {
      onSave(block.id, checkpoint, condition);
      onClose();
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
        <div className="bg-gradient-to-r from-indigo-500 to-purple-600 px-6 py-4 flex justify-between items-center">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-white rounded-lg flex items-center justify-center">
              <svg className="w-6 h-6 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all"
              autoFocus
              required
            />
            <p className="mt-2 text-sm text-gray-500">このブロックで実行する作業内容を入力してください</p>
          </div>

          <div>
            <label htmlFor="edit-condition" className="block text-sm font-semibold text-gray-700 mb-2">
              達成条件 <span className="text-red-500">*</span>
            </label>
            <textarea
              id="edit-condition"
              value={condition}
              onChange={(e) => setCondition(e.target.value)}
              placeholder="例: 鍵が正しく開いていることを確認する"
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all resize-none"
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

            {block.imageUrl && !selectedImage ? (
              <div className="space-y-2">
                <div className="w-full h-64 flex items-center justify-center bg-gray-50 rounded-lg border-2 border-gray-200">
                  <img
                    src={block.imageUrl}
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
                <button
                  type="button"
                  onClick={handleImageUpload}
                  disabled={uploadingImage}
                  className="w-full px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 font-medium transition-colors disabled:bg-gray-300 disabled:cursor-not-allowed"
                >
                  {uploadingImage ? 'アップロード中...' : '画像を追加'}
                </button>
              </div>
            ) : (
              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                onChange={handleImageChange}
                className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-purple-50 file:text-purple-700 hover:file:bg-purple-100 cursor-pointer"
              />
            )}
            <p className="mt-2 text-sm text-gray-500">ブロックの参考画像をアップロードできます</p>
          </div>

          {/* Actions */}
          <div className="flex flex-col gap-3 pt-4">
            <button
              type="submit"
              className="w-full px-6 py-3 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 font-medium transition-colors shadow-lg"
            >
              保存
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
