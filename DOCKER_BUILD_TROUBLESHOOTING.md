# Solución de problemas de Docker Build en Koyeb

## Error: "Docker build failed with exit code 1"

Este error indica que el `Dockerfile` no pudo compilarse. Aquí están las soluciones más comunes:

### Causa 1: npm install tarda demasiado (timeout)

**Síntoma**: Build inicia pero se queda "pegado" o falla sin mensaje claro.

**Solución**: Aumentar el timeout en Koyeb:
1. Ve a tu servicio en Koyeb
2. Settings > Build Options > Build timeout
3. Aumenta a 30-45 minutos

### Causa 2: Problemas con dependencias nativas (sqlite3, bcrypt)

**Síntoma**: Error menciona `gyp`, `node-gyp`, `build failed`

**Solución**: El nuevo `Dockerfile` incluye `python3 make g++` para compilar dependencias nativas. Si aún falla:

```dockerfile
# En Dockerfile, asegúrate que esté en el builder:
RUN apk add --no-cache python3 make g++ ca-certificates
```

### Causa 3: package-lock.json corrupto

**Síntoma**: "Cannot find module" o "ERESOLVE"

**Solución**:
```bash
# Localmente
rm package-lock.json
npm install
git add package-lock.json
git commit -m "fix: regenerate package-lock.json"
git push
```

Luego redeploy en Koyeb.

### Causa 4: Memoria insuficiente durante build

**Síntoma**: Build falla sin razón aparente, o "OutOfMemory"

**Solución**: 
- Usar versión más pequeña: cambiar a `node:18-slim` (en lugar de alpine, menos optimizado pero más estable)
- O usar builder multi-stage más eficiente

### Próximos pasos:

1. **Revisa los logs en Koyeb**:
   - Ve a tu servicio → Activity → último build
   - Haz clic en el build fallido para ver logs completos
   - Copia el error específico

2. **Si ves el error**, comparte aquí (la línea exacta donde falla)

3. **Prueba local con Docker** antes de Koyeb:
   ```bash
   docker build -t user-management .
   ```

4. **Si es problema de timeout**: 
   - Koyeb tiene límites en free tier
   - Considera plan de pago o usar builder alternativo

---

## Pasos para diagnosticar:

1. **Haz push de los cambios**:
   ```bash
   git add .
   git commit -m "fix: dockerfile improvements for Koyeb"
   git push origin main
   ```

2. **En Koyeb**: Redeploy manualmente (Settings > Redeploy)

3. **Observa los logs** durante el build:
   - Click en "Watch Build"
   - Copia la línea con error

4. **Comparte el error específico** aquí para ayuda adicional.

