import { apiClient } from '@/lib/api-client';
import { User as DomainUser } from '@/domain/entities/User';

// ==========================================
// 型定義
// ==========================================

export interface RegisterRequest {
  email: string;
  password: string;
  name?: string;
}

export interface RegisterCompanyRequest {
  email: string;
  password: string;
  company_id: string;
  name?: string;
}

export interface RegisterResponse {
  token: string;
  user: DomainUser;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  user: DomainUser;
}

// ==========================================
// API Client関数
// ==========================================

export const authApi = {
  /**
   * 新規登録（個人ユーザー）
   * POST /api/auth/register-personal
   */
  register: async (params: RegisterRequest): Promise<RegisterResponse> => {
    const response = await apiClient.post<RegisterResponse>('/auth/register-personal', params);
    return response.data;
  },

  /**
   * 新規登録（会社ユーザー）
   * POST /api/auth/register
   */
  registerCompany: async (params: RegisterCompanyRequest): Promise<RegisterResponse> => {
    const response = await apiClient.post<RegisterResponse>('/auth/register', params);
    return response.data;
  },

  /**
   * ログイン
   * POST /api/auth/login
   */
  login: async (params: LoginRequest): Promise<LoginResponse> => {
    const response = await apiClient.post<LoginResponse>('/auth/login', params);
    return response.data;
  },
};
