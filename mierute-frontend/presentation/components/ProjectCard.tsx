import Link from 'next/link';
import { Project } from '@/domain/entities/Project';

interface ProjectCardProps {
  project: Project;
  onDelete: (id: string) => void;
}

export default function ProjectCard({ project, onDelete }: ProjectCardProps) {
  const handleDelete = (e: React.MouseEvent) => {
    e.preventDefault();
    if (confirm('本当に削除しますか？')) {
      onDelete(project.id);
    }
  };

  return (
    <Link href={`/projects/${project.id}/edit`}>
      <div className="group relative bg-white rounded-2xl shadow-lg hover:shadow-2xl transition-all duration-300 cursor-pointer border border-gray-100 hover:border-indigo-200 overflow-hidden transform hover:-translate-y-1 h-48">
        <div className="p-6 h-full flex flex-col">
          {/* Header */}
          <div className="flex justify-between items-start mb-4">
            <div className="flex-1 pr-4 min-h-[3.5rem]">
              <h3 className="text-xl font-bold text-gray-800 group-hover:text-indigo-600 transition-colors line-clamp-2 overflow-hidden text-ellipsis">
                {project.name}
              </h3>
            </div>
            <button
              onClick={handleDelete}
              className="flex-shrink-0 p-1.5 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-all duration-200"
              title="削除"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
              </svg>
            </button>
          </div>

          {/* Spacer */}
          <div className="flex-1"></div>

          {/* Stats */}
          <div className="flex items-center justify-between text-sm mt-auto">
            <div className="flex items-center space-x-2 px-3 py-2 bg-indigo-50 rounded-lg group-hover:bg-indigo-100 transition-colors">
              <svg className="w-4 h-4 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
              </svg>
              <span className="font-semibold text-indigo-700">{(project.blockOrderIds || []).length}</span>
              <span className="text-indigo-600">ブロック</span>
            </div>
            <div className="flex items-center text-gray-500">
              <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <span className="text-xs">
                {new Date(project.updatedAt).toLocaleDateString('ja-JP', {
                  month: 'short',
                  day: 'numeric'
                })}
              </span>
            </div>
          </div>
        </div>
      </div>
    </Link>
  );
}
