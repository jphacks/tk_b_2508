# MIERUTE - マニュアル作成ツール

Zapierのように、ブロックを直列に組み合わせることでマニュアルのフローを作成できるアプリケーションです。

## 技術スタック

- **フレームワーク**: Next.js 15 (App Router, TypeScript, Turbopack)
- **スタイリング**: Tailwind CSS
- **認証**: Firebase Authentication
- **状態管理**: Zustand
- **HTTPクライアント**: Axios
- **ドラッグ&ドロップ**: @dnd-kit
- **通知**: react-hot-toast

## アーキテクチャ

Clean Architectureを採用しています：

```
/domain          # エンティティ、リポジトリインターフェース、ユースケース
/infrastructure  # Firebase Auth実装、API Client実装、リポジトリ実装
/presentation    # コンポーネント、hooks、stores（Zustand）
/app            # Next.js App Router（画面）
/lib            # 共通ライブラリ（Firebase設定、DI Container等）
```

## セットアップ

### 1. 依存関係のインストール

```bash
npm install
```

### 2. 環境変数の設定

`.env.local.example`をコピーして`.env.local`を作成し、環境変数を設定してください：

```bash
cp .env.local.example .env.local
```

必要な環境変数：

```
# Firebase Configuration
NEXT_PUBLIC_FIREBASE_API_KEY=your_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_auth_domain
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_storage_bucket
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id
NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id

# Backend API
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000/api
```

### 3. 開発サーバーの起動

```bash
npm run dev
```

ブラウザで [http://localhost:3000](http://localhost:3000) を開きます。

### 4. ビルド

```bash
npm run build
```

## 機能

### 認証機能
- ログイン（`/login`）
- サインアップ（`/signup`）
- Firebase Authenticationを使用

### プロジェクト管理
- プロジェクト一覧表示（`/projects`）
- プロジェクト作成・削除

### マニュアル編集
- ブロック追加・編集・削除
- ドラッグ&ドロップでブロックの並び替え
- 自動保存機能

## データ構造

### Company（会社）
```typescript
{
  id: string;
  company: string;       // 会社名
  email: string;         // メールアドレス
  createdAt: Date;
  updatedAt: Date;
}
```

### Project（プロジェクト）
```typescript
{
  id: string;
  name: string;          // プロジェクト名
  blockOrderIds: string[]; // ブロックの順番
  companyId: string;     // 会社ID
  createdAt: Date;
  updatedAt: Date;
}
```

### Block（ブロック）
```typescript
{
  id: string;
  checkpoint: string;    // ブロックの内容
  projectId: string;     // プロジェクトID
  createdAt: Date;
  updatedAt: Date;
}
```

## API仕様

バックエンドAPIは別途作成されていることを前提としています。

### 必要なエンドポイント

#### 認証
- Firebase Authenticationで発行されたIDトークンを`Authorization: Bearer <token>`ヘッダーで送信

#### Company
- `POST /companies` - 会社作成

#### Project
- `GET /projects?companyId={companyId}` - プロジェクト一覧取得
- `GET /projects/{id}` - プロジェクト詳細取得
- `POST /projects` - プロジェクト作成
- `PATCH /projects/{id}` - プロジェクト更新
- `DELETE /projects/{id}` - プロジェクト削除

#### Block
- `GET /blocks?projectId={projectId}` - ブロック一覧取得
- `GET /blocks/{id}` - ブロック詳細取得
- `POST /blocks` - ブロック作成
- `PATCH /blocks/{id}` - ブロック更新
- `DELETE /blocks/{id}` - ブロック削除

## ディレクトリ構造

```
mierute-frontend/
├── app/                      # Next.js App Router
│   ├── layout.tsx           # ルートレイアウト
│   ├── page.tsx             # ホームページ（リダイレクト）
│   ├── login/               # ログイン画面
│   ├── signup/              # サインアップ画面
│   └── projects/            # プロジェクト関連画面
│       ├── page.tsx         # プロジェクト一覧
│       └── [id]/
│           └── edit/        # マニュアル編集画面
├── domain/                  # ドメイン層
│   ├── entities/           # エンティティ
│   ├── repositories/       # リポジトリインターフェース
│   └── usecases/           # ユースケース
├── infrastructure/          # インフラ層
│   └── repositories/       # リポジトリ実装
├── presentation/            # プレゼンテーション層
│   ├── components/         # コンポーネント
│   ├── hooks/              # カスタムフック
│   └── stores/             # Zustand stores
├── lib/                    # 共通ライブラリ
│   ├── firebase.ts         # Firebase設定
│   ├── api-client.ts       # Axiosクライアント
│   └── di-container.ts     # DIコンテナ
└── public/                 # 静的ファイル
```

## 開発時の注意点

1. **Clean Architecture**: 各層の責務を守り、依存関係を正しく保つ
2. **型安全性**: TypeScriptの型を活用し、`any`型の使用を避ける
3. **エラーハンドリング**: すべての非同期処理でエラーハンドリングを実装
4. **状態管理**: Zustandで状態管理を一元化
5. **認証**: Firebase IDトークンを使用してバックエンドAPIと通信
