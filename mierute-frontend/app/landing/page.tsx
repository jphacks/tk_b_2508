'use client';

import Link from 'next/link';
import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/presentation/hooks/useAuth';

export default function LandingPage() {
  const router = useRouter();
  const { isAuthenticated, isInitialized } = useAuth();

  useEffect(() => {
    if (isInitialized && isAuthenticated) {
      router.push('/projects');
    }
  }, [isAuthenticated, isInitialized, router]);

  return (
    <div className="min-h-screen bg-gradient-to-br from-cyan-50 via-blue-50 to-orange-50">
      {/* Header */}
      <header className="container mx-auto px-6 py-8">
        <div className="flex justify-between items-center">
          <h1 className="text-2xl font-bold" style={{ color: '#57CAEA' }}>MIERUTE</h1>
        </div>
      </header>

      {/* Hero Section */}
      <main className="container mx-auto px-6 py-16">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-5xl font-extrabold text-gray-900 mb-6">
            マニュアル作成を
            <span style={{ color: '#57CAEA' }}>もっとシンプルに</span>
          </h2>
          <p className="text-xl text-gray-600 mb-12">
            ブロックを組み合わせるだけで、わかりやすいマニュアルを簡単に作成できます
          </p>

          {/* CTA Buttons */}
          <div className="grid md:grid-cols-2 gap-8 max-w-3xl mx-auto mb-20">
            {/* Company Card */}
            <div className="bg-white rounded-2xl shadow-lg p-8 border-2 transition-all flex flex-col" style={{ borderColor: '#57CAEA40' }}>
              <div className="flex-grow">
                <div className="w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4" style={{ backgroundColor: '#57CAEA20' }}>
                  <svg className="w-8 h-8" style={{ color: '#57CAEA' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                  </svg>
                </div>
                <h3 className="text-2xl font-bold text-gray-900 mb-2">企業向け</h3>
                <p className="text-gray-600 mb-6 min-h-[3rem]">
                  社内マニュアルの作成・管理・共有をチームで効率化
                </p>
              </div>
              <div className="space-y-3">
                <Link
                  href="/company/login"
                  className="block w-full py-3 px-6 text-white rounded-lg font-semibold transition-colors text-center"
                  style={{ backgroundColor: '#57CAEA' }}
                  onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#4AB8D8'}
                  onMouseLeave={(e) => e.currentTarget.style.backgroundColor = '#57CAEA'}
                >
                  ログイン
                </Link>
                <Link
                  href="/company/signup"
                  className="block w-full py-3 px-6 bg-white rounded-lg font-semibold transition-colors text-center border-2"
                  style={{ color: '#57CAEA', borderColor: '#57CAEA' }}
                  onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#57CAEA10'}
                  onMouseLeave={(e) => e.currentTarget.style.backgroundColor = 'white'}
                >
                  新規登録
                </Link>
              </div>
            </div>

            {/* Personal Card */}
            <div className="bg-white rounded-2xl shadow-lg p-8 border-2 transition-all flex flex-col" style={{ borderColor: '#FF9C4340' }}>
              <div className="flex-grow">
                <div className="w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4" style={{ backgroundColor: '#FF9C4320' }}>
                  <svg className="w-8 h-8" style={{ color: '#FF9C43' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                  </svg>
                </div>
                <h3 className="text-2xl font-bold text-gray-900 mb-2">個人向け</h3>
                <p className="text-gray-600 mb-6 min-h-[3rem]">
                  個人で使える簡単マニュアル作成ツール
                </p>
              </div>
              <div className="space-y-3">
                <Link
                  href="/personal/login"
                  className="block w-full py-3 px-6 text-white rounded-lg font-semibold transition-colors text-center"
                  style={{ backgroundColor: '#FF9C43' }}
                  onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#F08A31'}
                  onMouseLeave={(e) => e.currentTarget.style.backgroundColor = '#FF9C43'}
                >
                  ログイン
                </Link>
                <Link
                  href="/personal/signup"
                  className="block w-full py-3 px-6 bg-white rounded-lg font-semibold transition-colors text-center border-2"
                  style={{ color: '#FF9C43', borderColor: '#FF9C43' }}
                  onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#FF9C4310'}
                  onMouseLeave={(e) => e.currentTarget.style.backgroundColor = 'white'}
                >
                  新規登録
                </Link>
              </div>
            </div>
          </div>

          {/* Features */}
          <div className="grid md:grid-cols-3 gap-8 mt-20">
            <div className="text-center">
              <div className="w-12 h-12 rounded-full flex items-center justify-center mx-auto mb-4" style={{ backgroundColor: '#57CAEA20' }}>
                <svg className="w-6 h-6" style={{ color: '#57CAEA' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
              </div>
              <h4 className="font-bold text-gray-900 mb-2">簡単操作</h4>
              <p className="text-gray-600 text-sm">直感的なブロック操作で誰でも使える</p>
            </div>
            <div className="text-center">
              <div className="w-12 h-12 rounded-full flex items-center justify-center mx-auto mb-4" style={{ backgroundColor: '#57CAEA20' }}>
                <svg className="w-6 h-6" style={{ color: '#57CAEA' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <h4 className="font-bold text-gray-900 mb-2">画像認識</h4>
              <p className="text-gray-600 text-sm">作業の正確性を自動でチェック</p>
            </div>
            <div className="text-center">
              <div className="w-12 h-12 rounded-full flex items-center justify-center mx-auto mb-4" style={{ backgroundColor: '#57CAEA20' }}>
                <svg className="w-6 h-6" style={{ color: '#57CAEA' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
              </div>
              <h4 className="font-bold text-gray-900 mb-2">チーム共有</h4>
              <p className="text-gray-600 text-sm">組織全体でマニュアルを共有</p>
            </div>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="container mx-auto px-6 py-8 mt-20 border-t border-gray-200">
        <p className="text-center text-gray-600 text-sm">
          © 2025 MIERUTE. All rights reserved.
        </p>
      </footer>
    </div>
  );
}
