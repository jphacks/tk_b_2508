import { useState, useRef } from 'react';
import toast from 'react-hot-toast';
import { uploadBlockImage } from '@/lib/storage';

interface AddBlockModalProps {
  isOpen: boolean;
  onClose: () => void;
  onAdd: (checkpoint: string, achievement: string, img_url?: string) => void;
  projectId: string;
}

export default function AddBlockModal({ isOpen, onClose, onAdd, projectId }: AddBlockModalProps) {
  const [checkpoint, setCheckpoint] = useState('');
  const [achievement, setAchievement] = useState('');
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  if (!isOpen) return null;

  const handleImageSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      // ファイルタイプの検証
      if (!file.type.startsWith('image/')) {
        toast.error('画像ファイルのみアップロードできます');
        return;
      }

      // ファイルサイズの検証（10MB未満）
      const maxSize = 10 * 1024 * 1024;
      if (file.size > maxSize) {
        toast.error('ファイルサイズは10MB未満にしてください');
        return;
      }

      setImageFile(file);

      // プレビュー表示用のURL生成
      const reader = new FileReader();
      reader.onloadend = () => {
        setImagePreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleRemoveImage = () => {
    setImageFile(null);
    setImagePreview(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (checkpoint.trim()) {
      try {
        setIsUploading(true);
        let img_url: string | undefined;

        // 画像が選択されている場合はアップロード
        if (imageFile) {
          img_url = await uploadBlockImage(imageFile, projectId);
        }

        onAdd(checkpoint, achievement, img_url);

        // フォームのリセット
        setCheckpoint('');
        setAchievement('');
        setImageFile(null);
        setImagePreview(null);
        if (fileInputRef.current) {
          fileInputRef.current.value = '';
        }

        onClose();
        toast.success('ブロックを追加しました');
      } catch (error) {
        console.error('Error adding block:', error);
        toast.error('ブロックの追加に失敗しました');
      } finally {
        setIsUploading(false);
      }
    }
  };

  const handleBackdropClick = (e: React.MouseEvent) => {
    if (e.target === e.currentTarget) {
      onClose();
    }
  };

  return (
    <div
      className="fixed inset-0 bg-black bg-opacity-30 flex items-center justify-center z-50 p-4"
      onClick={handleBackdropClick}
    >
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-hidden animate-fade-in flex flex-col">
        {/* Header */}
        <div className="px-6 py-4 flex justify-between items-center flex-shrink-0" style={{ backgroundColor: '#57CAEA' }}>
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-white rounded-lg flex items-center justify-center">
              <svg className="w-6 h-6" style={{ color: '#57CAEA' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
              </svg>
            </div>
            <h2 className="text-xl font-bold text-white">新しいブロックを追加</h2>
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
        <form onSubmit={handleSubmit} className="flex flex-col flex-1 min-h-0">
          <div className="p-6 space-y-6 overflow-y-auto flex-1">
          <div>
            <label htmlFor="checkpoint" className="block text-sm font-semibold text-gray-700 mb-2">
              チェックポイント <span className="text-red-500">*</span>
            </label>
            <input
              id="checkpoint"
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
            <label htmlFor="achievement" className="block text-sm font-semibold text-gray-700 mb-2">
              達成条件 <span className="text-red-500">*</span>
            </label>
            <textarea
              id="achievement"
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

          {/* 画像選択 */}
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2">
              参考画像
            </label>

            {!imagePreview ? (
              <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center transition-colors"
                onMouseEnter={(e) => e.currentTarget.style.borderColor = '#57CAEA'}
                onMouseLeave={(e) => e.currentTarget.style.borderColor = ''}
              >
                <input
                  ref={fileInputRef}
                  type="file"
                  accept="image/*"
                  onChange={handleImageSelect}
                  className="hidden"
                  id="image-upload"
                />
                <label htmlFor="image-upload" className="cursor-pointer">
                  <div className="flex flex-col items-center gap-2">
                    <svg className="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                    <div className="text-sm text-gray-600">
                      <span className="font-medium" style={{ color: '#57CAEA' }}>クリックして画像を選択</span>
                      <span className="text-gray-500"> またはドラッグ&ドロップ</span>
                    </div>
                    <p className="text-xs text-gray-500">PNG, JPG, GIF (最大10MB)</p>
                  </div>
                </label>
              </div>
            ) : (
              <div className="relative border-2 border-gray-200 rounded-lg overflow-hidden">
                <img
                  src={imagePreview}
                  alt="プレビュー"
                  className="w-full h-48 object-cover"
                />
                <button
                  type="button"
                  onClick={handleRemoveImage}
                  className="absolute top-2 right-2 bg-red-500 text-white rounded-full p-2 hover:bg-red-600 transition-colors shadow-lg"
                >
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
                <div className="p-3 bg-gray-50 border-t border-gray-200">
                  <p className="text-sm text-gray-600 truncate">{imageFile?.name}</p>
                  <p className="text-xs text-gray-500">{((imageFile?.size || 0) / 1024 / 1024).toFixed(2)} MB</p>
                </div>
              </div>
            )}
            <p className="mt-2 text-sm text-gray-500">作業手順の参考となる画像をアップロードできます（任意）</p>
          </div>
          </div>

          {/* Actions - Fixed at bottom */}
          <div className="flex gap-3 p-6 border-t border-gray-200 bg-gray-50 flex-shrink-0">
            <button
              type="button"
              onClick={onClose}
              disabled={isUploading}
              className="flex-1 px-6 py-3 border-2 border-gray-300 rounded-lg hover:bg-gray-50 bg-white font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              キャンセル
            </button>
            <button
              type="submit"
              disabled={isUploading}
              className="flex-1 px-6 py-3 text-white rounded-lg font-medium transition-colors shadow-lg disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              style={{ backgroundColor: '#57CAEA' }}
              onMouseEnter={(e) => !isUploading && (e.currentTarget.style.backgroundColor = '#4AB8D8')}
              onMouseLeave={(e) => !isUploading && (e.currentTarget.style.backgroundColor = '#57CAEA')}
            >
              {isUploading && (
                <svg className="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                  <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
              )}
              {isUploading ? 'アップロード中...' : '追加'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
