# DELETE THIS SCRIPT 

# Variables to fill in
$csvFilePath = "C:\test\Greentech-Users-V2.csv"
$domain = "lan.greentechsolutions.nl"
$departmentMapping = @{
    "Finance" = "GL-Finance"
    "Human Resources" = "GL-Human Resources"
    "Marketing" = "GL-Marketing"
    "Operations" = "GL-Operations"
    "Sales" = "GL-Sales"
    # Add more department mappings as needed
}

# Import users from CSV file
$users = Import-Csv -Path $csvFilePath -Delimiter "`t"

foreach ($user in $users) {
    # Extract user data from the CSV row
    $firstName = $user.GivenName
    $middleInitial = $user.MiddleInitial
    $lastName = $user.Surname
    $country = $user.Country
    $zipCode = $user.ZipCode
    $city = $user.City
    $streetAddress = $user.StreetAddress
    $department = $user.Department

    # Generate username based on naming context
    $username = $lastName.Substring(0, 2) + $firstName.Substring(0, 2)
    $originalUsername = $username

    # Check for duplicate usernames
    $suffix = 1
    while (Get-ADUser -Filter "SamAccountName -eq '$username'" -ErrorAction SilentlyContinue) {
        $lastLetter = $username[-1]
        $username = $username.Substring(0, $username.Length - 1) + [char]([int]$lastLetter[0] + $suffix)
        $suffix++
    }

    # Create the user account
    $password = ConvertTo-SecureString -String "Greentechsolution!" -AsPlainText -Force
    $userParams = @{
        SamAccountName = $username
        UserPrincipalName = "$username@$domain"
        Name = "$firstName $middleInitial $lastName"
        GivenName = $firstName
        Surname = $lastName
        Country = "NL"
        PostalCode = $zipCode
        City = $city
        StreetAddress = $streetAddress
        Department = $department
        AccountPassword = $password
        Enabled = $true
        ChangePasswordAtLogon = $false
        Path = "OU=$department,OU=Greentech Users,DC=lan,DC=greentechsolutions,DC=nl"
    }

    foreach ($key in $userParams.Keys) {
        Write-Host "$key : $($userParams[$key])"
    }

    if (![string]::IsNullOrWhiteSpace($username)) {
        try {
            New-ADUser @userParams -Verbose -ErrorAction Stop -ErrorVariable newADUserError
            $newUser = Get-ADUser -Identity $username

            # Add the user to the department security group
            if (![string]::IsNullOrWhiteSpace($department)) {
                $groupName = "GL-$department"
                Write-Host "Group found! $groupName being added to $username rn"
                Add-ADGroupMember -Identity $groupName -Members $newUser -ErrorAction Stop
            } else {
                Write-Host "No department and no group specified"
            }
        } catch {
            Write-Host "Error creating user account for $(username): $($_.Exception.Message)"
            Write-Host "Detailed error: $($newADUserError | Out-String)"
        }
    } else {
        Write-Host "Error: Username is null or empty"
    }
}