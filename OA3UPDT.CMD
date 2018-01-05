REM *************************************************************************************************
REM  OA3UPDT.CMD - Batch program to update OA3 DPK & OS Licence Description for Windows 8.x/1- System
REM  Support OS: 32BitWinPE,64BitWinPE
REM  Ver 1.0 (2015-08-04) Init Version
REM
REM Usage:  OA3UPDT.BAT  dpk_stat [wk_dir] [mkr_dir]
REM           dpk_stat   ... DPK State to be updated
REM                             WIN     - DPK for Win8.x/Win10 SKU
REM                             NODPK   - No OA3 DPK 
REM           wk_dir     ... Path for work directory where all required tools reside
REM                          Below default path will be used if not specified
REM                            DSKT_DIR=A:
REM                            PGMS_DIR=C:\FLASH
REM
REM          dsk_dir     ... Path for the folder where OA3.BIN reside
REM                          If no specified, the same folder as working folder shall be used
REM
REM   This batch program will update both DPK and OS Licence Description in SMBIOS based on
REM   the requested DPK state.
REM
REM   History:
REM     2015-08-05  Jacky Liu Initial for ThinkPad SkyLake Products
REM *************************************************************************************************

if %PROCESSOR_ARCHITECTURE% == AMD64 SET OSBIT=64
if %PROCESSOR_ARCHITECTURE% == x86 SET OSBIT=32

:START
REM ///////////////////////////////////////////
REM    Validation for Specified Options
REM ///////////////////////////////////////////

SET PGMS_DIR=%TEST_DRV%\%WFTDIR%\
SET DSKT_DRV=%CTL_DRV%\%MTSN%\
SET OA3_DRV=C:\A\

IF "%2" == "" GOTO   DSK_PATH
SET DSKT_DRV=%2
SET PGMS_DIR=%2

:DSK_PATH
IF "%3" == "" GOTO   DEF_PATH
SET DSKT_DRV=%3

:DEF_PATH

if "%1"=="" goto E_NOOPT

ECHO.OA3UPDT.BAT Dated 2015-08-05 - Rev0
ECHO.OA3UPDT.BAT %1 %2 %3           
ECHO.OA3UPDT.BAT Dated 2015-08-05 - Rev0>> %DSKT_DRV%TESTER.LOG
ECHO.OA3UPDT.BAT %1 %2 %3           >> %DSKT_DRV%TESTER.LOG
ECHO.////////////////////////////// >> %DSKT_DRV%TESTER.LOG

if exist %DSKT_DRV%OA3UPDT.DON  del %DSKT_DRV%OA3UPDT.DON > nul
                                                                        
REM /////////////////////////////////////////////////////////////
REM       Preparation/Validation for Reqruied Files/Tools 
REM /////////////////////////////////////////////////////////////

if not exist %PGMS_DIR%LNVOA3W%OSBIT%.EXE   goto E_NOTOOL
if not exist %PGMS_DIR%NULL02.BIN   goto E_NOTOOL
if not exist %PGMS_DIR%DIS02.BIN    goto E_NOTOOL

REM /////////////////////////////////////////////////////////////
REM       DISPATCH OPERATION FOR SPECIFIED OS SKU OPTION 
REM /////////////////////////////////////////////////////////////
REM       WIN   - Windows 8.x/10 SKU
REM       NODPK - Non Windows 8.x SKU (Windows 7/DOS/Linux etc)
REM 

if "%1" == "WIN"   goto OP_WIN
if "%1" == "win"   goto OP_WIN

if "%1" == "NODPK" goto OP_NODPK
if "%1" == "nodpk" goto OP_NODPK
goto E_INVOPT


REM ////////////////////////////////////////////////////////////////////////////
REM    Process Entry For Windows 8.x SKU/10
REM ////////////////////////////////////////////////////////////////////////////
:OP_WIN

::Decrypts OA3 DPK to Local disk, skip this step if no encrypted DPK exist in %MTSN%
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set DPKTOOL=ENDPK64.EXE) else (set DPKTOOL=ENDPK32.EXE)

if exist %CTL_DRV%\%MTSN%\OA3.DAT (
	if exist %OA3_DRV%OA3.BIN goto CK4DPKPN
	if not exist %TEST_DRV%\%WFTDIR%\%DPKTOOL% goto DPKTOOL_LOST
	pushd %CTL_DRV%\%MTSN%
	%TEST_DRV%\%WFTDIR%\%DPKTOOL% Dxx %OA3_DRV%
	if errorlevel 1 goto DECRYPT_ERR
	if not exist %OA3_DRV%OA3.BIN goto DECRYPT_ERR
	echo Decrypts OA3 DPK successfully!! >>%CTL_DRV%\%MTSN%\tester.log
	popd
)
set DPKTOOL=

if exist %OA3_DRV%OA3.BIN goto CK4DPKPN
if exist %CTL_DRV%\%MTSN%\OA3.BIN copy %CTL_DRV%\%MTSN%\OA3.BIN C:\A

:CK4DPKPN
echo.
echo.OA3UPDT.BAT: Checking for PICI.INI file existance in %CTL_DRV%\%MTSN% ...
echo.OA3UPDT.BAT: Checking for PICI.INI file existance in %CTL_DRV%\%MTSN% ... >> %DSKT_DRV%TESTER.LOG
IF NOT EXIST %CTL_DRV%\%MTSN%\PICI.INI GOTO E_NOPICI

echo.Found!
echo.Found! >> %DSKT_DRV%TESTER.LOG

echo.OA3UPDT.BAT: Checking DPK PN Info in %CTL_DRV%\%MTSN%\PICI.INI ...
echo.OA3UPDT.BAT: Checking DPK PN Info in %CTL_DRV%\%MTSN%\PICI.INI ... >> %DSKT_DRV%TESTER.LOG

WININI%OSBIT%.exe -r %CTL_DRV%\%MTSN%\PICI.INI OS ITEMCODE ITEMCODE DPK.BAT
IF ERRORLEVEL 1 GOTO FAIL
CALL DPK.BAT

if @%ITEMCODE%@==@@       GOTO E_DPKPN
if  %ITEMCODE% ==ININULL  GOTO E_DPKPN

echo.DPK PN (%ITEMCODE%) Found!
echo.DPK PN (%ITEMCODE%) Found! >> %DSKT_DRV%TESTER.LOG
SET DPKPN=%ITEMCODE%

:DPKPNCKD

:CK4DESC
echo.OA3UPDT.BAT: Checking DPK DESC Info in %CTL_DRV%\%MTSN%\PICI.INI ...
echo.OA3UPDT.BAT: Checking DPK DESC Info in %CTL_DRV%\%MTSN%\PICI.INI ... >> %DSKT_DRV%TESTER.LOG

WININI%OSBIT%.exe -r %CTL_DRV%\%MTSN%\PICI.INI OS DESC DESC DESC.BAT
IF ERRORLEVEL 1 GOTO FAIL
CALL DESC.BAT

if @%DESC%@==@@       GOTO E_DESCST
if  %DESC% ==ININULL  GOTO E_DESCST

echo.DPK Description (%DESC%) Found!
echo.DPK Description (%DESC%) Found! >> %DSKT_DRV%TESTER.LOG

:DESCCKD

echo.
echo.OA3UPDT.BAT: Requested Windows SKU is Windows8.x/10  
echo.OA3UPDT.BAT: Requested Windows SKU is Windows8.x/10  >> %DSKT_DRV%TESTER.LOG

echo.OA3UPDT.BAT: Checking for OA3.BIN existance on %OA3_DRV% ...
echo.OA3UPDT.BAT: Checking for OA3.BIN existance on %OA3_DRV% ... >> %DSKT_DRV%TESTER.LOG
IF NOT EXIST %OA3_DRV%OA3.BIN GOTO E_NOOA3

echo.
echo.OA3.BIN FOUND! OK!
echo.OA3.BIN FOUND! OK! >> %DSKT_DRV%TESTER.LOG
echo.------------ OA3.BIN Contentes ------------- >> %DSKT_DRV%TESTER.LOG
REM type %OA3_DRV%OA3.BIN >> %DSKT_DRV%TESTER.LOG
echo.------------ OA3.BIN Contentes -Remove Show By OA3 Decrypts ------------- >> %DSKT_DRV%TESTER.LOG

echo.
echo.Injecting DPK to Target System ...
echo.Injecting DPK to Target System ...>> %DSKT_DRV%TESTER.LOG
%PGMS_DIR%LNVOA3W%OSBIT%.EXE /bcp %PGMS_DIR%NULL02.BIN /slp %OA3_DRV%OA3.BIN > LNVOA3.LOG
IF ERRORLEVEL 1 GOTO E_OA3UP

type LNVOA3.LOG >> %DSKT_DRV%TESTER.LOG
echo.
echo.Success! 
echo.Success! >> %DSKT_DRV%TESTER.LOG

echo.OA3UPDT.BAT: Verifying for MSDM Table existance on Target System ...
echo.OA3UPDT.BAT: Verifying for MSDM Table existance on Target System ... >> %DSKT_DRV%TESTER.LOG
oa3tool.exe /validate > MSDMCHK.LOG
IF not "%ERRORLEVEL%" == "0"  GOTO E_NOMSDM

type MSDMCHK.LOG
type MSDMCHK.LOG >> %DSKT_DRV%TESTER.LOG
echo.
echo.Success! 
echo.Success! >> %DSKT_DRV%TESTER.LOG

:DPKDESC
echo.
echo.Updating OS Licence Description ("%DPKPN% %DESC%") in SMBIOS ...
echo.Updating OS Licence Description ("%DPKPN% %DESC%") in SMBIOS ... >> %DSKT_DRV%TESTER.LOG
%PGMS_DIR%LNVOA3W%OSBIT%.EXE /osw "%DPKPN% %DESC%" > LNVOA3.LOG
IF ERRORLEVEL 1 GOTO E_DESCUP

REM  type LNVOA3.LOG
type LNVOA3.LOG >> %DSKT_DRV%TESTER.LOG
echo.
echo.Success! 
echo.Success! >> %DSKT_DRV%TESTER.LOG

echo.
echo.Verifying OS Licence Description ("%DPKPN% %DESC%") in SMBIOS ...
echo.Verifying OS Licence Description ("%DPKPN% %DESC%") in SMBIOS ... >> %DSKT_DRV%TESTER.LOG
%PGMS_DIR%LNVOA3W%OSBIT%.EXE /osv "%DPKPN% %DESC%" > LNVOA3.LOG
IF ERRORLEVEL 1 GOTO E_DESCVF

type LNVOA3.LOG
type LNVOA3.LOG >> %DSKT_DRV%TESTER.LOG
echo.
echo.Success! 
echo.Success! >> %DSKT_DRV%TESTER.LOG

echo.
echo.OA3UPDT.BAT: DPK Injection for Windows 8.x Completed Successfully.
echo.OA3UPDT.BAT: DPK Injection for Windows 8.x Completed Successfully.>> %DSKT_DRV%TESTER.LOG

if exist %OA3_DRV%OA3.BIN (
	if exist c:\A\OA3.BIN del C:\A\OA3.BIN
	if exist S:\A\OA3.BIN del S:\A\OA3.BIN
	if exist Q:\A\OA3.BIN del Q:\A\OA3.BIN
	del %OA3_DRV%OA3.BIN
	echo empty >%CTL_DRV%\%MTSN%\OA3.BIN		
)

GOTO OA3_DONE


REM ////////////////////////////////////////////////////////////////////////////
REM    Process Entry For NO DPK SKU
REM ////////////////////////////////////////////////////////////////////////////

:OP_NODPK
echo.
echo.OA3UPDT.BAT: NO DPK State is requested ...
echo.OA3UPDT.BAT: NO DPK State is requested ... >> %DSKT_DRV%TESTER.LOG

REM @si20130207 - START
echo.
echo.Verifying Initial DPK State ...
echo.Verifying Initial DPK State ... >> %DSKT_DRV%TESTER.LOG
%PGMS_DIR%LNVOA3W%OSBIT%.EXE /oa3v Disable  > LNVOA3.LOG
IF ERRORLEVEL 1 GOTO SET2DISB

type LNVOA3.LOG
type LNVOA3.LOG >> %DSKT_DRV%TESTER.LOG
echo.
echo.Success! 
echo.Success! >> %DSKT_DRV%TESTER.LOG

echo.
echo.Initial DPK State is Disabled (NO DPK). So, No need to set Disable marker. 
echo.Initial DPK State is Disabled (NO DPK). So, No need to set Disable marker.  >> %DSKT_DRV%TESTER.LOG
GOTO DPK_DLTD

:SET2DISB
REM @si20130207 - END
echo.
echo.Disabling DPK with %PGMS_DIR%DIS02.BIN ...
echo.Disabling DPK with %PGMS_DIR%DIS02.BIN ... >> %DSKT_DRV%TESTER.LOG
%PGMS_DIR%LNVOA3W%OSBIT%.EXE /bcp %PGMS_DIR%DIS02.BIN  > LNVOA3.LOG
IF ERRORLEVEL 1 GOTO E_NODPK

REM  type LNVOA3.LOG
type LNVOA3.LOG >> %DSKT_DRV%TESTER.LOG
echo.
echo.Success! 
echo.Success! >> %DSKT_DRV%TESTER.LOG

echo.
echo.Verifying NO DPK is set (Disable State) ...
echo.Verifying NO DPK is set (Disable State) ... >> %DSKT_DRV%TESTER.LOG
%PGMS_DIR%LNVOA3W%OSBIT%.EXE /oa3v Disable  > LNVOA3.LOG
IF ERRORLEVEL 1 GOTO E_NODPK

type LNVOA3.LOG
type LNVOA3.LOG >> %DSKT_DRV%TESTER.LOG
echo.
echo.Success! 
echo.Success! >> %DSKT_DRV%TESTER.LOG

echo.
echo.NO DPK(OA3 Marker) Set OK!
echo.NO DPK(OA3 Marker) Set OK! >> %DSKT_DRV%TESTER.LOG

REM @si20130207 - START
:DPK_DLTD

echo.
echo.Verifying OS Description Variable condition ...
echo.Verifying OS Description Variable condition ... >> %DSKT_DRV%TESTER.LOG
%PGMS_DIR%LNVOA3W%OSBIT%.EXE /osv " " > LNVOA3.LOG

FIND.EXE /I "Can not find Variable" LNVOA3.LOG
IF NOT ERRORLEVEL 1 GOTO OS_DELTD
REM @si20130207 - END

REM @si20120923 Modified for OS Desc change from No DPK to EMPTY - START -
echo.
echo.Deleting OS Licence Description in SMBIOS ...
echo.Deleting OS Licence Description in SMBIOS ... >> %DSKT_DRV%TESTER.LOG
%PGMS_DIR%LNVOA3W%OSBIT%.EXE /osdelete > LNVOA3.LOG
IF ERRORLEVEL 1   GOTO E_DESCUP
GOTO OS_DELTD

:OS_DELTD
REM @si20120923 - END -

REM  type LNVOA3.LOG
type LNVOA3.LOG >> %DSKT_DRV%TESTER.LOG
echo.
echo.Success! 
echo.Success! >> %DSKT_DRV%TESTER.LOG

echo.
echo.OA3UPDT.BAT: DPK DISABLED for NO DPK SKU Successfully.
echo.OA3UPDT.BAT: DPK DISABLED for NO DPK SKU Successfully. >> %DSKT_DRV%TESTER.LOG

GOTO OA3_DONE

:OA3_DONE
echo.OA3 Marker Update Completed Successfully > %DSKT_DRV%OA3UPDT.DON

exit /b 0
goto exit


REM @si20130207
:E_NOTOOL
echo. **********************************************************************
echo. OA3UPDT.BAT: Required Tool not found in specified folder %PGMS_DIR% !
echo. **********************************************************************
echo. OA3UPDT.BAT: Required Tool not found in specified folder %PGMS_DIR% ! >> %DSKT_DRV%TESTER.LOG
exit /b 1
goto exit


:E_NOOA3
echo. ******************************************************************
echo. OA3UPDT.BAT: OA3.BIN not found in %OA3_DRV% !
echo. ******************************************************************
echo. OA3UPDT.BAT: OA3.BIN not found in %OA3_DRV% ! >> %DSKT_DRV%TESTER.LOG
exit /b 1
goto exit

:E_OA3UP
type LNVOA3.LOG
type LNVOA3.LOG >> %DSKT_DRV%TESTER.LOG
echo. ******************************************************************
echo. OA3UPDT.BAT: Failed to update DPK with %OA3_DRV%OA3.BIN !
echo. ******************************************************************
echo. OA3UPDT.BAT: Failed to update DPK with %OA3_DRV%OA3.BIN ! >> %DSKT_DRV%TESTER.LOG
exit /b 1
goto exit

:E_INVOPT
echo. ******************************************************************
echo. OA3UPDT.BAT: ERROR - Invalid Option specfied. 
echo. OA3UPDT.BAT %1 %2 %3 %4 %5 %6 %7 %8 %9
echo. ******************************************************************
echo. OA3UPDT.BAT: ERROR - Invalid Option specfied.  >> %DSKT_DRV%TESTER.LOG
echo. OA3UPDT.BAT %1 %2 %3 %4 %5 %6 %7 %8 %9         >> %DSKT_DRV%TESTER.LOG
exit /b 1
goto exit

:E_NOMSDM
type MSDMCHK.LOG
type MSDMCHK.LOG >> %DSKT_DRV%TESTER.LOG
echo.
echo. **************************************************************************
echo. OA3UPDT.BAT:ERROR - MSDM Table (OA3 DPK) not SET on Tartet System !
echo. **************************************************************************
echo. OA3UPDT.BAT:ERROR - MSDM Table (OA3 DPK) not SET on Tartet System ! >> %DSKT_DRV%TESTER.LOG
exit /b 1
goto exit


:E_DESCUP
type LNVOA3.LOG
type LNVOA3.LOG >> %DSKT_DRV%TESTER.LOG
echo.
echo. **************************************************************************
echo. OA3UPDT.BAT:ERROR - Failed to update OS Licence Description !
echo. **************************************************************************
echo. OA3UPDT.BAT:ERROR - Failed to update OS Licence Description ! >> %DSKT_DRV%TESTER.LOG
exit /b 1
goto exit

:E_DESCVF
type LNVOA3.LOG
type LNVOA3.LOG >> %DSKT_DRV%TESTER.LOG
echo.
echo. **************************************************************************
echo. OA3UPDT.BAT:ERROR - OS Licence Description Verify Failed!
echo. **************************************************************************
echo. OA3UPDT.BAT:ERROR - OS Licence Description Verify Failed! >> %DSKT_DRV%TESTER.LOG
exit /b 1
goto exit

:E_OA21VF
type SSP2.LOG
type SSP2.LOG >> %DSKT_DRV%TESTER.LOG
echo.
echo. **************************************************************************
echo. OA3UPDT.BAT:ERROR - OA2.1 Marker not SET !
echo. **************************************************************************
echo. OA3UPDT.BAT:ERROR - OA2.1 Marker not SET ! >> %DSKT_DRV%TESTER.LOG
exit /b 1
goto exit

:E_NOSLIC
type SSP2.LOG
type SSP2.LOG >> %DSKT_DRV%TESTER.LOG
echo.
echo. **************************************************************************
echo. OA3UPDT.BAT:ERROR - NO SLIC Marker Update/Verify Failed !
echo. **************************************************************************
echo. OA3UPDT.BAT:ERROR - NO SLIC Marker Update/Verify Failed ! >> %DSKT_DRV%TESTER.LOG
exit /b 1
goto exit

:E_NODPK
type LNVOA3.LOG
type LNVOA3.LOG >> %DSKT_DRV%TESTER.LOG
echo. ******************************************************************
echo. OA3UPDT.BAT:ERROR - NO DPK State Update/Verify Failed !
echo. ******************************************************************
echo. OA3UPDT.BAT: NO DPK State Update/Verify Failed ! >> %DSKT_DRV%TESTER.LOG
exit /b 1
goto exit

:E_NOPICI
echo. ******************************************************************
echo. OA3UPDT.BAT:ERROR - PICI.INI not found!
echo. ******************************************************************
echo. OA3UPDT.BAT:ERROR - PICI.INI not found! >> %DSKT_DRV%TESTER.LOG
exit /b 1
goto exit

:E_DPKPN
echo. ******************************************************************
echo. OA3UPDT.BAT:ERROR - DPK PN not defined in PICI.INI!
echo. ******************************************************************
echo. OA3UPDT.BAT:ERROR - DPK PN not defined in PICI.INI! >> %DSKT_DRV%TESTER.LOG
exit /b 1
goto exit

:E_DESCST
echo. ******************************************************************
echo. OA3UPDT.BAT:ERROR - DPK Description not defined in PICI.INI!
echo. ******************************************************************
echo. OA3UPDT.BAT:ERROR - DPK Description not defined in PICI.INI! >> %DSKT_DRV%TESTER.LOG
exit /b 1
goto exit

:E_OA21ST
echo. ******************************************************************
echo. OA3UPDT.BAT:ERROR - DPK OA2.1 State not defined in PICI.INI!
echo. ******************************************************************
echo. OA3UPDT.BAT:ERROR - DPK OA2.1 State not defined in PICI.INI! >> %DSKT_DRV%TESTER.LOG
exit /b 1
goto exit


:E_NOOPT
echo.
echo. ******************************************************************
echo. OA3UPDT.BAT:ERROR - No Option Specified.
echo. ******************************************************************
echo. OA3UPDT.BAT:ERROR - No Option Specified. >> %DSKT_DRV%TESTER.LOG
exit /b 1
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
REM @si20131202
SET DPKPN=
SET ITEMCODE=
SET DESC=
SET OA21STAT=
%DSKT_DRV%
 
