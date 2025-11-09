import { Module } from '@nestjs/common';
import { UserService } from './user.service';
import { FirebaseModule } from '../common/firebase/module';

@Module({
  imports: [FirebaseModule],
  providers: [UserService],
  exports: [UserService],
})
export class UserModule {}