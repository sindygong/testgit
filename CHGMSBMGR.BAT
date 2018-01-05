@echo on
::
:: CHGMSBMGR.BAT - Batch Script to Manipulate MS Boot Manager Boot Priority in Boot Order
::
:: Usage: CHGMSBMGR.BAT [FIRST|LAST|REMOVE]
::
:: 2015-02-22 S.Ikeda Initial
:: 2015-02-23 S.Ikeda Added the check code for ESP with S drive letter to avoid the error
::                    in case ESP drive letter already assigned
:: 2015-09-12 Jacky.L Check file exist on partition S, Then start to change Windows Boot Manger Priority
::                    Windows Boot Manager only created when SSD have content
:: 2016-03-14 Jacky.L Modified to goto pass if no bcd file exist then bcdedit will return with errorlevel 1
:: 2016-04-14 Jacky.L Modified to check if BCD exist on par2 on some custom image.
:: 2016-12-06 Jerry.H Modified to call drvnum.bat and select correct boot HDD.
:: 2017-04-19 Jerry.H Modified to add remove retry to fix issue found in WV4 custom image.
:: 2017-04-21 Jerry.H Modified to fix NO OS retry issue.
:: 2017-10-25 Jacky.L Modified to fix issue found on custom image with Lagacy PXE + Legacy Image
::

echo.
echo.Changing MS Boot Manager Boot Priority in Boot Order ...
echo.

MParse.exe /?
call drvnum.bat

echo.
echo.Assigning drive letter S: for EFI System Partition ..

if exist S:\efi\boot\bootx64.efi goto ESP_FND

echo select disk %HDD0% > %~n0.SCP
echo select partition 1 >> %~n0.SCP
echo assign letter s >> %~n0.SCP

echo.
echo.Checking file existance for %~n0.SCP ...
if not exist %~n0.SCP goto FAILEXIT
echo.Found. OK.

diskpart /s %~n0.SCP
rem modified for no preload
rem if errorlevel 1 goto FAILEXIT
rem echo.Done!

if exist S:\efi\boot\bootx64.efi goto ESP_FND
if exist S:\nonefi\boot\bootx64.efi goto ESP_FND

:REMOVE_RETRY
echo select disk %HDD0% > %~n0.SCP
echo select partition 1 >> %~n0.SCP
echo remove             >> %~n0.SCP
echo select partition 2 >> %~n0.SCP
echo assign letter s >> %~n0.SCP

echo.
echo.Checking file existance for %~n0.SCP ...
if not exist %~n0.SCP goto FAILEXIT
echo.Found. OK.

diskpart /s %~n0.SCP >%~n0.log

if exist S:\efi\boot\bootx64.efi goto ESP_FND
if exist S:\nonefi\boot\bootx64.efi goto ESP_FND

REM Issue found with Wolverine4 custom image
find /i "The specified drive letter is not free to be assigned"  %~n0.log
if not errorlevel 1 goto REMOVE_RETRY
goto PASSEXIT

:ESP_FND
bcdedit /set {bootmgr} device partition=s:
rem Modified to goto pass if no BCD file exist then bcdedit will return with errorlevel 1
rem if errorlevel 1 goto PASSEXIT
if errorlevel 1 goto PASSEXIT


rem ++++++++++++++++++++++++++++++++++++++++++++++++++
REM Updated on 2017/10/25 to fix issue on custom image

bcdedit > bcdedit.txt
find /i "winload.exe" bcdedit.txt
if errorlevel 1 goto WINLOADEFI
goto PASSEXIT

REM Updated on 2017/10/25 to fix issue on custom image
rem ++++++++++++++++++++++++++++++++++++++++++++++++++

:WINLOADEFI

if /I "%1" EQU "FIRST" (
        echo.
        echo.Changing to FIRST ...
        bcdedit /set {fwbootmgr} displayorder {bootmgr} /addfirst
        if errorlevel 1 goto FAILEXIT
        echo.
        echo.Done!

) else if /I "%1" EQU "LAST" (
        echo.
        echo.Changing to LAST ...
        bcdedit /set {fwbootmgr} displayorder {bootmgr} /addlast
        if errorlevel 1 goto FAILEXIT
        echo.
        echo.Done!

) else if /I "%1" EQU "REMOVE" (
        echo.
        echo.Removing ...
        bcdedit /set {fwbootmgr} displayorder {bootmgr} /remove
        if errorlevel 1 goto FAILEXIT
        echo.
        echo.Done!
) else (
        echo.
        echo.Unknown Option or No option specified. so DO NOTHING.
        echo.
        echo.
)

goto PASSEXIT

:FAILEXIT
echo.
echo.
echo.  Operation Failed!!
echo.
echo.
pause
pause
goto FAILEXIT

:PASSEXIT
echo.
echo.
echo.  Operation completed successfully!!
echo.
echo.
goto EXIT

:EXIT

