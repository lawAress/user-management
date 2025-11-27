# Script para probar todos los endpoints de la API

$API = "http://localhost:3000"
$user1 = @{
    name = "Juan Pérez"
    email = "juan@example.com"
    password = "Password123!"
}

$user2 = @{
    name = "María García"
    email = "maria@example.com"
    password = "SecurePass456!"
}

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "PRUEBA 1: GET / (Health Check)" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
try {
    $resp = Invoke-WebRequest -Uri "$API/" -Method GET -ErrorAction Stop
    Write-Host "✅ Status: $($resp.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($resp.Content)" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "PRUEBA 2: POST /users (Crear Usuario 1)" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
try {
    $body = $user1 | ConvertTo-Json
    $resp = Invoke-WebRequest -Uri "$API/users" -Method POST `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $body -ErrorAction Stop
    $user1_data = $resp.Content | ConvertFrom-Json
    Write-Host "✅ Status: $($resp.StatusCode)" -ForegroundColor Green
    Write-Host "Usuario creado: $($user1_data | ConvertTo-Json)" -ForegroundColor Green
    $USER1_ID = $user1_data.id
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "PRUEBA 3: POST /users (Crear Usuario 2)" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
try {
    $body = $user2 | ConvertTo-Json
    $resp = Invoke-WebRequest -Uri "$API/users" -Method POST `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $body -ErrorAction Stop
    $user2_data = $resp.Content | ConvertFrom-Json
    Write-Host "✅ Status: $($resp.StatusCode)" -ForegroundColor Green
    Write-Host "Usuario creado: $($user2_data | ConvertTo-Json)" -ForegroundColor Green
    $USER2_ID = $user2_data.id
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "PRUEBA 4: GET /users (Listar Usuarios)" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
try {
    $resp = Invoke-WebRequest -Uri "$API/users" -Method GET -ErrorAction Stop
    Write-Host "✅ Status: $($resp.StatusCode)" -ForegroundColor Green
    $users = $resp.Content | ConvertFrom-Json
    Write-Host "Usuarios encontrados: $($users.Count)" -ForegroundColor Green
    Write-Host "$($users | ConvertTo-Json)" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "PRUEBA 5: GET /users/:id (Obtener Usuario)" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
try {
    $resp = Invoke-WebRequest -Uri "$API/users/$USER1_ID" -Method GET -ErrorAction Stop
    Write-Host "✅ Status: $($resp.StatusCode)" -ForegroundColor Green
    Write-Host "Usuario: $($resp.Content | ConvertFrom-Json | ConvertTo-Json)" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "PRUEBA 6: POST /auth/login (Login Usuario 1)" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
try {
    $loginData = @{
        email = $user1.email
        password = $user1.password
    }
    $body = $loginData | ConvertTo-Json
    $resp = Invoke-WebRequest -Uri "$API/auth/login" -Method POST `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $body -ErrorAction Stop
    $loginResp = $resp.Content | ConvertFrom-Json
    Write-Host "✅ Status: $($resp.StatusCode)" -ForegroundColor Green
    Write-Host "Login exitoso!" -ForegroundColor Green
    Write-Host "Token: $($loginResp.access_token.Substring(0, 20))..." -ForegroundColor Green
    $TOKEN = $loginResp.access_token
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "PRUEBA 7: PATCH /users/:id (Actualizar Usuario)" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
try {
    $updateData = @{
        name = "Juan Pérez Actualizado"
        role = "admin"
    }
    $body = $updateData | ConvertTo-Json
    $resp = Invoke-WebRequest -Uri "$API/users/$USER1_ID" -Method PATCH `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $body -ErrorAction Stop
    Write-Host "✅ Status: $($resp.StatusCode)" -ForegroundColor Green
    Write-Host "Usuario actualizado: $($resp.Content | ConvertFrom-Json | ConvertTo-Json)" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "PRUEBA 8: DELETE /users/:id (Eliminar Usuario 2)" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
try {
    $resp = Invoke-WebRequest -Uri "$API/users/$USER2_ID" -Method DELETE -ErrorAction Stop
    Write-Host "✅ Status: $($resp.StatusCode)" -ForegroundColor Green
    Write-Host "Usuario eliminado correctamente" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "PRUEBA 9: Intentar login con usuario eliminado" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
try {
    $loginData = @{
        email = $user2.email
        password = $user2.password
    }
    $body = $loginData | ConvertTo-Json
    $resp = Invoke-WebRequest -Uri "$API/auth/login" -Method POST `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $body -ErrorAction Stop
    Write-Host "⚠️  Login exitoso (no debería)" -ForegroundColor Yellow
} catch {
    Write-Host "✅ Login rechazado (esperado)" -ForegroundColor Green
    Write-Host "Error: $($_.Exception.Response.StatusCode)" -ForegroundColor Green
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "PRUEBA 10: GET /users (Verificar usuario eliminado)" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
try {
    $resp = Invoke-WebRequest -Uri "$API/users" -Method GET -ErrorAction Stop
    Write-Host "✅ Status: $($resp.StatusCode)" -ForegroundColor Green
    $users = $resp.Content | ConvertFrom-Json
    Write-Host "Usuarios restantes: $($users.Count)" -ForegroundColor Green
    Write-Host "$($users | ConvertTo-Json)" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "✅ PRUEBAS COMPLETADAS" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
