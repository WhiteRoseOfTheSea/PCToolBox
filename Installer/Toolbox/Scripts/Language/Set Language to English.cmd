@echo off
set "___args="%~f0" %*"
fltmc > nul 2>&1 || (
    echo Administrator privileges are required.
    powershell -c "Start-Process -Verb RunAs -FilePath 'cmd' -ArgumentList """/c $env:___args"""" 2> nul || (
        echo You must run this script as admin.
        if "%*"=="" pause
        exit /b 1
    )
    exit /b
)

powershell -EP Bypass -NoP -File "%~dp0SetLanguage.ps1" -Lang en-US -GeoId 244
if %errorlevel% neq 0 (
    echo error: failed to set the language. See the message above for details.
    if "%*"=="" pause
    exit /b 1
)

if "%~1"=="/silent" exit /b
echo Finished. Please restart your device for all changes to apply.
pause
exit /b
