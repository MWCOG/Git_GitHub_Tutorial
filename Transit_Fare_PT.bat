::--------------------------------------
::  Version 2.5 Transit Fare Process
::--------------------------------------
:: rqn Add script V2.5_PTNet_Build.s to build PT Network as part of the model
CD %1

::copy transit lines and support files from the inputs subdir. 
copy inputs\*.TB /y
copy inputs\mfare1.a1 /y

::develop PT network building process
if exist voya*.*  del voya*.*
if exist V2.5_PTNet_Build.rpt  del V2.5_PTNet_Build.rpt 
start /w Voyager.exe  ..\scripts\V2.5_PTNet_Build.S /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn V2.5_PTNet_Build.rpt /y

::develop walk access links.
if exist voya*.*  del voya*.*
if exist walkacc.rpt  del walkacc.rpt 
start /w Voyager.exe  ..\scripts\walkacc.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn walkacc.rpt /y


if exist voya*.*  del voya*.*
if exist %_iter_%_prefarV23.rpt  del %_iter_%_prefarV23.rpt
start /w Voyager.exe  ..\scripts\prefarV23.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_prefarV23.rpt /y



if exist voya*.*  del voya*.*
if exist %_iter_%_Metrorail_skims.rpt  del %_iter_%_Metrorail_skims.rpt
start /w Voyager.exe  ..\scripts\Metrorail_skims.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Metrorail_skims.rpt /y


if exist voya*.*  del voya*.*
if exist %_iter_%_MFARE1.rpt  del %_iter_%_MFARE1.rpt
start /w Voyager.exe  ..\scripts\MFARE1.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_MFARE1.rpt /y


goto end


:error
REM  Processing Error......
PAUSE
:end

CD..

