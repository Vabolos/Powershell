# Check if the Active Directory Administrative Center tool is installed
if (Get-Command "dsac.exe" -ErrorAction SilentlyContinue) {
    Write-Host "Opening Active Directory Administrative Center..." -ForegroundColor Green
    Start-Process "dsac.exe"
} else {
    Write-Host "Active Directory Administrative Center (dsac.exe) is not installed or accessible on this system." -ForegroundColor Red
}
