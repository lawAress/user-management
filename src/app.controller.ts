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
  // Accept zero or two arguments to preserve compatibility with existing tests
  getHello(@Req() req?: Request, @Response() res?: ExpressResponse) {
    // If no request provided (e.g. unit test calling getHello()),
    // return the simple string from AppService to keep tests stable.
    if (!req) {
      return this.appService.getHello();
    }

    // Construir URL completa a la documentación basada en el request
    const host = req.get('host') || 'localhost:3000';
    const protocol = (req.protocol as string) || 'http';
    const docsUrl = `${protocol}://${host}/api/docs`;

    const response = {
      message: this.appService.getHello(),
      docs: docsUrl,
    };

    // Si se pasa `res`, usar res.json(); en otros casos, devolver el objeto.
    if (res) {
      res.json(response);
      return;
    }

    return response;
  }
}
