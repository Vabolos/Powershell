REM *****************************************************************************
REM *							        		*
REM *	Vogels - Disable Virtual Lock Sensor              			*
REM *	Author: Luc Frankhuizen							*
REM *							        		*
REM *****************************************************************************
REM
REM *****************************************************************************************************
REM * 	This will disable the Lenovo Virtual Lock Sensor                                              	*
REM *****************************************************************************************************

REM Call Powershell Script
REM Example powershell.exe -executionpolicy bypass -command "%~dp0Lenovo\Scripts\VirtualLockSensor\Vogels_Disable_Lock_Sensor.ps1"
powershell.exe -executionpolicy bypass -file "%~dp0Lenovo\Scripts\VirtualLockSensor\Vogels_Disable_Lock_Sensor.ps1"
pause

