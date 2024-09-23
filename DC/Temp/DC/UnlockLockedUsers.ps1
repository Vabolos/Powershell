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

# Get all locked-out users
$LockedOutUsers = Search-ADAccount -LockedOut -UsersOnly

# Filter out disabled users
$ActiveLockedOutUsers = $LockedOutUsers | Where-Object { $_.Enabled -eq $true }

# Initialize a counter for successfully unlocked users
$UnlockedUsers = @()

# Unlock active, locked-out users
foreach ($user in $ActiveLockedOutUsers) {
    try {
        # Attempt to unlock the user
        Unlock-ADAccount -Identity $user
        Write-Host "Unlocked user: $($user.SamAccountName) - $($user.Name)"
        # Add successfully unlocked user to the list (both SAM and Full Name)
        $UnlockedUsers += "$($user.SamAccountName) - $($user.Name)"
    }
    catch {
        Write-Host "Failed to unlock user: $($user.SamAccountName) - $($user.Name) - $_" -ForegroundColor Yellow
    }
}

# Output list and count of unlocked users
$UnlockedUserCount = $UnlockedUsers.Count
Write-Host "`nTotal unlocked users: $UnlockedUserCount"
Write-Host "Unlocked users:"
$UnlockedUsers | ForEach-Object { $_ }

pause
