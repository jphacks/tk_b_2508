import { Injectable, NotFoundException } from '@nestjs/common';
import { FirestoreService } from '../common/firebase/firestore.service';
import { CreateCompanyDto, UpdateCompanyDto, CompanyResponseDto } from '../dto/company.dto';

@Injectable()
export class CompanyService {
  private readonly collectionName = 'companies';

  constructor(private readonly firestoreService: FirestoreService) {}

  async createCompany(createCompanyDto: CreateCompanyDto): Promise<CompanyResponseDto> {
    // 会社作成（管理者用メソッド）
    const companyId = await this.firestoreService.create(
      this.collectionName,
      createCompanyDto,
    );

    const company = await this.firestoreService.findOne(this.collectionName, companyId);
    return this.mapToResponseDto(company);
  }

  async findAllCompanies(): Promise<CompanyResponseDto[]> {
    const companies = await this.firestoreService.findAll(this.collectionName);
    return companies.map(company => this.mapToResponseDto(company));
  }

  async findCompanyById(id: string): Promise<CompanyResponseDto> {
    const company = await this.firestoreService.findOne(this.collectionName, id);

    if (!company) {
      throw new NotFoundException(`会社ID ${id} が見つかりません`);
    }

    return this.mapToResponseDto(company);
  }


  async updateCompany(id: string, updateCompanyDto: UpdateCompanyDto): Promise<CompanyResponseDto> {
    const existingCompany = await this.firestoreService.findOne(this.collectionName, id);

    if (!existingCompany) {
      throw new NotFoundException(`会社ID ${id} が見つかりません`);
    }

    await this.firestoreService.update(this.collectionName, id, updateCompanyDto);

    const updatedCompany = await this.firestoreService.findOne(this.collectionName, id);
    return this.mapToResponseDto(updatedCompany);
  }

  async deleteCompany(id: string): Promise<void> {
    const existingCompany = await this.firestoreService.findOne(this.collectionName, id);

    if (!existingCompany) {
      throw new NotFoundException(`会社ID ${id} が見つかりません`);
    }

    await this.firestoreService.delete(this.collectionName, id);
  }

  private mapToResponseDto(company: any): CompanyResponseDto {
    return {
      id: company.id as string,
      company: company.company as string,
      createdAt: company.createdAt as string,
      updatedAt: company.updatedAt as string,
    };
  }
}