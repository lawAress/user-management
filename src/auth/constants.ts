export const jwtConstants = {
  // En producción, establecer JWT_SECRET y JWT_EXPIRES_IN en variables de entorno
  secret: process.env.JWT_SECRET ?? 'secretKey123456',
  expiresIn: Number(process.env.JWT_EXPIRES_IN ?? 3600), // segundos
};