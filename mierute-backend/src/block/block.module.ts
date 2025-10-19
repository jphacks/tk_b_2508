import { Module, forwardRef } from '@nestjs/common';
import { BlockController } from './block.controller';
import { BlockService } from './block.service';
import { FirebaseModule } from '../common/firebase/module';
import { ProjectModule } from '../project/project.module';

@Module({
  imports: [FirebaseModule, forwardRef(() => ProjectModule)],
  controllers: [BlockController],
  providers: [BlockService],
  exports: [BlockService],
})
export class BlockModule {}