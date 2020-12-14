CD %1

SET MAXTGRPS=1000

IF EXIST TOLL_SETTING del TOLL_SETTING /s /q
md TOLL_SETTING
md TOLL_SETTING\AM
md TOLL_SETTING\MD
md TOLL_SETTING\PM
md TOLL_SETTING\FINAL_TOLL

CD TOLL_SETTING

if errorlevel 1 goto error

copy ..\i4_Assign_Output.net AM /y
copy ..\i4_Assign_Output.net MD /y
copy ..\i4_Assign_Output.net PM /y

START ..\..\DP_TS_AM.BAT
START ..\..\DP_TS_MD.BAT
START ..\..\DP_TS_PM.BAT
 
:wait
@ping -n 11 127.0.0.1>nul
if exist *.flag goto wait

for /f %%a in ('dir AM\OUT*.TXT /B /O:-D') do (set AMTOLL=%%a
goto amstop)
:amstop

for /f %%a in ('dir MD\OUT*.TXT /B /O:-D') do (set MDTOLL=%%a
goto mdstop)
:mdstop

for /f %%a in ('dir PM\OUT*.TXT /B /O:-D') do (set PMTOLL=%%a
goto pmstop)
:pmstop

echo The final toll file are %AMTOLL%, %MDTOLL%, and %PMTOLL%.

CD FINAL_TOLL

start /w Voyager.exe  ../../../scripts/Post_Toll_Search.s /start -Pvoya -S./

goto end
:error
REM  Processing Error....
PAUSE

:end
CD..