# MIERUTE（ミエルテ）

[![IMAGE ALT TEXT HERE](https://jphacks.com/wp-content/uploads/2025/05/JPHACKS2025_ogp.jpg)](https://www.youtube.com/watch?v=lA9EluZugD8)

Webフロント
https://mierute-frontend.vercel.app/projects

iOSアプリ（TestFlight）
https://testflight.apple.com/join/EPs78pM9

# 製品概要

### 背景（製品開発のきっかけ、課題等）

1. **作成コストの高さ**: 詳細な手順書を作成するには多大な時間と労力が必要
2. **理解の困難さ**: テキストと静止画だけでは、実際の作業内容を正確に理解できない
3. **確実さ担保の難しさ**: マニュアル通り進めていても、ヒューマンエラーは起こり得る

- 家具の組み立てのマニュアルは、パーツとの対応がわかりにくかったり、マニュアル通り進められているか不安になる
- セルフのガソリンスタンドは、車によって給油口を開けるボタンの位置が違うなど、マニュアル化するのが難しい
- 親が子供に洗濯機の使い方を教えたいが、手順をしっかり伝えられない

### 製品説明（具体的な製品の説明）

**MIERUTE**は、**AIによる自動タスク分割**と**リアルタイム進捗確認**を組み合わせた、次世代の手順説明プラットフォームです。

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

1. **マニュアル作成（Web）**: 自然言語を入力すると、最適なマニュアルを自動生成し、ブロック化
2. **QRコード配布**: 作成したマニュアルをQRコード化して配布
3. **作業実行（iOS）**: QRコードをスキャンして手順を表示。カメラで撮影するとVision APIが達成度を自動判定
4. **次ステップへ**: 60点以上で自動的に次のステップへ遷移

### 特長

#### 1. GPT-4oによる自動タスク分割

自然言語で手順を入力するだけで、**AIが最適なブロック構造を自動生成**します。

**実装箇所**: `mierute-backend/src/common/openai/openai.service.ts`

**従来との比較**:
- 従来: 手動で1ステップずつ入力（30分〜1時間）
- MIERUTE: 自然言語入力で自動生成（<30秒）

**RAGの構築**
マニュアルに対して添付資料を追加することで、RAGの構築ができるようになっています。説明したい対象固有の用語や既存の資料などを、簡単に追加することができます。

#### 2. リアルタイム進捗確認

作業者がカメラで現在の状況を撮影すると、**OpenAI Vision APIが画像を解析**し、チェックポイントの達成度を100点満点で自動判定します。

**実装箇所**: `mierute-backend/src/common/openai/openai.service.ts`

**判定基準**:
- **60点以上**: 次のステップへ自動遷移
- **60点未満**: 具体的なフィードバックを提供し、再撮影を促す

#### 3. チャットによる質問

RAGデータを用いたチャットによる、マニュアルに即したチャット質問機能が実装されています。

**実装箇所**: 

#### 4. Metal Shadersによる没入型UI体験

iOSアプリでは、**Metal Shading Language**を活用した先進的なビジュアルエフェクトを実装しています。

**実装ファイル**:
- `MIERUTE/MIERUTE/Shaders/TiltShineShader.metal` - 傾き連動光沢効果（CoreMotion統合）
- `MIERUTE/MIERUTE/Shaders/BorderShineShader.metal` - ボーダー光沢効果（GPU並列処理）
- `MIERUTE/MIERUTE/Shaders/RippleShader.metal` - タッチ波紋エフェクト
- `MIERUTE/MIERUTE/ShaderViewGroup/ShaderPreviewView.swift` - 総合実装

CoreMotionによるデバイス傾き検出と連動し、デバイスを傾けると光が流れる**直感的なフィードバック**を実現しています。

# 解決できること

従来の説明やマニュアルは、説明する側が **どのように言葉や図で伝えたらわかりやすいか** を考える必要があり多くの時間を必要としていましたが、MIERUTEではiOSアプリの実装によってわかりやすい説明の伝え方を実現するため、伝える難しさを大幅に軽減しています。

また、説明される側は、マニュアルを読み解き、正しいかチェックしながら進めていく必要がありました。マニュアルのバージョンが古いと手順が食い違っていたり、図がないことで分かりにくかったり、逆に図があることで分かりにくかったり、といった問題点がありましたが、MIERUTEでは画像認識昨日のおかげで正確かつ理解しやすくマニュアルを進められ、

# 今後の展望

## 機能面

#### 1. iOS Foundation Model Tool Calling

iOS 26以降の**Apple Intelligence**（on-device LLM）を活用し、デバイス上で完結する処理を実現します。

#### 2. エンタープライズ向け機能拡張（toB展開）

**マニュアルマーケットプレイス**:
- 企業が作成したマニュアルを公開・販売
- QRコードでの配布と利用状況トラッキング
- バージョン管理と自動更新

#### 3. 多言語対応
- GPT-4によるマニュアルの自動翻訳
- 音声ガイダンス（Text-to-Speech）

## ビジネス面



# 注力したこと（こだわり等）

* **Clean Architecture徹底実装** - iOS（MVVM）、Web（Domain-Driven Design）、Backend（NestJS Modular）すべてで一貫したアーキテクチャを採用。保守性と拡張性を最大化
* **Metal Shaders統合** - SwiftUIにMetal Shading Languageを直接統合し、CPUオーバーヘッドを最小化。滑らかなアニメーションを実現
* **マルチモーダルAI活用** - GPT-4o（タスク分割）とVision API（画像判定）を適材適所で使い分け、最適なユーザー体験を追求
* **RAG基盤構築** - 将来的なベクトル検索（Embedding）統合を見据えた設計。Firestore上でドキュメント管理を実装
* **実用性重視** - 技術デモに留まらず、製造業・医療・教育現場で即座に実用化できる機能を厳選して実装

# 開発技術

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
