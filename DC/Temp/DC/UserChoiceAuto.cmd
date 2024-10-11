@echo off
setlocal enabledelayedexpansion

:: Define the folder where the PowerShell scripts are stored
set scriptFolder=Path\to\your\scripts\folder
:: for example, if the directory is on the desktop:
:: set scriptFolder=%USERPROFILE%\Desktop\PowerShellScripts


:menu
cls
echo ============================
echo Select a PowerShell script:
echo ============================

:: Initialize counter
set i=1
:: Loop through all .ps1 files in the script folder
for %%f in (%scriptFolder%\*.ps1) do (
    echo !i!. %%~nf
    set "script[!i!]=%%f"
    set /a i+=1
)

echo !i!. Exit
set /p choice=Enter the number of the script you want to run:

if "!choice!"=="!i!" (
    echo Exiting...
    exit
)

:: Validate the choice
if defined script[%choice%] (
    PowerShell -File "!script[%choice%]!"
    goto menu
) else (
    echo Invalid choice. Please try again.
    pause
    goto menu
)
