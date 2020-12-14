

echo running>pm.flag

cd PM

Cluster.exe pmtoll 1-8 start exit

start /w Voyager.exe  ../../../scripts/TS_V23_PM.S /start -Pvoya -S./

Cluster.exe pmtoll 1-8 close exit

cd..
del pm.flag
exit