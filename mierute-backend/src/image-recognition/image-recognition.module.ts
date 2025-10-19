import { Module } from '@nestjs/common';
import { ImageRecognitionController } from './image-recognition.controller';
import { FirebaseModule } from '../common/firebase/module';
import { OpenAIModule } from '../common/openai/openai.module';

@Module({
  imports: [FirebaseModule, OpenAIModule],
  controllers: [ImageRecognitionController],
})
export class ImageRecognitionModule {}
