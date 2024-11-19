@echo off
setlocal ENABLEDELAYEDEXPANSION

:: Paths to your files
set "scriptFolder=%USERPROFILE%\Desktop\PowerShellScripts"
set "aliasFile=%scriptFolder%\aliases.txt"
set "excludeFile=%scriptFolder%\exclude.txt"

:main_menu
cls
echo =======================
echo    File Management
echo =======================
echo [1] Add to Alias File
echo [2] Add to Exclusion File
echo [3] Reset to Defaults
echo [4] Remove from Exclusion File
echo [5] Reset Alias
echo [6] Exit (or type "exit")
echo =======================
set /p "choice=Choose an option: "

if "%choice%"=="1" goto alias_menu
if "%choice%"=="2" goto exclude_menu
if "%choice%"=="3" goto reset_defaults
if "%choice%"=="4" goto remove_exclusion
if "%choice%"=="5" goto reset_alias
if "%choice%"=="6" exit /b
if /i "%choice%"=="exit" exit /b

:: Invalid input
echo Invalid choice. Try again.
pause
goto main_menu

:alias_menu
cls
echo == Add to Alias File ==
set /p "scriptname=Enter the script name (without '.ps1'): "
set "scriptname=%scriptname%.ps1"
set /p "alias=Enter the alias for the script: "

:: Confirmation
cls
echo ===========================
echo Confirm the following:
echo Script Name: %scriptname%
echo Alias: %alias%
echo ===========================
set /p "confirm=Is this correct? (y/n): "
if /i "%confirm%"=="y" (
    echo.>>"%aliasFile%" & echo %scriptname%=%alias%>>"%aliasFile%"
    echo Alias added successfully.
    pause
    goto main_menu
) else (
    echo Operation canceled. Try again.
    pause
    goto alias_menu
)

:exclude_menu
cls
echo == Add to Exclusion File ==
set /p "exclude=Enter the script name to exclude (without '.ps1'): "

:: Confirmation
cls
echo ===========================
echo Confirm the following:
echo Script to Exclude: %exclude%
echo ===========================
set /p "confirm=Is this correct? (y/n): "
if /i "%confirm%"=="y" (
    echo.>>"%excludeFile%" & echo %exclude%>>"%excludeFile%"
    echo Script excluded successfully.
    pause
    goto main_menu
) else (
    echo Operation canceled. Try again.
    pause
    goto exclude_menu
)

:remove_exclusion
cls
echo == Remove from Exclusion File ==
set /p "removeExclude=Enter the script name to remove (without '.ps1'): "

:: Confirmation
cls
echo ===========================
echo Confirm the following:
echo Script to Remove: %removeExclude%
echo ===========================
set /p "confirm=Is this correct? (y/n): "
if /i "%confirm%"=="y" (
    findstr /v "^%removeExclude%$" "%excludeFile%" > "%excludeFile%.tmp" && move /y "%excludeFile%.tmp" "%excludeFile%"
    echo Removed %removeExclude% from exclusion file.
    pause
    goto main_menu
) else (
    echo Operation canceled. Try again.
    pause
    goto remove_exclusion
)

:reset_alias
cls
echo == Reset Alias ==
set /p "scriptname=Enter the script name to reset the alias (without '.ps1'): "

:: Display the alias to be removed
set "aliasLine="
for /f "tokens=1,2 delims==" %%a in ('findstr /i "^%scriptname%.ps1=" "%aliasFile%"') do (
    set "aliasLine=%%a=%%b"
)
if defined aliasLine (
    cls
    echo ===========================
    echo Alias to Remove: %aliasLine%
    echo ===========================
    set /p "confirm=Is this correct? (y/n): "
    if /i "%confirm%"=="y" (
        findstr /v "^%scriptname%.ps1=" "%aliasFile%" > "%aliasFile%.tmp" && move /y "%aliasFile%.tmp" "%aliasFile%"
        echo Alias for %scriptname% removed successfully.
        pause
        goto main_menu
    ) else (
        echo Operation canceled. Try again.
        pause
        goto reset_alias
    )
) else (
    echo No alias found for %scriptname%.ps1
    pause
    goto main_menu
)

:reset_defaults
cls
echo Resetting files to default...
:: Replace the files with defaults or clear them
echo. >"%aliasFile%"
echo. >"%excludeFile%"
echo Files reset successfully.
pause
goto main_menu
