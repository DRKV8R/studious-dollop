# Firebase Setup for ditttto™ DaaS MVP

## Quick Start

### 1. Create Firebase Project
```bash
# Go to https://console.firebase.google.com
# Click "Add project"
# Name: ditttto-daas-mvp
# Enable Google Analytics (optional)
```

### 2. Enable Services
- **Firestore Database** (document store)
- **Cloud Storage** (file storage)
- **Authentication** (optional, for user management)

### 3. Get Credentials
1. Go to Project Settings → Service Accounts
2. Click "Generate New Private Key"
3. Save JSON file as `.env.local` variables:

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-service-account@project.iam.gserviceaccount.com
FIREBASE_STORAGE_BUCKET=your-bucket.appspot.com
```

### 4. Install Firebase Admin SDK
```bash
pnpm add firebase-admin
```

### 5. Create Adapter Layer

**server/firebase.ts** - Standard storage interface:
```typescript
import admin from 'firebase-admin';

admin.initializeApp({
  projectId: process.env.FIREBASE_PROJECT_ID,
  privateKey: process.env.FIREBASE_PRIVATE_KEY,
  clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
});

const db = admin.firestore();
const storage = admin.storage().bucket(process.env.FIREBASE_STORAGE_BUCKET);

// Standard storage interface
export const firebaseStorage = {
  put: async (path: string, data: Buffer, contentType?: string) => {
    const file = storage.file(path);
    await file.save(data, { metadata: { contentType } });
    return { url: `gs://${storage.name}/${path}`, key: path };
  },
  
  get: async (path: string, expiresIn?: number) => {
    const file = storage.file(path);
    const [url] = await file.getSignedUrl({
      version: 'v4',
      action: 'read',
      expires: Date.now() + (expiresIn || 3600) * 1000,
    });
    return { url, key: path };
  },
};

// Standard database interface
export const firebaseDb = {
  set: async (collection: string, doc: string, data: any) => {
    await db.collection(collection).doc(doc).set(data);
  },
  
  get: async (collection: string, doc: string) => {
    const snap = await db.collection(collection).doc(doc).get();
    return snap.data();
  },
  
  query: async (collection: string, where: any) => {
    let q = db.collection(collection);
    Object.entries(where).forEach(([key, value]) => {
      q = q.where(key, '==', value);
    });
    const snap = await q.get();
    return snap.docs.map(d => d.data());
  },
};
```

### 6. Use in tRPC Procedures

```typescript
import { firebaseStorage, firebaseDb } from '@/server/firebase';

export const appRouter = router({
  chat: router({
    save: protectedProcedure
      .input(z.object({ messages: z.array(z.any()) }))
      .mutation(async ({ ctx, input }) => {
        await firebaseDb.set('chats', ctx.user.id, {
          messages: input.messages,
          updatedAt: new Date(),
        });
        return { success: true };
      }),
    
    load: protectedProcedure
      .query(async ({ ctx }) => {
        return await firebaseDb.get('chats', ctx.user.id);
      }),
  }),
});
```

## Benefits
- ✅ Lower latency (GCP native)
- ✅ Standard storage interface (drop-in replacement)
- ✅ Automatic scaling
- ✅ Real-time updates (Firestore)
- ✅ Integrated with GCP ecosystem

## Next Steps
1. Create Firebase project at console.firebase.google.com
2. Add credentials to environment variables
3. Run: `pnpm add firebase-admin`
4. Create server/firebase.ts with adapter code above
5. Wire into tRPC procedures
