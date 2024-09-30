REM *************************************************************
REM *							        *
REM *	Vogels - Clean Free Space on Drive of your choice	*
REM *	Author: Thomas Jacobs					*
REM *							        *
REM *************************************************************
REM
REM *************************************************************
REM * Ask for Drive Letter to clean the free space off		*
REM *************************************************************
:: set drive letter manually
SET /P L="Type the drive letter, then press ENTER: "
SET D=%L%:

:CLEAN
C:\Windows\System32\cipher.exe /w:%L%:

Pause