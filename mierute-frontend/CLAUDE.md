- Clean Architectureで実装すること。ファイルの分割は細かくすること
- 綺麗なデザインにすること

企画
Zapierのように、ブロックを直列に組み合わせることによりマニュアルのフローを作ることができる。
各テーブルはこんな感じ。

erDiagram

    COMPANY {
        string company "会社名"
        string email "メールアドレス"
        string password
    }

    PROJECT {
        string name "プロジェクト名"
        array block_order_ids "blockの順番"
        reference company_id "会社id"
    }

    BLOCK {
        string checkpoint "Blockの中身"
        reference project_id "projectID"
    }

    %% リレーション
    COMPANY ||--o{ PROJECT : "has"
    PROJECT ||--o{ BLOCK : "contains"


マニュアル作成の画面のイメージはこんな感じ：

|------------|
| 給油高を開く |
|------------|
      |
      +
      |
|------------|
| ガソリンを入れる |
|------------|
      |
      +


こんな感じでブロックが繋がっている。

画面一覧
- ログイン画面
- サインアップ画面
- プロジェクト一覧画面

用語定義
- company
- アカウントとcompanyは一対一。マニュアルを提供する会社。
- project
- マニュアルを一つ持つ。マニュアルとはブロックのつながりのこと
- マニュアルの中でブロックは一列にしか作れない

API設計
認証：firebase Auth（フロントから直接呼び出す）

ノード：テキストインプット

ユーザーインプット、達成条件の言語化

- 画像認識のendpoint

リクエスト

img

block_id

レスポンス

block_id

画像認識判定

- 画像判定してテキストで何してるかを返す
- checkpointとテキストを照らし合わせる
- 画像判定がOKだったらblock_idを返す
- 画像判定がダメだった場合400返す

---

```objectivec
// =========================
// 基本ユーティリティ
// =========================
export type UUID = string & { readonly __brand: "uuid" };
export type ISODateString = string & { readonly __brand: "iso8601" };

export type Id<TName extends string> = UUID & { readonly __entity: TName };

// =========================
// エンティティ（DBレコード）
// =========================
export interface Company {
  id: Id<"company">;
  company: string;        // 会社名
  email: string;          // メールアドレス
  password: string;       // ハッシュを想定
  created_at: ISODateString;
  updated_at: ISODateString;
}

export interface Project {
  id: Id<"project">;
  name: string;                 // プロジェクト名
  company_id: Id<"company">;    // 参照
  block_order_ids: Array<Id<"block">>; // 並び順（BlockのID配列）
  created_at: ISODateString;
  updated_at: ISODateString;
}

export interface Block {
  id: Id<"block">;
  project_id: Id<"project">; // 参照
  checkpoint: string;        // Blockの中身
  created_at: ISODateString;
  updated_at: ISODateString;
}

// =========================
// エラーレスポンス（共通）
// =========================
export interface ApiErrorResponse {
  error: {
    code:
      | "BAD_REQUEST"
      | "UNAUTHORIZED"
      | "FORBIDDEN"
      | "NOT_FOUND"
      | "CONFLICT"
      | "UNPROCESSABLE_ENTITY"
      | "INTERNAL_SERVER_ERROR";
    message: string;
    details?: Record<string, unknown>;
  };
}

// =========================
// 実際のバックエンドAPIエンドポイント
// =========================
// ProjectController:
//   - POST /api/projects
//   - GET /api/projects
//   - GET /api/projects/:id
//   - PUT /api/projects/:id
//   - DELETE /api/projects/:id
//
// BlockController:
//   - POST /api/blocks
//   - GET /api/blocks
//   - GET /api/blocks/project/:projectId
//   - GET /api/blocks/:id
//   - PUT /api/blocks/:id
//   - DELETE /api/blocks/:id

// =========================
// API: Project 作成
// POST /api/projects
// =========================
export interface CreateProjectRequest {
  name: string;
  company_id: Id<"company">;
}

export interface CreateProjectResponse {
  project: Project;
}

// =========================
// API: Project 更新
// PUT /api/projects/:id
// =========================
export interface UpdateProjectRequest {
  name?: string;
  block_order_ids?: Array<Id<"block">>;
}

export interface UpdateProjectResponse {
  project: Project;
}

// =========================
// API: Block 作成
// POST /api/blocks
// 並び挿入も同時に反映
// =========================
export type InsertPosition =
  | { position: "end" }
  | { position: "start" }
  | { position: "index"; index: number }; // 0-based

export interface CreateBlockRequest {
  project_id: Id<"project">;
  checkpoint: string;
  insert?: InsertPosition; // 省略時は末尾扱い
}

export interface CreateBlockResponse {
  block: Block;
  project: Pick<Project, "id" | "block_order_ids" | "updated_at">;
}

// =========================
// API: Block 編集
// PUT /api/blocks/:id
// =========================
export interface EditBlockRequest {
  checkpoint?: string;   // 本文更新
  condition?: string;    // 達成条件更新
  project_id?: Id<"project">; // プロジェクト移動（通常は使わない）
}

export interface EditBlockResponse {
  block: Block;
}

// =========================
// API: Block 削除
// DELETE /api/blocks/:id
// =========================
export interface DeleteBlockResponse {
  message: string;
}

// =========================
// 便利型（フロント向け）
// =========================
/** 特定プロジェクトの並び情報だけ欲しい時 */
export interface ProjectOrderSnapshot {
  project_id: Id<"project">;
  block_order_ids: Array<Id<"block">>;
  updated_at: ISODateString;
}

/** まとめて取得する時のレスポンス例 */
export interface ProjectWithBlocks {
  project: Project;
  blocks: Block[]; // 順序は block_order_ids に従って並べ替え
}

```
