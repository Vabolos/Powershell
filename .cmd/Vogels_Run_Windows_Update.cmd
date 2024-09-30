@echo off
REM *************************************************************
REM *							        *
REM *	Vogels - Run Windows Update				*
REM *	Author: Written by Thomas Jacobs			*
REM *							        *
REM *************************************************************
REM
echo ************************************************************
echo * Run Windows Update			 		*
echo ************************************************************

wuauclt.exe /resetauthorization
wuauclt.exe /detectnow
wuauclt.exe /updatenow
wuauclt.exe /reportnow

exit