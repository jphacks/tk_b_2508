import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { AppService } from './app.service';
import { FirestoreService } from './common/firebase/firestore.service';
import { CreateSampleDto, UpdateSampleDto } from './dto/sample.dto';

@Controller()
export class AppController {
  constructor(
    private readonly appService: AppService,
    private readonly firestoreService: FirestoreService,
  ) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @Post('items')
  async createItem(@Body() createDto: CreateSampleDto) {
    try {
      const id = await this.firestoreService.create('items', createDto);
      return {
        success: true,
        id,
        message: 'Item created successfully',
      };
    } catch (error) {
      throw new HttpException(
        'Failed to create item',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Get('items')
  async getItems(
    @Query('limit') limit?: number,
    @Query('orderBy') orderBy?: string,
  ) {
    try {
      const items = await this.firestoreService.findAll('items', {
        limit: limit ? Number(limit) : 10,
        orderBy: orderBy ? { field: orderBy, direction: 'asc' } : undefined,
      });

      return {
        success: true,
        data: items,
        count: items.length,
      };
    } catch (error) {
      throw new HttpException(
        'Failed to fetch items',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Get('items/:id')
  async getItem(@Param('id') id: string) {
    try {
      const item = await this.firestoreService.findOne('items', id);

      if (!item) {
        throw new HttpException('Item not found', HttpStatus.NOT_FOUND);
      }

      return {
        success: true,
        data: item,
      };
    } catch (error) {
      if (error instanceof HttpException) {
        throw error;
      }
      throw new HttpException(
        'Failed to fetch item',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Put('items/:id')
  async updateItem(
    @Param('id') id: string,
    @Body() updateDto: UpdateSampleDto,
  ) {
    try {
      const existing = await this.firestoreService.findOne('items', id);

      if (!existing) {
        throw new HttpException('Item not found', HttpStatus.NOT_FOUND);
      }

      await this.firestoreService.update('items', id, updateDto);

      return {
        success: true,
        message: 'Item updated successfully',
      };
    } catch (error) {
      if (error instanceof HttpException) {
        throw error;
      }
      throw new HttpException(
        'Failed to update item',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Delete('items/:id')
  async deleteItem(@Param('id') id: string) {
    try {
      const existing = await this.firestoreService.findOne('items', id);

      if (!existing) {
        throw new HttpException('Item not found', HttpStatus.NOT_FOUND);
      }

      await this.firestoreService.delete('items', id);

      return {
        success: true,
        message: 'Item deleted successfully',
      };
    } catch (error) {
      if (error instanceof HttpException) {
        throw error;
      }
      throw new HttpException(
        'Failed to delete item',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Post('items/batch')
  async batchOperations(@Body() operations: any[]) {
    try {
      await this.firestoreService.batchWrite(operations);

      return {
        success: true,
        message: 'Batch operations completed successfully',
      };
    } catch (error) {
      throw new HttpException(
        'Failed to execute batch operations',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }
}
