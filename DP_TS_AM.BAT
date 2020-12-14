
echo running>am.flag

cd AM

Cluster.exe amtoll 1-8 start exit

start /w Voyager.exe  ../../../scripts/TS_V23_AM.S /start -Pvoya -S./

Cluster.exe amtoll 1-8 close exit

cd..
del am.flag
exit

