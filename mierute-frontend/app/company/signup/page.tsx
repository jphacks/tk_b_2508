'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { useAuth } from '@/presentation/hooks/useAuth';
import toast from 'react-hot-toast';

export const dynamic = 'force-dynamic';

export default function CompanySignupPage() {
  const router = useRouter();
  const { signUpCompany, loading } = useAuth();
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    confirmPassword: '',
    company_id: '',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (formData.password !== formData.confirmPassword) {
      toast.error('パスワードが一致しません');
      return;
    }

    if (formData.password.length < 6) {
      toast.error('パスワードは6文字以上で入力してください');
      return;
    }

    try {
      await signUpCompany({
        email: formData.email,
        password: formData.password,
        company_id: formData.company_id,
        name: formData.name,
      });
      toast.success('登録が完了しました');
      router.push('/projects');
    } catch (error) {
      const message = error instanceof Error ? error.message : '登録に失敗しました';
      toast.error(message);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-cyan-50 via-blue-50 to-orange-50 py-12 px-4">
      <div className="bg-white p-8 rounded-2xl shadow-xl w-full max-w-md">
        <div className="mb-8">
          <Link href="/landing" className="text-sm font-medium flex items-center" style={{ color: '#57CAEA' }}>
            <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
            </svg>
            戻る
          </Link>
        </div>

        <div className="text-center mb-8">
          <div className="w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4" style={{ backgroundColor: '#57CAEA20' }}>
            <svg className="w-8 h-8" style={{ color: '#57CAEA' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
            </svg>
          </div>
          <h1 className="text-3xl font-bold text-gray-800 mb-2">
            企業ユーザー新規登録
          </h1>
          <p className="text-gray-600 text-sm">
            企業アカウントを作成してください
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label htmlFor="company_id" className="block text-sm font-medium text-gray-700 mb-1">
              会社ID
            </label>
            <input
              id="company_id"
              name="company_id"
              type="text"
              value={formData.company_id}
              onChange={handleChange}
              required
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:border-transparent"
              style={{ '--tw-ring-color': '#57CAEA' } as React.CSSProperties}
              placeholder="company-12345"
            />
            <p className="mt-1 text-xs text-gray-500">
              会社の管理者から提供されたIDを入力してください
            </p>
          </div>

          <div>
            <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-1">
              名前
            </label>
            <input
              id="name"
              name="name"
              type="text"
              value={formData.name}
              onChange={handleChange}
              required
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:border-transparent"
              style={{ '--tw-ring-color': '#57CAEA' } as React.CSSProperties}
              placeholder="山田太郎"
            />
          </div>

          <div>
            <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">
              メールアドレス
            </label>
            <input
              id="email"
              name="email"
              type="email"
              value={formData.email}
              onChange={handleChange}
              required
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:border-transparent"
              style={{ '--tw-ring-color': '#57CAEA' } as React.CSSProperties}
              placeholder="user@company.com"
            />
          </div>

          <div>
            <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-1">
              パスワード
            </label>
            <input
              id="password"
              name="password"
              type="password"
              value={formData.password}
              onChange={handleChange}
              required
              minLength={6}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:border-transparent"
              style={{ '--tw-ring-color': '#57CAEA' } as React.CSSProperties}
              placeholder="••••••••"
            />
            <p className="mt-1 text-xs text-gray-500">
              6文字以上で入力してください
            </p>
          </div>

          <div>
            <label htmlFor="confirmPassword" className="block text-sm font-medium text-gray-700 mb-1">
              パスワード（確認）
            </label>
            <input
              id="confirmPassword"
              name="confirmPassword"
              type="password"
              value={formData.confirmPassword}
              onChange={handleChange}
              required
              minLength={6}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:border-transparent"
              style={{ '--tw-ring-color': '#57CAEA' } as React.CSSProperties}
              placeholder="パスワードを再入力"
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full text-white py-3 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed font-semibold mt-6"
            style={{ backgroundColor: '#57CAEA' }}
            onMouseEnter={(e) => !loading && (e.currentTarget.style.backgroundColor = '#4AB8D8')}
            onMouseLeave={(e) => !loading && (e.currentTarget.style.backgroundColor = '#57CAEA')}
          >
            {loading ? '登録中...' : '登録'}
          </button>
        </form>

        <p className="mt-6 text-center text-sm text-gray-600">
          既にアカウントをお持ちの方は{' '}
          <Link href="/company/login" className="font-medium" style={{ color: '#57CAEA' }}>
            ログイン
          </Link>
        </p>
      </div>
    </div>
  );
}
