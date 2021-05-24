## Access reports focus on riders who arrive or depart using transit access links
## i.e., the summary does not include transfers
TITLE                             Metrorail Station Access Summary
DEFAULT_FILE_FORMAT               DBASE

LINESUM_REPORT_1			  ACCESS_REPORT

PEAK_RIDERSHIP_FILE_1     				PK_VOL.DBF
PEAK_RIDERSHIP_FORMAT_1   				DBASE
OFFPEAK_RIDERSHIP_FILE_1  				OP_VOL.DBF
OFFPEAK_RIDERSHIP_FORMAT_1				DBASE

STOP_NAME_FILE                    ..\inputs\station_names.dbf
STOP_NAME_FORMAT                  DBASE

ACCESS_REPORT_TITLE_1					Metrorail
ACCESS_REPORT_STOPS_1					8001..8100, 8119..8140, 8145..8148, 8150..8154, 8160..8166, 8169..8182
ACCESS_REPORT_MODES_1		 			ALL

