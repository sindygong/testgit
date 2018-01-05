##########################################################################################
# ME11R6VPRO.NSH - EFI Shell Script for Intel Kabylake ME 11.6 MFG Flow at Box MFG
#
# Usage: ME11R6VPRO.NSH FW_PKG FW_BLD FW_VER FW_MODE SKU_CFG LK_CTRL [ToolPath] [LogPath]
#
# where  FW_PKG(%1)    - Name of ME FW Package    
#        FW_BLD(%2)    - MEFW Build ID to be updated 
#        FW_VER(%3)    - MEFW Version to be verified
#        FW_MODE(%4)   - ME FW Update Mode
#                           FORCE - Always update FW regardless of current FW version
#                                   (Only when the flash descriptor was still unlocked)
#                           AUTO  - Update FW only when FW version does not match with 
#                                    the expected version
#        SKU_CFG(%5)   - vPro/Non-vPro SKU Configuration for Shipment
#                           VPRO        -  Configure as vPro     System
#                           VPRONOWLAN  -  Configure as vPro     System w/o WLAN (for Shell)
#                           NONVPRO     -  Configure as Non-vPro System
#        LK_CTRL(%6)   - Flash Descriptor Lock-down control (LOCK/UNLOCK)
#                           LOCK will be set as default if not specified
#        ToolPath(%7)  - Folder where all required tool reside
#                        Current working folder shall be used as Default if not specified
#        LogPath(%8)   - Destination folder where Test Log/Result file shall be created
#                        Current working folder shall be used as Default if not specified
#
#  Output:
#        TESTER.LOG       - Test Log
#        ME11R6VPRO.DON   - Test Result Flag for PASS case
#        ME11R6VPRO.ERR   - Test Result Flag for FAIL case
#
#  Support ME FW:       
#       
#        FW Build ID    Product         MEFW SKU    %MEFW_SKU%  %PCH_SKU%
#       --------------  -------------   ----------  ----------  ---------
#       R0IMBxxW        WV-4            Corporate   VPRO        LP
#       R0INBxxW        WV-4            Consumer    NONVPRO     LP
#       R0GMVxxW        Larue-3         Corporate   VPRO        LP
#       R0GMFxxW        Larue-3         Consumer    NONVPRO     LP
#       N1MRMxxW        Yoda-1          Corporate   VPRO        LP
#       N1MRNxxW        Yoda-1          Consumer    NONVPRO     LP
#       N1QRMxxW        Windu-1         Corporate   VPRO        LP
#       N1QRNxxW        Windu-1         Consumer    NONVPRO     LP
#       N1WRMxxW        Thorpe-2        Corporate   VPRO        LP
#       N1WRNxxW        Thorpe-2        Consumer    NONVPRO     LP
#       R0FMVxxW        Taylor-2        Corporate   VPRO        H
#       R0FMFxxW        Taylor-2        Consumer    NONVPRO     H
#       N1URMxxW        Walter/Payton-2 Corporate   VPRO        H
#       N1URNxxW        Walter/Payton-2 Consumer    NONVPRO     H
#       R0HRMxxW        Storm-2         Corporate   VPRO        LP
#       R0HRNxxW        Storm-2         Consumer    NONVPRO     LP
#       N1NRMxxW        Raven-2         Corporate   VPRO        LP
#       N1NRNxxW        Raven-2         Consumer    NONVPRO     LP
#       N1XRMxxW        LIN-2           Corporate   VPRO        LP
#       N1XRNxxW        LIN-2           Consumer    NONVPRO     LP
# 
#  Support Products:            
#                       - WV-4              (R0IMBxxW/R0INBxxW)
#                       - Larue-3           (R0GMVxxW/R0GMFxxW)
#                       - Yoda-1            (N1MRMxxW/N1MRNxxW)
#                       - Windu-1           (N1QRMxxW/N1QRNxxW)
#                       - Thorpe-2          (N1WRMxxW/N1WRNxxW)
#                       - Taylor-2          (R0FMVxxW/R0FMFxxW)
#                       - Walter/Payton-2   (N1URMxxW/N1URNxxW)
#                       - Storm-2   (R0HRMxxW/R0HRNxxW)
#                       - Raven-2   (N1NRMxxW/N1NRNxxW)
#                       - LIN-2     (N1XRMxxW/N1XRNxxW)
#
# History:
#   2016-08-29 S.Ikeda  Initial based on below ME11.6 MFG FLOW
#                       KBL_Intel ME 11.6 MFG Flow_2016.08.26_Yoda1_Raven2.xlsx
#                       KBL_Intel ME 11.6 MFG Flow_2016.08.18_LCFC.xlsx (Windu-1/PTWT-2) 
#   2016-09-06 S.Ikeda  Fixed invalid option to chkdesc.efi at PCH_VER check step
#                       option must be lower case
#   2016-11-09 S.Ikeda  Added Step9_5 for Global Reset after Wireless u-code update
#                       based on the updated ME11.6 MFG FLOW  below
#                       KBL_Intel ME 11.6 MFG Flow_2016.11.09_Yoda1_Raven2_v2.xlsx
#   2016-11-10 S.Ikeda  Added the code to initialize desc.bin/me.bin/me_upd.bin on root folder
#                       Added the code to handle desc_LK.bin as default descriptor file name
#                       for some MEFW packages
#   2017-01-18 S.Ikeda  Added ME Unconfiguration Step into STEP1 
#                       for vPro customization order support in MP
#   2017-02-12 S.Ikeda  Added descriptor condition check at STEP11 
#                       to handle system with ME locked already
#   2017-02-13 Jacky.L  Update Validation for Specified MEFW Package against Target System for Thorpe-2
#   2017-02-13 Jacky.L  Update Use Method for Variables to Fix "Syntax after analyzing ==" error with using UDK UEFI SHELL.
#   2017-04-10 Jacky.L  Update Validation for Specified MEFW Package against Target System for WV3/Larue-3/Taylor-2/Walter-2/Patyon-2
#   2017-05-16 Sindy.G  Update Validation for Specified MEFW Package against Target System for Storm-2
#   2017-06-06 Sindy.G  Update Validation for Specified MEFW Package against Target System for Raven-2
#   2017-05-23 S.Ikeda  Added the code to use MEINFO.OVR as MEINFO.EFI if exist
#                       This is temp W/A for the issue of MEINFO.EFI v11.6.29.3287
#   2017-07-13 Sindy.G  Update Validation for Specified MEFW Package against Target System for LIN-2
#   2017-11-02 S.Ikeda  Update for ME 11.8.50.3425 deployment for KBL/SKB 
#                       Removed W/A code for ME 11.6.29.3287
#   2017-11-06 S.Ikeda  Update for ME 11.8.50.3425 with following below ME11.x MFG Flow 
#                       KBL_Intel ME 11.x MFG Flow_2017.11.02_Yoda1_Raven2.xlsx
#   2017-11-10 S.Ikeda  Added the code to use MEManuf.116 as MEManuf.EFI if descriptor already locked with ME11.6
#                       KBL_Intel ME 11.x MFG Flow_2017.11.10_Yoda1_Raven2.xlsx
##########################################################################################
echo -off
 
########################## 
# SETUP
##########################
set -v NSHNAME ME11R6VPRO
set -v NSHVER 2017-11-10-Rev.0
set -v LOGPATH %cwd%
set -v TOOLPATH %cwd%
set -v ORGCWD %cwd%
set -v DLY 10

# Setup for LogPath(%8)
if not %8 == "" then
    set -v LOGPATH %8
endif

if not %7 == "" then
    set -v TOOLPATH %7
    goto PATH_DEFD
else
    if not %6 == "" then
        goto PATH_DEFD
    else
        goto E_FEWOPT
    endif
endif

:PATH_DEFD

# Setup for FW_PKG(%1)
if not exist %TOOLPATH%%1\FPT.EFI then
    goto E_NOPKG
else
    set -v MEFWPATH %TOOLPATH%%1\
endif

# Setup FW_BLD(%2)
set -v FW_BLD %2

# Setup FW_VER(%3)
set -v FW_VER %3

# Setup FW_MODE(%4)
if %4 == AUTO then
    set -v FW_MODE AUTO
else
    if %4 == FORCE then 
        set -v FW_MODE FORCE
    else
        goto E_INVOPT
    endif
endif

# Setup SKU_CFG(%5)
if %5 == VPRO then
    set -v SKU_CFG VPRO
    set -v WLAN_CFG WLAN
else
    if %5 == VPRONOWLAN then
        set -v SKU_CFG VPRO
        set -v WLAN_CFG NOWLAN
    else
        if %5 == NONVPRO then 
            set -v SKU_CFG NONVPRO
        else
            goto E_INVOPT
        endif
    endif
endif

# Setup LK_CTRL(%6)
if %6 == LOCK then
    set -v LK_CTRL LOCK
else
    if %6 == UNLOCK then 
        set -v LK_CTRL UNLOCK
    else
        goto E_INVOPT
    endif
endif

# Initialization for Flag File
if exist %LOGPATH%%NSHNAME%.ERR then 
     del %LOGPATH%%NSHNAME%.ERR
endif

if exist %LOGPATH%%NSHNAME%.DON then 
     del %LOGPATH%%NSHNAME%.DON
endif


##########################
# START
##########################
date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo "Running ME11R6VPRO.NSH -- Dated %NSHVER%" 
echo ==================================================================
echo %0 %1 %2 %3 %4 %5 %6 %7 %8 
#@si20170118c
echo (Executed from %ORGCWD%)
echo ==================================================================
echo "Running ME11R6VPRO.NSH -- Dated %NSHVER%" >>a %LOGPATH%TESTER.LOG
echo ================================================================== >>a %LOGPATH%TESTER.LOG
echo %0 %1 %2 %3 %4 %5 %6 %7 %8 (Executed from %ORGCWD%) >>a %LOGPATH%TESTER.LOG
echo ================================================================== >>a %LOGPATH%TESTER.LOG

##############################################################
# Preparation/Validation for Required Files/Tools 
##############################################################
echo .
echo "Checking for ME FW Utility Package Folder (%MEFWPATH%) ..."
echo "Checking for ME FW Utility Package Folder (%MEFWPATH%) ..." >>a %LOGPATH%TESTER.LOG
if not exist %MEFWPATH%MEINFO.EFI then
    goto E_NOPKG
endif

echo .
echo "Copying Other Required Tools in %TOOLPATH% to %MEFWPATH% ..."
echo "Copying Other Required Tools in %TOOLPATH% to %MEFWPATH% ..." >>a %LOGPATH%TESTER.LOG
copy -q %TOOLPATH%FINDSTRG.EFI %MEFWPATH%
copy -q %TOOLPATH%ACSTAT.EFI   %MEFWPATH%
copy -q %TOOLPATH%TPMFGFLG.EFI %MEFWPATH%
copy -q %TOOLPATH%MEMFGCTL.EFI %MEFWPATH%
copy -q %TOOLPATH%DELAY.EFI    %MEFWPATH%

##@si20171102c -START-
##@si20170523c -START-
#if exist %TOOLPATH%MEINFO.OVR then
#    echo .
#    echo "Copying %TOOLPATH%MEINFO.OVR as %MEFWPATH%MEINFO.EFI ..."
#    echo "Copying %TOOLPATH%MEINFO.OVR as %MEFWPATH%MEINFO.EFI ..." >>a %LOGPATH%TESTER.LOG
#   copy -q %TOOLPATH%MEINFO.OVR    %MEFWPATH%
#   cd %MEFWPATH%
#   if not exist MEINFO.ORG then
#       copy -q MEINFO.EFI    MEINFO.ORG
#   endif
#   copy -q MEINFO.OVR    MEINFO.EFI
#   cd %ORGCWD%
#endif
##@si20170523c -END-
##@si20171102c -END-

##@si20171110c -START-
if exist %TOOLPATH%MEManuf.116 then
   if not exist %MEFWPATH%MEManuf.116 then
       echo .
       echo "Copying %TOOLPATH%MEManuf.116 as %MEFWPATH%..."
       echo "Copying %TOOLPATH%MEManuf.116 as %MEFWPATH% ..." >>a %LOGPATH%TESTER.LOG
       copy -q %TOOLPATH%MEManuf.116    %MEFWPATH%
   endif
   if not exist %MEFWPATH%vsccommn.116 then
       echo .
       echo "Copying %TOOLPATH%vsccommn.116 as %MEFWPATH%..."
       echo "Copying %TOOLPATH%vsccommn.116 as %MEFWPATH% ..." >>a %LOGPATH%TESTER.LOG
       copy -q %TOOLPATH%vsccommn.116    %MEFWPATH%
   endif
endif
##@si20171110c -END-


echo .
echo "Verifying for Other Required Tools in ME Package Folder %MEFWPATH% ..."
echo "Verifying for Other Required Tools in ME Package Folder %MEFWPATH% ..." >>a %LOGPATH%TESTER.LOG
if not exist %TOOLPATH%FINDSTRG.EFI then
    goto E_NOTOOL
endif
if not exist %TOOLPATH%ACSTAT.EFI then
    goto E_NOTOOL
endif
if not exist %TOOLPATH%TPMFGFLG.EFI then
    goto E_NOTOOL
endif
if not exist %TOOLPATH%MEMFGCTL.EFI then
    goto E_NOTOOL
endif
if not exist %TOOLPATH%DELAY.EFI then
    goto E_NOTOOL
endif
if not exist %TOOLPATH%PhyID64e.efi then
    goto E_NOTOOL
endif

echo .
echo "Verified. OK"
echo "Verified. OK" >>a %LOGPATH%TESTER.LOG

# Move CWD to ME FW Package Folder
cd %MEFWPATH%

##############################################################
#  Validation for Specified MEFW Package against Target System
##############################################################
echo .
echo "Verifying for the specified ME PKG(%FW_BLD%) against ME on Target System ..."
echo "Verifying for the specified ME PKG(%FW_BLD%) against ME on Target System ..." >>a %LOGPATH%TESTER.LOG

# Note - Redirect output needs to be ASCII text format with 'a'
CHKDESC.EFI >a CHKDESC.LOG
echo %FW_BLD% >a FW_BLD.LOG
##@SG20170713 -START-
# LIN-2 N1XRMxxW - VPRO MEFW
:N1XRMxxW
FINDSTRG.EFI "OEMdata0  = N1XRM" CHKDESC.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto N1XRNxxW
endif
FINDSTRG.EFI "N1XRM" FW_BLD.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
set -v MEFW_SKU VPRO
set -v PCH_SKU LP
set -v BLD_ID N1X
goto PKGVFYOK

# LIN-2 N1XRNxxW - NON-VPRO MEFW
:N1XRNxxW
FINDSTRG.EFI "OEMdata0  = N1XRN" CHKDESC.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto N1NRMxxW
endif
FINDSTRG.EFI "N1XRN" FW_BLD.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
set -v MEFW_SKU NONVPRO
set -v PCH_SKU LP
set -v BLD_ID N1X
goto PKGVFYOK
##@SG20170713 -END-

##@SG20170606 -START-
# RVN-2 N1NRMxxW - VPRO MEFW
:N1NRMxxW
FINDSTRG.EFI "OEMdata0  = N1NRM" CHKDESC.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto N1NRNxxW
endif
FINDSTRG.EFI "N1NRM" FW_BLD.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
set -v MEFW_SKU VPRO
set -v PCH_SKU LP
set -v BLD_ID N1N
goto PKGVFYOK

# RVN-2 N1NRNxxW - NON-VPRO MEFW
:N1NRNxxW
FINDSTRG.EFI "OEMdata0  = N1NRN" CHKDESC.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto R0HRMxxW
endif
FINDSTRG.EFI "N1NRN" FW_BLD.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
set -v MEFW_SKU NONVPRO
set -v PCH_SKU LP
set -v BLD_ID N1N
goto PKGVFYOK
##@SG20170606 -END-

##@SG20170516 -START-
# STM-2 R0HRMxxW - VPRO MEFW
:R0HRMxxW
FINDSTRG.EFI "OEMdata0  = R0HRM" CHKDESC.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto R0HRNxxW
endif
FINDSTRG.EFI "R0HRM" FW_BLD.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
set -v MEFW_SKU VPRO
set -v PCH_SKU LP
set -v BLD_ID R0H
goto PKGVFYOK

# STM-2 R0HRNxxW - NON-VPRO MEFW
:R0HRNxxW
FINDSTRG.EFI "OEMdata0  = R0HRN" CHKDESC.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto R0IMBxxW
endif
FINDSTRG.EFI "R0HRN" FW_BLD.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
set -v MEFW_SKU NONVPRO
set -v PCH_SKU LP
set -v BLD_ID R0H
goto PKGVFYOK
##@SG20170606 -END-

# WV-4 R0IMBxxW - VPRO MEFW
:R0IMBxxW
FINDSTRG.EFI "OEMdata0  = R0IMB" CHKDESC.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto R0INBxxW
endif
FINDSTRG.EFI "R0IMB" FW_BLD.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
set -v MEFW_SKU VPRO
set -v PCH_SKU LP
set -v BLD_ID R0I
goto PKGVFYOK

# WV-4 R0INBxxW - NON-VPRO MEFW
:R0INBxxW
FINDSTRG.EFI "OEMdata0  = R0INB" CHKDESC.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto R0GMVxxW
endif
FINDSTRG.EFI "R0INB" FW_BLD.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
set -v MEFW_SKU NONVPRO
set -v PCH_SKU LP
set -v BLD_ID R0I
goto PKGVFYOK

# Larue-3 R0GMVxxW - VPRO MEFW
:R0GMVxxW
FINDSTRG.EFI "OEMdata0  = R0GMV" CHKDESC.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto R0GMFxxW
endif
FINDSTRG.EFI "R0GMV" FW_BLD.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
set -v MEFW_SKU VPRO
set -v PCH_SKU LP
set -v BLD_ID R0G
goto PKGVFYOK

# Larue-3 R0GMFxxW - NON-VPRO MEFW
:R0GMFxxW
FINDSTRG.EFI "OEMdata0  = R0GMF" CHKDESC.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto N1MRMxxW
endif
FINDSTRG.EFI "R0GMF" FW_BLD.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
set -v MEFW_SKU NONVPRO
set -v PCH_SKU LP
set -v BLD_ID R0G
goto PKGVFYOK

# Yoda-1 N1MRMxxW - VPRO MEFW
:N1MRMxxW
FINDSTRG.EFI "OEMdata0  = N1MRM" CHKDESC.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto N1MRNxxW
endif
FINDSTRG.EFI "N1MRM" FW_BLD.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
set -v MEFW_SKU VPRO
set -v PCH_SKU LP
set -v BLD_ID N1M
goto PKGVFYOK

# Yoda-1 N1MRNxxW - Non-VPRO MEFW
:N1MRNxxW
FINDSTRG.EFI "OEMdata0  = N1MRN" CHKDESC.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto N1QRMxxW
endif
FINDSTRG.EFI "N1MRN" FW_BLD.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
set -v MEFW_SKU NONVPRO
set -v PCH_SKU LP
set -v BLD_ID N1M
goto PKGVFYOK

# Windu-1 N1QRMxxW - VPRO MEFW
:N1QRMxxW
FINDSTRG.EFI "OEMdata0  = N1QRM" CHKDESC.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto N1QRNxxW
endif
FINDSTRG.EFI "N1QRM" FW_BLD.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
set -v MEFW_SKU VPRO
set -v PCH_SKU LP
set -v BLD_ID N1Q
goto PKGVFYOK

# Windu-1 N1QRNxxW - NON-VPRO MEFW
:N1QRNxxW
FINDSTRG.EFI "OEMdata0  = N1QRN" CHKDESC.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto N1WRMxxW
endif
FINDSTRG.EFI "N1QRN" FW_BLD.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
set -v MEFW_SKU NONVPRO
set -v PCH_SKU LP
set -v BLD_ID N1Q
goto PKGVFYOK

# Thorpe-2 N1WRMxxW - VPRO MEFW
:N1WRMxxW
FINDSTRG.EFI "OEMdata0  = N1WRM" CHKDESC.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto N1WRNxxW
endif
FINDSTRG.EFI "N1WRM" FW_BLD.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
set -v MEFW_SKU VPRO
set -v PCH_SKU LP
set -v BLD_ID N1W
goto PKGVFYOK

# Thorpe-2 N1WRNxxW - NON-VPRO MEFW
:N1WRNxxW
FINDSTRG.EFI "OEMdata0  = N1WRN" CHKDESC.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto R0FMVxxW
endif
FINDSTRG.EFI "N1WRN" FW_BLD.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
set -v MEFW_SKU NONVPRO
set -v PCH_SKU LP
set -v BLD_ID N1W
goto PKGVFYOK

# Taylor-2 R0FMVxxW - VPRO MEFW
:R0FMVxxW
FINDSTRG.EFI "OEMdata0  = R0FMV" CHKDESC.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto R0FMFxxW
endif
FINDSTRG.EFI "R0FMV" FW_BLD.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
set -v MEFW_SKU VPRO
set -v PCH_SKU H
set -v BLD_ID R0F
goto PKGVFYOK

# Taylor-2 R0FMFxxW - NON-VPRO MEFW
:R0FMFxxW
FINDSTRG.EFI "OEMdata0  = R0FMF" CHKDESC.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto N1URMxxW
endif
FINDSTRG.EFI "R0FMF" FW_BLD.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
set -v MEFW_SKU NONVPRO
set -v PCH_SKU H
set -v BLD_ID R0F
goto PKGVFYOK

# Walter/Payton-2 N1URMxxW - VPRO MEFW
:N1URMxxW
FINDSTRG.EFI "OEMdata0  = N1URM" CHKDESC.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto N1URNxxW
endif
FINDSTRG.EFI "N1URM" FW_BLD.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
set -v MEFW_SKU VPRO
set -v PCH_SKU H
set -v BLD_ID N1U
goto PKGVFYOK

# Walter/Payton-2 N1URNxxW - NON-VPRO MEFW
:N1URNxxW
FINDSTRG.EFI "OEMdata0  = N1URN" CHKDESC.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
FINDSTRG.EFI "N1URN" FW_BLD.LOG /INV >>a %LOGPATH%TESTER.LOG
if not %lasterror% == 0 then
    goto E_INVPKG
endif
set -v MEFW_SKU NONVPRO
set -v PCH_SKU H
set -v BLD_ID N1U
goto PKGVFYOK

:PKGVFYOK
echo .
echo "Specified ME PKG(%FW_BLD%) matched with MEFW Build ID on Target System ..."
echo "Specified ME PKG(%FW_BLD%) matched with MEFW Build ID on Target System ..." >>a %LOGPATH%TESTER.LOG
echo "Verified OK."
echo "Verified OK." >>a %LOGPATH%TESTER.LOG
#type CHKDESC.LOG    >>a %LOGPATH%TESTER.LOG
#MEINFO.EFI >>a %LOGPATH%TESTER.LOG

# PCH(CPU) Version Check
    ##@si20160906c
    CHKDESC.EFI -oemdata4 ES >>a %LOGPATH%TESTER.LOG
    if %lasterror% == 0 then 
        set -v PCH_VER ES
    else
        set -v PCH_VER QS
    endif

# Log shell variables
echo "============= EFI Shell Variables ============" >>a %LOGPATH%TESTER.LOG
set >>a %LOGPATH%TESTER.LOG
echo "==============================================" >>a %LOGPATH%TESTER.LOG

# AC/DC Presence Check before starting process
echo .
echo "Checking for AC/DC Presence ..."
:NO_AC
DELAY.EFI 3

ACSTAT.EFI ATTACH
if not %lasterror% == 0 then
    goto NO_AC
else
    echo "Attached. OK"
endif

#############################
#  Flow Control
#############################
:FlowDispatch
# Check for Flow Control Flag
if not exist %LOGPATH%AMTSTATE.CTL then
    echo "%NSHNAME%.NSH - AMTSTATE.CTL file missing -- Start from STEP1_0"
    set AMTSTATE STEP1_0
else
# Check for Test Control Flag
    if '%AMTSTATE%' == '' then
        echo "%NSHNAME%.NSH - AMTSTATE is NULL -- Set to STEP1_0"
        set AMTSTATE STEP1_0
    endif
endif

goto %AMTSTATE%

# ========================================================================
#   STEP-1 : ME UnConfiguration 
# ========================================================================
:STEP1_0
date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

# Initialize Update State Variables
if not '%DESCUPDT%' == '' then
    set -d DESCUPDT
endif
if not '%MEFWUPDT%' == '' then
    set -d MEFWUPDT
endif
if not '%FWUPDLCL%' == '' then
    set -d FWUPDLCL 
endif


echo .
echo "STEP:1_0 Logging for Initial Descriptor Status ..."
echo "STEP:1_0 Logging for Initial Descriptor Status ..." >>a %LOGPATH%TESTER.LOG
type CHKDESC.LOG    >>a %LOGPATH%TESTER.LOG

echo .
echo "STEP:1_0 Logging for Initial ME Status ..."
echo "STEP:1_0 Logging for Initial ME Status ..." >>a %LOGPATH%TESTER.LOG
MEINFO.EFI >a MEINFO.LOG
if not %lasterror% == 0 then 
    goto E_MESTAT
endif
type MEINFO.LOG >>a %LOGPATH%TESTER.LOG

#@si20170118c -START-
:STEP1_1
if /i NOT '%LK_CTRL%' == 'LOCK' then
    set  AMTSTATE STEP2_0
    echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL
    goto IPL
endif

#  ME Unconfiguration Request
:STEP1_2
set  AMTSTATE STEP1_2
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL
echo .
echo "STEP:1_2 Requesting ME Unconfiguration at next boot ..."
echo "STEP:1_2 Requesting ME Unconfiguration at next boot ..." >>a %LOGPATH%TESTER.LOG
MEMFGCTL.EFI UNCFGME >a MEMFGCTL.Log
if not %lasterror% == 0 then
    goto E_EEPLKD
endif

echo "Done."
echo "Done." >>a %LOGPATH%TESTER.LOG

set  AMTSTATE STEP1_3
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL
goto IPL

#  Clear MFG Mode Flag
:STEP1_3
date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

echo "STEP:1_3 ME Unconfiguration completed! Clearing MFG Mode Flag ..."
echo "STEP:1_3 ME Unconfiguration completed! Clearing MFG Mode Flag ..." >>a %LOGPATH%TESTER.LOG

# Clear MFG Mode Flag to 0x0000 (default) if not cleared yet
TPMFGFLG.EFI /V 0X0000
if not %lasterror% == 0 then
    TPMFGFLG.EFI /S 0X0000
endif

echo "Done."
echo "Done." >>a %LOGPATH%TESTER.LOG

set  AMTSTATE STEP2_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL
goto IPL
#@si20170118c -END-

# ========================================================================
#   STEP-2 : Check ME Version
# ========================================================================
:STEP2_0
set  AMTSTATE STEP2_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

if '%FW_MODE%' == 'FORCE' then
    goto STEP3_0
endif

:STEP2_1
echo .
echo "STEP:2_1 Checking for ME FW Build ID (%FW_BLD%) ..."
echo "STEP:2_1 Checking for ME FW Build ID (%FW_BLD%) ..." >>a %LOGPATH%TESTER.LOG
CHKDESC.EFI  -oemdata0  %FW_BLD%
if not %lasterror% == 0 then 
    goto STEP3_0
endif

echo "Matched OK!"
echo "Matched OK!" >>a %LOGPATH%TESTER.LOG

:STEP2_2
echo .
echo "STEP:2_2 Checking for ME FW Version (%FW_VER% %PCH_SKU%) ..."
echo "STEP:2_2 Checking for ME FW Version (%FW_VER% %PCH_SKU%) ..." >>a %LOGPATH%TESTER.LOG
MEINFO.efi  -FEAT "FW Version"  -VALUE "%FW_VER% %PCH_SKU%"
if not %lasterror% == 0 then 
    goto STEP3_0
endif

echo "Matched OK!"
echo "Matched OK!" >>a %LOGPATH%TESTER.LOG

goto STEP7_0

# ========================================================================
#   STEP-3 : Check Descriptor Lock State ( & Firmware Update Local )
# ========================================================================
:STEP3_0
set  AMTSTATE STEP3_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

:STEP3_1
echo .
echo "STEP:3_1 Checking for Flash Descriptor Condition..."
echo "STEP:3_1 Checking for Flash Descriptor Condition..." >>a %LOGPATH%TESTER.LOG
MEINFO.efi  -FEAT "Host Write Access to ME"  -VALUE "Disabled" >a MEINFO.LOG
if %lasterror% == 0 then 
    echo "ME LOCKed."
    echo "ME LOCKed."  >>a %LOGPATH%TESTER.LOG
    type MEINFO.LOG    >>a %LOGPATH%TESTER.LOG
    set -v LK_STAT LOCKED
else
    echo "ME UNLOCKEDed."
    echo "ME UNLOCKEDed."  >>a %LOGPATH%TESTER.LOG
    type MEINFO.LOG        >>a %LOGPATH%TESTER.LOG
    set -v LK_STAT UNLOCKED
    goto STEP4_0
endif


##@si20171110c -START-
chkdesc.efi >a chkdesc.log
if exist chkdesc.log then
    FINDSTRG.EFI "OEMdata1  = 11.6" chkdesc.log /INV
    if %lasterror% == 0 then
        type chkdesc.log >>a %LOGPATH%TESTER.LOG
        if exist MEManuf.116 then
            if not exist MEManuf.org then
                copy -q MEManuf.EFI MEManuf.ORG
            endif
            echo .
            echo "Copying %TOOLPATH%MEManuf.116 as %MEFWPATH%MEManuf.EFI ..."
            echo "Copying %TOOLPATH%MEManuf.116 as %MEFWPATH%MEManuf.EFI ..." >>a %LOGPATH%TESTER.LOG           
            copy -q MEManuf.116 MEManuf.EFI
            
            if not exist vsccommn.org then
                copy -q vsccommn.bin vsccommn.ORG
            endif
            echo .
            echo "Copying %TOOLPATH%vsccommn.116 as %MEFWPATH%vsccommn.bin ..."
            echo "Copying %TOOLPATH%vsccommn.116 as %MEFWPATH%vsccommn.bin ..." >>a %LOGPATH%TESTER.LOG           
            copy -q vsccommn.116 vsccommn.bin
        endif
        
    endif
endif
##@si20171110c -END-


:STEP3_2
echo .
echo "STEP:3_2 Updating ME FW with FWUpdLcl.efi with ME_UPD_%PCH_VER%.BIN ..."
echo "STEP:3_2 Updating ME FW with FWUpdLcl.efi with ME_UPD_%PCH_VER%.BIN ..." >>a %LOGPATH%TESTER.LOG
#@si20161110c
del \ME_UPD.bin
copy -q ME_UPD_%PCH_VER%.bin \ME_UPD.bin
if not exist \ME_UPD.bin then
    echo .
    echo "\ME_UPD_%PCH_VER%.bin not found then use \ME_UPD.bin instead"
    echo "\ME_UPD_%PCH_VER%.bin not found then use \ME_UPD.bin instead" >>a %LOGPATH%TESTER.LOG
    copy -q ME_UPD.bin \
    if not exist \ME_UPD.bin then
        echo "Neither \ME_UPD_%PCH_VER%.bin nor \ME_UPD.bin found."
        echo "Neither \ME_UPD_%PCH_VER%.bin nor \ME_UPD.bin found." >>a %LOGPATH%TESTER.LOG
        goto E_NOPKG
    endif
endif

FWUpdLcl.efi -f ME_UPD.bin -OEMID 4C656E6F-766F-0000-0000-000000000000 -allowsv
if not %lasterror% == 0 then 
    goto E_FWLCL
endif

set FWUPDLCL UPDT
echo "Success."
echo "Success."  >>a %LOGPATH%TESTER.LOG

:STEP3_3
echo .
echo "STEP:3_3 Invoking Global Reset with FPT.EXE -GReset ..."
echo "STEP:3_3 Invoking Global Reset with FPT.EXE -GReset ..." >>a %LOGPATH%TESTER.LOG
#Delay for Write Access to Storage Devices
DELAY.efi %DLY%

# Recheck ME FW version
set  AMTSTATE STEP2_2
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

FPT.efi -GReset

:STEP3_4
echo .
echo "STEP:3_4 Global Reset did not happened by FPT.EXE -GReset. Try again ..."
echo "STEP:3_4 Global Reset did not happened by FPT.EXE -GReset. Try again ..." >>a %LOGPATH%TESTER.LOG
set  AMTSTATE STEP3_3
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL
goto IPL

# ========================================================================
#   STEP-4 :  Descriptor Update
# ========================================================================
:STEP4_0
set  AMTSTATE STEP4_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

echo .
echo "STEP:4_0 Checking for ME FW Build ID (%FW_BLD%) ..."
echo "STEP:4_0 Checking for ME FW Build ID (%FW_BLD%) ..." >>a %LOGPATH%TESTER.LOG
#@si20161110c
CHKDESC.EFI >>a %LOGPATH%TESTER.LOG
CHKDESC.EFI  -oemdata0  %FW_BLD%
if not %lasterror% == 0 then 
    goto STEP4_1
else
    echo "Matched OK!"
    echo "Matched OK!" >>a %LOGPATH%TESTER.LOG
    if '%FW_MODE%' == 'FORCE' then
        if not '%DESCUPDT%' == 'UPDT' then
            goto STEP4_1
        endif
    endif
    goto STEP5_0
endif

:STEP4_1
echo .
echo "STEP:4_1 Updating Flash Descriptor with desc_%PCH_VER%.bin (%FW_BLD%)..."
echo "STEP:4_1 Updating Flash Descriptor with desc_%PCH_VER%.bin (%FW_BLD%)..." >>a %LOGPATH%TESTER.LOG
#@si20161110c 
del \desc.bin
copy -q fparts.txt \
copy -q desc_%PCH_VER%.bin \desc.bin
if not exist \desc.bin then
    echo "\desc_%PCH_VER%.bin not found then use \desc.bin instead."
    echo "\desc_%PCH_VER%.bin not found then use \desc.bin instead." >>a %LOGPATH%TESTER.LOG
    copy -q desc.bin \
    if not exist \desc.bin then
        echo "Neither \desc_%PCH_VER%.bin nor \desc.bin found."
        echo "Neither \desc_%PCH_VER%.bin nor \desc.bin found." >>a %LOGPATH%TESTER.LOG
        goto E_NOPKG
    endif
endif

FPT.efi -desc -f desc.bin
if not %lasterror% == 0 then 
    goto E_UPDESC
endif

set DESCUPDT UPDT
echo "Success."
echo "Success."  >>a %LOGPATH%TESTER.LOG

# Recheck Descriptor Version
goto STEP4_0


# ========================================================================
#   STEP-5 :  ME FW Update
# ========================================================================
:STEP5_0
set  AMTSTATE STEP5_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

echo .
echo "STEP:5_0 Checking for ME FW Version (%FW_VER% %PCH_SKU%) ..."
echo "STEP:5_0 Checking for ME FW Version (%FW_VER% %PCH_SKU%) ..." >>a %LOGPATH%TESTER.LOG
MEINFO.efi  -FEAT "FW Version"  -VALUE "%FW_VER% %PCH_SKU%"
if not %lasterror% == 0 then 
    goto STEP5_1
else
    echo "Matched OK!"
    echo "Matched OK!" >>a %LOGPATH%TESTER.LOG
    if '%FW_MODE%' == 'FORCE' then
        if not '%MEFWUPDT%' == 'UPDT' then
            goto STEP5_1
        endif
    endif
        
    # Update State Counter to Next Step 
    if '%MEFW_SKU%' == 'NONVPRO' then
        set  AMTSTATE STEP10_0
    else
        set  AMTSTATE STEP7_0
    endif
    echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL   
    goto %AMTSTATE%
endif

:STEP5_1
echo .
echo "STEP:5_1 ME Firmware with ME_%PCH_VER%.bin (%FW_BLD%)..."
echo "STEP:5_1 ME Firmware with ME_%PCH_VER%.bin (%FW_BLD%)..." >>a %LOGPATH%TESTER.LOG
#@si20161110c
del \ME.bin
copy -q fparts.txt \
copy -q ME_%PCH_VER%.bin \ME.bin
if not exist \ME.bin then
    echo "\ME_%PCH_VER%.bin not found then use \ME.bin instead."
    echo "\ME_%PCH_VER%.bin not found then use \ME.bin instead." >>a %LOGPATH%TESTER.LOG
    copy -q ME.bin \
    if not exist \ME.bin then
        echo "Neither \ME_%PCH_VER%.bin nor \ME.bin found."
        echo "Neither \ME_%PCH_VER%.bin nor \ME.bin found." >>a %LOGPATH%TESTER.LOG
        goto E_NOPKG
    endif
endif

FPT.efi -me -f ME.bin
if not %lasterror% == 0 then 
    goto E_UPMEFW
endif

set MEFWUPDT UPDT
echo "Success."
echo "Success."  >>a %LOGPATH%TESTER.LOG

if not '%FWUPDLCL%' == '' then
    set -d FWUPDLCL
endif

goto STEP6_0

# ========================================================================
#   STEP-6 :  Global Reset
# ========================================================================
:STEP6_0
set  AMTSTATE STEP6_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

echo .
echo "STEP:6_0 Invoking Global Reset with FPT.EXE -GReset ..."
echo "STEP:6_0 Invoking Global Reset with FPT.EXE -GReset ..." >>a %LOGPATH%TESTER.LOG
#Delay for Write Access to Storage Devices
DELAY.efi %DLY%

# Recheck ME FW Version
set  AMTSTATE STEP5_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

FPT.efi -GReset

echo .
echo "STEP:6_1 Global Reset did not happened by FPT.EXE -GReset. Try again ..."
echo "STEP:6_1 Global Reset did not happened by FPT.EXE -GReset. Try again ..." >>a %LOGPATH%TESTER.LOG
set  AMTSTATE STEP6_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL
goto IPL

# ========================================================================
#   STEP-7 :  Clear M3 Test Result 
# ========================================================================
:STEP7_0
set  AMTSTATE STEP7_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

if '%SKU_CFG%' == 'NONVPRO'  then
    goto STEP10_0
endif

echo .
echo "STEP:7_0 Clearing Previous M3 Test Result in SPI ..."
echo "STEP:7_0 Clearing Previous M3 Test Result in SPI ..." >>a %LOGPATH%TESTER.LOG
MEMANUF.efi  -NextReboot
if not %lasterror% == 0 then 
    goto E_M3CLR
endif

echo "Success."
echo "Success."  >>a %LOGPATH%TESTER.LOG

goto STEP8_0

# ========================================================================
#   STEP-8 :  Global Reset
# ========================================================================
:STEP8_0
set  AMTSTATE STEP8_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

echo .
echo "STEP:8_0 Invoking Global Reset with FPT.EXE -GReset ..."
echo "STEP:8_0 Invoking Global Reset with FPT.EXE -GReset ..." >>a %LOGPATH%TESTER.LOG

# Update State Counter to Next Step 
set  AMTSTATE STEP9_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

#Delay for Write Access to Storage Devices
DELAY.efi %DLY%

FPT.efi -GReset

echo .
echo "STEP:8_1 Global Reset did not happened by FPT.EXE -GReset. Try again ..."
echo "STEP:8_1 Global Reset did not happened by FPT.EXE -GReset. Try again ..." >>a %LOGPATH%TESTER.LOG
set  AMTSTATE STEP7_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL
goto IPL


# ========================================================================
#   STEP-9 :  Update Wireless Micro-code
# ========================================================================
:STEP9_0
set  AMTSTATE STEP9_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

echo .
echo "STEP:9_0 Update Wireless Micro-code ..."
echo "STEP:9_0 Update Wireless Micro-code ...%" >>a %LOGPATH%TESTER.LOG

if '%SKU_CFG%' == 'NONVPRO'  then
    echo .
    echo "STEP:9_1 Requested SKU is %SKU_CFG% so DO NOTHING."
    echo "STEP:9_1 Requested SKU is %SKU_CFG% so DO NOTHING." >>a %LOGPATH%TESTER.LOG
    goto STEP10_0
endif

if '%WLAN_CFG%' == 'NOWLAN'  then
    echo .
    echo "STEP:9_1 NO WLAN SKU (%WLAN_CFG%) System so DO NOTHING."
    echo "STEP:9_1 NO WLAN SKU (%WLAN_CFG%) System so DO NOTHING." >>a %LOGPATH%TESTER.LOG
    goto STEP10_0
endif

#@si20161109c -START-
#if not '%FWUPDLCL%' == 'UPDT' then
#   echo .
#   echo "STEP:9_1 ME Region UNLOCKed so DO NOTHING."
#   echo "STEP:9_1 ME Region UNLOCKed so DO NOTHING." >>a %LOGPATH%TESTER.LOG
#    goto STEP10_0
#endif
#@si20161109c -START-

echo .
echo "STEP:9_2 Updating WLAN Micro-code with ME_UPD_%PCH_VER%.bin ..."
echo "STEP:9_2 Updating WLAN Micro-code with ME_UPD_%PCH_VER%.bin ..." >>a %LOGPATH%TESTER.LOG
#@si20170118c
del -q \ME_UPD.bin
copy -q ME_UPD_%PCH_VER%.bin \ME_UPD.bin
if not exist \ME_UPD.bin then
    echo "\ME_UPD_%PCH_VER%.bin not found the use\ME_UPD.bin instead."
    echo "\ME_UPD_%PCH_VER%.bin not found the use\ME_UPD.bin instead." >>a %LOGPATH%TESTER.LOG
    copy -q ME_UPD.bin \
    if not exist \ME_UPD.bin then
        echo "Neither \ME_UPD_%PCH_VER%.bin nor \ME_UPD.bin found."
        echo "Neither \ME_UPD_%PCH_VER%.bin nor \ME_UPD.bin found." >>a %LOGPATH%TESTER.LOG
        goto E_NOPKG
    endif
endif

FWUPDLCL.efi  -F  ME_UPD.bin  -PartID  WCOD >a FWupdLcl.LOG
if not %lasterror% == 0 then 
    goto E_WLMCUP
endif

echo "Success."
echo "Success."  >>a %LOGPATH%TESTER.LOG

#@si20161109c -START-
#goto STEP10_0
goto STEP9_5
#@si20161109c -END-

#@si20161109c -START-
# ========================================================================
#   STEP-9.5 :  Global Reset
# ========================================================================
:STEP9_5
set  AMTSTATE STEP9_5
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

echo .
echo "STEP:9_5 Invoking Global Reset with FPT.EXE -GReset ..."
echo "STEP:9_5 Invoking Global Reset with FPT.EXE -GReset ..." >>a %LOGPATH%TESTER.LOG

# Update State Counter to Next Step 
set  AMTSTATE STEP10_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

#Delay for Write Access to Storage Devices
DELAY.efi %DLY%

FPT.efi -GReset

echo .
echo "STEP:9_5 Global Reset did not happened by FPT.EXE -GReset. Try again ..."
echo "STEP:9_5 Global Reset did not happened by FPT.EXE -GReset. Try again ..." >>a %LOGPATH%TESTER.LOG
set  AMTSTATE STEP9_5
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL
goto IPL
#@si20161109c -END-

# ========================================================================
#   STEP-10 :  Validating Manufacture
# ========================================================================
:STEP10_0
set  AMTSTATE STEP10_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

:CHK4AC_10
echo "STEP:10_0 Checking/Waiting for AC connection ..."
echo "STEP:10_0 Checking/Waiting for AC connection ..." >>a %LOGPATH%TESTER.LOG
ACSTAT.EFI ATTACH
if not %lasterror% == 0 then 
    DELAY.EFI 3
    goto CHK4AC_10
endif

echo "AC Connected OK."
echo "AC Connected OK."  >>a %LOGPATH%TESTER.LOG

echo .
echo "STEP:10_0 ME Function Test with MEMANUF -VERBOSE ..."
echo "STEP:10_0 ME Function Test with MEMANUF -VERBOSE ..." >>a %LOGPATH%TESTER.LOG
MEMANUF.efi -VERBOSE >a MEMANUF.LOG
if not %lasterror% == 0 then 
    goto E_METST0
endif

echo "ME Function Test Passed."
echo "ME Function Test Passed."  >>a %LOGPATH%TESTER.LOG
type MEMANUF.LOG >>a %LOGPATH%TESTER.LOG

goto STEP10_5

# ========================================================================
#   STEP-10.5 :  vPro/Non-vPro SKU Validation
# ========================================================================
:STEP10_5
set  AMTSTATE STEP10_5
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

if '%MEFW_SKU%' == 'VPRO' then
    if '%SKU_CFG%' == 'VPRO'  then
        echo .
        echo "STEP:10_5 Verifying AMT Feature is Enabled for vPro SKU ..."
        echo "STEP:10_5 Verifying AMT Feature is Enabled for vPro SKU ..." >>a %LOGPATH%TESTER.LOG
        MEInfo.efi  -feat  "Intel(R) AMT State"  -value  "Enabled" >a MEINFO.LOG
        if not %lasterror% == 0 then 
            goto E_VF4VP
        endif
    else
        echo .
        echo "STEP:10_5 Verifying AMT Feature is Disabled for Non-vPro SKU ..."
        echo "STEP:10_5 Verifying AMT Feature is Disabled for Non-vPro SKU ..." >>a %LOGPATH%TESTER.LOG
        MEInfo.efi  -feat  "Intel(R) AMT State"  -value  "Enabled" >a MEINFO.LOG
        if %lasterror% == 0 then 
            goto E_VF4NVP
        endif
    endif
else
    ##@si20171106c -START-
    echo .
    echo "STEP:10_5 Do NOT care AMT Feature for Non-vPro FW SKU ..."
    echo "STEP:10_5 Do NOT care AMT Feature for Non-vPro FW SKU ..." >>a %LOGPATH%TESTER.LOG
    #MEInfo.efi  -feat  "Intel(R) AMT State"  -value  "Enabled" >a MEINFO.LOG
    #if %lasterror% == 0 then 
    #    goto E_VF4NVP
    #endif
    ##@si20171106c -END-
endif

echo "Verified OK."
echo "Verified OK."  >>a %LOGPATH%TESTER.LOG
type MEINFO.LOG >>a %LOGPATH%TESTER.LOG

# ========================================================================
#   STEP-10.6 :  Wired LAN Chip SKU Validation (MFG Local Enhancement)
# ========================================================================
:STEP10_6
set  AMTSTATE STEP10_6
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

if '%SKU_CFG%' == 'VPRO'  then
    echo .
    echo "STEP:10_6 Verifying Wired LAN Phy ID is i219LM for vPro SKU ..."
    echo "STEP:10_6 Verifying Wired LAN Phy ID is i219LM for vPro SKU ..." >>a %LOGPATH%TESTER.LOG
    %TOOLPATH%PhyID64e.efi >a PHYID.LOG
    if not %lasterror% == 7 then 
        goto E_VF4PHY
    endif
else
    echo .
    echo "STEP:10_6 Logging Wired LAN Phy ID due to Non-vPro SKU ..."
    echo "STEP:10_6 Logging Wired LAN Phy ID due to Non-vPro SKU ..." >>a %LOGPATH%TESTER.LOG
    %TOOLPATH%PhyID64e.efi >a PHYID.LOG
endif

echo "Verified OK."
echo "Verified OK."  >>a %LOGPATH%TESTER.LOG
type PHYID.LOG >>a %LOGPATH%TESTER.LOG

goto STEP11_0

# ========================================================================
#   STEP-11 :  Complete Manufacture
# ========================================================================
:STEP11_0
set  AMTSTATE STEP11_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

if '%LK_CTRL%' == 'UNLOCK' then
    goto STEP18_0
else 
    if not '%LK_CTRL%' == 'LOCK' then
        goto E_INVOPT
    endif
endif

#@si20170212c -START-
echo .
echo "STEP:11_0 Checking for Current Flash Descriptor Condition..."
echo "STEP:11_0 Checking for Current Flash Descriptor Condition..." >>a %LOGPATH%TESTER.LOG
MEINFO.efi  -FEAT "Host Write Access to ME"  -VALUE "Disabled" >a MEINFO.LOG
if %lasterror% == 0 then 
    echo "ME LOCKed. So NO need to lock again then Skip!"
    echo "ME LOCKed. So NO need to lock again then Skip!"  >>a %LOGPATH%TESTER.LOG
    type MEINFO.LOG    >>a %LOGPATH%TESTER.LOG
    set -v LK_STAT LOCKED
    goto STEP14_0
else
    echo "ME UNLOCKEDed. So Continue."
    echo "ME UNLOCKEDed. So Continue."  >>a %LOGPATH%TESTER.LOG
    type MEINFO.LOG        >>a %LOGPATH%TESTER.LOG
    set -v LK_STAT UNLOCKED
endif
#@si20170212c -END-

echo . 
echo "STEP:11_0 Starting Complete Manufacture Process with FPT -closemnf NO -y ..."
echo "STEP:11_0 Starting Complete Manufacture Process with FPT -closemnf NO -y ..." >>a %LOGPATH%TESTER.LOG

# Delay for Write Access to Storage Devices
DELAY.efi %DLY%

copy -q fparts.txt \
FPT.efi -closemnf NO -y
if not %lasterror% == 0 then 
    goto E_CMPMFG
endif

echo "Completed."
echo "Completed."  >>a %LOGPATH%TESTER.LOG

goto STEP12_0

# ========================================================================
#   STEP-12 :  Global Reset
# ========================================================================
:STEP12_0
set  AMTSTATE STEP12_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

echo .
echo "STEP:12_0 Invoking Global Reset with FPT.EXE -GReset ..."
echo "STEP:12_0 Invoking Global Reset with FPT.EXE -GReset ..." >>a %LOGPATH%TESTER.LOG

# Update State Counter to Next Step 
set  AMTSTATE STEP13_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

#Delay for Write Access to Storage Devices
DELAY.efi %DLY%

FPT.efi -GReset

echo .
echo "STEP:12_0 Global Reset did not happened by FPT.EXE -GReset. Try again ..."
echo "STEP:12_0 Global Reset did not happened by FPT.EXE -GReset. Try again ..." >>a %LOGPATH%TESTER.LOG
set  AMTSTATE STEP12_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL
goto IPL

# ========================================================================
#   STEP-13 :  Verify Descriptor Lock State
# ========================================================================
:STEP13_0
set  AMTSTATE STEP13_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

if '%FWUPDLCL%' == 'UPDT' then
    goto STEP14_0
endif

echo .
echo "STEP:13_0 Verifying Descriptor State ..."
echo "STEP:13_0 Verifying Descriptor State ..." >>a %LOGPATH%TESTER.LOG
#@si20170118c
del -q \deskLK.bin
copy -q fparts.txt \
copy -q desc_%PCH_VER%_LK.bin \descLK.bin
if not exist \descLK.bin then
    echo "\desc_%PCH_VER%_LK.bin not found then use\descLK.bin instead."
    echo "\desc_%PCH_VER%_LK.bin not found then use\descLK.bin instead." >>a %LOGPATH%TESTER.LOG
    #@si20161110c -START-
    if exist desc_LK.bin then
        copy -q desc_LK.bin descLK.bin
    endif
    #@si20161110c -END-
    copy -q descLK.bin \    
    if not exist \descLK.bin then
        echo "\descLK.bin not found."
        echo "\descLK.bin not found." >>a %LOGPATH%TESTER.LOG
        goto E_NOPKG
    endif
endif

FPT.efi  -desc  -verify  descLK.bin
if not %lasterror% == 0 then 
    goto E_DESCLK
endif

echo "Verified OK."
echo "Verified OK."  >>a %LOGPATH%TESTER.LOG

goto STEP14_0

# ========================================================================
#   STEP-14 :  Verify ME FW Version
# ========================================================================
:STEP14_0
set  AMTSTATE STEP14_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

echo .
echo "STEP:14_0 Verifying for ME FW Version (%FW_VER% %PCH_SKU%) ..."
echo "STEP:14_0 Verifying for ME FW Version (%FW_VER% %PCH_SKU%) ..." >>a %LOGPATH%TESTER.LOG
MEINFO.efi  -FEAT "FW Version"  -VALUE "%FW_VER% %PCH_SKU%" 
if not %lasterror% == 0 then 
    goto E_FWVER
endif

echo "Matched OK!"
echo "Matched OK!" >>a %LOGPATH%TESTER.LOG

goto STEP15_0

# ========================================================================
#   STEP-15 :  Verify AMT support of the system
# ========================================================================
:STEP15_0
set  AMTSTATE STEP15_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

if '%MEFW_SKU%' == 'VPRO' then
    if '%SKU_CFG%' == 'VPRO'  then
        echo .
        echo "STEP:15_0 Verifying AMT Feature is Enabled for vPro SKU ..."
        echo "STEP:15_0 Verifying AMT Feature is Enabled for vPro SKU ..." >>a %LOGPATH%TESTER.LOG
        MEInfo.efi  -feat  "Intel(R) AMT State"  -value  "Enabled" >a MEINFO.LOG
        if not %lasterror% == 0 then 
            goto E_VF4VP
        endif
    else
        echo .
        echo "STEP:15_0 Verifying AMT Feature is Disabled for Non-vPro SKU ..."
        echo "STEP:15_0 Verifying AMT Feature is Disabled for Non-vPro SKU ..." >>a %LOGPATH%TESTER.LOG
        MEInfo.efi  -feat  "Intel(R) AMT State"  -value  "Enabled" >a MEINFO.LOG
        if %lasterror% == 0 then 
            goto E_VF4NVP
        endif
    endif
else
    ##@si20171106c -START-
    echo .
    echo "STEP:15_0 Do NOT care AMT Feature for Non-vPro FW SKU ..."
    echo "STEP:15_0 Do NOT care AMT Feature for Non-vPro FW SKU ..." >>a %LOGPATH%TESTER.LOG
    #MEInfo.efi  -feat  "Intel(R) AMT State"  -value  "Enabled" >a MEINFO.LOG
    #if %lasterror% == 0 then 
    #    goto E_VF4NVP
    #endif
    ##@si20171106c -END-
endif

echo "Verified OK."
echo "Verified OK."  >>a %LOGPATH%TESTER.LOG
type MEINFO.LOG >>a %LOGPATH%TESTER.LOG

goto STEP16_0

# ========================================================================
#   STEP-16 :  Re-Validate Manufacture
# ========================================================================
:STEP16_0
set  AMTSTATE STEP16_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

:CHK4AC_16
echo "STEP:16_0 Checking/Waiting for AC connection ..."
echo "STEP:16_0 Checking/Waiting for AC connection ..." >>a %LOGPATH%TESTER.LOG
ACSTAT.EFI ATTACH
if not %lasterror% == 0 then 
    DELAY.EFI 3
    goto CHK4AC_16
endif

echo "AC Connected OK."
echo "AC Connected OK."  >>a %LOGPATH%TESTER.LOG

echo .
echo "STEP:16_0 Re-Validation ME Function Test with MEMANUF -VERBOSE ..."
echo "STEP:16_0 Re-Validation ME Function Test with MEMANUF -VERBOSE ..." >>a %LOGPATH%TESTER.LOG
MEMANUF.efi -VERBOSE >a MEMANUF.LOG
if not %lasterror% == 0 then 
    goto E_METST1
endif

echo "ME Function Test Passed."
echo "ME Function Test Passed."  >>a %LOGPATH%TESTER.LOG
type MEMANUF.LOG >>a %LOGPATH%TESTER.LOG

goto STEP17_0

# ========================================================================
#   STEP-17 :  End Of Line Check  
# ========================================================================
:STEP17_0
set  AMTSTATE STEP17_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

echo .
echo "STEP:17_0 End of line check with MEMANUF -EOL ..."
echo "STEP:17_0 End of line check with MEMANUF -EOL ..." >>a %LOGPATH%TESTER.LOG
MEMANUF.efi -EOL -VERBOSE >a MEMANUF.LOG
if not %lasterror% == 0 then 
    goto E_MEEOL
endif

echo "Success."
echo "Success."  >>a %LOGPATH%TESTER.LOG
type MEMANUF.LOG >>a %LOGPATH%TESTER.LOG

goto STEP18_0

# ========================================================================
#   STEP-18 :  End of ME 11.6 MFG Flow 
# ========================================================================
:STEP18_0
set  AMTSTATE STEP18_0
echo %AMTSTATE% >a  %LOGPATH%AMTSTATE.CTL

date >>a %LOGPATH%TESTER.LOG
time >>a %LOGPATH%TESTER.LOG
echo [%AMTSTATE%] >>a %LOGPATH%TESTER.LOG

echo .
echo "STEP:18_0 ME 11.6 MFG Flow completed successfully."
echo "STEP:18_0 ME 11.6 MFG Flow completed successfully." >>a %LOGPATH%TESTER.LOG
echo "STEP:18_0 ME 11.6 MFG Flow completed successfully." >>a %LOGPATH%%NSHNAME%.DON

goto EXIT

##############################################
# Reboot System
###############################################
:IPL
echo .
echo "Restart System." >>a %LOGPATH%TESTER.LOG
RESET

# Should never return to here
echo "%NSHNAME%.NSH:ERROR - FAILED to Reboot System!!!"
echo "%NSHNAME%.NSH:ERROR - FAILED to Reboot System!!!" >>a %LOGPATH%TESTER.LOG
goto ERR_EXIT

# ========================================================================
#   E N D   O F   P R O C E S S 
# ========================================================================

:E_FEWOPT
echo .
echo *****************************************************
echo "%NSHNAME%.NSH:ERROR - TOO Few Option specified !!"
echo "%0 %1 %2 %3 %4 %5 %6 %7  (Executed from %ORGCWD%)"
echo *****************************************************
echo "%NSHNAME%.NSH:ERROR - TOO Few Option specified !!" >>a %LOGPATH%TESTER.LOG
echo .
goto ERR_EXIT 

:E_NOPKG
echo .
echo *************************************************************************
echo "%NSHNAME%.NSH:ERROR - Specified MEFW PACKAGE not found in %MEFWPATH% !!"
echo *************************************************************************
echo "%NSHNAME%.NSH:ERROR - Specified MEFW PACKAGE not found in %MEFWPATH% !!" >>a %LOGPATH%TESTER.LOG
echo .
goto ERR_EXIT 
   
:E_NOTOOL
echo .
echo *************************************************************************
echo "%NSHNAME%.NSH:ERROR - Required Tool NOT found in %TOOLPATH% !!"
echo *************************************************************************
echo "%NSHNAME%.NSH:ERROR - Required Tool NOT found in %TOOLPATH% !!" >>a %LOGPATH%TESTER.LOG
echo .
goto ERR_EXIT    

:E_INVPKG
echo .
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - Specified ME FW PKG(%MEFWPATH%) invalid."
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - Specified ME FW PKG(%MEFWPATH%) invalid." >>a %LOGPATH%TESTER.LOG
echo .
goto ERR_EXIT   

:E_FWLCL
echo .
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - ME FW Update failed with FWUpdLcl."
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - ME FW Update failed with FWUpdLcl." >>a %LOGPATH%TESTER.LOG
echo .
goto ERR_EXIT   

:E_UPDESC
echo .
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - Flash Descriptor update failed."
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - Flash Descriptor update failed." >>a %LOGPATH%TESTER.LOG
echo .
goto ERR_EXIT   

:E_UPMEFW
echo .
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - ME FW Update/Verify failed."
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - ME FW Update/Verify failed." >>a %LOGPATH%TESTER.LOG
echo .
goto ERR_EXIT   

:E_M3CLR
echo .
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - M3 Test Result Clear failed."
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - M3 Test Result Clear failed." >>a %LOGPATH%TESTER.LOG
echo .
goto ERR_EXIT   

:E_WLMCUP
echo .
type FWupdLcl.LOG >>a %LOGPATH%TESTER.LOG
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - WLAN Micro-code update failed."
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - WLAN Micro-code update failed." >>a %LOGPATH%TESTER.LOG
echo .
goto ERR_EXIT   

:E_METST0
echo .
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - ME Function test failed."
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - ME Function test failed." >>a %LOGPATH%TESTER.LOG
type MEMANUF.LOG >>a %LOGPATH%TESTER.LOG
echo .
goto ERR_EXIT   

:E_METST1
echo .
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - Re-validation ME Function test failed."
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - Re-validation ME Function test failed." >>a %LOGPATH%TESTER.LOG
type MEMANUF.LOG >>a %LOGPATH%TESTER.LOG
echo .
goto ERR_EXIT   

:E_VF4VP
echo .
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - SKU Validation failed for vPro SKU."
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - SKU Validation failed for vPro SKU." >>a %LOGPATH%TESTER.LOG
echo .
goto ERR_EXIT   

:E_VF4NVP
echo .
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - SKU Validation failed for Non-vPro SKU."
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - SKU Validation failed for Non-vPro SKU." >>a %LOGPATH%TESTER.LOG
echo .
goto ERR_EXIT   

:E_VF4PHY
echo .
echo ***************************************************************************
echo "%NSHNAME%.NSH:ERROR - Wired LAN Chip SKU Validation failed for vPro SKU."
echo ***************************************************************************
echo "%NSHNAME%.NSH:ERROR - Wired LAN Chip SKU Validation failed for vPro SKU." >>a %LOGPATH%TESTER.LOG
echo .
goto ERR_EXIT   

:E_CMPMFG
echo .
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - Complete Manufacture Failed."
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - Complete Manufacture Failed." >>a %LOGPATH%TESTER.LOG
echo .
goto ERR_EXIT  

:E_FWVER
echo .
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - ME FW Version Verify failed."
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - ME FW Version Verify failed." >>a %LOGPATH%TESTER.LOG
echo .
goto ERR_EXIT  

:E_DESCLK
echo .
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - Descriptor Lockdown verify failed."
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - Descriptor Lockdown verify failed." >>a %LOGPATH%TESTER.LOG
echo .
goto ERR_EXIT  

:E_MEEOL
echo .
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - End Of Line Check failed."
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - End Of Line Check failed." >>a %LOGPATH%TESTER.LOG
type MEMANUF.LOG >>a %LOGPATH%TESTER.LOG
echo .
goto ERR_EXIT  

:E_MESTAT
type MEINFO.LOG
type MEINFO.LOG >>a %LOGPATH%TESTER.LOG
echo .
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - MEINFO.efi failed to get Initial ME Status."
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - MEINFO.efi failed to get Initial ME Status." >>a %LOGPATH%TESTER.LOG
echo .
goto ERR_EXIT  

#@si20170118c -START-
:E_EEPLKD
#type MEMFGCTL.LOG
type MEMFGCTL.LOG >>a %LOGPATH%TESTER.LOG
echo .
echo ******************************************************************
echo "%NSHNAME%.NSH:Failed to access ME MFG Flag due to EEPROM is Locked."
echo ******************************************************************
echo "%NSHNAME%.NSH:Failed to access ME MFG Flag due to EEPROM is Locked." >>a %LOGPATH%TESTER.LOG

echo .
echo "%NSHNAME%.NSH:Setting MFG Mode Flag 0x55A0 to unlock EEPROM ... "
echo "%NSHNAME%.NSH:Setting MFG Mode Flag 0x55A0 to unlock EEPROM ... " >>a %LOGPATH%TESTER.LOG
TPMFGFLG.EFI /S 0X55A0 >>a %LOGPATH%TESTER.LOG
echo "Done."
echo "Done." >>a %LOGPATH%TESTER.LOG
goto IPL 
#@si20170118c -END-

:E_INVOPT
echo .
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - Invalid option specified."
echo "%0 %1 %2 %3 %4 %5 %6 %7 %8"
echo ******************************************************************
echo "%NSHNAME%.NSH:ERROR - Invalid option specified." >>a %LOGPATH%TESTER.LOG
echo "%0 %1 %2 %3 %4 %5 %6 %7 %8" >>a %LOGPATH%TESTER.LOG
echo .
goto ERR_EXIT   


###############################################
# ERROR EXIT
###############################################
:ERR_EXIT
echo %NSHNAME%.NSH:Failed >a %LOGPATH%%NSHNAME%.ERR
date >>a %LOGPATH%%NSHNAME%.ERR
time >>a %LOGPATH%%NSHNAME%.ERR
if exist %LOGPATH%%NSHNAME%.DON then
    del %LOGPATH%%NSHNAME%.DON
endif

cd %ORGCWD%
exit /b 1

###############################################
# EXIT
###############################################
:EXIT
cd %ORGCWD%
exit /b 0

