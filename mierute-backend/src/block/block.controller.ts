import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { BlockService } from './block.service';
import { CreateBlockDto, UpdateBlockDto, BlockResponseDto } from '../dto/block.dto';

@Controller('api/blocks')
export class BlockController {
  constructor(private readonly blockService: BlockService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async createBlock(@Body() createBlockDto: CreateBlockDto): Promise<BlockResponseDto> {
    return this.blockService.createBlock(createBlockDto);
  }

  @Get()
  async findAllBlocks(): Promise<BlockResponseDto[]> {
    return this.blockService.findAllBlocks();
  }

  @Get('project/:projectId')
  async findBlocksByProjectId(@Param('projectId') projectId: string): Promise<BlockResponseDto[]> {
    return this.blockService.findBlocksByProjectId(projectId);
  }

  @Get(':id')
  async findBlockById(@Param('id') id: string): Promise<BlockResponseDto> {
    return this.blockService.findBlockById(id);
  }

  @Put(':id')
  async updateBlock(
    @Param('id') id: string,
    @Body() updateBlockDto: UpdateBlockDto,
  ): Promise<BlockResponseDto> {
    return this.blockService.updateBlock(id, updateBlockDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteBlock(@Param('id') id: string): Promise<void> {
    return this.blockService.deleteBlock(id);
  }
}