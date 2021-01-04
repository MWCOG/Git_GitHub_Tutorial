:: Z:\ModelRuns\fy20\CGV2_3_82\run_Model_2014.bat
:: Version 2.3.82
:: 9/12/2019 12:03:40 PM

set root=.
set scenar=2007
set runbat=run_ModelSteps_2007.bat
:: Environment variables for (multistep) distributed processing:
:: Environment variables for (intrastep) distributed processing:
::     use MDP = t/f (for true or false)
::     use IDP = t/f (for true or false)
::     Number of subnodes:  1-3 => 3 subnodes and one main node = 4 nodes in total
set useIdp=t
set useMdp=t
::  05/10/2019 AMsubnode, MDsubnode, PMsubnode, NTsubnode are used in highway_assignment_parallel.bat/s
set AMsubnode=1-4
set MDsubnode=2-4
set PMsubnode=2-4
set NTsubnode=2-4
::  subnode used in transit fare and transit assignment
::  We no longer use IDP in transit skimming, since it would require 16 cores
set subnode=1-3

:: This command will 
::  1) time the model run (using timethis.exe and the double quotes)
::  2) redirect standard output and standard error to a file
::  3) Use the tee command so that stderr & stdout are sent both to the file and the screen

timethis "%runbat%  %scenar%" 2>&1 | tee %root%\%scenar%\%scenar%_fulloutput.txt

:: Open up the file containing the stderr and stdout
if exist %root%\%scenar%\%scenar%_fulloutput.txt     start %root%\%scenar%\%scenar%_fulloutput.txt

:: Look four errors in the reports and output files
call searchForErrs.bat  %scenar%
:: Open up the file containing any errors found
if exist %root%\%scenar%\%scenar%_searchForErrs.txt  start %root%\%scenar%\%scenar%_searchForErrs.txt

:: Open up other report files
if exist %root%\%scenar%\i4_Highway_Assignment.rpt   start %root%\%scenar%\i4_Highway_Assignment.rpt
if exist %root%\%scenar%\i4_mc_NL_summary.txt        start %root%\%scenar%\i4_mc_NL_summary.txt
if exist %root%\%scenar%\i4_Assign_Output.net        start %root%\%scenar%\i4_Assign_Output.net
cd %scenar%
start powershell.exe -noexit -Command get-content i4_ue*AM_nonHov*txt -tail 1; get-content i4_ue*AM_hov*txt -tail 1; get-content i4_ue*PM_nonHov*txt -tail 1; get-content i4_ue*PM_hov*txt -tail 1; get-content i4_ue*MD*txt -tail 1; get-content i4_ue*NT*txt -tail 1
cd ..
move_temp_files_v6.bat %scenar%

:: Cleanup
set root=
set scenar=
set runbat=
set useIdp=
set useMdp=
set AMsubnode=
set MDsubnode=
set subnode=