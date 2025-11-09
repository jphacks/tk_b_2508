import { Injectable, NotFoundException, ConflictException, BadRequestException } from '@nestjs/common';
import { FirestoreService } from '../common/firebase/firestore.service';
import { CreateUserDto, UpdateUserDto, UserResponseDto, UserType } from '../dto/user.dto';

@Injectable()
export class UserService {
  private readonly collectionName = 'users';

  constructor(private readonly firestoreService: FirestoreService) {}

  async createUser(createUserDto: CreateUserDto): Promise<UserResponseDto> {
    // メールアドレスの重複チェック
    const existingUser = await this.findUserByEmail(createUserDto.email);
    if (existingUser) {
      throw new ConflictException('このメールアドレスは既に使用されています');
    }

    // ユーザータイプに応じたバリデーション
    if (createUserDto.user_type === UserType.COMPANY && !createUserDto.company_id) {
      throw new BadRequestException('会社ユーザーはcompany_idが必要です');
    }
    if (createUserDto.user_type === UserType.PERSONAL && createUserDto.company_id) {
      throw new BadRequestException('個人ユーザーはcompany_idを持つことができません');
    }

    // パスワードは保存しない（Firebase Authが管理）
    const { password, ...userData } = createUserDto;
    
    const userId = await this.firestoreService.create(
      this.collectionName,
      userData,
    );

    const user = await this.firestoreService.findOne(this.collectionName, userId);
    return this.mapToResponseDto(user);
  }

  async findAllUsers(): Promise<UserResponseDto[]> {
    const users = await this.firestoreService.findAll(this.collectionName);
    return users.map(user => this.mapToResponseDto(user));
  }

  async findUsersByCompanyId(companyId: string): Promise<UserResponseDto[]> {
    const users = await this.firestoreService.findAll(this.collectionName, {
      where: [
        {
          field: 'company_id',
          operator: '==',
          value: companyId,
        },
      ],
    });

    return users.map(user => this.mapToResponseDto(user));
  }

  async findUserById(id: string): Promise<UserResponseDto> {
    const user = await this.firestoreService.findOne(this.collectionName, id);

    if (!user) {
      throw new NotFoundException(`ユーザーID ${id} が見つかりません`);
    }

    return this.mapToResponseDto(user);
  }

  async findUserByEmail(email: string): Promise<UserResponseDto | null> {
    const users = await this.firestoreService.findAll(this.collectionName, {
      where: [
        {
          field: 'email',
          operator: '==',
          value: email,
        },
      ],
    });

    if (users.length === 0) {
      return null;
    }

    return this.mapToResponseDto(users[0]);
  }

  async findUserByUid(uid: string): Promise<UserResponseDto | null> {
    const users = await this.firestoreService.findAll(this.collectionName, {
      where: [
        {
          field: 'uid',
          operator: '==',
          value: uid,
        },
      ],
    });

    if (users.length === 0) {
      return null;
    }

    return this.mapToResponseDto(users[0]);
  }

  async updateUser(id: string, updateUserDto: UpdateUserDto): Promise<UserResponseDto> {
    const existingUser = await this.firestoreService.findOne(this.collectionName, id);

    if (!existingUser) {
      throw new NotFoundException(`ユーザーID ${id} が見つかりません`);
    }

    // パスワードは更新しない（Firebase Authが管理）
    const { password, ...updateData } = updateUserDto;

    // メールアドレスを変更する場合の重複チェック
    if (updateData.email && updateData.email !== existingUser.email) {
      const emailExists = await this.findUserByEmail(updateData.email);
      if (emailExists) {
        throw new ConflictException('このメールアドレスは既に使用されています');
      }
    }

    await this.firestoreService.update(this.collectionName, id, updateData);

    const updatedUser = await this.firestoreService.findOne(this.collectionName, id);
    return this.mapToResponseDto(updatedUser);
  }

  async updateUserUid(userId: string, uid: string): Promise<void> {
    await this.firestoreService.update(this.collectionName, userId, { uid });
  }

  async deleteUser(id: string): Promise<void> {
    const existingUser = await this.firestoreService.findOne(this.collectionName, id);

    if (!existingUser) {
      throw new NotFoundException(`ユーザーID ${id} が見つかりません`);
    }

    await this.firestoreService.delete(this.collectionName, id);
  }

  private mapToResponseDto(user: any): UserResponseDto {
    return {
      id: user.id as string,
      email: user.email as string,
      uid: user.uid as string,
      company_id: user.company_id || undefined,
      user_type: user.user_type as UserType,
      name: user.name || undefined,
      createdAt: user.createdAt as string,
      updatedAt: user.updatedAt as string,
    };
  }
}