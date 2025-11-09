import { Injectable, UnauthorizedException, BadRequestException, ConflictException, NotFoundException } from '@nestjs/common';
import { FirebaseService } from '../common/firebase/service';
import { CompanyService } from '../company/company.service';
import { UserService } from '../user/user.service';
import { RegisterDto, RegisterPersonalDto, LoginDto, ResetPasswordDto, AuthResponseDto } from '../dto/auth.dto';
import { UserType } from '../dto/user.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly firebaseService: FirebaseService,
    private readonly companyService: CompanyService,
    private readonly userService: UserService,
  ) {}

  async registerPersonal(registerPersonalDto: RegisterPersonalDto): Promise<AuthResponseDto> {
    try {
      // メールアドレスの重複チェック
      const existingUser = await this.userService.findUserByEmail(registerPersonalDto.email);
      if (existingUser) {
        throw new ConflictException('このメールアドレスは既に使用されています');
      }

      // Firebase Authでユーザー作成
      const userRecord = await this.firebaseService.admin
        .auth()
        .createUser({
          email: registerPersonalDto.email,
          password: registerPersonalDto.password,
          emailVerified: false,
          displayName: registerPersonalDto.name,
        });

      // Firestoreにユーザー情報を保存
      const user = await this.userService.createUser({
        email: registerPersonalDto.email,
        password: registerPersonalDto.password, // サービス側で除外される
        user_type: UserType.PERSONAL,
        name: registerPersonalDto.name,
      });

      // ユーザー情報にUIDを紐付け
      await this.userService.updateUserUid(user.id, userRecord.uid);

      // カスタムトークンを生成
      const customToken = await this.firebaseService.admin
        .auth()
        .createCustomToken(userRecord.uid, {
          email: userRecord.email,
          userId: user.id,
          userType: UserType.PERSONAL,
        });

      return {
        token: customToken,
        user: {
          uid: userRecord.uid,
          email: userRecord.email || '',
          name: registerPersonalDto.name,
          user_type: UserType.PERSONAL,
        },
      };
    } catch (error) {
      console.error('Personal registration error:', error);
      
      if (error.status === 409) {
        throw error;
      }
      
      if (error.code === 'auth/email-already-exists') {
        throw new ConflictException('このメールアドレスは既に使用されています');
      }
      
      if (error.code === 'auth/invalid-email') {
        throw new BadRequestException('無効なメールアドレスです');
      }
      
      if (error.code === 'auth/weak-password') {
        throw new BadRequestException('パスワードは6文字以上にしてください');
      }

      throw new BadRequestException('登録に失敗しました: ' + error.message);
    }
  }

  async register(registerDto: RegisterDto): Promise<AuthResponseDto> {
    try {
      // 会社が存在するか確認
      const company = await this.companyService.findCompanyById(registerDto.company_id);
      
      if (!company) {
        throw new NotFoundException('指定された会社IDが見つかりません');
      }

      // メールアドレスの重複チェック
      const existingUser = await this.userService.findUserByEmail(registerDto.email);
      if (existingUser) {
        throw new ConflictException('このメールアドレスは既に使用されています');
      }

      // Firebase Authでユーザー作成
      const userRecord = await this.firebaseService.admin
        .auth()
        .createUser({
          email: registerDto.email,
          password: registerDto.password,
          emailVerified: false,
          displayName: registerDto.name,
        });

      // Firestoreにユーザー情報を保存
      const user = await this.userService.createUser({
        email: registerDto.email,
        password: registerDto.password, // サービス側で除外される
        company_id: registerDto.company_id,
        user_type: UserType.COMPANY,
        name: registerDto.name,
      });

      // ユーザー情報にUIDを紐付け
      await this.userService.updateUserUid(user.id, userRecord.uid);

      // カスタムトークンを生成
      const customToken = await this.firebaseService.admin
        .auth()
        .createCustomToken(userRecord.uid, {
          email: userRecord.email,
          userId: user.id,
          companyId: registerDto.company_id,
        });

      return {
        token: customToken,
        user: {
          uid: userRecord.uid,
          email: userRecord.email || '',
          name: registerDto.name,
          user_type: UserType.COMPANY,
          company_id: registerDto.company_id,
          company_name: company.company,
        },
      };
    } catch (error) {
      console.error('Registration error:', error);
      
      if (error.status === 404 || error.status === 409) {
        throw error;
      }
      
      if (error.code === 'auth/email-already-exists') {
        throw new ConflictException('このメールアドレスは既に使用されています');
      }
      
      if (error.code === 'auth/invalid-email') {
        throw new BadRequestException('無効なメールアドレスです');
      }
      
      if (error.code === 'auth/weak-password') {
        throw new BadRequestException('パスワードは6文字以上にしてください');
      }

      throw new BadRequestException('登録に失敗しました: ' + error.message);
    }
  }

  async login(loginDto: LoginDto): Promise<AuthResponseDto> {
    try {
      // メールアドレスでユーザーを取得
      const userRecord = await this.firebaseService.admin
        .auth()
        .getUserByEmail(loginDto.email);

      // ユーザー情報を取得
      const user = await this.userService.findUserByEmail(loginDto.email);
      
      if (!user) {
        throw new UnauthorizedException('ログイン認証に失敗しました');
      }

      // ユーザータイプに応じて会社情報を取得
      let companyName: string | undefined = undefined;
      if (user.user_type === UserType.COMPANY && user.company_id) {
        const company = await this.companyService.findCompanyById(user.company_id);
        if (!company) {
          throw new UnauthorizedException('会社情報が見つかりません');
        }
        companyName = company.company;
      }

      // カスタムトークンを生成
      const customToken = await this.firebaseService.admin
        .auth()
        .createCustomToken(userRecord.uid, {
          email: userRecord.email,
          userId: user.id,
          userType: user.user_type,
          companyId: user.company_id,
        });

      return {
        token: customToken,
        user: {
          uid: userRecord.uid,
          email: userRecord.email || '',
          name: user.name,
          user_type: user.user_type,
          company_id: user.company_id,
          company_name: companyName,
        },
      };
    } catch (error) {
      console.error('Login error:', error);
      
      if (error.code === 'auth/user-not-found') {
        throw new UnauthorizedException('ユーザーが見つかりません');
      }

      if (error.status === 401) {
        throw error;
      }

      throw new UnauthorizedException('ログイン認証に失敗しました');
    }
  }

  async resetPassword(resetPasswordDto: ResetPasswordDto): Promise<{ message: string }> {
    try {
      // Firebase Authのパスワードリセットリンクを生成
      const link = await this.firebaseService.admin
        .auth()
        .generatePasswordResetLink(resetPasswordDto.email);

      // 実際のアプリケーションでは、ここでメールを送信します
      // 今回はリンクを返すだけにします（実装時は要変更）
      console.log('Password reset link:', link);

      return {
        message: 'パスワードリセットメールを送信しました',
      };
    } catch (error) {
      console.error('Password reset error:', error);
      
      if (error.code === 'auth/user-not-found') {
        throw new BadRequestException('このメールアドレスは登録されていません');
      }

      throw new BadRequestException('パスワードリセットに失敗しました');
    }
  }

  async getProfile(uid: string): Promise<any> {
    try {
      // Firebase Authからユーザー情報を取得
      const userRecord = await this.firebaseService.admin
        .auth()
        .getUser(uid);

      // Firestoreからユーザー情報を取得
      const user = await this.userService.findUserByUid(uid);

      if (!user) {
        throw new UnauthorizedException('ユーザー情報が見つかりません');
      }

      // ユーザータイプに応じて会社情報を取得
      let companyName: string | undefined = undefined;
      if (user.user_type === UserType.COMPANY && user.company_id) {
        const company = await this.companyService.findCompanyById(user.company_id);
        if (!company) {
          throw new UnauthorizedException('会社情報が見つかりません');
        }
        companyName = company.company;
      }

      return {
        uid: userRecord.uid,
        email: userRecord.email,
        emailVerified: userRecord.emailVerified,
        name: user.name,
        userId: user.id,
        userType: user.user_type,
        companyId: user.company_id,
        companyName: companyName,
        createdAt: user.createdAt,
      };
    } catch (error) {
      console.error('Get profile error:', error);
      throw new UnauthorizedException('プロフィール取得に失敗しました');
    }
  }

  async verifyIdToken(idToken: string): Promise<any> {
    try {
      const decodedToken = await this.firebaseService.admin
        .auth()
        .verifyIdToken(idToken);
      return decodedToken;
    } catch (error) {
      console.error('Token verification error:', error);
      throw new UnauthorizedException('無効なトークンです');
    }
  }
}