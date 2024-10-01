# Define the network adapter name and IP address information + more
param(
    [Parameter(Position=0)]
    [string]$ipAddress = "192.168.10.10",
    [Parameter(Position=1)]
    [string]$subnetMask = "255.255.255.0",
    [Parameter(Position=2)]
    [string]$defaultGateway = "192.168.10.1",
    [Parameter(Position=3)]
    [String[]]$dnsServers = ("127.0.0.1", "8.8.8.8"),
    [Parameter(Position=4)]
    [string]$domainName = "automation.nl",
    [Parameter(Position=5)]
    [string]$startRange = "192.168.10.50",
    [Parameter(Position=6)]
    [string]$endRange = "192.168.10.150",
    [Parameter(Position=7)]
    [string]$scopeName = "automationScope"
)

# create auth.ps1
$item = New-Item -Path C:\powershell -Name auth.ps1 -ItemType File -Force
# Add content to auth.ps1
$authContent = 'Add-DhcpServerInDC -DNSName automation.nl -IPAddress 192.168.10.10'
$authContent += "`n"
$authContent += 'Start-Sleep -Seconds 5'
$authContent += "`n"
$authContent += 'Unregister-ScheduledTask -TaskName "DHCP Authorization" -Confirm:$false'

if (-not(Test-Path -Path 'C:\powershell')) {
    Write-Host "C:\ps directory does not exist, creating now." -ForegroundColor Yellow
    $item = New-Item -Path C:\ps -Name auth.ps1 -ItemType File -Force
    Add-Content -Path $item -Value $authContent
    Write-Host "auth.ps1 created successfully." -ForegroundColor Cyan
}
else {
    Write-Host "auth.ps1 already successfully." -ForegroundColor Cyan
    Add-Content -Path $item -Value $authContent
}

# Get the network adapter to configure
$adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }

if ($adapter -eq !$null) {
    Write-Host "No active network adapter found." -ForegroundColor Red
}
else {
    # Set the IP address configuration for the network adapter
    $adapter | New-NetIPAddress -IPAddress $ipAddress -PrefixLength 24 -DefaultGateway $defaultGateway
    $adapter | Set-DnsClientServerAddress -ServerAddresses $dnsServers
    $currentIpAddress = ($adapter | Get-NetIPAddress -AddressFamily IPv4).IPAddress
    if ($currentIpAddress -eq $ipAddress) {
        Write-Host "IP address configuration completed successfully." -ForegroundColor Cyan
        
    }
    else {
        Write-Host "IP address configuration failed." -ForegroundColor Red
    }
}

Start-Sleep -Seconds 10

# Install DHCP role
$dhcpRole = Get-WindowsFeature -Name DHCP*

if (!$dhcpRole.installed) {
    Write-Host "DHCP role is not installed, installing right now." -ForegroundColor Yellow
    # Install DHCP role
    Install-WindowsFeature -Name DHCP -IncludeManagementTools
    # Create DHCP scope
    Add-DhcpServerV4Scope -Name $scopeName -StartRange $startRange -Endrange $endRange -SubnetMask $subnetMask -State Active -PassThru
    # Remove configuration warning in server manager
    Set-ItemProperty -Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 -Name ConfigurationState -Value 2
    Write-Host "DHCP role installed successfully." -ForegroundColor Cyan
}
else {
    Write-Host "DHCP role is installed" -ForegroundColor Cyan
}

# Automatic windows updates disabled
$autoWinUpd = Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Name AUOptions -Value 1

if (!$autoWinUpd.AUOptions -eq 1) {
    Write-Host "Automatic windows updates not disabled." -ForegroundColor Red
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Name AUOptions -Value 1
    Write-Host "Automatic windows updates disabled." -ForegroundColor Cyan
}
else {
    Write-Host "Automatic windows updates disabled." -ForegroundColor Cyan
}

# Disable windows updates
$winUpd = Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAutoUpdate -Value 1

if (!$winUpd.NoAutoUpdate -eq 1) {
    Write-Host "Windows updates not disabled." -ForegroundColor Red
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAutoUpdate -Value 1
    Write-Host "Windows updates disabled." -ForegroundColor Cyan
}
else {
    Write-Host "Windows updates disabled." -ForegroundColor Cyan
}

# install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# install firefox
choco install firefox -y

if ([System.Exception]) {
    Write-Host "Firefox is being installed." -ForegroundColor Yellow
}
else {
    Write-Host "Firefox not installed." -ForegroundColor Red
    choco install firefox -y
}

# install WinSCP
choco install winscp -y

if ([System.Exception]) {
    Write-Host "WinSCP is being installed." -ForegroundColor Yellow
}
else {
    Write-Host "WinSCP not installed." -ForegroundColor Red
    choco install winscp -y
}

# install filezilla
choco install filezilla -y

if ([System.Exception]) {
    Write-Host "Filezilla is being installed." -ForegroundColor Yellow
}
else {
    Write-Host "Filezilla not installed." -ForegroundColor Red
    choco install filezilla -y
}

# 
Register-ScheduledTask -TaskName "DHCP Authorization" -Action (New-ScheduledTaskAction -Execute "powershell.exe" -Argument "C:\powershell\auth.ps1") -Trigger (New-ScheduledTaskTrigger -AtLogOn) -User "NT AUTHORITY\SYSTEM" -Force

# Bottom of automation.ps1 (only 1 restart required)
# install DNS role
$dnsRole = Get-WindowsFeature -Name AD-Domain-Services*
$securePassword = ConvertTo-SecureString -String "BrownGreen78!" -AsPlainText -Force
if (!$dnsRole.installed) {
    Write-Host "DNS role installation failed, installing now." -ForegroundColor Yellow
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
    Install-ADDSForest -DomainName $domainName -DomainNetbiosName automation -ForestMode default -DomainMode default -NoRebootOnCompletion -SafeModeAdministratorPassword $securePassword -Confirm:$false
    Write-Host "DNS role installation completed successfully." -ForegroundColor Cyan
    Start-Sleep -Seconds 5
    Restart-Computer -Force
}
else {
    Write-Host "DNS role installation completed successfully." -ForegroundColor Cyan
}
