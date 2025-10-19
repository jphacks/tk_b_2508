import { Block } from '@/domain/entities/Block';

interface BlockItemProps {
  block: Block;
  onClick: (block: Block) => void;
  onDelete: (id: string) => void;
}

export default function BlockItem({ block, onClick, onDelete }: BlockItemProps) {

  const handleDelete = () => {
    if (confirm('このブロックを削除しますか？')) {
      onDelete(block.id);
    }
  };

  return (
    <div
      className="bg-white rounded-xl shadow-lg border border-gray-200 hover:shadow-xl transition-shadow cursor-pointer"
      onClick={() => onClick(block)}
    >
      <div className="p-5">
        <div className="flex items-center gap-4">
          {/* Check Icon */}
          <div className="flex-shrink-0">
            <div className="w-8 h-8 rounded-full bg-green-100 flex items-center justify-center">
              <svg className="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M5 13l4 4L19 7" />
              </svg>
            </div>
          </div>

          {/* Content */}
          <div className="flex-1 min-w-0">
            <p className="text-gray-800 font-medium">{block.checkpoint}</p>
            <p className="text-sm text-gray-500 mt-1">{block.condition}</p>
          </div>

          {/* Actions */}
          <div className="flex-shrink-0 flex items-center gap-1">
            <button
              onClick={(e) => {
                e.stopPropagation();
                handleDelete();
              }}
              className="p-2 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors"
              title="削除"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
              </svg>
            </button>
            <button
              className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-50 rounded-lg transition-colors"
              onClick={(e) => e.stopPropagation()}
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
              </svg>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
