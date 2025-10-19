interface BlockConnectorProps {
  onAddBlock?: () => void;
}

export default function BlockConnector({ onAddBlock }: BlockConnectorProps) {
  return (
    <div className="flex flex-col items-center my-2">
      {/* Top Line */}
      <div className="w-0.5 h-8 bg-indigo-300"></div>

      {/* Plus Button */}
      <button
        onClick={onAddBlock}
        className="w-10 h-10 rounded-full bg-white border-2 border-indigo-400 text-indigo-600 hover:bg-indigo-50 hover:border-indigo-500 hover:scale-110 transition-all duration-200 flex items-center justify-center shadow-md z-10"
        title="ブロックを追加"
      >
        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M12 4v16m8-8H4" />
        </svg>
      </button>

      {/* Bottom Line */}
      <div className="w-0.5 h-8 bg-indigo-300"></div>
    </div>
  );
}
