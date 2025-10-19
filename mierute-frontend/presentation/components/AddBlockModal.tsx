import { useState } from 'react';

interface AddBlockModalProps {
  isOpen: boolean;
  onClose: () => void;
  onAdd: (checkpoint: string, condition: string) => void;
}

export default function AddBlockModal({ isOpen, onClose, onAdd }: AddBlockModalProps) {
  const [checkpoint, setCheckpoint] = useState('');
  const [condition, setCondition] = useState('');

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (checkpoint.trim()) {
      onAdd(checkpoint, condition);
      setCheckpoint('');
      setCondition('');
      onClose();
    }
  };

  const handleBackdropClick = (e: React.MouseEvent) => {
    if (e.target === e.currentTarget) {
      onClose();
    }
  };

  return (
    <div
      className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      onClick={handleBackdropClick}
    >
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-hidden animate-fade-in">
        {/* Header */}
        <div className="bg-gradient-to-r from-indigo-500 to-purple-600 px-6 py-4 flex justify-between items-center">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-white rounded-lg flex items-center justify-center">
              <svg className="w-6 h-6 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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
        <form onSubmit={handleSubmit} className="p-6 space-y-6">
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
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all"
              autoFocus
              required
            />
            <p className="mt-2 text-sm text-gray-500">このブロックで実行する作業内容を入力してください</p>
          </div>

          <div>
            <label htmlFor="condition" className="block text-sm font-semibold text-gray-700 mb-2">
              達成条件 <span className="text-red-500">*</span>
            </label>
            <textarea
              id="condition"
              value={condition}
              onChange={(e) => setCondition(e.target.value)}
              placeholder="例: 鍵が正しく開いていることを確認する"
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all resize-none"
              rows={3}
              required
            />
            <p className="mt-2 text-sm text-gray-500">作業が完了したと判断する条件を入力してください</p>
          </div>

          {/* Actions */}
          <div className="flex gap-3 pt-4">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 px-6 py-3 border-2 border-gray-300 rounded-lg hover:bg-gray-50 font-medium transition-colors"
            >
              キャンセル
            </button>
            <button
              type="submit"
              className="flex-1 px-6 py-3 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 font-medium transition-colors shadow-lg"
            >
              追加
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
