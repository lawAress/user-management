# Script para crear un usuario de prueba
$API = "http://localhost:3000"

# Datos del usuario
$body = @{
    name = "Admin User"
    email = "admin@example.com"
    password = "Admin123456"
    role = "admin"
} | ConvertTo-Json

Write-Host "Creando usuario en: $API/users" -ForegroundColor Cyan
Write-Host "Datos enviados:" -ForegroundColor Yellow
Write-Host $body -ForegroundColor Gray

try {
    $response = Invoke-WebRequest -Uri "$API/users" -Method POST `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $body
    
    $userData = $response.Content | ConvertFrom-Json
    
    Write-Host "Usuario creado exitosamente!" -ForegroundColor Green
    Write-Host "Datos del usuario:" -ForegroundColor Cyan
    $userData | Format-List
    
    Write-Host "CREDENCIALES:" -ForegroundColor Yellow
    Write-Host "Email: $($userData.email)" -ForegroundColor White
    Write-Host "Contraseña: Admin123456" -ForegroundColor White
    Write-Host "ID: $($userData.id)" -ForegroundColor White
    Write-Host "Rol: $($userData.role)" -ForegroundColor White
}
catch {
    Write-Host "Error al crear usuario: $_" -ForegroundColor Red
}
