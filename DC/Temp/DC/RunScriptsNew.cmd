@echo off
setlocal enabledelayedexpansion

:: Define the folder where the PowerShell scripts and aliases.txt are stored
set scriptFolder=%USERPROFILE%\Desktop\PowerShellScripts
set aliasFile=%scriptFolder%\aliases.txt
set excludeFile=%scriptFolder%\exclude.txt

:: Read aliases from alias file
if exist "%aliasFile%" (
    for /f "tokens=1,2 delims==" %%A in (%aliasFile%) do (
        set "alias[%%~nA]=%%B"
    )
)

:: Read exclusion list into memory
set excludeList=
if exist "%excludeFile%" (
    for /f "usebackq delims=" %%A in ("%excludeFile%") do (
        set "excludeList=!excludeList! %%A"
    )
)

:menu
cls
echo:
echo:       ______________________________________________________________
echo:
echo:                     Available PowerShell Scripts
echo:       ______________________________________________________________
echo:

:: Initialize counter
set i=1

:: Loop through all .ps1 files in the script folder
for %%f in ("%scriptFolder%\*.ps1") do (
    set scriptName=%%~nf
    set alias=!alias[%%~nf]!

    if not defined alias (
        set alias=%%~nf
    )

    :: Check if the script is in the exclusion list
    echo !excludeList! | findstr /i "\<%%~nf\>" >nul && (
        echo:           ---Skipping excluded script---
    ) || (
        echo:           [!i!] !alias!
        set "script[!i!]=%%f"
        set /a i+=1
    )
)

echo:
echo:       ______________________________________________________________
echo:
echo:             [!i!] Exit (or type "exit" to close)
echo:       ______________________________________________________________
echo:
set /p choice=Choose a script to run [1-%i%]: 

echo:
if /i "!choice!"=="exit" (
    echo Exiting...
    exit
)

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
