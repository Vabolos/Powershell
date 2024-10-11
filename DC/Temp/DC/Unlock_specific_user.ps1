# Function to unlock an AD user account
function Unlock-ADUserAccount {
    param(
        [string]$Username
    )

    try {
        # Import the Active Directory module
        Import-Module ActiveDirectory -ErrorAction Stop

        # Find the user account using the provided username
        $User = Get-ADUser -Filter { SamAccountName -eq $Username } -Properties LockedOut

        if ($User) {
            # Check if the user is locked out
            if ($User.LockedOut -eq $true) {
                # Unlock the user account
                Unlock-ADAccount -Identity $User
                Write-Host "Account for user '$Username' has been unlocked." -ForegroundColor Green
            } else {
                Write-Host "User '$Username' is not locked out." -ForegroundColor Yellow
            }
        } else {
            Write-Host "User '$Username' not found in Active Directory." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
}

# Get the username input from the user
$Username = Read-Host -Prompt "Enter the username to unlock"

# Pause for 2 seconds before calling the function
Start-Sleep -Seconds 2

# Call the function with the input username
Unlock-ADUserAccount -Username $Username

# Pause for 3 seconds after function execution
Pause
