# Define the service and software names
$serviceName = "Virtual Lock Sensor"

# Step 1: Check if the service exists
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($null -eq $service) {
    Write-Output "Step 1: Service '$serviceName' is not installed on this system."
    $serviceInstalled = $false
    Start-Sleep -Seconds 1
    Write-Output "Step 2: Skipped"
    Start-Sleep -Seconds 1
    Write-Output "Step 3: Skipped"
    Start-Sleep -Seconds 1
    Write-Output "Step 4: Skipped"
    Start-Sleep -Seconds 1
    Write-Output "Step 5: Skipped"
    Start-Sleep -Seconds 1
    Write-Output "Step 6: Skipped"
} else {
    Write-Output "Step 1: Service '$serviceName' is installed on this system."
    $serviceInstalled = $true
    
    # Step 2: Check if the service is running
    if ($service.Status -eq "Running") {
        Write-Output "Step 2: Service '$serviceName' is currently running."
        $serviceRunning = $true
    } else {
        Write-Output "Step 2: Service '$serviceName' is not running."
        $serviceRunning = $false
    }

    # Step 3: Check if the service is set to auto-start
    $startupType = Get-WmiObject -Class Win32_Service -Filter "Name='$serviceName'" | Select-Object -ExpandProperty StartMode
    if ($startupType -eq "Auto") {
        Write-Output "Step 3: Service '$serviceName' is set to auto-start."
        $serviceAutoStart = $true
    } else {
        Write-Output "Step 3: Service '$serviceName' is not set to auto-start."
        $serviceAutoStart = $false
    }

    # Step 4: Stop the service if it's running
    if ($serviceRunning) {
        Write-Output "Step 4: Stopping the service: $serviceName"
        Stop-Service -Name $serviceName -Force
        $serviceStopped = $true
    } else {
        Write-Output "Step 4: Service '$serviceName' is already stopped."
        $serviceStopped = $false
    }

    # Step 5: Disable the service (turn off auto-start)
    if ($serviceAutoStart) {
        Write-Output "Step 5: Disabling auto-start for the service: $serviceName"
        Set-Service -Name $serviceName -StartupType Disabled
        $serviceAutoStartDisabled = $true
    } else {
        Write-Output "Step 5: Auto-start is already disabled for the service: $serviceName"
        $serviceAutoStartDisabled = $false
    }

    # Step 6: Configure recovery options to "Take No Action" on failures
    Write-Output "Step 6: Setting recovery options to 'Take No Action' for the service: $serviceName"
    sc.exe failure $serviceName reset= 0 actions=none
    $recoveryConfigured = $true
}

# Step 7: Delete the Virtual Lock Sensor executable
Start-Sleep -Seconds 1
Write-Output "Step 7: Checking if the Virtual Lock Sensor executable exists."

$exePath = "C:\Program Files (x86)\Elliptic Labs\Virtual Lock Sensor.exe"

if (Test-Path $exePath) {
    Write-Output "Executable found at $exePath. Attempting to delete it."
    Remove-Item -Path $exePath -Force
    Write-Output "Virtual Lock Sensor executable deleted successfully."
    $exeDeleted = $true
} else {
    Write-Output "Virtual Lock Sensor executable not found at $exePath."
    $exeDeleted = $false
}


# Summary Output
Write-Output "`n===== Summary of Actions ====="
if ($serviceInstalled) {
    Write-Output "Service '$serviceName' is installed."
    Write-Output "Service was running: $serviceRunning"
    Write-Output "Service was set to auto-start: $serviceAutoStart"
    Write-Output "Service stopped: $serviceStopped"
    Write-Output "Auto-start disabled: $serviceAutoStartDisabled"
    Write-Output "Recovery options configured: $recoveryConfigured"
    Write-Output "Software has been uninstalled: $exeDeleted"
} else {
    Write-Output "Service '$serviceName' is not installed, no further actions taken."
}
Write-Output "=============================="
