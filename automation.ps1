# Define the network adapter name and IP address information
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
    [string]$domainName = "coolnetwork.com",
    [Parameter(Position=5)]
    [string]$scopeName = "coolScope"
)

# Get the network adapter to configure
$adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }

if ($null -eq $adapter) {
    Write-Host "No active network adapter found."
}
else {
    # Set the IP address configuration for the network adapter
    $adapter | New-NetIPAddress -IPAddress $ipAddress -PrefixLength 24 -DefaultGateway $defaultGateway
    $adapter | Set-DnsClientServerAddress -ServerAddresses $dnsServers
    $currentIpAddress = ($adapter | Get-NetIPAddress -AddressFamily IPv4).IPAddress
    if ($currentIpAddress -eq $ipAddress) {
        Write-Host "IP address configuration completed successfully."
        
    }
    else {
        Write-Host "IP address configuration failed."
    }
}

Start-Sleep -Seconds 10

# Install DHCP role
$dhcpRole = Install-WindowsFeature -Name DHCP -IncludeManagementTools

if ($dhcpRole.installed) {
    Write-Host "DHCP role installation completed successfully."
    Set-ItemProperty -Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 -Name ConfigurationState -Value 2
}
else {
    Write-Host "DHCP role installation failed."
    Install-WindowsFeature -Name DHCP -IncludeManagementTools
}




# Automatic windows updates disabled
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Name AUOptions -Value 1

if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update").AUOptions -eq 1) {
    Write-Host "Automatic windows updates disabled."
}
else {
    Write-Host "Automatic windows updates not disabled."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Name AUOptions -Value 1
}

# Disable windows updates
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAutoUpdate -Value 1

if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU").NoAutoUpdate -eq 1) {
    Write-Host "Windows updates disabled."
}
else {
    Write-Host "Windows updates not disabled."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAutoUpdate -Value 1
}

# install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# install firefox
choco install firefox -y

if ([System.Exception]) {
    Write-Host "Firefox already installed."
}
else {
    Write-Host "Firefox not installed."
    choco install firefox -y
}

# install WinSCP
choco install winscp -y

if ([System.Exception]) {
    Write-Host "WinSCP already installed."
}
else {
    Write-Host "WinSCP not installed."
    choco install winscp -y
}

# install filezilla
choco install filezilla -y

if ([System.Exception]) {
    Write-Host "Filezilla already installed."
}
else {
    Write-Host "Filezilla not installed."
    choco install filezilla -y
}

# Bottom of automation.ps1
# install DNS role
$dnsRole = Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
$securePassword = ConvertTo-SecureString -String "BrownGreen78" -AsPlainText -Force
Install-ADDSForest -DomainName $domainName -DomainNetbiosName automation -ForestMode default -DomainMode default -NoRebootOnCompletion -SafeModeAdministratorPassword $securePassword -Confirm:$false
Restart-Computer -Force

if (!$dnsRole.installed) {
    Write-Host "DNS role installation completed successfully."
}
else {
    Write-Host "DNS role installation failed."
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
}

