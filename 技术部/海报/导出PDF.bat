@echo off
setlocal enabledelayedexpansion
REM Export all posters in this folder to PDF via Microsoft Edge headless (Windows built-in)
set "EDGE=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
if not exist "%EDGE%" set "EDGE=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
if not exist "%EDGE%" (
  echo [ERROR] Microsoft Edge not found.
  pause
  exit /b 1
)
cd /d "%~dp0"
set /a N=0
for %%f in (*.html) do (
  set /a N+=1
  REM unique user-data-dir per file avoids Edge instance lock conflict
  set "UDD=%TEMP%\edge-pdf-!N!-%RANDOM%%RANDOM%"
  echo Exporting: %%f
  "%EDGE%" --headless --disable-gpu --user-data-dir="!UDD!" --print-to-pdf="%%~dpnf.pdf" "%%~ff" 2>nul
  if exist "%%~dpnf.pdf" (
    echo   OK  -^> %%~nf.pdf
  ) else (
    echo   FAILED
  )
  rmdir /s /q "!UDD!" 2>nul
)
echo.
echo All done.
pause
