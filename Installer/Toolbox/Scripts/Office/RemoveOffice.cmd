@echo off
:: Silently removes all installed Click-to-Run Office products using the
:: official Microsoft Office Deployment Tool (ODT), the supported method
:: for unattended Office removal.
:: ODT's setup.exe must be staged in the gold image under
:: PCToolsModules\Toolbox\Tools\ODT\setup.exe (download from Microsoft:
:: https://aka.ms/officedeploymenttool).

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

set "odtDir=%windir%\PCToolsModules\Toolbox\Tools\ODT"
set "odtExe=%odtDir%\setup.exe"
set "odtConfig=%odtDir%\remove-all-config.xml"

if not exist "%odtExe%" (
    echo error: Office Deployment Tool wasn't found in "%odtDir%".
    echo Download it from https://aka.ms/officedeploymenttool and place setup.exe there.
    if "%*"=="" pause
    exit /b 1
)

if not exist "%odtConfig%" (
    echo error: "%odtConfig%" wasn't found.
    if "%*"=="" pause
    exit /b 1
)

echo Removing all installed Office products...
echo This can take a few minutes.
"%odtExe%" /configure "%odtConfig%"

if "%~1"=="/silent" exit /b

echo Finished. Please reboot your device to complete the removal.
pause
exit /b
