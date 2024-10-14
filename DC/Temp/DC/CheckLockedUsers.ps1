# Function to check if the script is running with sufficient privileges
function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# If not running as administrator, restart the script with elevated privileges
if (-not (Test-Admin)) {
    Write-Host "Restarting PowerShell with elevated privileges..." -ForegroundColor Green
    Start-Sleep -Seconds 1
    # Relaunch PowerShell with 'Run as Administrator' and pass the script as an argument
    Start-Process powershell -ArgumentList "-File `"$($MyInvocation.MyCommand.Definition)`"" -Verb RunAs
    exit
}

Do {
    # Perform the AD account locked-out search
    $lockedOutUsers = Search-ADAccount -LockedOut

    # Check if any locked-out users were found
    if ($lockedOutUsers) {
        Write-Host "Locked-out users:" -ForegroundColor Yellow
        $lockedOutUsers | ForEach-Object {
            Write-Host $_.SamAccountName
        }
    } else {
        Write-Host "There are no users currently locked out." -ForegroundColor Green
    }

    # Ask user if they want to restart or close the script
    $response = Read-Host "Would you like to [R]estart or [C]lose the script?"

    # Clear previous output
    Clear-Host
# Continue the loop if the user chooses 'R', exit if 'C'
} While ($response -eq 'R' -or $response -eq 'r')

# Clear previous output
Clear-Host

Write-Host "Closing the script..."
Start-Sleep -Seconds 1
