import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { FirebaseModule } from './common/firebase/module';
import { ImageRecognitionModule } from './image-recognition/image-recognition.module';
import { ProjectModule } from './project/project.module';
import { BlockModule } from './block/block.module';
import { TaskPlanningModule } from './task-planning/task-planning.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    FirebaseModule,
    ImageRecognitionModule,
    ProjectModule,
    BlockModule,
    TaskPlanningModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
