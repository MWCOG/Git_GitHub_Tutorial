
echo running>md.flag

cd MD

Cluster.exe mdtoll 1-8 start exit

start /w Voyager.exe  ../../../scripts/TS_V23_MD.S /start -Pvoya -S./

Cluster.exe mdtoll 1-8 close exit

cd..
del md.flag
exit


