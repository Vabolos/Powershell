REM @echo off
REM *************************************************************
REM *							                                *
REM *	Shell - Run Winget Update Tool				            *
REM *	Author: Written by Vabolos      			            *
REM *							                                *
REM *************************************************************
REM
echo ************************************************************
echo * Run Winget Update Tool			 		                *
echo ************************************************************


winget upgrade --all --accept-source-agreements --accept-package-agreements

pause
