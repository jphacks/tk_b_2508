import {
  Controller,
  Post,
  Get,
  Body,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto, RegisterPersonalDto, LoginDto, ResetPasswordDto, AuthResponseDto } from '../dto/auth.dto';
import { FirebaseAuthGuard } from '../common/guards/firebase-auth.guard';

@Controller('api/auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  async register(@Body() registerDto: RegisterDto): Promise<AuthResponseDto> {
    return this.authService.register(registerDto);
  }

  @Post('register-personal')
  @HttpCode(HttpStatus.CREATED)
  async registerPersonal(@Body() registerPersonalDto: RegisterPersonalDto): Promise<AuthResponseDto> {
    return this.authService.registerPersonal(registerPersonalDto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() loginDto: LoginDto): Promise<AuthResponseDto> {
    return this.authService.login(loginDto);
  }

  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  async resetPassword(@Body() resetPasswordDto: ResetPasswordDto): Promise<{ message: string }> {
    return this.authService.resetPassword(resetPasswordDto);
  }

  @Get('profile')
  @UseGuards(FirebaseAuthGuard)
  async getProfile(@Request() req): Promise<any> {
    return this.authService.getProfile(req.user.uid);
  }

  @Post('verify-token')
  @HttpCode(HttpStatus.OK)
  async verifyToken(@Body('token') token: string): Promise<any> {
    return this.authService.verifyIdToken(token);
  }
}