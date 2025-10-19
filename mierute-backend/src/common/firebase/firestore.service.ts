import { Injectable } from '@nestjs/common';
import { FirebaseService } from './service';
import {
  Firestore,
  CollectionReference,
  DocumentReference,
  Query,
  Transaction,
  DocumentSnapshot,
} from 'firebase-admin/firestore';

@Injectable()
export class FirestoreService {
  private db: Firestore;

  constructor(private readonly firebaseService: FirebaseService) {
    this.db = this.firebaseService.admin.firestore();
  }

  // Convert camelCase fields to snake_case for database storage
  private convertToDbFields(data: any): any {
    if (!data || typeof data !== 'object') return data;
    
    const converted = { ...data };
    
    // Convert specific camelCase fields to snake_case
    if (converted.projectId !== undefined) {
      converted.project_id = converted.projectId;
      delete converted.projectId;
    }
    if (converted.companyId !== undefined) {
      converted.company_id = converted.companyId;
      delete converted.companyId;
    }
    if (converted.createdAt !== undefined) {
      converted.created_at = converted.createdAt;
      delete converted.createdAt;
    }
    if (converted.updatedAt !== undefined) {
      converted.updated_at = converted.updatedAt;
      delete converted.updatedAt;
    }
    
    return converted;
  }

  // Convert snake_case fields to camelCase for API responses
  private convertFromDbFields(data: any): any {
    if (!data || typeof data !== 'object') return data;
    
    const converted = { ...data };
    
    // Convert specific snake_case fields to camelCase
    if (converted.project_id !== undefined) {
      converted.projectId = converted.project_id;
      delete converted.project_id;
    }
    if (converted.company_id !== undefined) {
      converted.companyId = converted.company_id;
      delete converted.company_id;
    }
    if (converted.created_at !== undefined) {
      converted.createdAt = converted.created_at;
      delete converted.created_at;
    }
    if (converted.updated_at !== undefined) {
      converted.updatedAt = converted.updated_at;
      delete converted.updated_at;
    }
    
    return converted;
  }

  getCollection(collectionPath: string): CollectionReference {
    return this.db.collection(collectionPath);
  }

  getDocument(collectionPath: string, documentId: string): DocumentReference {
    return this.db.collection(collectionPath).doc(documentId);
  }

  async create(
    collectionPath: string,
    data: any,
    documentId?: string,
  ): Promise<string> {
    const collection = this.getCollection(collectionPath);
    const dbData = this.convertToDbFields({
      ...data,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    });

    if (documentId) {
      await collection.doc(documentId).set(dbData);
      return documentId;
    } else {
      const docRef = await collection.add(dbData);
      return docRef.id;
    }
  }

  async findOne(
    collectionPath: string,
    documentId: string,
  ): Promise<any | null> {
    const doc = await this.getDocument(collectionPath, documentId).get();

    if (!doc.exists) {
      return null;
    }

    const data = doc.data();
    return {
      id: doc.id,
      ...this.convertFromDbFields(data),
    };
  }

  async findAll(
    collectionPath: string,
    options?: {
      limit?: number;
      orderBy?: { field: string; direction?: 'asc' | 'desc' };
      where?: Array<{ field: string; operator: any; value: any }>;
    },
  ): Promise<any[]> {
    let query: Query = this.getCollection(collectionPath);

    if (options?.where) {
      options.where.forEach((condition) => {
        query = query.where(
          condition.field,
          condition.operator,
          condition.value,
        );
      });
    }

    if (options?.orderBy) {
      query = query.orderBy(
        options.orderBy.field,
        options.orderBy.direction || 'asc',
      );
    }

    if (options?.limit) {
      query = query.limit(options.limit);
    }

    const snapshot = await query.get();

    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...this.convertFromDbFields(doc.data()),
    }));
  }

  async update(
    collectionPath: string,
    documentId: string,
    data: any,
  ): Promise<void> {
    const docRef = this.getDocument(collectionPath, documentId);
    const dbData = this.convertToDbFields({
      ...data,
      updated_at: new Date().toISOString(),
    });

    await docRef.update(dbData);
  }

  async delete(collectionPath: string, documentId: string): Promise<void> {
    const docRef = this.getDocument(collectionPath, documentId);
    await docRef.delete();
  }

  async batchWrite(
    operations: Array<{
      type: 'create' | 'update' | 'delete';
      collection: string;
      documentId?: string;
      data?: any;
    }>,
  ): Promise<void> {
    const batch = this.db.batch();

    operations.forEach((op) => {
      const docRef = op.documentId
        ? this.getDocument(op.collection, op.documentId)
        : this.getCollection(op.collection).doc();

      switch (op.type) {
        case 'create':
          batch.set(docRef, this.convertToDbFields({
            ...op.data,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          }));
          break;
        case 'update':
          batch.update(docRef, this.convertToDbFields({
            ...op.data,
            updated_at: new Date().toISOString(),
          }));
          break;
        case 'delete':
          batch.delete(docRef);
          break;
      }
    });

    await batch.commit();
  }

  async runTransaction<T>(
    callback: (transaction: Transaction) => Promise<T>,
  ): Promise<T> {
    return this.db.runTransaction(callback);
  }

  async queryWithPagination(
    collectionPath: string,
    pageSize: number,
    lastDocument?: DocumentSnapshot,
    options?: {
      orderBy?: { field: string; direction?: 'asc' | 'desc' };
      where?: Array<{ field: string; operator: any; value: any }>;
    },
  ): Promise<{
    data: any[];
    lastDoc: DocumentSnapshot | null;
    hasMore: boolean;
  }> {
    let query: Query = this.getCollection(collectionPath);

    if (options?.where) {
      options.where.forEach((condition) => {
        query = query.where(
          condition.field,
          condition.operator,
          condition.value,
        );
      });
    }

    if (options?.orderBy) {
      query = query.orderBy(
        options.orderBy.field,
        options.orderBy.direction || 'asc',
      );
    }

    if (lastDocument) {
      query = query.startAfter(lastDocument);
    }

    query = query.limit(pageSize + 1);

    const snapshot = await query.get();
    const docs = snapshot.docs;

    const hasMore = docs.length > pageSize;
    const data = docs.slice(0, pageSize).map((doc) => ({
      id: doc.id,
      ...this.convertFromDbFields(doc.data()),
    }));

    const lastDoc =
      docs.length > 0 ? docs[Math.min(pageSize - 1, docs.length - 1)] : null;

    return {
      data,
      lastDoc,
      hasMore,
    };
  }
}
