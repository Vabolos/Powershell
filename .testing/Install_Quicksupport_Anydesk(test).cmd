@echo off
cls
set LOGFILE=%~dp0installation_log.txt
echo Installation log: %LOGFILE%
echo -------------------------------------------------------- > %LOGFILE%
echo . Vogels AnyDesk QuickSupport Installation Log          >> %LOGFILE%
echo -------------------------------------------------------- >> %LOGFILE%
echo Starting installation... >> %LOGFILE%

REM Function to log success or failure
:log_step
setlocal
set STEP=%1
set MESSAGE=%2
if "%ERRORLEVEL%"=="0" (
    echo [%TIME%] %STEP%: SUCCESS - %MESSAGE% >> %LOGFILE%
    echo [%TIME%] %STEP%: SUCCESS - %MESSAGE%
) else (
    echo [%TIME%] %STEP%: FAILED - %MESSAGE% (Error Level: %ERRORLEVEL%) >> %LOGFILE%
    echo [%TIME%] %STEP%: FAILED - %MESSAGE% (Error Level: %ERRORLEVEL%)
)
exit /b

REM Start script execution
echo Hello %username%! Please wait while the installation completes.

REM Determine system architecture
echo Checking system architecture... >> %LOGFILE%
if exist "%ProgramFiles(x86)%" (
    echo Detected 64-bit architecture. >> %LOGFILE%
    call :log_step "Check Architecture" "Detected 64-bit"
    goto uninstall_x64
) else (
    echo Detected 32-bit architecture. >> %LOGFILE%
    call :log_step "Check Architecture" "Detected 32-bit"
    goto uninstall_x86
)

:uninstall_x86
echo Uninstalling 32-bit version... >> %LOGFILE%
call :uninstall_common "%ProgramFiles%" "32-bit uninstall"
goto install_x86

:uninstall_x64
echo Uninstalling 64-bit version... >> %LOGFILE%
call :uninstall_common "%ProgramFiles(x86)%" "64-bit uninstall"
goto install_x64

:uninstall_common
REM Deletes files and shortcuts
set TARGET_DIR=%~1
set STEP_NAME=%~2
del /q "%TARGET_DIR%\Vogels Quicksupport*.exe" >> %LOGFILE% 2>&1
call :log_step "%STEP_NAME" "Delete executable files"
del /q "%TARGET_DIR%\Vogels Quicksupport*.lnk" >> %LOGFILE% 2>&1
call :log_step "%STEP_NAME" "Delete shortcut files"
if exist "%public%\Desktop\Vogels Quicksupport*.lnk" (
    del /q "%public%\Desktop\Vogels Quicksupport*.lnk" >> %LOGFILE% 2>&1
    call :log_step "%STEP_NAME" "Delete desktop shortcut"
)
if exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Vogels Quicksupport*.lnk" (
    del /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Vogels Quicksupport*.lnk" >> %LOGFILE% 2>&1
    call :log_step "%STEP_NAME" "Delete Start Menu shortcut"
)
exit /b

:install_x86
echo Installing 32-bit version... >> %LOGFILE%
set TARGET_DIR=%ProgramFiles%\Vogels_Quicksupport
if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%" >> %LOGFILE% 2>&1
    call :log_step "Install 32-bit" "Create target directory"
)
call :install_common "%TARGET_DIR%" "32-bit install"
goto Check

:install_x64
echo Installing 64-bit version... >> %LOGFILE%
set TARGET_DIR=%ProgramFiles(x86)%\Vogels_Quicksupport
if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%" >> %LOGFILE% 2>&1
    call :log_step "Install 64-bit" "Create target directory"
)
call :install_common "%TARGET_DIR%" "64-bit install"
goto Check

:install_common
set DEST_DIR=%~1
set STEP_NAME=%~2
copy /y "%~dp0Vogels_Quicksupport\AnyDesk\Vogels_AnyDesk_Quicksupport.exe" "%DEST_DIR%" >> %LOGFILE% 2>&1
call :log_step "%STEP_NAME" "Copy executable file"
copy /y "%~dp0Vogels_Quicksupport\AnyDesk\Vogels AnyDesk Quicksupport.lnk" "%DEST_DIR%" >> %LOGFILE% 2>&1
call :log_step "%STEP_NAME" "Copy local shortcut"
copy /y "%~dp0Vogels_Quicksupport\AnyDesk\Vogels AnyDesk Quicksupport.lnk" "%ProgramData%\Microsoft\Windows\Start Menu\Programs\" >> %LOGFILE% 2>&1
call :log_step "%STEP_NAME" "Copy Start Menu shortcut"
copy /y "%~dp0Vogels_Quicksupport\AnyDesk\Vogels AnyDesk Quicksupport.lnk" "C:\Users\Public\Desktop\" >> %LOGFILE% 2>&1
call :log_step "%STEP_NAME" "Copy desktop shortcut"
exit /b

:Check
echo Performing version check... >> %LOGFILE%
del /f /q "C:\Vogels_Deploy_Check\Vogels_*.txt" >> %LOGFILE% 2>&1
call :log_step "Version Check" "Delete old version files"
xcopy /y "%~dp0Vogels_Quicksupport\Vogels_AnyDesk_Quicksupport_v7.0.15.txt" "C:\Vogels_Deploy_Check\" >> %LOGFILE% 2>&1
call :log_step "Version Check" "Copy new version check file"
goto Einde

:Einde
echo Installation complete. Check the log file for details: %LOGFILE%
timeout /t 5 >nul
exit
