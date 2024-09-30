REM *************************************************************
REM *							        *
REM *	Vogels - Temp Files Cleaner script // Version - 1.3	*
REM *	Author: Written by Twisty modified by Thomas Jacobs	*
REM *							        *
REM *************************************************************
REM
REM *************************************************************
REM * Clean ALL Users and Windows Temp Files			*
REM *************************************************************

@echo off
Rem


    Rem Identify version of Windows


    SET WinVer=Unknown

    VER | FINDSTR /IL "5.1." > NUL
    IF %ERRORLEVEL% EQU 0 SET WinVer=XP

    rem 5.2 is actually Server 2003, but for our purposes it's the same as XP
    VER | FINDSTR /IL "5.2." > NUL
    IF %ERRORLEVEL% EQU 0 SET WinVer=XP

    VER | FINDSTR /IL "6.0." > NUL
    IF %ERRORLEVEL% EQU 0 SET WinVer=VISTA

    rem 6.1 is actually Windows 7, but for our purposes it's the same as Vista
    VER | FINDSTR /IL "6.1." > NUL
    IF %ERRORLEVEL% EQU 0 SET WinVer=VISTA

    rem 6.2 is actually Windows 8, but for our purposes it's the same as Vista
    VER | FINDSTR /IL "6.2." > NUL
    IF %ERRORLEVEL% EQU 0 SET WinVer=VISTA

    rem 6.3 is actually Windows 8.1, but for our purposes it's the same as Vista
    VER | FINDSTR /IL "6.3." > NUL
    IF %ERRORLEVEL% EQU 0 SET WinVer=VISTA

    rem 10.0 is actually Windows 10, but for our purposes it's the same as Vista
    VER | FINDSTR /IL "10.0" > NUL
    IF %ERRORLEVEL% EQU 0 SET WinVer=VISTA

    rem Ask user the version if we cannot automatically determine
    If Not "%WinVer%" EQU "Unknown" Goto :SetUserProfPath

    Set /P Response="Select OS  [X]P, [V]ista/7/8/8.1/10: "
    If /i "%Response%" EQU "X" Set WinVer=XP
    If /i "%Response%" EQU "V" Set WinVer=VISTA
    If "%WinVer%" EQU "" Echo Invalid response. Exiting.&goto :eof


:SetUserProfPath
    If %WinVer% EQU XP (
        Set UserProfileRootPath=%SystemDrive%\Documents and Settings
    ) Else (
        Set UserProfileRootPath=%SystemDrive%\Users
    )

    Call :RemoveSubfoldersAndFiles %SystemDrive%\Temp
    Call :RemoveSubfoldersAndFiles %SystemDrive%\ProgramData\Microsoft\Windows\WER
    Call :RemoveSubfoldersAndFiles %SystemDrive%\ProgramData\Microsoft\Windows Defender\Scans\History\Results
    Call :RemoveSubfoldersAndFiles %SystemDrive%\Program Files\Google\Update\Download
    Call :RemoveSubfoldersAndFiles %SystemDrive%\Windows\Prefetch
    Call :RemoveSubfoldersAndFiles %SystemDrive%\Windows\pchealth\ERRORREP
    Call :RemoveSubfoldersAndFiles %SystemDrive%\Windows\SoftwareDistribution\Download
    Call :RemoveSubfoldersAndFiles %SystemDrive%\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Media Player\Art Cache
    Call :RemoveSubfoldersAndFiles %SystemDrive%\Windows\System32\spool\Printers
    Call :RemoveSubfoldersAndFiles %SystemDrive%\Windows\Temp
    Call :RemoveSubfoldersAndFiles %SystemDrive%\Windows\Logs
    Call :RemoveSubfoldersAndFiles %SystemDrive%\Windows\Debug
    Call :RemoveSubfoldersAndFiles %SystemDrive%\Windows\MiniDump
    Call :RemoveSubfoldersAndFiles %SystemDrive%\Windows\Downloaded Installations
    Call :RemoveSubfoldersAndFiles %SystemDrive%\Windows\SoftwareDistribution\DeliveryOptimization
    Call :RemoveSubfoldersAndFiles %SystemDrive%\Windows\Security\Logs
    Call :RemoveSubfoldersAndFiles %SystemDrive%\Windows\System32\Wbem\Logs


    Rem Walk through each user profile folder
    Rem This convoluted command is necessary to ensure we process hidden and system folders too
    for /f "delims=" %%D in ('dir /ad /b "%UserProfileRootPath%"') DO Call :ProcessProfileFolder %UserProfileRootPath%\%%D

goto :EOF


:ProcessProfileFolder

    Set FolderName=%*

    Rem Leave if it's not a user profile folder
    If Not Exist "%FolderName%\ntuser.dat" goto :EOF

    Rem Leave it's a profile folder on the exclude list
    If /I "%FolderName%" EQU "%UserProfileRootPath%\Default" goto :EOF
    If /I "%FolderName%" EQU "%UserProfileRootPath%\Default User" goto :EOF
    If /I "%FolderName%" EQU "%UserProfileRootPath%\DefaultUser" goto :EOF
    If /I "%FolderName%" EQU "%UserProfileRootPath%\NetworkService" goto :EOF
    If /I "%FolderName%" EQU "%UserProfileRootPath%\LocalService" goto :EOF

    Set UserProfilePath=%FolderName%

    Rem Clean up these folders
    If %WinVer% EQU XP (
        Call :RemoveSubfoldersAndFiles %UserProfilePath%\Local Settings\Temp
        Call :RemoveSubfoldersAndFiles %UserProfilePath%\Local Settings\Temporary Internet Files
        Call :RemoveSubfoldersAndFiles %UserProfilePath%\Application Data\Sun\Java\Deployment\cache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\Local Settings\Temp\History
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\Local Settings\Temp\Temporary Internet Files
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\Local Settings\Application Data\Google\Chrome\User Data\Default\Cache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\Local Settings\Application Data\Mozilla\Firefox\Profiles
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\Local Settings\Application Data\Microsoft\Media Player\Art Cache

    ) Else (
        Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Temp
        Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\LocalLow\Temp
        Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Microsoft\Windows\Temporary Internet Files
        Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Microsoft\Windows\INetCache
        Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Microsoft\Windows\INetCache\IE
        Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Microsoft\Terminal Server Client\Cache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Microsoft\Media Player
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Microsoft\Messenger
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Microsoft\Outlook\Offline Address Books
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Microsoft\Windows Live Contacts
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Microsoft\Windows\Explorer
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Microsoft\Windows\Explorer\IconCacheToDelete
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Microsoft\Windows\Explorer\ThumbCacheToDelete
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Microsoft\Windows\Burn
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Microsoft\Windows\History
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Microsoft\Windows\WER\ReportArchive
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Microsoft\Internet Explorer\Recovery\Active
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Microsoft\Internet Explorer\Recovery\Last Active
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Microsoft\Terminal Server Client\Cache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Packages\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe\AC
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\local\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\CrashRpt
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\CrashDumps
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Downloaded Installations
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Adobe\Acrobat\9.0\Updater
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Adobe\Acrobat\9.0\Cache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Adobe\Acrobat\10.0\Updater
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Adobe\Acrobat\10.0\Cache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Adobe\Acrobat\11.0\Updater
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Adobe\Acrobat\11.0\Cache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Adobe\Acrobat\DC\Updater
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Adobe\Acrobat\DC\Cache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Google\Chrome\User Data\Default\Cache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Opera Software\Opera Stable\Cache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Mozilla\Firefox\Profiles
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\TechSmith\SnagIt\CrashDumps
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\TechSmith\SnagIt\Thumbnails
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\TechSmith\SnagIt\DataStore
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Local\Sap\SAP GUI\Traces
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Roaming\Macromedia\Flash Player
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Roaming\Adobe\Flash Player\AssetCache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Roaming\Microsoft\Windows\Cookies
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Roaming\Microsoft\Windows\PrivacIE
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Roaming\Microsoft\Windows\IECompatCache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Roaming\Microsoft\Windows\IETldCache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Roaming\Microsoft\Teams\blob_storage
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Roaming\Microsoft\Teams\cache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Roaming\Microsoft\Teams\databases
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Roaming\Microsoft\Teams\gpucache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Roaming\Microsoft\Teams\IndexedDB
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Roaming\Microsoft\Teams\Local Storage
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\Roaming\Microsoft\Teams\tmp
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\LocalLow\Microsoft\CryptnetUrlCache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\LocalLow\Sun\Java\Deployment\cache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\LocalLow\Sun\Java\Deployment\SystemCache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\AppData\LocalLow\Sun\Java\Deployment\javaws\cache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\Application Data\Sun\Java\Deployment\cache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\Application Data\Sun\Java\Deployment\SystemCache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\Application Data\Sun\Java\Deployment\javaws\cache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\Application Data\Opera\Opera\cache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\Application Data\Microsoft\CryptnetUrlCache
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\Application Data\Macromedia\Flash Player
	Call :RemoveSubfoldersAndFiles %UserProfilePath%\Application Data\Adobe\Flash Player\AssetCache
    )


goto :SPECIFIC


:RemoveSubfoldersAndFiles

    Set FolderRootPath=%*

    Rem Confirm target folder exists
    If Not Exist "%FolderRootPath%" Goto :EOF

    Rem Make the folder to clean current and confirm it exists...
    CD /D %FolderRootPath%

    Rem Confirm we switched directories
    If /I "%CD%" NEQ "%FolderRootPath%" Goto :EOF

    Rem ...so that this command cannot delete the folder, only everything in it
    Echo Purging %CD%
    RD /S /Q . >>nul 2>>&1

goto :EOF

:SPECIFIC

    Del %AppData%\Microsoft\Templates\~$normal.dot

goto :EOF

:EOF

    Echo.
    Echo Finished! Press a key to exit...
    Pause>Nul
