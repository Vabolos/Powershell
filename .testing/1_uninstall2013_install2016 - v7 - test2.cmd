@echo off
SETLOCAL

:: Set variables
set path=C:\office365install
set office2016_path=C:\office365install\Office
set min_size=2000
set startmenu=C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office 2016

SET __COMPAT_LAYER=WINXPSP3

:: Disable UAC
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f

:: Check if install folder exists
if not exist "%path%" (
    echo Creating local install folder
    mkdir "%path%"
    echo Done...
) else (
    echo .
    echo Local install folder already exists, skipping create folder job
)

echo .
echo Now...copying needed files to local install folder

:: Copy necessary files to local temp folder
copy "%cd%\setup.exe" "%path%\"
copy "%cd%\configuration.xml" "%path%\"
copy "%cd%\disableprompt.reg" "%path%\"
copy "%cd%\mkdir.bat" "%path%\"
echo Done copying first step...

:: Copy Office files
if exist "%office2016_path%" (
    rmdir /s /q "%office2016_path%"
    xcopy "%cd%\Office" "%path%\Office" /s /e
) else (
    xcopy "%cd%\Office" "%path%\Office" /s /e
)

echo Done...copying Office files

cd "%path%"

:: Check if Office folder was copied successfully
if not exist "%office2016_path%" (
    echo ERROR!
    echo Office 2016 has not been copied to local folder, stopping script now!
    pause
    exit /b
)

:: Verify folder size
for /f "tokens=3" %%A in ('dir /s "%office2016_path%" ^| find "bytes"') do set /a FolderSize=%%A / 1048576
if %FolderSize% LSS %min_size% (
    echo ERROR!
    echo Installation folder has incorrect size, stopping script now!
    pause
    exit /b
)

echo OK...
echo Verified that Office 2016 has been copied correctly
echo Now Installing Office 2016, this might take a while...

:: Install Office 2016
"%path%\setup.exe" /configure "%path%\configuration.xml"

echo YES! Completed Office setup

:: Disable default file types splash screen
regedit /s "%path%\disableprompt.reg"

:: Create start menu folder and move shortcuts
call "%path%\mkdir.bat"

echo Removing temporary files Office setup
cd "%path%"

:: Remove temporary files after installation
del setup.exe
del configuration.xml
del disableprompt.reg
del mkdir.bat
rmdir /s /q "%office2016_path%"

echo .
echo Installation completed successfully!

:: Re-enable UAC
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 1 /f

pause
ENDLOCAL
