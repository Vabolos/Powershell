param (
    [string]$AliasFile
)

# Load WPF assemblies
Add-Type -AssemblyName PresentationFramework

# Define the folder where the PowerShell scripts are stored
$scriptFolder = "$([Environment]::GetFolderPath('Desktop'))\PowerShellScripts"

# Read aliases from the aliases file if provided
$aliases = @{}
if (Test-Path $AliasFile) {
    Get-Content $AliasFile | ForEach-Object {
        # Match alias definition format: ScriptName=AliasName
        if ($_ -match "^(.*?)=(.*?)$") {
            $aliases[$matches[1]] = $matches[2]
        }
    }
} else {
    Write-Host "Alias file not found or not provided" -ForegroundColor Red
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
    # Get the alias for the script from the aliases hashtable
    $alias = $aliases[$script.BaseName]

    # If no alias is found, use the script name (BaseName excludes the extension)
    if (-not $alias) {
        $alias = $script.BaseName
    }

    # Create a button for each script
    $button = New-Object System.Windows.Controls.Button
    $button.Content = $alias  # Set the button's content to the alias or script name
    $button.Margin = 5
    $button.Tag = $script.FullName  # Correctly associate the full path of the script with the button

    # Add click event to run the script
    $button.Add_Click({
        Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($button.Tag)`""
    })

    # Add the button to the StackPanel
    $stackPanel.Children.Add($button)
}

# Create an Exit button
$exitButton = New-Object System.Windows.Controls.Button
$exitButton.Content = "Exit"
$exitButton.Margin = 10
$exitButton.Add_Click({
    $window.Close()
})
$stackPanel.Children.Add($exitButton)

# Add the StackPanel to the Window
$window.Content = $stackPanel

# Show the Window
$window.ShowDialog()
