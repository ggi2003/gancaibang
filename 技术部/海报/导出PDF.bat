@echo off
setlocal enabledelayedexpansion
REM Export posters to PDF via Microsoft Edge headless (Windows built-in, no third-party lib)
REM 打印尺寸自由设定:任意宽度+高度(mm),默认 210 x 373.3 (9:16)
set "EDGE=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
if not exist "%EDGE%" set "EDGE=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
if not exist "%EDGE%" (
  echo [ERROR] Microsoft Edge not found.
  pause
  exit /b 1
)
cd /d "%~dp0"
set "DIR=%~dp0"

echo ============================================================
echo   请自由设定打印尺寸(单位 mm,按设定尺寸输出,两侧无黑边)
echo   常用参考: 9:16=210x373.3  3:4=210x280  A4=210x297
echo   直接回车使用默认值(宽 210,高按 9:16 自动计算)
echo ============================================================
set "PW=210"
set /p PW=请输入打印宽度(mm),回车默认 210: 
echo %PW%| findstr /r "^[1-9][0-9]*$" >nul || (
  echo [错误] 无效宽度: %PW%
  pause
  exit /b 1
)
REM 默认高度 = 宽 * 16 / 9 (保留一位小数)
set /a PH10=%PW% * 160 / 9
set /a PHI=%PH10% / 10
set /a PHF=%PH10% %% 10
set "PH=%PHI%.%PHF%"
set /p PH=请输入打印高度(mm),回车默认 %PH% 即 9:16: 
set "PHOK="
echo %PH%| findstr /r "^[1-9][0-9]*$" >nul && set PHOK=1
echo %PH%| findstr /r "^[1-9][0-9]*\.[0-9][0-9]*$" >nul && set PHOK=1
if not defined PHOK (
  echo [错误] 无效高度: %PH%
  pause
  exit /b 1
)
echo 打印尺寸: %PW%mm x %PH%mm
echo.

set /a N=0
for %%f in ("竖版海报1-政策动态.html" "竖版海报2-行业趋势.html" "竖版海报3-技术部信条.html" "竖版海报4-数据治理价值.html") do (
  set /a N+=1
  REM unique user-data-dir per file avoids Edge instance lock conflict
  set "UDD=%TEMP%\edge-pdf-!N!-%RANDOM%%RANDOM%"
  set "TMPF=%DIR%_tmp_export.html"
  echo Exporting: %%~nxf
  del "%%~dpnf.pdf" 2>nul
  copy /y "%%~ff" "!TMPF!" >nul
  REM inject custom page size; poster fits page by width or height, background fills the rest (no black edges)
  powershell -NoProfile -Command "$c=Get-Content -Raw -Encoding UTF8 -LiteralPath '!TMPF!'; $c=$c -replace '@page \{ size: [0-9.]+mm [0-9.]+mm;', ('@page { size: %PW%mm %PH%mm;'); Set-Content -LiteralPath '!TMPF!' -Value $c -Encoding UTF8 -NoNewline"
  "%EDGE%" --headless --disable-gpu --user-data-dir="!UDD!" --print-to-pdf="%%~dpnf.pdf" "!TMPF!" 2>nul
  if not exist "%%~dpnf.pdf" timeout /t 6 /nobreak >nul
  if exist "%%~dpnf.pdf" (
    echo   OK  -^> %%~nf.pdf
  ) else (
    echo   FAILED
  )
  rmdir /s /q "!UDD!" 2>nul
  del "!TMPF!" 2>nul
)
echo.
echo All done.
pause
