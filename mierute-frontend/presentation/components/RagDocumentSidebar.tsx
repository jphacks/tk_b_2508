import { useState, useEffect, useRef } from 'react';
import { useRagDocumentStore } from '@/presentation/stores/useRagDocumentStore';
import toast from 'react-hot-toast';

interface RagDocumentSidebarProps {
  isOpen: boolean;
  projectId: string;
  onClose: () => void;
}

export default function RagDocumentSidebar({ isOpen, projectId, onClose }: RagDocumentSidebarProps) {
  const { ragDocuments, loading, uploading, fetchRagDocuments, uploadAndCreateRagDocument } = useRagDocumentStore();
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [markdownContent, setMarkdownContent] = useState<string | null>(null);

  useEffect(() => {
    if (isOpen && projectId) {
      fetchRagDocuments(projectId);
    }
  }, [isOpen, projectId, fetchRagDocuments]);

  useEffect(() => {
    if (selectedFile) {
      const isImage = selectedFile.type.startsWith('image/');
      const isMarkdown = selectedFile.name.endsWith('.md') || selectedFile.type === 'text/markdown';

      if (isImage) {
        const objectUrl = URL.createObjectURL(selectedFile);
        setPreviewUrl(objectUrl);
        setMarkdownContent(null);
        return () => URL.revokeObjectURL(objectUrl);
      } else if (isMarkdown) {
        setPreviewUrl(null);
        const reader = new FileReader();
        reader.onload = (e) => {
          const text = e.target?.result as string;
          setMarkdownContent(text);
        };
        reader.readAsText(selectedFile);
      }
    } else {
      setPreviewUrl(null);
      setMarkdownContent(null);
    }
  }, [selectedFile]);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      // Check if file is an image or markdown
      const isImage = file.type.startsWith('image/');
      const isMarkdown = file.name.endsWith('.md') || file.type === 'text/markdown';

      if (!isImage && !isMarkdown) {
        toast.error('画像ファイルまたはマークダウンファイル(.md)のみアップロード可能です');
        return;
      }
      setSelectedFile(file);
    }
  };

  const handleUpload = async () => {
    if (!selectedFile) {
      toast.error('ファイルを選択してください');
      return;
    }

    try {
      await uploadAndCreateRagDocument(projectId, selectedFile);
      toast.success('RAG資料をアップロードしました');
      setSelectedFile(null);
      setPreviewUrl(null);
      setMarkdownContent(null);
      if (fileInputRef.current) {
        fileInputRef.current.value = '';
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : 'アップロードに失敗しました';
      toast.error(message);
    }
  };

  if (!isOpen) return null;

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
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
            </div>
            <h2 className="text-xl font-bold text-white">RAG資料</h2>
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
        <div className="p-6 h-[calc(100%-80px)] overflow-y-auto space-y-6">
          {/* Upload Section */}
          <div className="bg-gray-50 rounded-lg p-4 space-y-4">
            <h3 className="text-lg font-semibold text-gray-800">資料を追加</h3>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                ファイルを選択（画像またはマークダウン）
              </label>
              <input
                ref={fileInputRef}
                type="file"
                accept="image/*,.md"
                onChange={handleFileChange}
                className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold cursor-pointer"
                style={{
                  '--file-bg': '#57CAEA20',
                  '--file-text': '#57CAEA',
                  '--file-hover-bg': '#57CAEA30'
                } as React.CSSProperties}
              />
            </div>

            {previewUrl && (
              <div className="space-y-2">
                <label className="block text-sm font-medium text-gray-700">プレビュー</label>
                <img
                  src={previewUrl}
                  alt="Preview"
                  className="max-w-full h-auto max-h-64 rounded-lg border-2 border-gray-200"
                />
              </div>
            )}

            {markdownContent && (
              <div className="space-y-2">
                <label className="block text-sm font-medium text-gray-700">プレビュー</label>
                <div className="max-h-64 overflow-y-auto p-4 bg-white rounded-lg border-2 border-gray-200">
                  <pre className="text-sm text-gray-700 whitespace-pre-wrap font-mono">{markdownContent}</pre>
                </div>
              </div>
            )}

            <button
              onClick={handleUpload}
              disabled={!selectedFile || uploading}
              className="w-full px-6 py-3 text-white rounded-lg font-medium transition-colors shadow-lg disabled:bg-gray-300 disabled:cursor-not-allowed"
              style={{ backgroundColor: '#57CAEA' }}
              onMouseEnter={(e) => !uploading && !(!selectedFile) && (e.currentTarget.style.backgroundColor = '#4AB8D8')}
              onMouseLeave={(e) => !uploading && !(!selectedFile) && (e.currentTarget.style.backgroundColor = '#57CAEA')}
            >
              {uploading ? 'アップロード中...' : 'アップロード'}
            </button>
          </div>

          {/* Documents List */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-800">登録済み資料</h3>

            {loading && (
              <div className="flex items-center justify-center py-8">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2" style={{ borderColor: '#57CAEA' }}></div>
              </div>
            )}

            {!loading && ragDocuments.length === 0 && (
              <div className="text-center py-8 bg-gray-50 rounded-lg">
                <p className="text-gray-500">RAG資料がありません</p>
                <p className="text-gray-400 text-sm mt-2">上のフォームから資料を追加してください</p>
              </div>
            )}

            {!loading && ragDocuments.length > 0 && (
              <div className="space-y-3">
                {ragDocuments.map((doc) => {
                  const isImage = doc.storageUrl.match(/\.(jpg|jpeg|png|gif|webp)(\?|$)/i);
                  const isMarkdown = doc.storageUrl.match(/\.md(\?|$)/i);

                  return (
                    <div
                      key={doc.id}
                      className="bg-white border-2 border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow"
                    >
                      <div className="flex items-start gap-4">
                        {isImage ? (
                          <img
                            src={doc.storageUrl}
                            alt="RAG Document"
                            className="w-24 h-24 object-cover rounded-lg border border-gray-200"
                          />
                        ) : (
                          <div className="w-24 h-24 rounded-lg border border-gray-200 flex items-center justify-center" style={{ backgroundColor: '#57CAEA20' }}>
                            <svg className="w-12 h-12" style={{ color: '#57CAEA' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                            </svg>
                          </div>
                        )}
                        <div className="flex-1 space-y-2">
                          <div className="flex items-center gap-2">
                            <div className="text-sm text-gray-500">
                              {new Date(doc.createdAt).toLocaleDateString('ja-JP')}
                            </div>
                            {isMarkdown && (
                              <span className="px-2 py-0.5 text-xs rounded-full font-medium" style={{ backgroundColor: '#57CAEA20', color: '#57CAEA' }}>
                                Markdown
                              </span>
                            )}
                            {isImage && (
                              <span className="px-2 py-0.5 bg-blue-100 text-blue-700 text-xs rounded-full font-medium">
                                画像
                              </span>
                            )}
                          </div>
                          <a
                            href={doc.storageUrl}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-purple-600 hover:text-purple-800 text-sm font-medium flex items-center gap-1"
                          >
                            ファイルを表示する
                            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                            </svg>
                          </a>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </div>
      </div>
    </>
  );
}
