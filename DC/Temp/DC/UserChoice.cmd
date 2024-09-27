@echo off
:menu
cls
echo ============================
echo Select a PowerShell script:
echo ============================
echo 1. Unlock all locked users
echo 2. Check all locked users
echo 3. Log all locked users
echo 4. Get user information
echo 5. Exit
echo ============================
set /p choice=Enter the number of the script you want to run:

if "%choice%"=="1" (
    PowerShell -File "UnlockLockedUsers.ps1"
    goto menu
) else if "%choice%"=="2" (
    PowerShell -File "CheckLockedUsers.ps1"
    goto menu
) else if "%choice%"=="3" (
    PowerShell -File "LockedUsersLog.ps1"
    goto menu
) else if "%choice%"=="4" (
    PowerShell -File "UserInfo.ps1"
    goto menu
) else if "%choice%"=="5" (
    echo Exiting...
    exit
) else (
    echo Invalid choice. Please try again.
    pause
    goto menu
)