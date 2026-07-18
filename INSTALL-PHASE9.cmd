@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0INSTALL-PHASE9.ps1" -Setup
if errorlevel 1 (
  echo.
  echo Instalasi gagal. Baca pesan error di atas.
  pause
  exit /b 1
)
echo.
echo Instalasi selesai.
pause
