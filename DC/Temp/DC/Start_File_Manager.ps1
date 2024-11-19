# Resolve the full path to the .cmd file on the desktop
$cmdFilePath = Join-Path -Path $env:USERPROFILE -ChildPath "Desktop\FileManagement.cmd"

# Check if the file exists before trying to open it
if (Test-Path $cmdFilePath) {
    # Display a message in green
    Write-Host "Opening the File Management window..." -ForegroundColor Green

    # Call the .cmd file
    Start-sleep -Seconds 1
    Start-Process $cmdFilePath
} else {
    # Display an error if the file is not found
    Write-Host "File not found: $cmdFilePath" -ForegroundColor Red
}
