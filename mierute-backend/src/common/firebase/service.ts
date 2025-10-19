import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';

@Injectable()
export class FirebaseService {
  private firebaseAdmin: admin.app.App;

  constructor(private readonly configService: ConfigService) {
    const projectId = this.configService.get<string>('APP_PROJECT_ID');
    const clientEmail = this.configService.get<string>('APP_CLIENT_EMAIL');
    const privateKey = this.configService
      .get<string>('APP_PRIVATE_KEY')
      ?.replace(/\\n/g, '\n');

    this.firebaseAdmin = admin.initializeApp({
      credential: admin.credential.cert({
        projectId,
        clientEmail,
        privateKey,
      }),
    });
  }

  get admin() {
    return this.firebaseAdmin;
  }
}
