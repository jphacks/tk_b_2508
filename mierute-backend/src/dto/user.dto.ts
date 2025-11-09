import { IsEmail, IsNotEmpty, IsString, IsOptional, MinLength, IsEnum } from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';

export enum UserType {
  COMPANY = 'company',
  PERSONAL = 'personal',
}

export class CreateUserDto {
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @IsString()
  @IsNotEmpty()
  @MinLength(6)
  password: string;

  @IsString()
  @IsOptional()
  company_id?: string;

  @IsEnum(UserType)
  @IsNotEmpty()
  user_type: UserType;

  @IsString()
  @IsOptional()
  name?: string;
}

export class UpdateUserDto extends PartialType(CreateUserDto) {}

export class UserResponseDto {
  id: string;
  email: string;
  uid: string;
  company_id?: string;
  user_type: UserType;
  name?: string;
  createdAt: string;
  updatedAt: string;
}