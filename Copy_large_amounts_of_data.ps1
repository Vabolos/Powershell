# Prompt the user for the source and destination directories
$SourceDir = Read-Host "Enter the source directory"
$DestDir = Read-Host "Enter the destination directory"

# Try to copy the data
try {
    # Check if the source directory exists
    if (!(Test-Path -Path $SourceDir)) {
        throw "Source directory does not exist: $SourceDir"
    }
    
    # Check if the destination directory exists, if not, create it
    if (!(Test-Path -Path $DestDir)) {
        New-Item -ItemType Directory -Path $DestDir
    }

    # Copy files and subdirectories from source to destination
    Copy-Item -Path "$SourceDir\*" -Destination $DestDir -Recurse -Force -Verbose

    Write-Host "Data copy complete."
    Write-Host "Data has been moved from:"
    Write-Host $SourceDir
    Write-Host "to:"
    Write-Host $DestDir
}
catch {
    # If an error occurs, output an error message
    Write-Host "An error occurred during the copy process: $_" -ForegroundColor Red
}
finally {
    # Pause the script at the end
    Pause
}
