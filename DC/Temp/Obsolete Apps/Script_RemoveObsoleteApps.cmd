REM
REM Verwijderen overbodige Microsoft Apps
REM

REM Call Powershell Script

PowerShell -NoProfile -ExecutionPolicy bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy bypass -File ""%~dp0RemoveObsoleteApps\RemoveObsoleteApps.ps1""' -Verb RunAs}";

