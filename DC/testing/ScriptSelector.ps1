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

# Dynamically create buttons for each script
$scriptPaths = Get-ChildItem -Path $scriptFolder -Filter "*.ps1" -File

foreach ($script in $scriptPaths) {
    # Skip scripts listed in the exclude file
    if ($excludedScripts -contains $script.BaseName) {
        Write-Host "Skipping excluded script: $($script.BaseName)" -ForegroundColor Red
        continue
    }

    # Get the alias for the script from the aliases hashtable
    $alias = $aliases[$script.BaseName]

    # Debug: Log script and alias
    Write-Host "Processing script: $($script.BaseName)" -ForegroundColor Blue
    if ($alias) {
        Write-Host "Alias found: $alias" -ForegroundColor Green
    } else {
        Write-Host "No alias found. Using script name." -ForegroundColor Yellow
        $alias = $script.BaseName
    }

    # Capture the script's full path in a scoped variable
    $scriptPath = $script.FullName

    # Create a button for each script
    $button = New-Object System.Windows.Controls.Button
    $button.Content = $alias  # Set the button's content to the alias or script name
    $button.Margin = 5

    # Debug: Log button creation
    Write-Host "Creating button for script: $scriptPath" -ForegroundColor Cyan

    # Add click event with a properly scoped variable
    $button.Add_Click({
        Write-Host "Executing script: $scriptPath" -ForegroundColor Green
        Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
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
