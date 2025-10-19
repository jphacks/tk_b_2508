import { NestFactory } from '@nestjs/core';
import { ExpressAdapter } from '@nestjs/platform-express';
import express from 'express';
import * as functions from 'firebase-functions';
import { AppModule } from './app.module';

const expressServer = express();

const createFunction = async (expressInstance: express.Application) => {
  const app = await NestFactory.create(
    AppModule,
    new ExpressAdapter(expressInstance),
  );

  app.enableCors({
    origin: true,
    credentials: true,
  });

  await app.init();
};

createFunction(expressServer)
  .then(() => console.log('Cloud Function initialized'))
  .catch((err) => console.error('Cloud Function initialization error', err));

export const api = functions.https.onRequest(expressServer);
