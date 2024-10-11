# Function to unlock an AD user account
function Unlock-ADUserAccount {
    try {
        # Get the username input from the user
        $Username = Read-Host -Prompt "Enter the username to unlock:"
        
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

    # Pause for 3 seconds before continuing
    Start-Sleep -Seconds 3
}

# Call the function
Unlock-ADUserAccount
