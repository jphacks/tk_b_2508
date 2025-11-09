'use client';

import { useEffect, useState, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/presentation/hooks/useAuth';
import { useProjectStore } from '@/presentation/stores/useProjectStore';
import ProjectCard from '@/presentation/components/ProjectCard';
import toast from 'react-hot-toast';
import { apiClient } from '@/lib/api-client';
import { extractTextFromPDF } from '@/lib/pdf-extractor';

export const dynamic = 'force-dynamic';

export default function ProjectsPage() {
  const router = useRouter();
  const { user, isAuthenticated, isInitialized, signOut } = useAuth();
  const { projects, loading, fetchProjects, createProject, deleteProject } = useProjectStore();
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [newProjectName, setNewProjectName] = useState('');
  const [newProjectDescription, setNewProjectDescription] = useState('');
  const [selectedPdf, setSelectedPdf] = useState<File | null>(null);
  const [extractingPdf, setExtractingPdf] = useState(false);
  const [taskPlanning, setTaskPlanning] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (isInitialized && !isAuthenticated) {
      router.push('/login');
    }
  }, [isAuthenticated, isInitialized, router]);

  useEffect(() => {
    if (user?.uid) {
      fetchProjects(user.uid);
    }
  }, [user, fetchProjects]);

  const handlePdfChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (file.type !== 'application/pdf') {
      toast.error('PDFファイルのみアップロード可能です');
      return;
    }

    setSelectedPdf(file);
  };

  const handleCreateProject = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user?.uid) return;

    try {
      const newProject = await createProject({
        name: newProjectName,
        companyId: user.uid,
      });

      // Prepare prompt for task planning
      let combinedPrompt = '';

      // Add text description if provided
      if (newProjectDescription.trim()) {
        combinedPrompt += newProjectDescription.trim();
      }

      // Extract and add PDF text if provided
      if (selectedPdf) {
        try {
          setExtractingPdf(true);
          const pdfText = await extractTextFromPDF(selectedPdf);
          if (pdfText.trim()) {
            if (combinedPrompt) {
              combinedPrompt += '\n\n';
            }
            combinedPrompt += pdfText.trim();
          }
        } catch {
          toast.error('PDFからのテキスト抽出に失敗しました');
          setExtractingPdf(false);
          return;
        } finally {
          setExtractingPdf(false);
        }
      }

      // If any prompt is provided, send to task planning API
      if (combinedPrompt) {
        try {
          setTaskPlanning(true);
          await apiClient.post('/task-planning', {
            prompt: combinedPrompt,
            projectId: newProject.id,
          });
          toast.success('プロジェクトを作成し、タスクプランニングを開始しました');
        } catch (taskPlanningError) {
          // Project was created successfully, but task planning failed
          toast.success('プロジェクトを作成しました');
          toast.error('タスクプランニングに失敗しました。後で手動で追加してください');
        } finally {
          setTaskPlanning(false);
        }
      } else {
        toast.success('プロジェクトを作成しました');
      }

      setNewProjectName('');
      setNewProjectDescription('');
      setSelectedPdf(null);
      if (fileInputRef.current) {
        fileInputRef.current.value = '';
      }
      setShowCreateModal(false);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'プロジェクト作成に失敗しました。';
      toast.error(message);
    }
  };

  const handleDeleteProject = async (id: string) => {
    try {
      await deleteProject(id);
      toast.success('プロジェクトを削除しました');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'プロジェクト削除に失敗しました';
      toast.error(message);
    }
  };

  const handleSignOut = async () => {
    try {
      await signOut();
      router.push('/login');
    } catch {
      toast.error('ログアウトに失敗しました');
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
      <header className="bg-white/80 backdrop-blur-sm shadow-sm border-b border-gray-100 sticky top-0 z-30">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
          <h1 className="text-2xl font-bold" style={{ color: '#57CAEA' }}>
            MIERUTE
          </h1>
          <button
            onClick={handleSignOut}
            className="flex items-center space-x-2 text-gray-600 hover:text-gray-800 px-4 py-2 rounded-lg hover:bg-gray-100 transition-all"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
            </svg>
            <span>ログアウト</span>
          </button>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-10 gap-4">
          <div>
            <h2 className="text-4xl font-bold text-gray-800 mb-2">プロジェクト</h2>
            <p className="text-gray-600">マニュアルを管理・編集できます</p>
          </div>
          <button
            onClick={() => setShowCreateModal(true)}
            className="text-white px-6 py-3 rounded-xl hover:shadow-lg hover:scale-105 transition-all duration-200 flex items-center space-x-2 font-medium"
            style={{ backgroundColor: '#57CAEA' }}
            onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#4AB8D8'}
            onMouseLeave={(e) => e.currentTarget.style.backgroundColor = '#57CAEA'}
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
            </svg>
            <span>新規作成</span>
          </button>
        </div>

        {loading ? (
          <div className="flex flex-col items-center justify-center py-20">
            <div className="animate-spin rounded-full h-16 w-16 border-4 mb-4" style={{ borderColor: '#57CAEA20', borderTopColor: '#57CAEA' }}></div>
            <p className="text-gray-500">読み込み中...</p>
          </div>
        ) : projects.length === 0 ? (
          <div className="text-center py-20">
            <div className="mb-8">
              <div className="w-24 h-24 rounded-full flex items-center justify-center mx-auto mb-6" style={{ backgroundColor: '#57CAEA20' }}>
                <svg className="w-12 h-12" style={{ color: '#57CAEA' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
              </div>
              <h3 className="text-2xl font-bold text-gray-800 mb-2">プロジェクトがありません</h3>
              <p className="text-gray-500 mb-8">最初のプロジェクトを作成して、マニュアル作成を始めましょう</p>
            </div>
            <button
              onClick={() => setShowCreateModal(true)}
              className="inline-flex items-center px-6 py-3 text-white rounded-xl hover:shadow-lg hover:scale-105 transition-all duration-200 font-medium"
              style={{ backgroundColor: '#57CAEA' }}
              onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#4AB8D8'}
              onMouseLeave={(e) => e.currentTarget.style.backgroundColor = '#57CAEA'}
            >
              <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
              </svg>
              プロジェクトを作成
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {projects.map((project, index) => (
              <div
                key={project.id}
                className="animate-fade-in"
                style={{ animationDelay: `${index * 50}ms` }}
              >
                <ProjectCard
                  project={project}
                  onDelete={handleDeleteProject}
                />
              </div>
            ))}
          </div>
        )}
      </main>

      {/* Create Project Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-fade-in">
          <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full mx-4 overflow-hidden animate-scale-in">
            {/* Modal Header */}
            <div className="px-8 py-6" style={{ backgroundColor: '#57CAEA' }}>
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-3">
                  <div className="w-10 h-10 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-sm">
                    <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                    </svg>
                  </div>
                  <h3 className="text-2xl font-bold text-white">新規プロジェクト</h3>
                </div>
                <button
                  onClick={() => {
                    setShowCreateModal(false);
                    setNewProjectName('');
                    setNewProjectDescription('');
                    setSelectedPdf(null);
                    if (fileInputRef.current) {
                      fileInputRef.current.value = '';
                    }
                  }}
                  className="text-white/80 hover:text-white hover:bg-white/20 rounded-lg p-2 transition-all"
                >
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
            </div>

            {/* Modal Body */}
            <form onSubmit={handleCreateProject} className="p-8">
              <div className="mb-6">
                <label htmlFor="projectName" className="block text-sm font-semibold text-gray-700 mb-2">
                  プロジェクト名 <span className="text-red-500">*</span>
                </label>
                <input
                  id="projectName"
                  type="text"
                  value={newProjectName}
                  onChange={(e) => setNewProjectName(e.target.value)}
                  required
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 transition-all"
                  style={{ '--tw-ring-color': '#57CAEA' } as React.CSSProperties}
                  onFocus={(e) => e.currentTarget.style.borderColor = '#57CAEA'}
                  placeholder="例: 店舗業務マニュアル"
                  autoFocus
                />
                <p className="mt-2 text-sm text-gray-500">プロジェクトの名前を入力してください</p>
              </div>
              <div className="mb-6">
                <label htmlFor="projectDescription" className="block text-sm font-semibold text-gray-700 mb-2">
                  何をするか（任意）
                </label>
                <textarea
                  id="projectDescription"
                  value={newProjectDescription}
                  onChange={(e) => setNewProjectDescription(e.target.value)}
                  rows={3}
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:ring-2 transition-all resize-none"
                  style={{ '--tw-ring-color': '#57CAEA' } as React.CSSProperties}
                  onFocus={(e) => e.currentTarget.style.borderColor = '#57CAEA'}
                  placeholder="例: 給油口を開く"
                />
                <p className="mt-2 text-sm text-gray-500">入力すると最初のブロックが自動で作成されます</p>
              </div>
              <div className="mb-6">
                <label htmlFor="pdfFile" className="block text-sm font-semibold text-gray-700 mb-2">
                  PDFをアップロード（任意）
                </label>
                <input
                  ref={fileInputRef}
                  id="pdfFile"
                  type="file"
                  accept=".pdf"
                  onChange={handlePdfChange}
                  className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold cursor-pointer"
                  style={{
                    '--file-bg': '#57CAEA20',
                    '--file-text': '#57CAEA',
                    '--file-hover-bg': '#57CAEA30'
                  } as React.CSSProperties}
                />
                {selectedPdf && (
                  <div className="mt-2 flex items-center text-sm text-gray-600">
                    <svg className="w-4 h-4 mr-1" style={{ color: '#57CAEA' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    {selectedPdf.name}
                  </div>
                )}
                <p className="mt-2 text-sm text-gray-500">PDFからテキストを抽出してマニュアルを作成します</p>
              </div>
              <div className="flex gap-3">
                <button
                  type="button"
                  onClick={() => {
                    setShowCreateModal(false);
                    setNewProjectName('');
                    setNewProjectDescription('');
                  }}
                  className="flex-1 px-6 py-3 border-2 border-gray-300 rounded-xl hover:bg-gray-50 font-medium transition-all"
                >
                  キャンセル
                </button>
                <button
                  type="submit"
                  disabled={extractingPdf || taskPlanning}
                  className="flex-1 text-white px-6 py-3 rounded-xl hover:shadow-lg font-medium transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                  style={{ backgroundColor: '#57CAEA' }}
                  onMouseEnter={(e) => !(extractingPdf || taskPlanning) && (e.currentTarget.style.backgroundColor = '#4AB8D8')}
                  onMouseLeave={(e) => !(extractingPdf || taskPlanning) && (e.currentTarget.style.backgroundColor = '#57CAEA')}
                >
                  {extractingPdf ? 'PDF処理中...' : taskPlanning ? 'AIがタスクを作成中...' : '作成'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
