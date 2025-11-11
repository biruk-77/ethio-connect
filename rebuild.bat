@echo off
echo ============================================
echo ETHIOCONNECT - FULL CLEAN AND REBUILD
echo ============================================
echo.

echo [1/6] Stopping any running Flutter processes...
taskkill /F /IM flutter.exe 2>nul
taskkill /F /IM dart.exe 2>nul
timeout /t 2 /nobreak >nul

echo [2/6] Deleting build cache...
if exist "build" rmdir /s /q "build"
if exist ".dart_tool" rmdir /s /q ".dart_tool"
if exist "android\.gradle" rmdir /s /q "android\.gradle"
if exist "android\app\build" rmdir /s /q "android\app\build"

echo [3/6] Running flutter clean...
call flutter clean

echo [4/6] Getting dependencies...
call flutter pub get

echo [5/6] Rebuilding project...
call flutter build apk --debug

echo [6/6] Done!
echo.
echo ============================================
echo NOW RUN: flutter run
echo ============================================
pause
