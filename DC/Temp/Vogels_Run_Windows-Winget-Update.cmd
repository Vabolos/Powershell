REM @echo off
REM *************************************************************
REM *							        *
REM *	Vogels - Run Winget Update Tool				*
REM *	Author: Written by Thomas Jacobs			*
REM *							        *
REM *************************************************************
REM
echo ************************************************************
echo * Run Winget Update Tool			 		*
echo ************************************************************


winget upgrade --all --accept-source-agreements --accept-package-agreements

pause
