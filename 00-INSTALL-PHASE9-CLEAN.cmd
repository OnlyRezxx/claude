@echo off
setlocal
cd /d "%~dp0"

echo ============================================
echo NAME GUESSER PHASE 9 - CLEAN INSTALLER
echo ============================================
echo.

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp000-INSTALL-PHASE9-CLEAN.ps1"
set "RESULT=%ERRORLEVEL%"

echo.
if not "%RESULT%"=="0" (
    echo Instalasi gagal. Baca pesan error di atas.
) else (
    echo Instalasi selesai.
)

echo.
pause
exit /b %RESULT%
