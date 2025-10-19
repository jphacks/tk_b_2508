# Mierute Backend

- **backend**: NestJS
- **database**: Firestore (NoSQL)
- **hosting**: Firebase Cloud Functions

### COMPANY 
```typescript
{
  company: string, 
  email: string,      
  password: string,  
  createdAt: string,
  updatedAt: string   
}
```

### PROJECT
```
{
  name: string,                 
  block_order_ids: string[],    
  company_id: reference,
  createdAt: string,        
  updatedAt: string             
}
```

### BLOCK 
```typescript
{
  checkpoint: string,
  achivement: string,  
  projectId: reference,
  img_url?: string,       // 画像URL（オプショナル）
  createdAt: string,      
  updatedAt: string      
}
```

### Firestore (firestore.service.ts)
- `create()` 
- `findOne()`
- `findAll()`
- `update()`
- `delete()`
- `batchWrite()`
- `runTransaction()`
- `queryWithPagination()` 
