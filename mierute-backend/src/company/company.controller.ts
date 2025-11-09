import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
  ForbiddenException,
} from '@nestjs/common';
import { CompanyService } from './company.service';
import { UpdateCompanyDto, CompanyResponseDto } from '../dto/company.dto';
import { FirebaseAuthGuard } from '../common/guards/firebase-auth.guard';

@Controller('api/companies')
@UseGuards(FirebaseAuthGuard)
export class CompanyController {
  constructor(private readonly companyService: CompanyService) {}

  @Get()
  async findAllCompanies(@Request() req): Promise<CompanyResponseDto[]> {
    // 管理者のみアクセス可能にする場合はここで権限チェック
    return this.companyService.findAllCompanies();
  }


  @Get(':id')
  async findCompanyById(@Param('id') id: string): Promise<CompanyResponseDto> {
    return this.companyService.findCompanyById(id);
  }

  @Put(':id')
  async updateCompany(
    @Param('id') id: string,
    @Body() updateCompanyDto: UpdateCompanyDto,
  ): Promise<CompanyResponseDto> {
    // 管理者のみ更新可能にする場合はここで権限チェック
    return this.companyService.updateCompany(id, updateCompanyDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteCompany(@Param('id') id: string): Promise<void> {
    // 管理者のみ削除可能にする場合はここで権限チェック
    return this.companyService.deleteCompany(id);
  }
}