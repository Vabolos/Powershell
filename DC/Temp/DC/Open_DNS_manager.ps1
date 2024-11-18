# Script to open DNS Manager
Write-Host "Opening DNS Manager..." -ForegroundColor Green

try {
    Start-Process dnsmgmt.msc
    Write-Host "DNS Manager opened successfully." -ForegroundColor Green
} catch {
    Write-Host "Failed to open DNS Manager: $($_.Exception.Message)" -ForegroundColor Red
}
