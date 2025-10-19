import { storage } from '@/lib/firebase';
import { ref, uploadBytes, getDownloadURL, deleteObject } from 'firebase/storage';

export class StorageService {
  async uploadFile(file: File, path: string): Promise<string> {
    if (typeof window === 'undefined') {
      throw new Error('StorageService can only be used on the client side');
    }

    if (!storage) {
      throw new Error('Firebase Storage is not initialized');
    }

    const storageRef = ref(storage, path);
    const snapshot = await uploadBytes(storageRef, file);
    const downloadURL = await getDownloadURL(snapshot.ref);
    return downloadURL;
  }

  async uploadBlockImage(blockId: string, file: File): Promise<string> {
    const timestamp = Date.now();
    const fileName = `${timestamp}_${file.name}`;
    const path = `blocks/${blockId}/images/${fileName}`;
    return this.uploadFile(file, path);
  }

  async uploadRagDocument(projectId: string, file: File): Promise<string> {
    const timestamp = Date.now();
    const fileName = `${timestamp}_${file.name}`;
    const path = `rag_documents/${projectId}/${fileName}`;
    return await this.uploadFile(file, path);
  }

  async deleteFile(url: string): Promise<void> {
    if (typeof window === 'undefined') {
      throw new Error('StorageService can only be used on the client side');
    }

    if (!storage) {
      throw new Error('Firebase Storage is not initialized');
    }

    const storageRef = ref(storage, url);
    await deleteObject(storageRef);
  }
}