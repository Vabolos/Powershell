@echo off
setlocal enabledelayedexpansion

:: Define the folder where the PowerShell scripts and aliases.txt are stored
set scriptFolder=%USERPROFILE%\Desktop\PowerShellScripts
set aliasFile=%scriptFolder%\aliases.txt

:: Check if the alias file exists and set it as an environment variable
if exist "%aliasFile%" (
    set ALIAS_FILE=%aliasFile%
) else (
    echo Alias file not found.
    exit /b
)

:: Execute the PowerShell script with the alias file path as argument
PowerShell -NoProfile -ExecutionPolicy Bypass -File "%scriptFolder%\ScriptSelector.ps1" -AliasFile "%ALIAS_FILE%"

endlocal
