import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { FirebaseModule } from './common/firebase/module';
import { ImageRecognitionModule } from './image-recognition/image-recognition.module';
import { ProjectModule } from './project/project.module';
import { BlockModule } from './block/block.module';
import { TaskPlanningModule } from './task-planning/task-planning.module';
import { RagModule } from './rag/rag.module';
import { AuthModule } from './auth/auth.module';
import { CompanyModule } from './company/company.module';
import { UserModule } from './user/user.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    FirebaseModule,
    AuthModule,
    CompanyModule,
    UserModule,
    ImageRecognitionModule,
    ProjectModule,
    BlockModule,
    TaskPlanningModule,
    RagModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
