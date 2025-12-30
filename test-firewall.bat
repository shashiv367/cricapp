@echo off
echo Testing firewall by temporarily disabling it...
echo.
echo WARNING: This will temporarily disable Windows Firewall for testing.
echo Press Ctrl+C to cancel, or
pause

echo.
echo Disabling Windows Firewall...
netsh advfirewall set currentprofile state off

echo.
echo Windows Firewall is now DISABLED.
echo.
echo Please try accessing http://192.168.1.4:4000/api/health from your phone browser NOW.
echo.
echo After testing, press any key to RE-ENABLE the firewall...
pause

echo.
echo Re-enabling Windows Firewall...
netsh advfirewall set currentprofile state on

echo.
echo Windows Firewall is now ENABLED again.
echo.
pause




