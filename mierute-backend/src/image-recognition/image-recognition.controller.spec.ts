import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException, NotFoundException, InternalServerErrorException } from '@nestjs/common';
import { ImageRecognitionController } from './image-recognition.controller';
import { FirestoreService } from '../common/firebase/firestore.service';
import { OpenAIService } from '../common/openai/openai.service';
import { ImageRecognitionRequestDto } from '../dto/image-recognition.dto';

describe('ImageRecognitionController', () => {
  let controller: ImageRecognitionController;
  let firestoreService: jest.Mocked<FirestoreService>;
  let openaiService: jest.Mocked<OpenAIService>;

  const mockBlock = {
    checkpoint: 'データベース設計の完了',
    achivement: 'ER図が作成され、テーブル構造が明確に定義されている',
    projectId: 'test-project-id',
    createdAt: '2024-01-01T00:00:00Z',
    updatedAt: '2024-01-01T00:00:00Z'
  };

  const mockRequest: ImageRecognitionRequestDto = {
    block_id: '7ZlXxDZgBpg2VyicKkMV',
    image_url: 'https://example.com/test-image.jpg'
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ImageRecognitionController],
      providers: [
        {
          provide: FirestoreService,
          useValue: {
            findOne: jest.fn(),
          },
        },
        {
          provide: OpenAIService,
          useValue: {
            analyzeImageWithCheckpoint: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<ImageRecognitionController>(ImageRecognitionController);
    firestoreService = module.get(FirestoreService);
    openaiService = module.get(OpenAIService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('recognizeImage', () => {
    it('should return success response when score >= 60', async () => {
      const mockScore = 85;
      firestoreService.findOne.mockResolvedValue(mockBlock);
      openaiService.analyzeImageWithCheckpoint.mockResolvedValue(mockScore);

      const result = await controller.recognizeImage(mockRequest);

      expect(result).toEqual({
        block_id: mockRequest.block_id,
        score: mockScore,
        status: 'success'
      });
      expect(firestoreService.findOne).toHaveBeenCalledWith('blocks', mockRequest.block_id);
      expect(openaiService.analyzeImageWithCheckpoint).toHaveBeenCalledWith(
        mockRequest.image_url,
        mockBlock.checkpoint,
        mockBlock.achivement
      );
    });

    it('should throw BadRequestException when score < 60', async () => {
      const mockScore = 45;
      firestoreService.findOne.mockResolvedValue(mockBlock);
      openaiService.analyzeImageWithCheckpoint.mockResolvedValue(mockScore);

      await expect(controller.recognizeImage(mockRequest)).rejects.toThrow(BadRequestException);

      expect(firestoreService.findOne).toHaveBeenCalledWith('blocks', mockRequest.block_id);
      expect(openaiService.analyzeImageWithCheckpoint).toHaveBeenCalledWith(
        mockRequest.image_url,
        mockBlock.checkpoint,
        mockBlock.achivement
      );
    });

    it('should throw NotFoundException when block is not found', async () => {
      firestoreService.findOne.mockResolvedValue(null);

      await expect(controller.recognizeImage(mockRequest)).rejects.toThrow(NotFoundException);

      expect(firestoreService.findOne).toHaveBeenCalledWith('blocks', mockRequest.block_id);
      expect(openaiService.analyzeImageWithCheckpoint).not.toHaveBeenCalled();
    });

    it('should throw InternalServerErrorException with AUTH_ERROR when OpenAI throws auth error', async () => {
      firestoreService.findOne.mockResolvedValue(mockBlock);
      const authError = new Error('API key authentication failed');
      authError.message = 'API key authentication failed';
      openaiService.analyzeImageWithCheckpoint.mockRejectedValue(authError);

      await expect(controller.recognizeImage(mockRequest)).rejects.toThrow(InternalServerErrorException);

      try {
        await controller.recognizeImage(mockRequest);
      } catch (error) {
        expect(error.response.error).toBe('AUTH_ERROR');
        expect(error.response.message).toContain('画像認識サービスの認証エラー');
      }
    });

    it('should throw InternalServerErrorException with RATE_LIMIT_ERROR when rate limited', async () => {
      firestoreService.findOne.mockResolvedValue(mockBlock);
      const rateLimitError = new Error('Rate limit exceeded');
      openaiService.analyzeImageWithCheckpoint.mockRejectedValue(rateLimitError);

      await expect(controller.recognizeImage(mockRequest)).rejects.toThrow(InternalServerErrorException);

      try {
        await controller.recognizeImage(mockRequest);
      } catch (error) {
        expect(error.response.error).toBe('RATE_LIMIT_ERROR');
        expect(error.response.message).toContain('一時的に利用できません');
      }
    });

    it('should throw InternalServerErrorException with IMAGE_ACCESS_ERROR when image access fails', async () => {
      firestoreService.findOne.mockResolvedValue(mockBlock);
      const imageError = new Error('Failed to fetch image');
      openaiService.analyzeImageWithCheckpoint.mockRejectedValue(imageError);

      await expect(controller.recognizeImage(mockRequest)).rejects.toThrow(InternalServerErrorException);

      try {
        await controller.recognizeImage(mockRequest);
      } catch (error) {
        expect(error.response.error).toBe('IMAGE_ACCESS_ERROR');
        expect(error.response.message).toContain('指定された画像にアクセスできません');
      }
    });

    it('should throw InternalServerErrorException with SCORE_EXTRACTION_ERROR when score extraction fails', async () => {
      firestoreService.findOne.mockResolvedValue(mockBlock);
      const scoreError = new Error('Could not extract score from response');
      openaiService.analyzeImageWithCheckpoint.mockRejectedValue(scoreError);

      await expect(controller.recognizeImage(mockRequest)).rejects.toThrow(InternalServerErrorException);

      try {
        await controller.recognizeImage(mockRequest);
      } catch (error) {
        expect(error.response.error).toBe('SCORE_EXTRACTION_ERROR');
        expect(error.response.message).toContain('画像の評価結果を正しく処理できませんでした');
      }
    });

    it('should throw InternalServerErrorException with NETWORK_ERROR when network fails', async () => {
      firestoreService.findOne.mockResolvedValue(mockBlock);
      const networkError = new Error('Network timeout');
      openaiService.analyzeImageWithCheckpoint.mockRejectedValue(networkError);

      await expect(controller.recognizeImage(mockRequest)).rejects.toThrow(InternalServerErrorException);

      try {
        await controller.recognizeImage(mockRequest);
      } catch (error) {
        expect(error.response.error).toBe('NETWORK_ERROR');
        expect(error.response.message).toContain('ネットワークエラーが発生しました');
      }
    });

    it('should re-throw BadRequestException and NotFoundException as-is', async () => {
      firestoreService.findOne.mockResolvedValue(mockBlock);
      const badRequestError = new BadRequestException('Invalid request');
      openaiService.analyzeImageWithCheckpoint.mockRejectedValue(badRequestError);

      await expect(controller.recognizeImage(mockRequest)).rejects.toThrow(BadRequestException);

      firestoreService.findOne.mockResolvedValue(null);
      const notFoundError = new NotFoundException('Block not found');
      firestoreService.findOne.mockRejectedValue(notFoundError);

      await expect(controller.recognizeImage(mockRequest)).rejects.toThrow(NotFoundException);
    });

    it('should handle unknown errors with generic error message', async () => {
      firestoreService.findOne.mockResolvedValue(mockBlock);
      const unknownError = new Error('Unknown error');
      openaiService.analyzeImageWithCheckpoint.mockRejectedValue(unknownError);

      await expect(controller.recognizeImage(mockRequest)).rejects.toThrow(InternalServerErrorException);

      try {
        await controller.recognizeImage(mockRequest);
      } catch (error) {
        expect(error.response.error).toBe('UNKNOWN_ERROR');
        expect(error.response.message).toBe('画像認識処理中にエラーが発生しました');
        expect(error.response.details.requestId).toBeDefined();
        expect(error.response.details.timestamp).toBeDefined();
      }
    });
  });
});