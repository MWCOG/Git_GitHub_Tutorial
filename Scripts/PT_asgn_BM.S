;---------------------------------------------------------------------------
;PT_asgn_BM.s
;TPB Version 2.3 travel model on the 3,722-TAZ area system
;                        - PATHSTYLE changed from 1 to 0 on 3.9.04 (RM)
;                        - iteration (_iter_) global variables used
;Assign Transit Trips by Time Period and Access Mode
; Input Files:
;  Cube Voyager Highway Network = ZONEHWY.NET
;  Transit Line Files           = MODE[1-10][AM|OP].TB
;  Transit Network Data         = MET_*.TB, COM_*.TB, BUS_*.TB
;  Walk and Drive Access        = WALKACC.TB, *_PNR_pp.TB
;  Walk Sidewalk Network        = SIDEWALK.ASC
;  Transit Trip Tables          = '%_iter_%_AMMS.TRP', '%_iter_%_OPMS.TRP'
; Output Files:
;  Transit Assignment Link and Node Files
;
; Step 1: AM Peak Walk Assignment
;  Input Files: ZONEHWY.NET, MODE?_AM.TB, *.TB, '%_iter_%_AMMS.TRP'
;  Output Files: WKBMAMnode.dbf; WKBMAMlink.dbf
; Step 2: AM Peak Drive Assignment
;  Input Files: ZONEHWY.NET, MODE?_AM.TB, *.TB, '%_iter_%_AMMS.TRP'
;  Output Files: DRBMAMnode.dbf; DRBMAMlink.dbf
; Step 3: AM Peak K/R Assignment
;  Input Files: ZONEHWY.NET, MODE?_AM.TB, *.TB, '%_iter_%_AMMS.TRP'
;  Output Files: KRBMAMnode.dbf; KRBMAMlink.dbf
; Step 4: Off Peak Walk Assignment
;  Input Files: ZONEHWY.NET, MODE?_OP.TB, *.TB, '%_iter_%_OPMS.TRP'
;  Output Files: WKBMOPnode.dbf; WKBMOPlink.dbf
; Step 5: Off Peak Drive Assignment
;  Input Files: ZONEHWY.NET, MODE?_OP.TB, *.TB, '%_iter_%_OPMS.TRP'
;  Output Files: DRBMOPnode.dbf; DRBMOPlink.dbf
; Step 6: Off Peak K/R Assignment
;  Input Files: ZONEHWY.NET, MODE?_OP.TB, *.TB, '%_iter_%_OPMS.TRP'
;  Output Files: KRBMOPnode.dbf; KRBMOPlink.dbf
;---------------------------------------------------------------------------

;  Read in time factors to increase local bus times
;  based on increasing arterial hwy congestion 

pageheight=32767  ; Preclude header breaks

;---------------------------------------------------------------------------
; Loop through each period and access mode
;---------------------------------------------------------------------------

LOOP PERIOD = 1, 2

 IF (PERIOD = 1)
  TIME_PERIOD = 'AM'
  COMBINE = 5.0

  MATIN='%_iter_%_AMMS.TRP'
  AM=' '
  OP=';'
 ELSE
  TIME_PERIOD = 'OP'
  COMBINE = 10.0

  MATIN='%_iter_%_OPMS.TRP'
  AM=';'
  OP=' '
 ENDIF

;---- start the access mode loop ----

LOOP ACCESS = 1,3

  IF (ACCESS = 1)
   ACCESS_MODE = 'WK'
   WALK_MODEL = ' '
   DRIVE_MODEL = ';'
   KR_MODEL = ';'
   TABIN = 'MI.1.3'
  ELSEIF (ACCESS = 2)
   ACCESS_MODE = 'DR'
   WALK_MODEL = ';'
   DRIVE_MODEL = ' '
   KR_MODEL = ';'
   TABIN = 'MI.1.8'
  ELSE
   ACCESS_MODE = 'KR'
   WALK_MODEL = ';'
   DRIVE_MODEL = ';'
   KR_MODEL = ' '
   TABIN = 'MI.1.9'
  ENDIF

;---------------------------------------------------------------------------
; Assign Bus/MR Transit Trips
;---------------------------------------------------------------------------

RUN PGM = PUBLIC TRANSPORT
FILEI NETI       = "%_ITER_%_@TIME_PERIOD@_@ACCESS_MODE@_BM.NET"
FILEI MATI[1]    =  @MATIN@

FILEI ROUTEI     = "%_ITER_%_@TIME_PERIOD@_@ACCESS_MODE@_BM.RTE"
FILEI FAREMATI[1] = Metrorail_Fare.mat
FILEI FAREMATI[2] = VRE_Fare.mat
FILEI FAREMATI[3] = MARC_Fare.mat
FILEO REPORTO    = "%_ITER_%_@TIME_PERIOD@_@ACCESS_MODE@_BM_ASGN.PRN"
FILEO LINKO      = "%_ITER_%_@TIME_PERIOD@_@ACCESS_MODE@_BM_LINKVOL.DBF", ONOFFS=Y
FILEO STOP2STOPO = "%_ITER_%_@TIME_PERIOD@_@ACCESS_MODE@_BM_S2Svol.dbf", ACCUMULATE = ADJACENTBYMODE,
                      NODES= 1-70000, MODES = 3  , LIST=N

FILEI FAREI = INPUTS\FARE_@TIME_PERIOD@.DAT

PARAMETERS EFARE=T,TRIPSIJ[1] = @TABIN@

ZONEMSG=50

ENDRUN

ENDLOOP ;---- ACCESS ----
ENDLOOP ;---- PERIOD ----


