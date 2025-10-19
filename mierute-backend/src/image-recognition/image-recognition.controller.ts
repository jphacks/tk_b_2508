import {
  Controller,
  Post,
  Body,
  BadRequestException,
  NotFoundException,
  InternalServerErrorException,
} from '@nestjs/common';
import {
  ImageRecognitionRequestDto,
  ImageRecognitionResponseDto,
} from '../dto/image-recognition.dto';
import { FirestoreService } from '../common/firebase/firestore.service';
import { OpenAIService } from '../common/openai/openai.service';

@Controller('api')
export class ImageRecognitionController {
  constructor(
    private readonly firestoreService: FirestoreService,
    private readonly openaiService: OpenAIService,
  ) {}

  @Post('image-recognition')
  async recognizeImage(
    @Body() dto: ImageRecognitionRequestDto,
  ): Promise<ImageRecognitionResponseDto> {
    const requestId = `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const requestStartTime = new Date().toISOString();

    console.log(`[画像認識リクエスト開始] ${requestId} at ${requestStartTime}`);
    console.log('リクエストDTO:', JSON.stringify(dto, null, 2));

    try {
      console.log(`[${requestId}] Firestoreからblock情報を取得中...`);
      const block = await this.firestoreService.findOne('blocks', dto.block_id);

      if (!block) {
        console.error(`[${requestId}] Block not found: ${dto.block_id}`);
        throw new NotFoundException('Block not found');
      }

      console.log(`[${requestId}] Block情報取得成功:`, {
        id: dto.block_id,
        checkpoint: block.checkpoint,
        achievement: block.achievement,
        projectId: block.projectId
      });

      const checkpoint = block.checkpoint as string;
      const achievement = block.achievement as string;

      console.log(`[${requestId}] OpenAI画像解析開始...`);
      const score = await this.openaiService.analyzeImageWithCheckpoint(
        dto.image_url,
        checkpoint,
        achievement,
      );

      console.log(`[${requestId}] OpenAI画像解析完了 - スコア: ${score}`);

      const response: ImageRecognitionResponseDto = {
        block_id: dto.block_id,
        score,
        status: score >= 60 ? 'success' : 'fail',
      };

      console.log(`[${requestId}] 最終レスポンス:`, JSON.stringify(response, null, 2));

      if (score >= 60) {
        console.log(`[${requestId}] 成功 - 処理時間: ${Date.now() - new Date(requestStartTime).getTime()}ms`);
        return response;
      } else {
        console.log(`[${requestId}] 失敗 (スコア不足) - 処理時間: ${Date.now() - new Date(requestStartTime).getTime()}ms`);
        throw new BadRequestException(response);
      }
    } catch (error) {
      if (
        error instanceof BadRequestException ||
        error instanceof NotFoundException
      ) {
        console.log(`[${requestId}] 予期されたエラー:`, error.message);
        throw error;
      }

      console.error(`=== 画像認識処理エラー [${requestId}] ===`);
      console.error('エラー発生時刻:', new Date().toISOString());
      console.error('リクエスト開始時刻:', requestStartTime);
      console.error('処理時間:', `${Date.now() - new Date(requestStartTime).getTime()}ms`);
      console.error('リクエストDTO:', JSON.stringify(dto, null, 2));
      console.error('エラータイプ:', error.constructor.name);
      console.error('エラーメッセージ:', error.message);
      console.error('スタックトレース:', error.stack);

      if (error.response) {
        console.error('HTTPレスポンスエラー:', {
          status: error.response.status,
          statusText: error.response.statusText,
          data: error.response.data
        });
      }

      // console.error('====================================');
      
      // エラータイプに応じた具体的なメッセージを返却
      let userMessage = '画像認識処理中にエラーが発生しました';
      let errorType = 'UNKNOWN_ERROR';
      
      if (error.message) {
        if (error.message.includes('API key') || error.message.includes('Unauthorized')) {
          userMessage = '画像認識サービスの認証エラーが発生しました。管理者にお問い合わせください。';
          errorType = 'AUTH_ERROR';
        } else if (error.message.includes('rate limit') || error.message.includes('Rate limit')) {
          userMessage = 'サービスが一時的に利用できません。しばらく待ってから再試行してください。';
          errorType = 'RATE_LIMIT_ERROR';
        } else if (error.message.includes('image') || error.message.includes('fetch')) {
          userMessage = '指定された画像にアクセスできません。URLを確認してください。';
          errorType = 'IMAGE_ACCESS_ERROR';
        } else if (error.message.includes('score') || error.message.includes('extract')) {
          userMessage = '画像の評価結果を正しく処理できませんでした。別の画像でお試しください。';
          errorType = 'SCORE_EXTRACTION_ERROR';
        } else if (error.message.includes('network') || error.message.includes('timeout')) {
          userMessage = 'ネットワークエラーが発生しました。接続を確認してください。';
          errorType = 'NETWORK_ERROR';
        }
      }
      
      throw new InternalServerErrorException({
        statusCode: 500,
        message: userMessage,
        error: errorType,
        details: {
          requestId: requestId,
          timestamp: new Date().toISOString(),
        },
      });
    }
  }
}
