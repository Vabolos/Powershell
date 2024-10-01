# Automation
automation script(s) written in PowerShell

When running this script you will need to have a few things ready:
- Change the Hostname of the server
- Make sure the Administrator account has a strong password set
- Make sure the user you are logged into has the correct permissions (admin perms)
- Install Chocolatey in Admin Shell to make sure apps can be installed (the script can now do this too)

It's possible that more scripts will be added to this repo in the future

## Script Features:
- Set Static IP + DNS
- Install $ Configure DHCP (auth file created at the start of the script)
    - Management Tools included
    - Registers a SchduledTask for DHCP auth on startup
    - Authorize DHCP after startup (TaskSchdule)
          - Task will be deleted after auth
- Disable auto updates
- Disable manual updates
- Install:
  - Chocolatey (for app installations)
  - Firefox
  - WinSCP
  - Filezilla
 - Install DNS roles
    - Management Tools included
    - Promotes to DC
    - Installs ADDS

# These features are now optional!

## Hostname Change:

```powershell
Rename-Comupter -NewName "SetHostnameHere"
```

## Set a strong User password:

```powershell
$adminPassword = ConvertTo-SecureString -String "BrownGreen78!" -AsPlainText -Force
set-LocalUser -Name "Administrator" -Password $adminPassword
```

## Install Chocolatey:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression
((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```
