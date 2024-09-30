@echo off
REM *************************************************************
REM *							                                *
REM *	Vogels - Install Office 365				                *
REM *	Author: Written by Luc Frankhuizen			            *
REM *							                                *
REM *************************************************************
REM
echo ************************************************************
echo * Run Install Office 365		 			                *
echo ************************************************************

REM First change the temp directory to a non-standard temporary directory path
set TEMP=C:\Temp
set TMP=C:\Temp

REM Secondly call Powershell Script
PowerShell -NoProfile -ExecutionPolicy Unrestricted -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Unrestricted -File \"\\Vogelsh5\ictdeploy\Microsoft Office 365 x64\1_Office365_install2016 - v7 - test.ps1\"' -Verb RunAs -Wait}"
@REM PowerShell -Command "Start-Process powershell_ise.exe -ArgumentList '-File \"\\Vogelsh5\ictdeploy\Microsoft Office 365 x64\1_Office365_install2016 - v7 - test.ps1\"' -Verb RunAs"

REM Thirdly and last, change back the temp directory's to their default locations to help protect your computer
set TEMP=%USERPROFILE%\AppData\Local\Temp
set TMP=%USERPROFILE%\AppData\Local\Temp
