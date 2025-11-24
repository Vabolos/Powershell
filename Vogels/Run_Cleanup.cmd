@echo off
setlocal enableextensions

REM =============================================
REM Run Delete_Version_History.ps1 as Administrator with PowerShell 7+
REM =============================================

set "scriptdir=%~dp0"
set "pwshexe=C:\Program Files\PowerShell\7\pwsh.exe"

:: 1) Ensure PowerShell 7 exists
if not exist "%pwshexe%" (
  echo ERROR: "%pwshexe%" not found.
  echo Please install PowerShell 7 or adjust the path in this BAT file.
  pause
  exit /b 1
)

:: 2) Elevate if needed
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo Requesting administrative privileges...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

:: 3) Switch to the script directory (so relative paths work)
cd /d "%scriptdir%"

:: 4) Run the PowerShell 7 script
echo Running Delete_Version_History.ps1 with: "%pwshexe%"
"%pwshexe%" -NoProfile -ExecutionPolicy Bypass -File "%scriptdir%Delete_Version_History.ps1"

echo.
pause
endlocal
