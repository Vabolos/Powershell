@echo off
REM *************************************************************
REM *							        *
REM *	Vogels - Run Bitlocker Suspend				*
REM *	Author: Written by Thomas Jacobs			*
REM *							        *
REM *************************************************************
REM
echo ************************************************************
echo * Run Bitlocker Suspend			 		*
echo ************************************************************

Manage-bde -Protectors -Disable C: -RebootCount 0

exit