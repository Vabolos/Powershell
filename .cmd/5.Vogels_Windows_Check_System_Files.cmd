REM *****************************************************
REM *							*
REM *	Vogels - SFC Scannow // Version - 1.0		*
REM *	Author: Thomas Jacobs				*
REM *							*
REM *****************************************************

REM *************************************************************
REM * Close all open file explorers and save your work		*
REM *************************************************************

REM Let Microsoft Windows SFC Utility scan and fix protected system files and replace incorrect versions

DISM /Online /Cleanup-Image /RestoreHealth
sfc /scannow