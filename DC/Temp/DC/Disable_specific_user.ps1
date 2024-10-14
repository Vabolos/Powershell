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

# Import the Active Directory module
Import-Module ActiveDirectory

# Function to disable user account
function Disable-User {
    param (
        [string]$UserName
    )

    # Check if the user exists in AD
    $user = Get-ADUser -Filter { SamAccountName -eq $UserName } -Properties Enabled

    if ($user) {
        if (-not $user.Enabled) {
            Write-Host "User account '$UserName' is already disabled." -ForegroundColor Yellow
        } else {
            # Disable the user account
            Disable-ADAccount -Identity $user
            Write-Host "User account '$UserName' has been disabled." -ForegroundColor Green
        }
    } else {
        Write-Host "User account '$UserName' does not exist." -ForegroundColor Red
    }
}

# Main script starts here
$UserName = Read-Host "Enter the username to disable"
Disable-User -UserName $UserName

pause
