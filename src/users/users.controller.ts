import { Controller, Get, Post, Body, Patch, Param, Delete, UseInterceptors, ClassSerializerInterceptor, HttpCode, HttpStatus, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags, ApiParam, ApiBody } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('users')
@Controller('users')
@UseInterceptors(ClassSerializerInterceptor) // Para excluir campos con @Exclude()
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Crear un nuevo usuario' })
  @ApiBody({ type: CreateUserDto })
  @ApiResponse({
    status: 201,
    description: 'Usuario creado exitosamente',
    example: {
      id: 1,
      name: 'Juan Pérez',
      email: 'juan@example.com',
      isActive: true,
      role: 'user',
      createdAt: '2025-11-26T10:00:00.000Z',
      updatedAt: '2025-11-26T10:00:00.000Z',
    },
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos o email duplicado' })
  create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto);
  }

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener todos los usuarios' })
  @ApiResponse({
    status: 200,
    description: 'Lista de usuarios obtenida exitosamente',
    example: [
      {
        id: 1,
        name: 'Juan Pérez',
        email: 'juan@example.com',
        isActive: true,
        role: 'user',
        createdAt: '2025-11-26T10:00:00.000Z',
        updatedAt: '2025-11-26T10:00:00.000Z',
      },
    ],
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  findAll() {
    return this.usersService.findAll();
  }

  @Get(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener usuario por ID' })
  @ApiParam({
    name: 'id',
    description: 'ID del usuario',
    example: 1,
  })
  @ApiResponse({
    status: 200,
    description: 'Usuario obtenido exitosamente',
    example: {
      id: 1,
      name: 'Juan Pérez',
      email: 'juan@example.com',
      isActive: true,
      role: 'user',
      createdAt: '2025-11-26T10:00:00.000Z',
      updatedAt: '2025-11-26T10:00:00.000Z',
    },
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 404, description: 'Usuario no encontrado' })
  findOne(@Param('id') id: string) {
    return this.usersService.findOne(+id);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Actualizar usuario por ID' })
  @ApiParam({
    name: 'id',
    description: 'ID del usuario',
    example: 1,
  })
  @ApiBody({ type: UpdateUserDto })
  @ApiResponse({
    status: 200,
    description: 'Usuario actualizado exitosamente',
    example: {
      id: 1,
      name: 'Juan Pérez',
      email: 'juan@example.com',
      isActive: true,
      role: 'user',
      createdAt: '2025-11-26T10:00:00.000Z',
      updatedAt: '2025-11-26T10:00:00.000Z',
    },
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 404, description: 'Usuario no encontrado' })
  update(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto) {
    return this.usersService.update(+id, updateUserDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Eliminar usuario por ID' })
  @ApiParam({
    name: 'id',
    description: 'ID del usuario',
    example: 1,
  })
  @ApiResponse({ status: 204, description: 'Usuario eliminado exitosamente' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 404, description: 'Usuario no encontrado' })
  remove(@Param('id') id: string) {
    return this.usersService.remove(+id);
  }
}