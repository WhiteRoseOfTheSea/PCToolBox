@echo off
:: Extends the Windows system partition (normally %SystemDrive%) using any
:: unallocated space on the disk. If a Recovery partition is found right
:: after it, deletes it first to free up its space too.
::
:: WARNING: if the Recovery partition is deleted, the local "Reset this PC" /
:: WinRE recovery option will no longer be available (reinstalling Windows
:: from USB/ISO is still possible).
::
:: Useful for FOG-deployed gold images: the captured image is often smaller
:: than the destination disk, leaving unallocated space after deployment
:: that this merges into the system partition.

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

setlocal enabledelayedexpansion
set "TARGET_DRIVE=%SystemDrive:~0,1%"
set "TMP1=%temp%\dp_listdisk.txt"
set "TMP2=%temp%\dp_listpart.txt"
set "DPSCRIPT1=%temp%\dp1.txt"
set "DPSCRIPT2=%temp%\dp2.txt"
set "DPSCRIPT3=%temp%\dp3.txt"

:: Step 1: find the disk number that contains the target volume
(
    echo select volume %TARGET_DRIVE%
    echo list disk
) > "%DPSCRIPT1%"
diskpart /s "%DPSCRIPT1%" > "%TMP1%"

set "DISKNUM="
for /f "tokens=1,2,3 delims= " %%A in ('findstr /R "\*" "%TMP1%"') do (
    if not defined DISKNUM if /i "%%B"=="Disk" set "DISKNUM=%%C"
)

if not defined DISKNUM (
    echo Couldn't determine the disk number. Aborting.
    type "%TMP1%"
    del "%DPSCRIPT1%" "%TMP1%" >nul 2>&1
    if "%~1"=="/silent" exit /b 1
    pause
    exit /b 1
)

echo Found disk: Disk %DISKNUM%

:: Step 2: look for a Recovery partition on that disk (best effort, may not exist)
(
    echo select disk %DISKNUM%
    echo list partition
) > "%DPSCRIPT2%"
diskpart /s "%DPSCRIPT2%" > "%TMP2%"

set "RECPART="
for /f "tokens=1,2,3 delims= " %%A in ('findstr /I "Recovery" "%TMP2%"') do (
    if not defined RECPART if /i "%%A"=="Partition" set "RECPART=%%B"
)

if defined RECPART (
    echo Recovery partition found: Partition %RECPART%
    echo Deleting it and extending %TARGET_DRIVE%: with the freed + unallocated space...
    (
        echo select disk %DISKNUM%
        echo select partition %RECPART%
        echo delete partition override
        echo select volume %TARGET_DRIVE%
        echo extend
    ) > "%DPSCRIPT3%"
) else (
    echo No Recovery partition found on disk %DISKNUM%.
    echo Extending %TARGET_DRIVE%: using any unallocated space on the disk...
    (
        echo select disk %DISKNUM%
        echo select volume %TARGET_DRIVE%
        echo extend
    ) > "%DPSCRIPT3%"
)

diskpart /s "%DPSCRIPT3%"

del "%DPSCRIPT1%" "%DPSCRIPT2%" "%DPSCRIPT3%" "%TMP1%" "%TMP2%" >nul 2>&1

if "%~1"=="/silent" exit /b 0

echo.
echo Finished. Check "Disk Management" to verify.
pause
