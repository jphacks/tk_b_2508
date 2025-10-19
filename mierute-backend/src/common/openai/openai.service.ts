import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import OpenAI from 'openai';
import { TaskPlanningResponseDto, Task } from '../../dto/task-planning.dto';

@Injectable()
export class OpenAIService {
  private openai: OpenAI;

  constructor(private configService: ConfigService) {
    const apiKey = this.configService.get<string>('OPENAI_API_KEY');
    this.openai = new OpenAI({
      apiKey,
    });
  }

  async analyzeImageWithCheckpoint(
    imageUrl: string,
    checkpoint: string,
    achivement: string,
  ): Promise<number> {
    const requestStartTime = new Date().toISOString();
    
    try {
      console.log(`[画像認識開始] ${requestStartTime}`);
      console.log(`画像URL: ${imageUrl}`);
      console.log(`チェックポイント: ${checkpoint}`);
      console.log(`達成条件: ${achivement}`);

      const prompt = `あなたは画像を分析して、指定されたチェックポイントとその達成条件に対してどの程度満たしているかを評価するAIです。

【評価対象】
チェックポイント（目標）: ${checkpoint}
達成条件（具体的な条件）: ${achivement}

【評価手順】
画像を詳しく観察し、以下の手順で評価してください：

1. **画像の状況説明**: この画像で何をしているところなのかを詳しく説明してください

2. **達成条件の確認**: 上記の「達成条件」に記載された具体的な条件が、画像の中でどの程度満たされているかを項目ごとに確認してください

3. **チェックポイント達成度の総合評価**: 達成条件の満たし具合を踏まえて、チェックポイント（目標）がどの程度達成されているかを100点満点で評価してください

4. **最終点数**: 最後に、点数のみを「点数: XX」の形式で必ず出力してください`;

      console.log('OpenAI API呼び出し開始...');

      const response = await this.openai.chat.completions.create({
        model: 'gpt-4o',
        messages: [
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: prompt,
              },
              {
                type: 'image_url',
                image_url: {
                  url: imageUrl,
                },
              },
            ],
          },
        ],
        max_tokens: 500,
      });

      console.log('OpenAI API呼び出し完了');
      console.log('OpenAI使用モデル:', response.model);
      console.log('OpenAI使用トークン数:', response.usage);

      const content = response.choices[0]?.message?.content || '';
      console.log('OpenAI レスポンス内容:');
      console.log(content);

      const scoreMatch = content.match(/点数[：:]\s*(\d+)/);
      if (scoreMatch) {
        const score = parseInt(scoreMatch[1], 10);
        console.log(`抽出されたスコア: ${score}`);
        return score;
      }

      console.error('【スコア抽出失敗】レスポンスからスコアを抽出できませんでした');
      console.error('レスポンス内容:', content);
      const extractError = new Error('Could not extract score from OpenAI response');
      extractError['type'] = 'SCORE_EXTRACTION_ERROR';
      throw extractError;
    } catch (error) {
      console.error('=== 画像認識エラー詳細 ===');
      console.error('エラー発生時刻:', new Date().toISOString());
      console.error('リクエスト開始時刻:', requestStartTime);
      console.error('画像URL:', imageUrl);
      console.error('チェックポイント:', checkpoint);
      console.error('達成条件:', achivement);
      console.error('エラータイプ:', error.constructor.name);
      console.error('エラーメッセージ:', error.message);
      
      if (error.response) {
        console.error('OpenAI APIレスポンスエラー:');
        console.error('ステータス:', error.response.status);
        console.error('ステータステキスト:', error.response.statusText);
        console.error('レスポンスデータ:', error.response.data);
      }
      
      if (error.code) {
        console.error('エラーコード:', error.code);
      }
      
      console.error('スタックトレース:', error.stack);
      console.error('========================');
      
      // エラータイプを保持したまま再スロー
      if (error['type'] === 'SCORE_EXTRACTION_ERROR') {
        throw error;
      }
      
      // OpenAI APIエラーの詳細を含めてスロー
      const apiError = new Error('Failed to analyze image with OpenAI');
      if (error.response) {
        if (error.response.status === 401) {
          apiError.message = 'OpenAI API key authentication failed';
          apiError['type'] = 'AUTH_ERROR';
        } else if (error.response.status === 429) {
          apiError.message = 'OpenAI API rate limit exceeded';
          apiError['type'] = 'RATE_LIMIT_ERROR';
        } else if (error.response.status === 400) {
          apiError.message = 'Invalid image or request format';
          apiError['type'] = 'IMAGE_ACCESS_ERROR';
        }
      } else if (error.code === 'ENOTFOUND' || error.code === 'ETIMEDOUT') {
        apiError.message = 'Network error while connecting to OpenAI';
        apiError['type'] = 'NETWORK_ERROR';
      }
      
      throw apiError;
    }
  }

  async generateTaskPlan(prompt: string): Promise<TaskPlanningResponseDto> {
    const requestStartTime = new Date().toISOString();
    
    try {
      console.log(`[タスクプランニング開始] ${requestStartTime}`);
      console.log(`ユーザープロンプト: ${prompt}`);

      const systemPrompt = `あなたは優秀なプロジェクトマネージャーです。ユーザーから与えられた要求を分析し、実行可能なタスクプランを作成してください。

各タスクについて、以下を生成してください：
- チェックポイント（目標・何を達成したいか）
- アチーブメント（具体的な達成条件・評価基準）

以下の形式でJSONレスポンスを返してください：

{
  "plan": "全体的な計画の説明",
  "summary": "プランの概要説明",
  "totalEstimatedTime": "全体の予想時間",
  "tasks": [
    {
      "id": "task_1",
      "title": "タスクのタイトル",
      "description": "タスクの詳細説明",
      "checkpoint": "このタスクで達成したい目標",
      "achivement": "具体的な完了条件・評価基準",
      "estimatedTime": "予想時間",
      "priority": "high|medium|low",
      "dependencies": ["依存するタスクのID配列"]
    }
  ]
}

以下の点に注意してください：
1. タスクは論理的な順序で並べてください
2. 依存関係を明確にしてください
3. 現実的な時間見積もりを行ってください
4. 優先度を適切に設定してください
5. checkpoint（目標）とachivement（達成条件）を明確に分けてください
6. achivementは後で画像認識で評価できるような具体的な条件にしてください
7. 必ずJSONフォーマットで回答してください`;

      console.log('OpenAI API呼び出し開始 (タスクプランニング)...');

      const response = await this.openai.chat.completions.create({
        model: 'gpt-4o',
        messages: [
          {
            role: 'system',
            content: systemPrompt,
          },
          {
            role: 'user',
            content: prompt,
          },
        ],
        max_tokens: 2000,
        temperature: 0.7,
      });

      console.log('OpenAI API呼び出し完了 (タスクプランニング)');
      console.log('OpenAI使用モデル:', response.model);
      console.log('OpenAI使用トークン数:', response.usage);

      const content = response.choices[0]?.message?.content || '';
      console.log('OpenAI レスポンス内容 (タスクプランニング):');
      console.log(content);
      
      try {
        console.log('JSON解析開始...');
        const jsonMatch = content.match(/\{[\s\S]*\}/);
        if (!jsonMatch) {
          console.error('【JSON抽出失敗】レスポンスにJSONが含まれていません');
          console.error('レスポンス内容:', content);
          throw new Error('No JSON found in response');
        }
        
        console.log('抽出されたJSON文字列:', jsonMatch[0]);
        const parsed = JSON.parse(jsonMatch[0]);
        console.log('JSON解析成功');
        console.log('解析されたデータ:', JSON.stringify(parsed, null, 2));
        
        const result = {
          plan: parsed.plan || '',
          summary: parsed.summary || '',
          totalEstimatedTime: parsed.totalEstimatedTime || '',
          tasks: parsed.tasks || [],
          saved_blocks: [],
          projectId: '',
        };
        
        console.log(`タスクプランニング完了 - ${result.tasks.length}個のタスクを生成`);
        return result;
      } catch (parseError) {
        console.error('=== JSONパースエラー詳細 ===');
        console.error('エラー発生時刻:', new Date().toISOString());
        console.error('リクエスト開始時刻:', requestStartTime);
        console.error('ユーザープロンプト:', prompt);
        console.error('パースエラータイプ:', parseError.constructor.name);
        console.error('パースエラーメッセージ:', parseError.message);
        console.error('OpenAIレスポンス全文:', content);
        console.error('JSON抽出試行結果:', content.match(/\{[\s\S]*\}/));
        console.error('パースエラースタックトレース:', parseError.stack);
        console.error('==========================');
        
        throw new Error('Failed to parse task plan response');
      }
    } catch (error) {
      console.error('=== タスクプランニングエラー詳細 ===');
      console.error('エラー発生時刻:', new Date().toISOString());
      console.error('リクエスト開始時刻:', requestStartTime);
      console.error('ユーザープロンプト:', prompt);
      console.error('エラータイプ:', error.constructor.name);
      console.error('エラーメッセージ:', error.message);
      
      if (error.response) {
        console.error('OpenAI APIレスポンスエラー (タスクプランニング):');
        console.error('ステータス:', error.response.status);
        console.error('ステータステキスト:', error.response.statusText);
        console.error('レスポンスデータ:', error.response.data);
      }
      
      if (error.code) {
        console.error('エラーコード:', error.code);
      }
      
      console.error('スタックトレース:', error.stack);
      console.error('===================================');
      
      throw new Error('Failed to generate task plan with OpenAI');
    }
  }
}
