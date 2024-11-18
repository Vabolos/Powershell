# Script to open DHCP Manager
Write-Host "Opening DHCP Manager..." -ForegroundColor Green

try {
    Start-Process dhcpmgmt.msc
    Write-Host "DHCP Manager opened successfully." -ForegroundColor Green
} catch {
    Write-Host "Failed to open DHCP Manager: $($_.Exception.Message)" -ForegroundColor Red
}
