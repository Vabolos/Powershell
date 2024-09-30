REM Script made by Vogel's ICT, TJACO
REM as per instructions from Microsoft, limit access to system32\config folder:
icacls %windir%\system32\config\*.* /inheritance:e

REM Enable Service:
sc config vss start=demand

REM Start Service:
net start vss

REM Remove Shadow Copies:
vssadmin delete shadows /all /quiet

REM Stop Service:
net stop vss

REM Disable Service:
sc config vss start=disabled

REM Bewaar ip adres als variable %ip%.
for /f "tokens=1-2 delims=:" %%a in ('ipconfig^|find "IPv4"') do set ip=%%b

REM Schrijf weg welke pc's dit script doorlopen hebben.
echo %DATE% %TIME% %COMPUTERNAME% %USERNAME% %IP% >> \\vogelsh5\public$\logfiles\vss-system-acl.txt

Rem Version Check File
del C:\Vogels_Deploy_Check\Vogels-Remove-ACL-*.txt /F
xcopy /Y "%~dp0LanSweeper\CheckFiles\Vogels-Remove-ACL-System-update.txt" "C:\Vogels_Deploy_Check\"