# Function to open Server Manager or check if it's already running
function Open-ServerManager {
    Write-Host "Checking if Server Manager is already running..." -ForegroundColor Yellow

    # Define the process name for Server Manager
    $processName = "ServerManager"

    # Check if the process is already running
    $runningProcess = Get-Process -Name $processName -ErrorAction SilentlyContinue

    if ($runningProcess) {
        Write-Host "Server Manager is already running. Bringing it to the foreground..." -ForegroundColor Green
        
        # Attempt to bring the existing window to the foreground
        Add-Type @"
using System;
using System.Runtime.InteropServices;

public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@

        $runningProcess | ForEach-Object {
            [Win32]::SetForegroundWindow($_.MainWindowHandle)
        }

    } else {
        Write-Host "Server Manager is not running. Launching it now..." -ForegroundColor Yellow
        
        # Try to launch Server Manager
        try {
            Start-Process "ServerManager.exe"
            Write-Host "Server Manager launched successfully!" -ForegroundColor Green
        } catch {
            Write-Host "Error: Unable to launch Server Manager. Ensure it's installed and accessible." -ForegroundColor Red
        }
    }
}

# Execute the function
Open-ServerManager
