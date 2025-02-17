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
    Start-Process powershell -ArgumentList "-File `"$($MyInvocation.MyCommand.Definition)`"" -Verb RunAs
    exit
}

# Get all locked-out users
$LockedOutUsers = Search-ADAccount -LockedOut -UsersOnly

# Filter out disabled users
$ActiveLockedOutUsers = $LockedOutUsers | Where-Object { $_.Enabled -eq $true }

# Check if there are any locked users
if ($ActiveLockedOutUsers.Count -eq 0) {
    Write-Host "No active locked-out users found." -ForegroundColor Yellow
    pause
    return
}

# Add an Index property using Select-Object instead of modifying the original object
$index = 1
$ActiveLockedOutUsers = $ActiveLockedOutUsers | Select-Object @{Name="Index"; Expression={ $script:index; $script:index++ }}, *

# Display the list of locked users with numbers
Write-Host "`nLocked Users:"
$ActiveLockedOutUsers | ForEach-Object {
    Write-Host "$($_.Index). $($_.SamAccountName) - $($_.Name)"
}

# Prompt for unlock method
$choice = Read-Host "`nHow would you like to unlock: [S]pecify/[A]ll"

if ($choice -eq "A") {
    # Unlock all users
    foreach ($user in $ActiveLockedOutUsers) {
        try {
            Unlock-ADAccount -Identity $user.SamAccountName
            Write-Host "Unlocked: $($user.SamAccountName) - $($user.Name)" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to unlock: $($user.SamAccountName) - $($user.Name) - $_" -ForegroundColor Yellow
        }
    }
}
elseif ($choice -eq "S") {
    # Unlock a specific user
    $userIndex = Read-Host "Enter the number of the user to unlock"

    # Convert input to an integer and find the corresponding user
    $selectedUser = $ActiveLockedOutUsers | Where-Object { $_.Index -eq [int]$userIndex }

    if ($selectedUser) {
        try {
            Unlock-ADAccount -Identity $selectedUser.SamAccountName
            Write-Host "Unlocked: $($selectedUser.SamAccountName) - $($selectedUser.Name)" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to unlock: $($selectedUser.SamAccountName) - $($selectedUser.Name) - $_" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "Invalid selection. Please enter a valid number." -ForegroundColor Red
    }
}
else {
    Write-Host "Invalid choice. Exiting..." -ForegroundColor Red
}

pause
