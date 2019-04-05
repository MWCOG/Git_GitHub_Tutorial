CD %1

REM  Highway Skims

:: RQN 02-04-2019   Add two lines 8-9 to fix a bug of the model using <ITER>_HWY.net 
::                  incorrectly when the model crash at a certain step

if exist temp1_%_iter_%_HWY.net copy temp1_%_iter_%_HWY.net %_iter_%_HWY.net
if exist temp2_%_iter_%_HWY.net copy temp2_%_iter_%_HWY.net %_iter_%_HWY.net

if exist voya*.*  del voya*.*
if exist %_iter_%_Highway_Skims_am.rpt  del %_iter_%_Highway_Skims_am.rpt
start /w Voyager.exe  ..\scripts\Highway_Skims_am.s /start -Pvoya -S..\%1
if errorlevel 2 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Highway_Skims_am.rpt /y

if exist voya*.*  del voya*.*
if exist %_iter_%_Highway_Skims_md.rpt  del %_iter_%_Highway_Skims_md.rpt
start /w Voyager.exe  ..\scripts\Highway_Skims_md.s /start -Pvoya -S..\%1
if errorlevel 2 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Highway_Skims_md.rpt /y


: Additional Steps per the Nested Logit 
:: modnet.bat / Highway_Skims_Mod.bat / JoinSkims.bat ===

REM  Utility - Convert dummy centroid connectors

if exist voya*.*  del voya*.*
if exist %_iter_%_ModNet.rpt  del %_iter_%_ModNet.rpt
start /w Voyager.exe  ..\scripts\modnet.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_ModNet.rpt /y

if exist voya*.*  del voya*.*
if exist %_iter_%_Highway_Skims_mod_am.rpt  del %_iter_%_Highway_Skims_mod_am.rpt
start /w Voyager.exe  ..\scripts\Highway_Skims_mod_am.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Highway_Skims_Mod_am.rpt /y

if exist voya*.*  del voya*.*
if exist %_iter_%_Highway_Skims_mod_md.rpt  del %_iter_%_Highway_Skims_mod_md.rpt
start /w Voyager.exe  ..\scripts\Highway_Skims_mod_md.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_Highway_Skims_Mod_md.rpt /y


REM  Utility - Join Highway Skims

if exist voya*.*  del voya*.*
if exist %_iter_%_JoinSkims.rpt  del %_iter_%_JoinSkims.rpt 
start /w Voyager.exe  ..\scripts\joinskims.s /start -Pvoya -S..\%1
if errorlevel 1 goto error
if exist voya*.prn  copy voya*.prn %_iter_%_JoinSkims.rpt /y


goto end
:error
REM  Processing Error....
PAUSE
:end
CD..
