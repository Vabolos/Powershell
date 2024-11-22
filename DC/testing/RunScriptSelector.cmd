@echo off
setlocal enabledelayedexpansion

:: Define the folder where the PowerShell scripts and aliases.txt are stored
set scriptFolder=%USERPROFILE%\Desktop\PowerShellScripts
set aliasFile=%scriptFolder%\aliases.txt

:: Debugging: Print paths
echo Script folder: %scriptFolder%
echo Alias file: %aliasFile%

:: Check if the alias file exists and set it as an environment variable
if exist "%aliasFile%" (
    set ALIAS_FILE=%aliasFile%
    echo Alias file found: %ALIAS_FILE%
) else (
    echo Alias file not found. Exiting.
    exit /b
)

:: Debugging: Verify PowerShell execution
echo Executing PowerShell script...
echo PowerShell -NoProfile -ExecutionPolicy Bypass -File "%scriptFolder%\ScriptSelector.ps1" -AliasFile "%ALIAS_FILE%"

:: Execute the PowerShell script with the alias file path as argument
PowerShell -NoProfile -ExecutionPolicy Bypass -File "%scriptFolder%\ScriptSelector.ps1" -AliasFile "%ALIAS_FILE%"

endlocal
