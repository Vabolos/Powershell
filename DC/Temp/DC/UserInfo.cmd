@echo off
set /p username="Enter username: "
net user %username% /domain
pause