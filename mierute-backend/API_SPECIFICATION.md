# Mierute Backend API 仕様書

## ベースURL
```
Local: http://localhost:3000
Production: https://us-central1-mierute-c7b7f.cloudfunctions.net/api
```

## 認証
現在、認証は実装されていません。

---

## 1. App Controller

### 1.1 Hello World
```http
GET /
```

**レスポンス:**
```json
"Hello World!"
```

### 1.2 アイテム作成
```http
POST /items
```

**リクエストボディ:**
```json
{
  "name": "string",
  "description": "string"
}
```

**レスポンス:**
```json
{
  "success": true,
  "id": "string",
  "message": "Item created successfully"
}
```

### 1.3 アイテム一覧取得
```http
GET /items?limit=10&orderBy=createdAt
```

**クエリパラメータ:**
- `limit` (optional): 取得件数制限 (default: 10)
- `orderBy` (optional): ソート対象フィールド

**レスポンス:**
```json
{
  "success": true,
  "data": [
    {
      "id": "string",
      "name": "string",
      "description": "string",
      "createdAt": "string",
      "updatedAt": "string"
    }
  ],
  "count": 1
}
```

### 1.4 アイテム取得
```http
GET /items/:id
```

**パスパラメータ:**
- `id`: アイテムID

**レスポンス:**
```json
{
  "success": true,
  "data": {
    "id": "string",
    "name": "string",
    "description": "string",
    "createdAt": "string",
    "updatedAt": "string"
  }
}
```

### 1.5 アイテム更新
```http
PUT /items/:id
```

**パスパラメータ:**
- `id`: アイテムID

**リクエストボディ:**
```json
{
  "name": "string",
  "description": "string"
}
```

**レスポンス:**
```json
{
  "success": true,
  "message": "Item updated successfully"
}
```

### 1.6 アイテム削除
```http
DELETE /items/:id
```

**パスパラメータ:**
- `id`: アイテムID

**レスポンス:**
```json
{
  "success": true,
  "message": "Item deleted successfully"
}
```

### 1.7 バッチ操作
```http
POST /items/batch
```

**リクエストボディ:**
```json
[
  {
    "type": "create|update|delete",
    "collection": "string",
    "documentId": "string",
    "data": {}
  }
]
```

**レスポンス:**
```json
{
  "success": true,
  "message": "Batch operations completed successfully"
}
```

---

## 2. Project Controller

### 2.1 プロジェクト作成
```http
POST /api/projects
```

**リクエストボディ:**
```json
{
  "name": "string",
  "block_order_ids": ["string"],
  "company_id": "string"
}
```

**レスポンス (201 Created):**
```json
{
  "id": "string",
  "name": "string",
  "block_order_ids": ["string"],
  "company_id": "string",
  "createdAt": "string",
  "updatedAt": "string"
}
```

### 2.2 プロジェクト一覧取得
```http
GET /api/projects
```

**レスポンス:**
```json
[
  {
    "id": "string",
    "name": "string",
    "block_order_ids": ["string"],
    "company_id": "string",
    "createdAt": "string",
    "updatedAt": "string"
  }
]
```

### 2.3 プロジェクト取得
```http
GET /api/projects/:id
```

**パスパラメータ:**
- `id`: プロジェクトID

**レスポンス:**
```json
{
  "id": "string",
  "name": "string",
  "block_order_ids": ["string"],
  "company_id": "string",
  "createdAt": "string",
  "updatedAt": "string"
}
```

### 2.4 プロジェクト更新
```http
PUT /api/projects/:id
```

**パスパラメータ:**
- `id`: プロジェクトID

**リクエストボディ:**
```json
{
  "name": "string",
  "block_order_ids": ["string"],
  "company_id": "string"
}
```

**レスポンス:**
```json
{
  "id": "string",
  "name": "string",
  "block_order_ids": ["string"],
  "company_id": "string",
  "createdAt": "string",
  "updatedAt": "string"
}
```

### 2.5 プロジェクト削除
```http
DELETE /api/projects/:id
```

**パスパラメータ:**
- `id`: プロジェクトID

**レスポンス (204 No Content):**
```
(空のレスポンス)
```

---

## 3. Block Controller

### 3.1 ブロック作成
```http
POST /api/blocks
```

**リクエストボディ:**
```json
{
  "checkpoint": "string",
  "achivement": "string",
  "projectId": "string"
}
```

**レスポンス (201 Created):**
```json
{
  "id": "string",
  "checkpoint": "string",
  "achivement": "string",
  "projectId": "string",
  "createdAt": "string",
  "updatedAt": "string"
}
```

### 3.2 ブロック一覧取得
```http
GET /api/blocks
```

**レスポンス:**
```json
[
  {
    "id": "string",
    "checkpoint": "string",
    "achivement": "string",
    "projectId": "string",
    "createdAt": "string",
    "updatedAt": "string"
  }
]
```

### 3.3 プロジェクト別ブロック取得
```http
GET /api/blocks/project/:projectId
```

**パスパラメータ:**
- `projectId`: プロジェクトID

**レスポンス:**
```json
[
  {
    "id": "string",
    "checkpoint": "string",
    "achivement": "string",
    "projectId": "string",
    "createdAt": "string",
    "updatedAt": "string"
  }
]
```

### 3.4 ブロック取得
```http
GET /api/blocks/:id
```

**パスパラメータ:**
- `id`: ブロックID

**レスポンス:**
```json
{
  "id": "string",
  "checkpoint": "string",
  "achivement": "string",
  "projectId": "string",
  "createdAt": "string",
  "updatedAt": "string"
}
```

### 3.5 ブロック更新
```http
PUT /api/blocks/:id
```

**パスパラメータ:**
- `id`: ブロックID

**リクエストボディ:**
```json
{
  "checkpoint": "string",
  "achivement": "string",
  "projectId": "string"
}
```

**レスポンス:**
```json
{
  "id": "string",
  "checkpoint": "string",
  "achivement": "string",
  "projectId": "string",
  "createdAt": "string",
  "updatedAt": "string"
}
```

### 3.6 ブロック削除
```http
DELETE /api/blocks/:id
```

**パスパラメータ:**
- `id`: ブロックID

**レスポンス (204 No Content):**
```
(空のレスポンス)
```

---

## 4. Image Recognition Controller

### 4.1 画像認識
```http
POST /api/image-recognition
```

**リクエストボディ:**
```json
{
  "block_id": "string",
  "image_url": "string"
}
```

**レスポンス (成功時):**
```json
{
  "block_id": "string",
  "score": 85,
  "status": "success"
}
```

**レスポンス (失敗時 - 400 Bad Request):**
```json
{
  "block_id": "string",
  "score": 45,
  "status": "fail"
}
```

**エラーレスポンス:**
- `400 Bad Request`: 画像認識スコアが60未満
- `404 Not Found`: 指定されたblock_idが存在しない
- `500 Internal Server Error`: 画像認識処理エラー

---

## 5. Task Planning Controller

### 5.1 タスクプランニング
```http
POST /api/task-planning
```

**リクエストボディ:**
```json
{
  "prompt": "string",
  "projectId": "string"
}
```

**レスポンス:**
```json
{
  "plan": "全体的な計画の説明",
  "summary": "プランの概要説明",
  "totalEstimatedTime": "40時間",
  "tasks": [
    {
      "id": "task_1",
      "title": "タスクのタイトル",
      "description": "タスクの詳細説明",
      "checkpoint": "このタスクで達成したい目標",
      "achivement": "具体的な完了条件・評価基準",
      "estimatedTime": "4時間",
      "priority": "high",
      "dependencies": []
    }
  ],
  "saved_blocks": [
    {
      "block_id": "generated_block_id",
      "title": "タスクのタイトル",
      "checkpoint": "このタスクで達成したい目標",
      "achivement": "具体的な完了条件・評価基準"
    }
  ],
  "projectId": "string"
}
```

**エラーレスポンス:**
- `500 Internal Server Error`: タスクプランニング処理エラー

---

## 共通エラーレスポンス

### 400 Bad Request
```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "error": "Bad Request"
}
```

### 404 Not Found
```json
{
  "statusCode": 404,
  "message": "Resource not found",
  "error": "Not Found"
}
```

### 500 Internal Server Error
```json
{
  "statusCode": 500,
  "message": "Internal server error",
  "error": "Internal Server Error"
}
```

---

## データモデル

### Company
```typescript
{
  company: string,
  email: string,
  password: string,
  createdAt: string,
  updatedAt: string
}
```

### Project
```typescript
{
  name: string,
  block_order_ids: string[],
  company_id: string,
  createdAt: string,
  updatedAt: string
}
```

### Block
```typescript
{
  checkpoint: string,
  achivement: string,
  projectId: string,
  createdAt: string,
  updatedAt: string
}
```

---

## 使用例

### プロジェクトとタスクプランニングの完全なフロー

1. **プロジェクト作成**
```bash
curl -X POST http://localhost:3000/api/projects \
  -H "Content-Type: application/json" \
  -d '{"name": "新規プロジェクト", "block_order_ids": [], "company_id": "test_company"}'
```

2. **タスクプランニング**
```bash
curl -X POST http://localhost:3000/api/task-planning \
  -H "Content-Type: application/json" \
  -d '{"prompt": "ウェブアプリを作成したい", "projectId": "project_id_from_step1"}'
```

3. **画像認識でタスク評価**
```bash
curl -X POST http://localhost:3000/api/image-recognition \
  -H "Content-Type: application/json" \
  -d '{"block_id": "block_id_from_step2", "image_url": "https://example.com/image.jpg"}'
```

---

## 技術仕様

- **フレームワーク**: NestJS
- **データベース**: Firestore (NoSQL)
- **ホスティング**: Firebase Cloud Functions
- **AI API**: OpenAI GPT-4o
- **バリデーション**: class-validator
- **型安全性**: TypeScript