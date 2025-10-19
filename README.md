# MIERUTE（ミエルテ）

[![IMAGE ALT TEXT HERE](https://jphacks.com/wp-content/uploads/2025/05/JPHACKS2025_ogp.jpg)](https://www.youtube.com/watch?v=lA9EluZugD8)

Webフロント
https://mierute-frontend.vercel.app/projects

iOSアプリ（TestFlight）
https://testflight.apple.com/join/EPs78pM9

## 製品概要

### 背景（製品開発のきっかけ、課題等）

誰かに何かを説明する時、その準備にはかなり時間がかかります。
また、説明される時にも、正確に手順を理解するのはとても大変です。

1. **作成コストの高さ**: 詳細な手順書を作成するには多大な時間と労力が必要
2. **理解の困難さ**: テキストと静止画だけでは、実際の作業内容を正確に理解できない

例えば、セルフガソリンスタンドなど、説明がすぐ見られない物も多いです。

### 製品説明（具体的な製品の説明）

**MIERUTE**は、**AIによる自動タスク分割**と**Vision APIによるリアルタイム進捗確認**を組み合わせた、次世代の手順説明プラットフォームです。

**社会実装例**:
- 家具の組み立ては、マニュアル通り進められているか不安なことが多いが、それをチェックしながら確実に組み立てられる
- ガソリンスタンドは、車によって給油口を開けるボタンの位置が違うなど、マニュアル化するのが難しいが、AIとの対話によってどんな人でも使い方がわかる。
- 親が子供に洗濯機の使い方をまとめたマニュアルを作ることで、おてつだいができるようになる。toBだけでなく、個人での利用もしやすいのがこのアプリの長所になる。

#### システム構成

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   iOS Client    │────▶│  Web Frontend   │────▶│    Backend      │
│   (SwiftUI)     │     │    (Next.js)    │     │   (NestJS)      │
│                 │     │                 │     │                 │
│ • Metal Shaders │     │ • DnD UI        │     │ • RAG           │
│ • Camera + CV   │     │ • Block Editor  │     │ • OpenAI API    │
│ • MVVM + Clean  │     │ • Clean Arch    │     │ • Firestore     │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

#### ワークフロー

1. **マニュアル作成（Web）**: 自然言語を入力すると、GPT-4oが最適なタスクプランを自動生成し、ブロック化
2. **QRコード配布**: 作成したマニュアルをQRコード化して配布
3. **作業実行（iOS）**: QRコードをスキャンして手順を表示。カメラで撮影するとVision APIが達成度を自動判定
4. **次ステップへ**: 60点以上で自動的に次のステップへ遷移

### 特長

#### 1. GPT-4oによる自動タスク分割

自然言語で手順を入力するだけで、**AIが最適なブロック構造を自動生成**します。

**実装箇所**: `mierute-backend/src/common/openai/openai.service.ts:142-273`

```typescript
async generateTaskPlan(prompt: string): Promise<TaskPlanningResponseDto> {
  const response = await this.openai.chat.completions.create({
    model: 'gpt-4o',
    messages: [
      {
        role: 'system',
        content: `各タスクについて、以下を生成してください：
          - チェックポイント（目標・何を達成したいか）
          - アチーブメント（具体的な達成条件・評価基準）`
      },
      {
        role: 'user',
        content: prompt
      }
    ]
  });

  // JSONレスポンスをパースしてブロック構造を返す
  return parsed.tasks.map(task => ({
    checkpoint: task.checkpoint,
    achievement: task.achievement,
    estimatedTime: task.estimatedTime
  }));
}
```

**従来との比較**:
- 従来: 手動で1ステップずつ入力（30分〜1時間）
- MIERUTE: 自然言語入力で自動生成（<30秒）

#### 2. Vision APIによるリアルタイム進捗確認

作業者がカメラで現在の状況を撮影すると、**OpenAI Vision APIが画像を解析**し、チェックポイントの達成度を100点満点で自動判定します。

**実装箇所**: `mierute-backend/src/common/openai/openai.service.ts:17-140`

```typescript
async analyzeImageWithCheckpoint(
  imageUrl: string,
  checkpoint: string,
  achievement: string
): Promise<number> {
  const prompt = `
    【評価対象】
    チェックポイント（目標）: ${checkpoint}
    達成条件（具体的な条件）: ${achievement}

    【評価手順】
    1. 画像の状況説明
    2. 達成条件の確認
    3. チェックポイント達成度の総合評価（100点満点）
  `;

  const response = await this.openai.chat.completions.create({
    model: 'gpt-4o',
    messages: [
      {
        role: 'user',
        content: [
          { type: 'text', text: prompt },
          { type: 'image_url', image_url: { url: imageUrl } }
        ]
      }
    ]
  });

  // 正規表現で点数を抽出
  const scoreMatch = content.match(/点数[：:]\s*(\d+)/);
  return parseInt(scoreMatch[1], 10);
}
```

**判定基準**:
- **60点以上**: 次のステップへ自動遷移
- **60点未満**: 具体的なフィードバックを提供し、再撮影を促す

#### 3. Metal Shadersによる没入型UI体験

iOSアプリでは、**Metal Shading Language**を活用した先進的なビジュアルエフェクトを実装しています。

**実装ファイル**:
- `MIERUTE/MIERUTE/Shaders/TiltShineShader.metal` - 傾き連動光沢効果（CoreMotion統合）
- `MIERUTE/MIERUTE/Shaders/BorderShineShader.metal` - ボーダー光沢効果（GPU並列処理）
- `MIERUTE/MIERUTE/Shaders/RippleShader.metal` - タッチ波紋エフェクト

**BorderShineShader.metal**:
```metal
[[ stitchable ]] half4 BorderShine(
    float2 position,
    SwiftUI::Layer layer,
    float time,
    float speed,
    float width,
    float angle
) {
    // GPU上で並列実行されるstitchable関数
    // ガウシアン分布による自然な光の広がりを実現
    float progress = fmod(time * speed, 1.0);
    float distance = calculateBorderDistance(position, layer.size);
    float gaussian = exp(-pow(distance - progress, 2) / (2 * width * width));

    return layer.sample(position) + half4(gaussian * 0.5);
}
```

**統合実装**: `MIERUTE/MIERUTE/ShaderViewGroup/ShaderPreviewView.swift`
```swift
.modifier(RippleEffect(at: origin, trigger: counter))
.tiltShine(tiltOffset: $motionService.tiltOffset, intensity: 0.2, shineWidth: 10)
```

CoreMotionによるデバイス傾き検出と連動し、デバイスを傾けると光が流れる**直感的なフィードバック**を実現しています。

### 解決できること

**社会実装例**:
- 家具の組み立ては、マニュアル通り進められているか不安なことが多いが、それをチェックしながら確実に組み立てられる
- ガソリンスタンドは、車によって給油口を開けるボタンの位置が違うなど、マニュアル化するのが難しいが、AIとの対話によってどんな人でも使い方がわかる。

### 今後の展望

#### 1. iOS Foundation Model Tool Calling

iOS 26以降の**Apple Intelligence**（on-device LLM）を活用し、デバイス上で完結する処理を実現します。

#### 2. エンタープライズ向け機能拡張（toB展開）

**マニュアルマーケットプレイス**:
- 企業が作成したマニュアルを公開・販売
- QRコードでの配布と利用状況トラッキング
- バージョン管理と自動更新

**分析ダッシュボード**:
```typescript
interface AnalyticsDashboard {
    completionRate: number;           // 完了率
    averageTimePerStep: number;       // ステップごとの平均時間
    failedCheckpoints: Checkpoint[];  // よく失敗するポイント
    userFeedback: Feedback[];         // ユーザーフィードバック
}
```

#### 3. 多言語対応
- GPT-4によるマニュアルの自動翻訳
- 音声ガイダンス（Text-to-Speech）

### 注力したこと（こだわり等）

* **Clean Architecture徹底実装** - iOS（MVVM）、Web（Domain-Driven Design）、Backend（NestJS Modular）すべてで一貫したアーキテクチャを採用。保守性と拡張性を最大化
* **Metal Shaders統合** - SwiftUIにMetal Shading Languageを直接統合し、CPUオーバーヘッドを最小化。60FPS以上の滑らかなアニメーションを実現
* **マルチモーダルAI活用** - GPT-4o（タスク分割）とVision API（画像判定）を適材適所で使い分け、最適なユーザー体験を追求
* **RAG基盤構築** - 将来的なベクトル検索（Embedding）統合を見据えた設計。Firestore上でドキュメント管理を実装
* **実用性重視** - 技術デモに留まらず、製造業・医療・教育現場で即座に実用化できる機能を厳選して実装

## 開発技術

### 活用した技術

#### API・データ

* **OpenAI GPT-4o API** - 自然言語からのタスクプラン自動生成
* **OpenAI Vision API** - 画像解析による進捗確認（100点満点評価）
* **Firebase Firestore** - NoSQLデータベース（Company、Project、Block、RAGドキュメント管理）
* **Firebase Authentication** - ユーザー認証
* **Firebase Cloud Storage** - 画像ファイル保存
* **Firebase Cloud Functions** - バックエンドホスティング

#### フレームワーク・ライブラリ・モジュール

**iOS**:
* **SwiftUI** - 宣言的UIフレームワーク
* **Metal Shading Language** - GPU駆動ビジュアルエフェクト
* **CoreMotion** - デバイス傾き検出（Tilt Shine Effect）
* **AVFoundation** - カメラ機能
* **Combine** - リアクティブプログラミング

**Web Frontend**:
* **Next.js 15.5.6** - React Server Components活用
* **React 19** - 最新のReactフレームワーク
* **@dnd-kit** - ドラッグ&ドロップUI実装
* **Zustand** - 軽量状態管理ライブラリ
* **Tailwind CSS 4** - ユーティリティファーストCSS
* **react-pdf** - PDFビューア（RAGドキュメント表示）

**Backend**:
* **NestJS** - TypeScript製エンタープライズフレームワーク
* **TypeScript** - 型安全な開発
* **@nestjs/config** - 環境変数管理
* **multer** - マルチパート/フォームデータ処理（画像アップロード）

#### デバイス

* **iPhone** - iOS 17以降（Metal対応デバイス）
* **カメラ** - Vision API用の画像取得
* **加速度センサー** - Tilt Shine Effect用のデバイス傾き検出

### 独自技術

#### ハッカソンで開発した独自機能・技術

**1. Metal Shading Languageを活用したGPU駆動エフェクト**

SwiftUIに**Metal Shading Languageを直接統合**し、CPUオーバーヘッドを最小化。60FPS以上の滑らかなアニメーションを実現しました。

**実装ファイル**:
* `MIERUTE/MIERUTE/Shaders/BorderShineShader.metal` - ボーダー光沢エフェクト
  * GPU並列処理によるstitchable関数実装
  * ガウシアン分布による自然な光の広がり
  * 任意角度への光の移動をパラメータ化
* `MIERUTE/MIERUTE/Shaders/TiltShineShader.metal` - 傾き連動光沢エフェクト
  * CoreMotion統合による加速度センサー連動
  * デバイスの傾きに応じたリアルタイム光沢変化
* `MIERUTE/MIERUTE/Shaders/RippleShader.metal` - タッチ波紋エフェクト
  * タッチ位置から広がる波紋アニメーション
  * 減衰関数による自然な波紋の消失

**統合実装**: `MIERUTE/MIERUTE/ShaderViewGroup/ShaderPreviewView.swift`
```swift
.modifier(RippleEffect(at: origin, trigger: counter))
.tiltShine(tiltOffset: $motionService.tiltOffset, intensity: 0.2, shineWidth: 10)
```

**技術的新規性**:
- 既存のiOSアプリでは、エフェクトをCoreAnimationやSpriteKitに依存していましたが、MIERUTEでは**Metal Shading Languageを直接SwiftUIに統合**することで、CPUオーバーヘッドを最小化し、60FPS以上の滑らかなアニメーションを実現しています。

---

**2. GPT-4oによる自動タスク分割とVision APIによるマルチモーダル進捗確認**

自然言語入力から**構造化されたタスクプラン**を自動生成し、Vision APIで画像解析による進捗確認を行う統合システムを構築しました。

**実装ファイル**:
* `mierute-backend/src/common/openai/openai.service.ts:142-273` - タスクプラン自動生成
  * GPT-4oに対してシステムプロンプトで「チェックポイント」と「達成条件」を分離したJSON生成を指示
  * 正規表現によるJSONレスポンス抽出
  * エラーハンドリング（パースエラー、API呼び出しエラー）の詳細ログ出力
* `mierute-backend/src/common/openai/openai.service.ts:17-140` - 画像解析による進捗確認
  * Vision APIに画像URLとチェックポイント、達成条件を送信
  * 100点満点での評価を正規表現で抽出
  * 60点以上で次ステップへ自動遷移
---

**3. Clean Architecture徹底実装（iOS、Web、Backend横断）**

3つのプロジェクトすべてでClean Architectureを徹底し、保守性と拡張性を最大化しました。

**iOS (MVVM + Clean Architecture)**:
* `MIERUTE/MIERUTE/CameraViewGroup/CameraViewModel.swift` - MVVM実装
  * `@MainActor`による安全なUI更新
  * `@Published`による状態管理
  * Viewは**レンダリングのみ**に特化
* ディレクトリ構造: `{Feature}ViewGroup/` 配下に View、ViewModel、Components を配置

**Web Frontend (Domain-Driven Design)**:
* `mierute-frontend/domain/` - ドメインロジック層
* `mierute-frontend/infrastructure/` - 外部API呼び出し層
* `mierute-frontend/presentation/` - プレゼンテーション層（Zustand Store）

**Backend (NestJS Modular Architecture)**:
* `mierute-backend/src/block/` - Block機能モジュール
* `mierute-backend/src/rag/` - RAG機能モジュール
* `mierute-backend/src/task-planning/` - タスクプランニング機能モジュール
* `mierute-backend/src/common/` - 共通サービス（Firebase、OpenAI）
