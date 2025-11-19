import { createSupabaseBrowserClient } from './auth';

// Storage bucket name
export const STORAGE_BUCKET = 'images';

// Storage folder names
export const STORAGE_FOLDERS = {
  AVATARS: 'avatars',
  ITEMS: 'items',
  MESSAGES: 'messages',
} as const;

// Image constraints
export const IMAGE_CONSTRAINTS = {
  MAX_SIZE_BYTES: 5 * 1024 * 1024, // 5MiB
  MAX_PER_ITEM: 5,
  MAX_PER_MESSAGE: 5,
  ALLOWED_TYPES: ['image/jpeg', 'image/png', 'image/webp'] as const,
} as const;

// Path helper functions
export function getAvatarPath(userId: string, filename: string): string {
  return `${STORAGE_FOLDERS.AVATARS}/${userId}/${filename}`;
}

export function getItemImagePath(
  itemId: string,
  orderIndex: number,
  ext: string = 'jpg'
): string {
  return `${STORAGE_FOLDERS.ITEMS}/${itemId}/${orderIndex}.${ext}`;
}

export function getMessageImagePath(
  messageId: string,
  orderIndex: number,
  ext: string = 'jpg'
): string {
  return `${STORAGE_FOLDERS.MESSAGES}/${messageId}/${orderIndex}.${ext}`;
}

// Get file extension from MIME type
export function getExtensionFromMimeType(mimeType: string): string {
  const mimeToExt: Record<string, string> = {
    'image/jpeg': 'jpg',
    'image/png': 'png',
    'image/webp': 'webp',
  };
  return mimeToExt[mimeType] || 'jpg';
}

// Upload result type
export interface StorageUploadResult {
  path: string;
  url: string;
  error?: string;
}

// Upload a file to storage
export async function uploadFile(
  path: string,
  file: File | Blob
): Promise<StorageUploadResult> {
  const supabase = createSupabaseBrowserClient();
  const { data, error } = await supabase.storage
    .from(STORAGE_BUCKET)
    .upload(path, file, {
      upsert: true,
      contentType: file.type,
    });

  if (error) {
    return {
      path: '',
      url: '',
      error: error.message,
    };
  }

  const {
    data: { publicUrl },
  } = supabase.storage.from(STORAGE_BUCKET).getPublicUrl(data.path);

  return {
    path: data.path,
    url: publicUrl,
  };
}

// Upload an avatar
export async function uploadAvatar(
  userId: string,
  file: File
): Promise<StorageUploadResult> {
  const ext = getExtensionFromMimeType(file.type);
  const path = getAvatarPath(userId, `avatar.${ext}`);
  return uploadFile(path, file);
}

// Upload an item image
export async function uploadItemImage(
  itemId: string,
  orderIndex: number,
  file: File
): Promise<StorageUploadResult> {
  const ext = getExtensionFromMimeType(file.type);
  const path = getItemImagePath(itemId, orderIndex, ext);
  return uploadFile(path, file);
}

// Upload a message image
export async function uploadMessageImage(
  messageId: string,
  orderIndex: number,
  file: File
): Promise<StorageUploadResult> {
  const ext = getExtensionFromMimeType(file.type);
  const path = getMessageImagePath(messageId, orderIndex, ext);
  return uploadFile(path, file);
}

// Delete a file from storage
export async function deleteFile(path: string): Promise<{ error?: string }> {
  const supabase = createSupabaseBrowserClient();
  const { error } = await supabase.storage.from(STORAGE_BUCKET).remove([path]);

  if (error) {
    return { error: error.message };
  }

  return {};
}

// Get a signed URL for a private file (useful for temporary access)
export async function getSignedUrl(
  path: string,
  expiresIn: number = 3600
): Promise<{ url: string; error?: string }> {
  const supabase = createSupabaseBrowserClient();
  const { data, error } = await supabase.storage
    .from(STORAGE_BUCKET)
    .createSignedUrl(path, expiresIn);

  if (error) {
    return { url: '', error: error.message };
  }

  return { url: data.signedUrl };
}

// Get the public URL for a file
export function getPublicUrl(path: string): string {
  const supabase = createSupabaseBrowserClient();
  const {
    data: { publicUrl },
  } = supabase.storage.from(STORAGE_BUCKET).getPublicUrl(path);
  return publicUrl;
}

// Validate file before upload
export function validateImageFile(file: File): {
  valid: boolean;
  error?: string;
} {
  if (file.size > IMAGE_CONSTRAINTS.MAX_SIZE_BYTES) {
    return {
      valid: false,
      error: `File size exceeds maximum of ${IMAGE_CONSTRAINTS.MAX_SIZE_BYTES / 1024 / 1024}MB`,
    };
  }

  if (
    !IMAGE_CONSTRAINTS.ALLOWED_TYPES.includes(
      file.type as (typeof IMAGE_CONSTRAINTS.ALLOWED_TYPES)[number]
    )
  ) {
    return {
      valid: false,
      error: `File type ${file.type} is not allowed. Allowed types: ${IMAGE_CONSTRAINTS.ALLOWED_TYPES.join(', ')}`,
    };
  }

  return { valid: true };
}
