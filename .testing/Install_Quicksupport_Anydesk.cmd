cls
echo --------------------------------------------------------
echo .      Installing Vogels AnyDesk QuickSupport
echo --------------------------------------------------------

Echo Hello %username% please wait for this installation and update script to finish, it will close automagically when done :-)
Echo

REM Uninstall existing Vogels Quicksupport version
If Exist "%ProgramFiles(x86)%" Goto uninstall_x64 Else Goto uninstall_x86

:uninstall_x86
DEL /Q "%ProgramFiles%\Vogels Quicksupport.exe"
DEL /Q "%ProgramFiles%\Vogels Quicksupport.lnk"
DEL /Q "%ProgramFiles%\Vogels_Quicksupport\Vogels Quicksupport.exe"
DEL /Q "%ProgramFiles%\Vogels_Quicksupport\Vogels Quicksupport v12.exe"
DEL /Q "%ProgramFiles%\Vogels_Quicksupport\Vogels Quicksupport.lnk"
DEL /Q "%ProgramFiles%\Vogels_Quicksupport\Vogels Quicksupport v12.lnk"
DEL /Q "%ProgramFiles%\Vogels_Quicksupport\Vogels_AnyDesk_Quicksupport.exe"
DEL /Q "%ProgramFiles%\Vogels_Quicksupport\Vogels_AnyDesk_Quicksupport.lnk"
DEL /Q "%ProgramFiles%\Vogels_Quicksupport\AnyDesk_Quicksupport.exe"
DEL /Q "%ProgramFiles%\Vogels_Quicksupport\AnyDesk_Quicksupport.lnk"
REM Removes Desktop Icon
if exist "%public%\Desktop\Vogels Quicksupport.lnk" DEL /Q "%public%\Desktop\Vogels Quicksupport.lnk"
if exist "%public%\Desktop\Vogels Quicksupport.lnk" DEL /Q "%public%\Desktop\Vogels Quicksupport v12.lnk"
REM Removes Startmenu Shortcut
if exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Vogels Quicksupport.lnk" DEL /Q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Vogels Quicksupport.lnk"
if exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Vogels Quicksupport.lnk" DEL /Q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Vogels Quicksupport v12.lnk"
GOTO install_x86

:uninstall_x64
DEL /Q "%ProgramFiles(x86)%\Vogels Quicksupport.exe"
DEL /Q "%ProgramFiles(x86)%\Vogels Quicksupport.lnk"
DEL /Q "%ProgramFiles(x86)%\Vogels_Quicksupport\Vogels Quicksupport.exe"
DEL /Q "%ProgramFiles(x86)%\Vogels_Quicksupport\Vogels Quicksupport v12.exe"
DEL /Q "%ProgramFiles(x86)%\Vogels_Quicksupport\Vogels Quicksupport.lnk"
DEL /Q "%ProgramFiles(x86)%\Vogels_Quicksupport\Vogels Quicksupport v12.lnk"
DEL /Q "%ProgramFiles(x86)%\Vogels_Quicksupport\Vogels_AnyDesk_Quicksupport.exe"
DEL /Q "%ProgramFiles(x86)%\Vogels_Quicksupport\Vogels_AnyDesk_Quicksupport.lnk"
DEL /Q "%ProgramFiles%\Vogels_Quicksupport\AnyDesk_Quicksupport.exe"
DEL /Q "%ProgramFiles%\Vogels_Quicksupport\AnyDesk_Quicksupport.lnk"
REM Removes Desktop Icon
if exist "%public%\Desktop\Vogels Quicksupport.lnk" DEL /Q "%public%\Desktop\Vogels Quicksupport.lnk"
if exist "%public%\Desktop\Vogels Quicksupport.lnk" DEL /Q "%public%\Desktop\Vogels Quicksupport v12.lnk"
REM Removes Startmenu Shortcut
if exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Vogels Quicksupport.lnk" DEL /Q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Vogels Quicksupport.lnk"
if exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Vogels Quicksupport.lnk" DEL /Q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Vogels Quicksupport.*"
if exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Vogels Quicksupport.lnk" DEL /Q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Vogels Quicksupport v12.lnk"
if exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Vogels Quicksupport.lnk" DEL /Q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Vogels Quicksupport v12.*"
GOTO install_x64

:install_x86
if not exist "%ProgramFiles%\Vogels_Quicksupport" (mkdir "%ProgramFiles%\Vogels_Quicksupport")
COPY /Y "%~dp0Vogels_Quicksupport\AnyDesk\Vogels_AnyDesk_Quicksupport.exe" "%ProgramFiles%\Vogels_QuickSupport\"
COPY /Y "%~dp0Vogels_Quicksupport\AnyDesk\AnyDesk _Quicksupport.lnk" "%ProgramFiles%\Vogels_QuickSupport\"
COPY /Y "%~dp0Vogels_Quicksupport\AnyDesk\AnyDesk _Quicksupport.lnk" "%ProgramData%\Microsoft\Windows\Start Menu\Programs\"
GOTO Check

:install_x64
if not exist "%ProgramFiles(x86)%\Vogels_Quicksupport" (mkdir "%ProgramFiles(x86)%\Vogels_Quicksupport")
COPY /Y "%~dp0Vogels_Quicksupport\AnyDesk\Vogels_AnyDesk_Quicksupport.exe" "%ProgramFiles(x86)%\Vogels_QuickSupport\"
COPY /Y "%~dp0Vogels_Quicksupport\AnyDesk\AnyDesk _Quicksupport.lnk" "%ProgramFiles(x86)%\Vogels_QuickSupport\"
COPY /Y "%~dp0Vogels_Quicksupport\AnyDesk\AnyDesk _Quicksupport.lnk" "%ProgramData%\Microsoft\Windows\Start Menu\Programs\"
COPY /Y "%~dp0Vogels_Quicksupport\AnyDesk\AnyDesk _Quicksupport.lnk" "C:\Users\Public\Desktop\"
GOTO Check

:Check
Rem Version Check File
del C:\Vogels_Deploy_Check\Vogels_AnyDesk_Quicksupport_*.txt /F
del C:\Vogels_Deploy_Check\Vogels_Quicksupport_v12.txt /F
xcopy /Y "%~dp0Vogels_Quicksupport\Vogels_AnyDesk_Quicksupport_v7.0.15.txt" "C:\Vogels_Deploy_Check\"
Goto Einde

:Einde
Echo All done, closing in 5 seconds

timeout 5
