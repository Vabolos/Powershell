# Function to open Group Policy Management Console (GPMC) to Drive Maps
function Open-DriveMapsGPO {
    Write-Host "Opening Group Policy Management Console (GPMC) to Drive Maps..." -ForegroundColor Green

    # Check if the GPMC snap-in is available
    if (-not (Get-Command "gpmc.msc" -ErrorAction SilentlyContinue)) {
        Write-Host "Error: GPMC is not installed on this system." -ForegroundColor Red
        return
    }

    # Open Group Policy Management Console
    Start-Process "gpmc.msc"
    
    Write-Host "Please navigate to 'User Configuration > Preferences > Windows Settings > Drive Maps' to manage drive mappings." -ForegroundColor Yellow
    Pause
}

# Execute the function
Open-DriveMapsGPO
