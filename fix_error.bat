@echo off
echo ====================================
echo FIX ERROR MERAH - MY MANAGE APP
echo ====================================
echo.

echo [1/4] Cleaning build...
call flutter clean
echo.

echo [2/4] Getting dependencies...
call flutter pub get
echo.

echo [3/4] Running app...
echo.
echo TUNGGU SAMPAI COMPILE SELESAI!
echo Jangan close terminal ini.
echo.
call flutter run -d chrome --web-renderer html

pause
