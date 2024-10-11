@echo off
:menu
cls
echo Select an option:
echo 1. Unlock Locked Users
echo 2. Check Locked Users
echo 3. View Locked Users Log
echo 4. Get User Info
echo 5. View Disabled Users
echo 6. Exit
set /p choice="Enter your choice: "

:: Set the path to the PowerShell scripts folder (adjust folder name if different)
set scriptDir=%USERPROFILE%\Desktop\PowerShellScripts

if "%choice%"=="1" (
    PowerShell -File "%scriptDir%\UnlockLockedUsers.ps1"
    goto menu
) else if "%choice%"=="2" (
    PowerShell -File "%scriptDir%\CheckLockedUsers.ps1"
    goto menu
) else if "%choice%"=="3" (
    PowerShell -File "%scriptDir%\LockedUsersLog.ps1"
    goto menu
) else if "%choice%"=="4" (
    PowerShell -File "%scriptDir%\UserInfo.ps1"
    goto menu
) else if "%choice%"=="5" (
    PowerShell -File "%scriptDir%\DisabledUsers.ps1"
    goto menu
) else if "%choice%"=="6" (
    echo Exiting...
    exit
) else (
    echo Invalid choice. Please try again.
    pause
    goto menu
)
