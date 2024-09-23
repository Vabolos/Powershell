# Define the paths for the folders to be copied
$folders = @("Desktop", "Downloads", "Documents", "Pictures", "Music", "Videos")

# Get the current username
$username = $env:USERNAME

# Define the network drive and UNC path dynamically using the username
$homeDriveLetter = "H:"
$uncPath = "\\VOGELSH6\$username$"

# Check if the network drive is mapped and accessible
if (-Not (Test-Path -Path $homeDriveLetter)) {
    Write-Host "Network drive $homeDriveLetter is not available. Attempting to map it..."
    New-PSDrive -Name "H" -PSProvider "FileSystem" -Root $uncPath -Persist -ErrorAction SilentlyContinue > $null

    if (-Not (Test-Path -Path $homeDriveLetter)) {
        Write-Host "Failed to map network drive $homeDriveLetter. Using UNC path instead."
        $homeDrivePath = $uncPath
    } else {
        $homeDrivePath = $homeDriveLetter
    }
} else {
    $homeDrivePath = $homeDriveLetter
}

# Get the current user's profile path
$userProfilePath = [System.Environment]::GetFolderPath("UserProfile")

# Loop through each folder and copy its contents to the home drive
foreach ($folder in $folders) {
    $sourcePath = Join-Path -Path $userProfilePath -ChildPath $folder
    $destinationPath = Join-Path -Path $homeDrivePath -ChildPath $folder

    # Check if the source folder exists
    if (Test-Path -Path $sourcePath) {
        # Copy the folder and its contents to the destination
        Write-Host "Copying $folder to $destinationPath..."
        Copy-Item -Path $sourcePath -Destination $destinationPath -Recurse -Force -ErrorAction SilentlyContinue > $null
    } else {
        Write-Host "Source folder $sourcePath does not exist."
    }
}

Write-Host "All specified folders have been copied."

# Pause to prevent the script from closing immediately
Read-Host -Prompt "Press Enter to exit"
