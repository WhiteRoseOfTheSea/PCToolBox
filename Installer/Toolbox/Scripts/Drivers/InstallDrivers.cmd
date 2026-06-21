@echo off
:: Runs the bundled SDIO (Snappy Driver Installer Origin) fully unattended
:: to detect this machine's hardware and install missing/better drivers.
:: Uses driver packs already staged in the gold image if present (offline),
:: otherwise downloads only what's needed from SDIO's own update servers
:: (requires internet). SDIO itself is staged under
:: PCToolsModules\Toolbox\Tools\SDIO.

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
    echo error: SDIO wasn't found in "%sdioDir%".
    echo Make sure it's staged in the gold image under PCToolsModules\Toolbox\Tools\SDIO.
    if "%*"=="" pause
    exit /b 1
)

set "sdioExe="
for /f "delims=" %%f in ('dir /b /a-d "%sdioDir%\SDIO_x64*.exe" 2^>nul') do set "sdioExe=%%f"
if not defined sdioExe (
    for /f "delims=" %%f in ('dir /b /a-d "%sdioDir%\SDIO_R*.exe" 2^>nul') do set "sdioExe=%%f"
)
if not defined sdioExe (
    echo error: couldn't find the SDIO executable in "%sdioDir%".
    if "%*"=="" pause
    exit /b 1
)

echo Checking for newer/missing driver packs (best effort, needs internet)...
pushd "%sdioDir%"
"%sdioExe%" -autoupdate -autoclose -nogui

echo Installing missing and better drivers for this machine...
echo This can take a while depending on how many drivers need to be installed.
"%sdioExe%" -script:scripts\pctools-install.txt
popd

if "%~1"=="/silent" exit /b

echo Finished. Please reboot your device for all driver changes to apply.
pause
exit /b
