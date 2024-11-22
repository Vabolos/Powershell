param (
    [string]$AliasFile
)

# Load WPF assemblies
Add-Type -AssemblyName PresentationFramework

# Define the folder where the PowerShell scripts and exclude file are stored
$scriptFolder = "$([Environment]::GetFolderPath('Desktop'))\PowerShellScripts"
$excludeFile = Join-Path -Path $scriptFolder -ChildPath "exclude.txt"

# Debug: Log script folder path
Write-Host "Script folder path: $scriptFolder" -ForegroundColor Cyan

# Read aliases from the aliases file if provided
$aliases = @{}
if (Test-Path $AliasFile) {
    Write-Host "Alias file found: $AliasFile" -ForegroundColor Green
    Get-Content $AliasFile | ForEach-Object {
        # Match alias definition format: ScriptName=AliasName
        if ($_ -match "^(.*?)=(.*?)$") {
            $scriptName = $matches[1].Trim().Replace('.ps1', '')  # Remove .ps1 from alias key
            $aliasName = $matches[2].Trim()
            $aliases[$scriptName] = $aliasName
            # Debug: Log each alias
            Write-Host "Loaded alias: $scriptName = $aliasName" -ForegroundColor Yellow
        } else {
            Write-Host "Invalid alias format: $_" -ForegroundColor Red
        }
    }
} else {
    Write-Host "Alias file not found or not provided" -ForegroundColor Red
}

# Read exclude list
$excludedScripts = @()
if (Test-Path $excludeFile) {
    Write-Host "Exclude file found: $excludeFile" -ForegroundColor Green
    $excludedScripts = Get-Content $excludeFile | ForEach-Object { $_.Trim() }
    # Debug: Log excluded scripts
    Write-Host "Excluded scripts: $($excludedScripts -join ', ')" -ForegroundColor Yellow
} else {
    Write-Host "Exclude file not found. No scripts will be excluded." -ForegroundColor Red
}

# Create a new WPF window
$window = New-Object System.Windows.Window
$window.Title = "Select a PowerShell Script"
$window.Width = 400
$window.Height = 600
$window.WindowStartupLocation = 'CenterScreen'

# Create a StackPanel to hold the buttons
$stackPanel = New-Object System.Windows.Controls.StackPanel
$stackPanel.Margin = 10

# Dynamically create buttons for each script based on the alias file
foreach ($aliasName in $aliases.Values) {
    # Debugging: Log the current alias being processed
    Write-Host "Processing alias: $aliasName" -ForegroundColor Blue
    
    # Get the corresponding script file name for the alias
    $scriptFileName = $aliases.GetEnumerator() | Where-Object { $_.Value -eq $aliasName } | Select-Object -ExpandProperty Key
    Write-Host "Script name from alias: $scriptFileName" -ForegroundColor Cyan

    # Get the corresponding script file path
    $scriptFilePath = Join-Path -Path $scriptFolder -ChildPath "$scriptFileName.ps1"
    Write-Host "Script file path: $scriptFilePath" -ForegroundColor Green

    # Skip scripts listed in the exclude file
    if ($excludedScripts -contains $scriptFileName) {
        Write-Host "Skipping excluded script: $scriptFileName" -ForegroundColor Red
        continue
    }

    # Debugging: Log before creating button
    Write-Host "Creating button for script: $scriptFilePath" -ForegroundColor Cyan

    # Create a button for each script
    $button = New-Object System.Windows.Controls.Button
    $button.Content = $aliasName  # Set the button's content to the alias name
    $button.Margin = 5

    # Add click event with the specific script for each button
    $button.Add_Click({
        Write-Host "Executing script: $scriptFilePath" -ForegroundColor Green
        Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptFilePath`""
    })

    # Add the button to the StackPanel
    $stackPanel.Children.Add($button)
}

# Create an Exit button
$exitButton = New-Object System.Windows.Controls.Button
$exitButton.Content = "Exit"
$exitButton.Margin = 10
$exitButton.Add_Click({
    Write-Host "Exiting application." -ForegroundColor Red
    $window.Close()
})
$stackPanel.Children.Add($exitButton)

# Add the StackPanel to the Window
$window.Content = $stackPanel

# Show the Window
Write-Host "Displaying window..." -ForegroundColor Cyan
$window.ShowDialog()
