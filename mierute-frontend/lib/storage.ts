import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { storage } from './firebase';

/**
 * Firebase Storageに画像をアップロードし、ダウンロードURLを取得する
 * @param file アップロードする画像ファイル
 * @param path ストレージ内のパス（例: 'blocks/project-id/image.jpg'）
 * @returns ダウンロードURL
 */
export async function uploadImage(file: File, path: string): Promise<string> {
  if (!storage) {
    throw new Error('Firebase Storage is not initialized');
  }

  // ファイルタイプの検証
  if (!file.type.startsWith('image/')) {
    throw new Error('Only image files are allowed');
  }

  // ファイルサイズの検証（10MB未満）
  const maxSize = 10 * 1024 * 1024; // 10MB
  if (file.size > maxSize) {
    throw new Error('File size must be less than 10MB');
  }

  try {
    const storageRef = ref(storage, path);
    const snapshot = await uploadBytes(storageRef, file);
    const downloadURL = await getDownloadURL(snapshot.ref);
    return downloadURL;
  } catch (error) {
    console.error('Error uploading image:', error);
    throw new Error('Failed to upload image');
  }
}

/**
 * プロジェクトのブロック用画像をアップロード
 * @param file アップロードする画像ファイル
 * @param projectId プロジェクトID
 * @returns ダウンロードURL
 */
export async function uploadBlockImage(file: File, projectId: string): Promise<string> {
  const timestamp = Date.now();
  const fileName = `${timestamp}-${file.name}`;
  const path = `blocks/${projectId}/${fileName}`;
  return uploadImage(file, path);
}
