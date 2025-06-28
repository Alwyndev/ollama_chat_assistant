@echo off
echo Finding your computer's IP address...
echo.
ipconfig | findstr "IPv4"
echo.
echo Look for the IP address that starts with 192.168.x.x or 10.0.x.x
echo This is your computer's local IP address for the app.
echo.
pause 