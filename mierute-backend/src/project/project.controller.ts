import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ProjectService } from './project.service';
import {
  CreateProjectDto,
  UpdateProjectDto,
  ReorderBlocksDto,
  ProjectResponseDto,
} from '../dto/project.dto';

@Controller('api/projects')
export class ProjectController {
  constructor(private readonly projectService: ProjectService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async createProject(
    @Body() createProjectDto: CreateProjectDto,
  ): Promise<ProjectResponseDto> {
    return this.projectService.createProject(createProjectDto);
  }

  @Get()
  async findAllProjects(@Query('companyId') companyId?: string): Promise<ProjectResponseDto[]> {
    if (companyId) {
      return this.projectService.findProjectsByCompanyId(companyId);
    }
    return this.projectService.findAllProjects();
  }

  @Get(':id')
  async findProjectById(@Param('id') id: string): Promise<ProjectResponseDto> {
    return this.projectService.findProjectById(id);
  }

  @Put(':id')
  async updateProject(
    @Param('id') id: string,
    @Body() updateProjectDto: UpdateProjectDto,
  ): Promise<ProjectResponseDto> {
    return this.projectService.updateProject(id, updateProjectDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteProject(@Param('id') id: string): Promise<void> {
    return this.projectService.deleteProject(id);
  }

  @Put(':id/reorder-blocks')
  async reorderBlocks(
    @Param('id') id: string,
    @Body() reorderBlocksDto: ReorderBlocksDto,
  ): Promise<ProjectResponseDto> {
    return this.projectService.reorderBlocks(id, reorderBlocksDto.block_order_ids);
  }
}
