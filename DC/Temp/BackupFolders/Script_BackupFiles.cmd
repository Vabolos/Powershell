REM *****************************************************************************
REM *							        		*
REM *	Vogels - Back up Files & Folders to Homedrive          			*
REM *	Author: Luc Frankhuizen							*
REM *							        		*
REM *****************************************************************************
REM
REM *****************************************************************************************************
REM * 	This will make a back up of the default folders and copy them to the homdedrive               	*
REM *****************************************************************************************************

REM Call Powershell Script
REM Example powershell.exe -executionpolicy bypass -command "%~dp0BackupDocs.ps1"
powershell.exe -executionpolicy bypass -file "%~dp0BackupDocs.ps1"

