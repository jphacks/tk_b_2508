interface BlockConnectorProps {
  onAddBlock?: () => void;
}

export default function BlockConnector({ onAddBlock }: BlockConnectorProps) {
  return (
    <div className="flex flex-col items-center my-2">
      {/* Top Line */}
      <div className="w-0.5 h-8" style={{ backgroundColor: '#57CAEA40' }}></div>

      {/* Plus Button */}
      <button
        onClick={onAddBlock}
        className="w-10 h-10 rounded-full bg-white border-2 hover:scale-110 transition-all duration-200 flex items-center justify-center shadow-md z-10"
        style={{ borderColor: '#57CAEA', color: '#57CAEA' }}
        onMouseEnter={(e) => {
          e.currentTarget.style.backgroundColor = '#57CAEA10';
          e.currentTarget.style.borderColor = '#4AB8D8';
        }}
        onMouseLeave={(e) => {
          e.currentTarget.style.backgroundColor = 'white';
          e.currentTarget.style.borderColor = '#57CAEA';
        }}
        title="ブロックを追加"
      >
        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M12 4v16m8-8H4" />
        </svg>
      </button>

      {/* Bottom Line */}
      <div className="w-0.5 h-8" style={{ backgroundColor: '#57CAEA40' }}></div>
    </div>
  );
}
