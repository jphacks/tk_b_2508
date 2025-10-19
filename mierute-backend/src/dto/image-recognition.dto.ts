import { IsString, IsNotEmpty, IsUrl } from 'class-validator';

export class ImageRecognitionRequestDto {
  @IsString()
  @IsNotEmpty()
  block_id: string;

  @IsUrl()
  @IsNotEmpty()
  image_url: string;
}

export class ImageRecognitionResponseDto {
  block_id: string;
  score: number;
  status: 'success' | 'fail';
}
