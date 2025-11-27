import { Controller, Get, Req, Response } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import type { Request, Response as ExpressResponse } from 'express';
import { AppService } from './app.service';

@ApiTags('health')
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  @ApiOperation({ summary: 'Verificar estado de la API y obtener enlace a documentación' })
  @ApiResponse({
    status: 200,
    description: 'API funcionando correctamente con enlace a documentación',
    schema: {
      type: 'object',
      properties: {
        message: { type: 'string' },
        docs: { type: 'string' },
      },
    },
  })
  getHello(@Req() req: Request, @Response() res: ExpressResponse) {
    // Construir URL completa a la documentación basada en el request
    const host = req.get('host') || 'localhost:3000';
    const protocol = (req.protocol as string) || 'http';
    const docsUrl = `${protocol}://${host}/api/docs`;

    const response = {
      message: this.appService.getHello(),
      docs: docsUrl,
    };

    res.json(response);
  }
}
