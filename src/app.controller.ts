import { Controller, Get, Req } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import type { Request } from 'express';
import { AppService } from './app.service';

@ApiTags('health')
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  @ApiOperation({ summary: 'Verificar estado de la API' })
  @ApiResponse({
    status: 200,
    description: 'API funcionando correctamente',
    example: 'Welcome to User Management API!',
  })
  getHello(@Req() req: Request) {
    // Construir URL completa a la documentación basada en el request
    const host = req.get('host') || `localhost:3000`;
    const protocol = (req.protocol as string) || 'http';
    const docsUrl = `${protocol}://${host}/api/docs`;

    return {
      message: this.appService.getHello(),
      docs: docsUrl,
    };
  }
}
