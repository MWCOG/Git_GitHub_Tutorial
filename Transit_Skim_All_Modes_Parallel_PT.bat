::  Transit Skimming for All Submodes
::  updated 4/27/07  copy sta_tpp.bse from inputs to output subdir.
::  updated 6/15/11  runs walkacc process for pp iteration only
::  updated 5/11/16  Update autoacc and local-bus in-vehicle speed degradation 
::  updated 2/19/20 for PT-based Skimming Process
::---------------------------------------------
::  Version 2.3 Transit SKIM and Fare2 Process
::---------------------------------------------

CD %1

::adjust local bus run times by applying bus speed degradation factors.
:: (Added 5/18/20 by fxie)
:: if exist voya*.*  del voya*.*
:: if exist Adjust_Runtime.rpt  del Adjust_Runtime.rpt 
:: start /w Voyager.exe  ..\scripts\Adjust_Runtime_PT.s /start -Pvoya -S..\%1
:: if errorlevel 1 goto error
:: if exist voya*.prn  copy voya*.prn Adjust_Runtime.rpt /y

::  
::develop PT network building process to include updating the transit speeds
:: (Added 4/24/19)  
if exist voya*.*  del voya*.*
if exist V2.5_PTNet_Build_Iteration.rpt  del V2.5_PTNet_Build_Iteration.rpt 
start /w Voyager.exe  ..\scripts\V2.5_PTNet_Build_Iteration.S /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn V2.5_PTNet_Build_Iteration.rpt /y
:: 

if exist voya*.*  del voya*.*
if exist PT_NetProcess_PT.rpt  del PT_NetProcess_PT.rpt 
start /w Voyager.exe  ..\scripts\PT_NetProcess_PT.s /start -Pvoya -S..\%1
if errorlevel 2 goto error
if exist voya*.prn  copy voya*.prn PT_NetProcess_PT.rpt /y

CD..

:: =======================================
:: = Transit Skimming Section            =
:: =======================================

::  Transit Network Building (Final) Commuter Rail

if %useMDP%==t goto Parallel_Processing
if %useMDP%==T goto Parallel_Processing
@echo Start Transit Skims
REM   If only one CPU, run the four skims sequentially

START /wait Transit_Skim_LineHaul_Parallel_PT.bat %1 CR 

REM  Transit Network Building (Final) Metrorail
START /wait Transit_Skim_LineHaul_Parallel_PT.bat %1 MR 

REM  Transit Network Building (Final) All Bus
START /wait Transit_Skim_LineHaul_Parallel_PT.bat %1 AB 

REM  Transit Network Building (Final) Bus+MetroRail
START /wait Transit_Skim_LineHaul_Parallel_PT.bat %1 BM  

goto Transit_Skims_Are_Done

:Parallel_Processing
@echo Start Transit Skim - Parallel

START Transit_Skim_LineHaul_Parallel_PT.bat %1 CR 

REM  Transit Network Building (Final) Metrorail
START Transit_Skim_LineHaul_Parallel_PT.bat %1 MR 

REM  Transit Network Building (Final) All Bus
START Transit_Skim_LineHaul_Parallel_PT.bat %1 AB 

REM  Transit Network Building (Final) Bus+MetroRail
START /wait Transit_Skim_LineHaul_Parallel_PT.bat %1 BM  

:Transit_Skims_Are_Done

CD %1

goto checkIfDone

:waitForMC
@ping -n 11 127.0.0.1

:checkIfDone

@REM Check file existence to ensure that there are no errors
if exist Transit_Skims_CR.err echo Error in Transit_Skims_CR && goto error
if exist Transit_Skims_MR.err echo Error in Transit_Skims_MR && goto error
if exist Transit_Skims_AB.err echo Error in Transit_Skims_AB && goto error
if exist Transit_Skims_BM.err echo Error in Transit_Skims_BM && goto error

@REM Check to ensure that each of the batch processes have finished successfully, if not wait.
if not exist Transit_Skims_CR.done goto waitForMC
if not exist Transit_Skims_MR.done goto waitForMC
if not exist Transit_Skims_AB.done goto waitForMC
if not exist Transit_Skims_BM.done goto waitForMC

REM @type CR.txt
REM @type MR.txt
REM @type AB.txt
REM @type BM.txt

:: if exist voya*.*  del voya*.*
:: if exist MFare2_PT.rpt  del MFare2_PT.rpt 
:: start /w Voyager.exe  ..\scripts\MFare2_PT.s /start -Pvoya -S..\%1
:: if errorlevel 2 goto error
:: if exist voya*.prn  copy voya*.prn MFare2_PT.rpt /y

if exist voya*.*  del voya*.*
if exist Post_Skim_PT.rpt  del Post_Skim_PT.rpt 
start /w Voyager.exe  ..\scripts\Post_Skim_PT.s /start -Pvoya -S..\%1
if errorlevel 2 goto error
if exist voya*.prn  copy voya*.prn Post_Skim_PT.rpt /y

if exist voya*.*  del voya*.*
if exist %_iter_%_TRANSIT_Accessibility.RPT  del %_iter_%_TRANSIT_Accessibility.RPT
start /w Voyager.exe  ..\scripts\transit_Accessibility.s /start -Pvoya -S..\%1
if errorlevel 2 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_TRANSIT_Accessibility.RPT /y

goto end


:error
REM  Processing Error......
PAUSE
:end

CD..

