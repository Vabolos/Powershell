# Script to open Server Manager
Write-Host "Opening Server Manager..." -ForegroundColor Green

try {
    Start-Process ServerManager.exe
    Write-Host "Server Manager opened successfully." -ForegroundColor Green
} catch {
    Write-Host "Failed to open Server Manager: $($_.Exception.Message)" -ForegroundColor Red
}
