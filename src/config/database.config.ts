import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import { join } from 'path';

const isPostgres = !!(process.env.DATABASE_URL || process.env.DB_TYPE === 'postgres');

export const databaseConfig: TypeOrmModuleOptions = isPostgres
  ? {
      type: 'postgres',
      url: process.env.DATABASE_URL,
      entities: [join(__dirname, '..', '**', '*.entity{.ts,.js}')],
      synchronize: process.env.NODE_ENV !== 'production',
      // Si necesitas SSL en producción, puedes agregar:
      // extra: { ssl: { rejectUnauthorized: false } },
    }
  : {
      type: 'sqlite',
      database: process.env.SQLITE_DB_PATH ?? join(__dirname, '..', '..', 'database.sqlite'),
      entities: [join(__dirname, '..', '**', '*.entity{.ts,.js}')],
      synchronize: true, // No usar en producción
    };