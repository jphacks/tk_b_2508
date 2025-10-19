# Mierute Backend - NestJS with Firestore & Cloud Functions

NestJSフレームワークを使用してFirestoreデータベースとCloud Functionsで動作するバックエンドAPIです。

## セットアップ

### 1. 依存関係のインストール
```bash
npm install
```

### 2. Firebaseプロジェクトのセットアップ

1. [Firebase Console](https://console.firebase.google.com/)で新しいプロジェクトを作成
2. Firestoreデータベースを有効化
3. サービスアカウントキーを生成：
   - プロジェクト設定 → サービスアカウント → 新しい秘密鍵を生成

### 3. 環境変数の設定

`.env.example`をコピーして`.env`を作成し、Firebase認証情報を設定：

```bash
cp .env.example .env
```

`.env`ファイルを編集：
```
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=your-service-account-email
FIREBASE_CREDENTIALS=-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----
PORT=3000
```

### 4. Firebase CLIのインストール

```bash
npm install -g firebase-tools
firebase login
firebase init
```

### 5. プロジェクトIDの設定

`.firebaserc`ファイルを編集して、実際のプロジェクトIDを設定：
```json
{
  "projects": {
    "default": "your-actual-project-id"
  }
}
```

## 開発

### ローカル開発サーバーの起動
```bash
npm run start:dev
```

### Firebaseエミュレータでの開発
```bash
npm run serve
```

## API エンドポイント

### 基本エンドポイント
- `GET /` - ヘルスチェック

### CRUD操作（サンプル：items）
- `POST /items` - 新規アイテム作成
- `GET /items` - 全アイテム取得（クエリ: limit, orderBy）
- `GET /items/:id` - 特定アイテム取得
- `PUT /items/:id` - アイテム更新
- `DELETE /items/:id` - アイテム削除
- `POST /items/batch` - バッチ操作

### リクエスト例

#### アイテム作成
```bash
curl -X POST http://localhost:3000/items \
  -H "Content-Type: application/json" \
  -d '{
    "name": "サンプルアイテム",
    "description": "これはテストアイテムです",
    "price": 1000
  }'
```

#### アイテム一覧取得
```bash
curl http://localhost:3000/items?limit=10&orderBy=name
```

## ビルド

### 通常のビルド
```bash
npm run build
```

### Cloud Functions用ビルド
```bash
npm run build:functions
```

## デプロイ

### 全体のデプロイ（Functions + Firestore Rules）
```bash
npm run deploy
```

### Cloud Functionsのみ
```bash
npm run deploy:functions
```

### Firestore Rulesのみ
```bash
npm run deploy:firestore
```

## プロジェクト構成

```
src/
├── common/
│   └── firebase/        # Firebase関連
│       ├── module.ts    # Firebaseモジュール
│       ├── service.ts   # Firebase Admin初期化
│       └── firestore.service.ts  # Firestore操作
├── dto/                 # データ転送オブジェクト
│   └── sample.dto.ts    # サンプルDTO
├── app.controller.ts    # メインコントローラー
├── app.module.ts        # メインモジュール
├── app.service.ts       # メインサービス
├── index.ts            # Cloud Functionsエントリポイント
└── main.ts             # ローカル開発用エントリポイント
```

## テスト

```bash
# ユニットテスト
npm run test

# E2Eテスト
npm run test:e2e

# テストカバレッジ
npm run test:cov
```

## その他のコマンド

```bash
# コードフォーマット
npm run format

# Lint
npm run lint
```

## 注意事項

- `.env`ファイルは絶対にGitにコミットしないでください
- 本番環境では`firestore.rules`を適切に設定してください
- Cloud Functionsのリージョンを変更する場合は`src/index.ts`を修正してください
