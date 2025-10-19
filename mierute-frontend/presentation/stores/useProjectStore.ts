import { create } from 'zustand';
import { Project, CreateProjectInput } from '@/domain/entities/Project';
import { projectUseCase } from '@/lib/di-container';

interface ProjectState {
  projects: Project[];
  selectedProject: Project | null;
  loading: boolean;
  error: string | null;

  // Actions
  fetchProjects: (companyId: string) => Promise<void>;
  fetchProjectById: (id: string) => Promise<void>;
  createProject: (input: CreateProjectInput) => Promise<Project>;
  deleteProject: (id: string) => Promise<void>;
  updateBlockOrder: (projectId: string, blockOrderIds: string[]) => Promise<void>;
  clearError: () => void;
}

export const useProjectStore = create<ProjectState>((set, get) => ({
  projects: [],
  selectedProject: null,
  loading: false,
  error: null,

  fetchProjects: async (companyId: string) => {
    set({ loading: true, error: null });
    try {
      const projects = await projectUseCase.getAllProjects(companyId);
      set({ projects, loading: false });
    } catch (error: any) {
      set({
        error: error.message || 'Failed to fetch projects',
        loading: false
      });
    }
  },

  fetchProjectById: async (id: string) => {
    set({ loading: true, error: null });
    try {
      const project = await projectUseCase.getProjectById(id);
      set({ selectedProject: project, loading: false });
    } catch (error: any) {
      set({
        error: error.message || 'Failed to fetch project',
        loading: false
      });
    }
  },

  createProject: async (input: CreateProjectInput) => {
    set({ loading: true, error: null });
    try {
      const project = await projectUseCase.createProject(input);
      set(state => ({
        projects: [...state.projects, project],
        loading: false
      }));
      return project;
    } catch (error: any) {
      set({
        error: error.message || 'Failed to create project',
        loading: false
      });
      throw error;
    }
  },

  deleteProject: async (id: string) => {
    set({ loading: true, error: null });
    try {
      await projectUseCase.deleteProject(id);
      set(state => ({
        projects: state.projects.filter(p => p.id !== id),
        loading: false
      }));
    } catch (error: any) {
      set({
        error: error.message || 'Failed to delete project',
        loading: false
      });
      throw error;
    }
  },

  updateBlockOrder: async (projectId: string, blockOrderIds: string[]) => {
    try {
      const updatedProject = await projectUseCase.updateBlockOrder(projectId, blockOrderIds);
      set(state => ({
        selectedProject: state.selectedProject?.id === projectId ? updatedProject : state.selectedProject,
        projects: state.projects.map(p => p.id === projectId ? updatedProject : p)
      }));
    } catch (error: any) {
      set({ error: error.message || 'Failed to update block order' });
      throw error;
    }
  },

  clearError: () => set({ error: null }),
}));
