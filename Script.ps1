# Failsafe function to stop the script
function Stop-Script {
    Write-Host "An error occurred. Script stopped." -ForegroundColor Red
    Exit
}

# Step 1: Create a new folder on the desktop
try {
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $newFolderPath = Join-Path $desktopPath "MyFolder"
    New-Item -ItemType Directory -Path $newFolderPath -ErrorAction Stop
}
catch {
    Write-Host "Failed to create new folder. Error: $_" -ForegroundColor Red
    Stop-Script
}

# Step 2: Create a new file in the new folder
try {
    $fileContent = "This is a test file."
    $file = Join-Path $newFolderPath "test.txt"
    Set-Content -Path $file -Value $fileContent -ErrorAction Stop
}
catch {
    Write-Host "Failed to create new file. Error: $_" -ForegroundColor Red
    Stop-Script
}

# Step 3: Copy files from C:\Temp to the new folder
try {
    $sourceFolderPath = "C:\Temp"
    Copy-Item -Path $sourceFolderPath\* -Destination $newFolderPath -ErrorAction Stop
}
catch {
    Write-Host "Failed to copy files. Error: $_" -ForegroundColor Red
    Stop-Script
}

# Step 4: Rename all files in the new folder
try {
    $i = 1
    Get-ChildItem -Path $newFolderPath | ForEach-Object {
        $newName = "New_" + $i + "_" + $_.Name
        Rename-Item -Path $_.FullName -NewName $newName -ErrorAction Stop
        $i++
    }
}
catch {
    Write-Host "Failed to rename files. Error: $_" -ForegroundColor Red
    Stop-Script
}

# Step 5: Modify file permissions
try {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($identity.Name, "FullControl", "Allow")
    $acl = Get-Acl -Path $newFolderPath
    $acl.SetAccessRule($accessRule)
    Set-Acl -Path $newFolderPath -AclObject $acl -ErrorAction Stop
}
catch {
    Write-Host "Failed to modify file permissions. Error: $_" -ForegroundColor Red
    Stop-Script
}

#end script
