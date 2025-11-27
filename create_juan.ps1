$body = '{"name":"Admin User","email":"admin@example.com","password":"Admin123456","role":"admin"}'
$response = Invoke-WebRequest -Uri 'http://localhost:3000/users' -Method POST -Headers @{'Content-Type'='application/json'} -Body $body
$user = $response.Content | ConvertFrom-Json

Write-Host "`n========== USUARIO ADMIN CREADO ==========" -ForegroundColor Green
Write-Host "ID: $($user.id)" -ForegroundColor Cyan
Write-Host "Email: $($user.email)" -ForegroundColor White
Write-Host "Nombre: $($user.name)" -ForegroundColor White
Write-Host "Rol: $($user.role)" -ForegroundColor Yellow
Write-Host "Activo: $($user.isActive)" -ForegroundColor White
Write-Host "======================================`n" -ForegroundColor Green
