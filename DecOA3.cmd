@echo off

if %PROCESSOR_ARCHITECTURE% == AMD64 SET OSBIT=64
if %PROCESSOR_ARCHITECTURE% == x86 SET OSBIT=32

:START
REM ///////////////////////////////////////////
REM    Validation for Specified Options
REM ///////////////////////////////////////////

SET PGMS_DIR=%TEST_DRV%\%WFTDIR%\
SET DSKT_DRV=%CTL_DRV%\%MTSN%\

::Decrypts OA3 DPK to Local/Network disk, skip this step if no encrypted DPK exist in %MTSN%
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set DPKTOOL=ENDPK64.EXE) else (set DPKTOOL=ENDPK32.EXE)

if exist %CTL_DRV%\%MTSN%\OA3.DAT (
	if not exist %TEST_DRV%\%WFTDIR%\%DPKTOOL% goto DPKTOOL_LOST
	pushd %CTL_DRV%\%MTSN%
	%TEST_DRV%\%WFTDIR%\%DPKTOOL% Dxx C:\A
	if errorlevel 1 goto DECRYPT_ERR
	if not exist C:\A\OA3.BIN goto DECRYPT_ERR
	echo Decrypts OA3 DPK successfully!! >>%CTL_DRV%\%MTSN%\tester.log
	popd
)
set DPKTOOL=

if exist C:\A\OA3.BIN goto WWDEC
if exist %CTL_DRV%\%MTSN%\OA3.BIN copy %CTL_DRV%\%MTSN%\OA3.BIN C:\A

:WWDEC
echo Start check OA3 file and to decrypt or not! >> %CTL_DRV%\%MTSN%\tester.log

O:

if not exist %TEST_DRV%\%WFTDIR%\tdcchk%OSBIT%.exe goto NO_TOOL                     
if not exist %TEST_DRV%\%WFTDIR%\crypt%OSBIT%.exe goto NO_TOOL 

COPY %TEST_DRV%\%WFTDIR%\crypt%OSBIT%.exe
COPY %TEST_DRV%\%WFTDIR%\tdcchk%OSBIT%.exe

if not exist crypt%OSBIT%.exe goto NO_TOOL
if not exist tdcchk%OSBIT%.exe goto NO_TOOL

echo Check the OA3.BIN file for DEC >> %CTL_DRV%\%MTSN%\tester.log

tdcchk%OSBIT%.exe Uxx %CTL_DRV%\%MTSN%\ %MTSN% %UUT_MACADDR% %TEST_GROUP%
If errorlevel 1 goto PASS

echo Start decrypt ... >> %CTL_DRV%\%MTSN%\tester.log
crypt%OSBIT%.exe -df 128 C:\A\OA3.BIN C:\A\OA3.DEC
if errorlevel 1 goto DEC_FAIL
copy C:\A\OA3.DEC C:\A\OA3.BIN
del C:\A\OA3.DEC
del tdcchk%OSBIT%.exe
del crypt%OSBIT%.exe

ping 127.0.0.1
goto PASS


:NO_TOOL
echo.
echo. **************************************************************************
echo. DECOA3.CMD:ERROR - NO TOOL FOR THIS PROCESS !
echo. **************************************************************************
echo. DECOA3.CMD:ERROR - Tools for decpry has not found! >> %CTL_DRV%\%MTSN%\Tester.log
exit /b 1
goto exit

:DEC_FAIL
echo.
echo. **************************************************************************
echo. DECOA3.CMD:ERROR - DEC OA3 FAIL !
echo. **************************************************************************
echo. DECOA3.CMD:ERROR - DEC OA3 FAIL, PLEASE ASK TE's HELP! >> %CTL_DRV%\%MTSN%\Tester.log
exit /b 1
goto exit


:PASS
echo Dec OA3 FILE finished ... >>%CTL_DRV%\%MTSN%\Tester.log
exit /b 0
goto exit

:DPKTOOL_LOST
color c
cls
echo ****************************************
echo Error: Can't find %TEST_DRV%\%WFTDIR%\%DPKTOOL%
echo ****************************************
pause
goto DPKTOOL_LOST

:DECRYPT_ERR
color c
cls
echo ****************************************
echo Error: Decrypts OA3 DPK fail!
echo ****************************************
pause
goto DECRYPT_ERR

:exit
SET PGMS_DIR=
SET DSKT_DRV=
%DSKT_DRV%
 