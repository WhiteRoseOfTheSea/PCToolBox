@echo off
:: Removes the bundled SDIO (Snappy Driver Installer Origin) and its driver
:: packs to reclaim disk space. Driver packs can take up tens of GB once
:: fully downloaded. Use "Install Drivers" again afterwards to fetch a fresh
:: copy and re-download driver packs on demand.

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

set "sdioDir=%windir%\PCToolsModules\Toolbox\Tools\SDIO"

if not exist "%sdioDir%" (
    echo The driver tool isn't installed, nothing to remove.
    if "%*"=="" pause
    exit /b 0
)

echo Removing the driver tool and any downloaded driver packs...
rmdir /s /q "%sdioDir%"

if "%~1"=="/silent" exit /b
echo Finished.
pause
exit /b
