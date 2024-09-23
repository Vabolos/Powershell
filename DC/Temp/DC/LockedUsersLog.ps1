# Function to check if the script is running with sufficient privileges
function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# If not running as administrator, restart the script with elevated privileges
if (-not (Test-Admin)) {
    Write-Host "Restarting PowerShell with elevated privileges..." -ForegroundColor Green
    # Relaunch PowerShell with 'Run as Administrator' and pass the script as an argument
    Start-Process powershell -ArgumentList "-File `"$($MyInvocation.MyCommand.Definition)`"" -Verb RunAs
    exit
}

$lockedAccounts = Search-ADAccount -LockedOut | ft

if ($lockedAccounts.Count -gt 0) {
    Write-Host "There are locked accounts"
    $lockedWhen = Search-ADAccount -LockedOut |
              Get-ADUser -Properties lockoutTime |
              Select-Object @{Name="User"; Expression = { $_.sAMAccountName.ToUpper() }},
                            @{Name="LockoutTime"; Expression = { ([datetime]::FromFileTime($_.lockoutTime).ToLocalTime()) }},
                            @{Name="UnlockTime"; Expression = { (Get-Date).AddMinutes(0) }} |  # Example to add 10 minutes to current time
              Sort-Object LockoutTime -Descending
    Search-AdAccount -LockedOut | Unlock-ADAccount
    Add-Content -Path C:\_Log\Log.txt -Value $lockedWhen

} else {
    Write-Host "There are no locked accounts"
}

pause