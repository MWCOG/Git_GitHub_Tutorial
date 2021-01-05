*del voya*prn
;PT_NetProcess_PT.S
; SET VOT VALUES
  _VOTperHr = 10.00
  _VOTperMin = _VOTperHr/60.0
  _MinPerDoll = 1.0/_VOTPerMin

  _OpCost = 10 ; highway operation cost of 10cents/mile


; Script File Name: PT_NetProcess.S
; This file is to update the transit network and generate Non-transit leg files used for
;    PT skim and assignment process
; 11/9/2017 rqn Corrected line 119 the location of @PERIOD@_PT_NET.NET (under scenario, not /Inputs/
; ********************************************************************************************************
; I: Extract the station parking cost, walk time, and shadow cost information from the station file
;   and file the data in a temporary file for skimming and assignment process
; ********************************************************************************************************
;
RUN PGM=MATRIX
ZONES=1
FILEI DBI[1]="INPUTS\STATION.DBF"
;FILEO PRINTO[1] = "_RAILSTATIONS.TXT"



LOOP K = 1,dbi.1.NUMRECORDS
      x = DBIReadRecord(1,k)

          MM          = di.1.MM          ;  Mode code ('M','C,','B','L','N')
          STAPARK     = di.1.STAPARK     ;  Station Parking lot flag ('Y' or blank)
          STAUSE      = di.1.STAUSE      ;  Station Active flag      ('Y' or blank)
          STAT        = di.1.STAT        ;  Station node         (9000 - 11999 series)
          STAZ        = di.1.STAZ        ;  Nearest TAZ centroid (   1 -  3722 series)
          STAC        = di.1.STAC        ;  Station centroid    ( 5000 -  8000 series)
          STAP        = di.1.STAP        ;  Station PNR node    (12000 - 14999 series)
          STAN1       = di.1.STAN1       ;  Bus Node connector
          STAPCAP     = di.1.STAPCAP     ;  Parking lot capacity
          STAPKCOST   = di.1.STAPKCOST   ;  AM Pk daily parking cost
          STAOPCOST   = di.1.STAOPCOST   ;  Offpk       parking cost
          STAPKSHAD   = di.1.STAPKSHAD   ;  AM    Shadow parking cost
          STAOPSHAD   = di.1.STAOPSHAD   ;  Offpk Shadow parking cost
	  STWALKTM    = di.1.STWALKTM    ;  Rail station walk time (new data field)
          STACnt      =  dbi.1.NUMRECORDS


 ; IF ((MM = 'M' || MM ='C') && STAPARK = 'Y' && STAUSE = 'Y')
 IF ((MM = 'M' || MM ='C') && STAUSE = 'Y')

     _stwalktm = STWALKTM
     _parkpk = INT(max(200.0,(STAPKCOST/2.0)))   ; One-way AM     period parking cost
     _parkop = INT(max(100.0,(STAOPCOST/2.0)))   ; One-way Off Pk period parking cost

     _walkpk= 0
     _walkop= 0
    if (STAPARK = 'Y')
     _walkpk = 200.00                            ; minimum walk time 2 mintues
     _walkop = 200.00
      IF (STAPCAP >  500) _Walkpk = 250.0        ; PNR walk times are longer for stations with larger lots
      IF (STAPCAP > 1000) _Walkpk = 350.0        ;
      IF (STAPCAP > 1500) _Walkpk = 400.0        ;
      IF (STAPCAP > 2000) _Walkpk = 500.0        ;
    endif
      _timepk = (_Walkpk + _parkpk/1.5 *@_MinPerDoll@ + STAPKSHAD)/100.   ; Peak PNR link composite impedance in min.

      _timeop = (_Walkop + _parkop/1.5 *@_MinPerDoll@ + STAOPSHAD)/100.   ; Peak PNR link composite impedance in min.

;;
;; the factor 1.5 in above statements is the pnr access time factor
;; The values STATION(X._STANOB) is actually the parking, we don't want to weight this term by 1.5 during the skimming process
;; So we devide the value by 1.5 to offset the weighting factor
;;


     PRINT LIST = STAT(6), _timepk(6.2), _timeop(6.2), _parkpk(6), _parkop(6), _stwalktm(6), ;
     FILE = "_RAILSTATIONS.TXT"
   ENDIF
ENDLOOP
ENDRUN


; ********************************************************************************************************
; II: update the transit network file with revised rail link travel time and PnR station
; ********************************************************************************************************

itr='%_iter_%'   ;*RJM*
pre='%_prev_%'   ;*RJM*


 LOOP PERIOD=1,2

 IF (PERIOD = 1)
  TIME_PERIOD = 'AM'
  AM_MODE = ' '
  OP_MODE = ';'
  PRD='AM'
 ELSE
  TIME_PERIOD = 'OP'
  AM_MODE = ';'
  OP_MODE = ' '
  PRD='MD'
 ENDIF


;; ************* Combine Transit Lines ***************

; combine bus/streetcar lines 1,2,6,7,8,9,10 (non-rail modes) to AM_Bus_Lines.lin
*copy "Inputs\Mode1@TIME_PERIOD@.lin" + "Inputs\Mode2@TIME_PERIOD@.lin" + "Inputs\Mode6@TIME_PERIOD@.lin" +
   "Inputs\Mode7@TIME_PERIOD@.lin" + "Inputs\Mode8@TIME_PERIOD@.lin" + "Inputs\Mode9@TIME_PERIOD@.lin" +
   "Inputs\Mode10@TIME_PERIOD@.lin"  "@TIME_PERIOD@_Bus_Lines.lin"

; combine Metro and LRT 3,5 lines to @TIME_PERIOD@_MRL_Lines.lin
*copy "Inputs\Mode3@TIME_PERIOD@.lin" + "Inputs\Mode5@TIME_PERIOD@.lin"   "@TIME_PERIOD@_MRL_Lines.lin"

; combine (copy) the commuter rail (mode 3) line to @TIME_PERIOD@_CRL_Lines.lin
*copy "Inputs\Mode4@TIME_PERIOD@.lin"  "@TIME_PERIOD@_CRL_Lines.lin"


;
RUN PGM = NETWORK
ZONES=3722


NETI[1] = @itr@_@TIME_PERIOD@_PT_INI.NET


LINKI[2] = INPUTS\RAIL_LINKS.DBF

NETO=@itr@_@TIME_PERIOD@_PT.NET, INCLUDE =DISTANCE,JUR,FTYPE,TOLL,TOLLGRP, AMLANE,AMLIMIT,PMLANE,PMLIMIT,OPLANE,OPLIMIT,
    TRANTIME,WKTIME,MODE,SPEED

; Rail station data file for lookup function - Gallop
  FILEI LOOKUPI[1]= "_RAILSTATIONS.TXT"
  LOOKUP LOOKUPI=1, NAME= STATION, ;
  LOOKUP[1]= 1, RESULT=2, ;     AM peak PNR impedance
  LOOKUP[2]= 1, RESULT=3, ;     Off peak PNR impedance
  LOOKUP[3]= 1, RESULT=4, ;     AM parking cost
  LOOKUP[4]= 1, RESULT=5, ;     Off Peak parking cost
  LOOKUP[5]= 1, RESULT=6, ;     Station walk time
  INTERPOLATE=F, FAIL=0,0,0


  IF (TRANTIME = 0) TRANTIME = ((DISTANCE/30) * 60)             ; ASSUMING SPEED= 30MPH if no highway speed
  IF (WKTIME = 0 && FTYPE <>1 && FTYPE <>5 && FTYPE <>6)
      SPEED    = 3
      WKTIME   = ((DISTANCE *60) /3)                            ; ASSUMING SPEED=3MPH FPR WALK LINKS
  ELSEIF (FTYPE =1 || FTYPE =5 || FTYPE =6)
      WKTIME   = 999
  ENDIF

 IF (MODE = 3,4) ; REVISE METRO RAIL LINK TIMES AND SPEEDS (INSTEAD OF BASED ON ASSUMED SPEED)
    SPEED = LI.2.SPEED
    TRANTIME = LI.2.TRANTIME
ENDIF


 IF (MODE = 15)   ; REVISE THE PNR CONNECTOR IMPEDANCE AND ADD STATION WALK TIME
   _STANOB = LI.1.B		    ;RETRIEVE THE PNR STATION NODE NUMBER
   @AM_MODE@    _PNRTIME  = STATION(1,_STANOB) + STATION(5,_STANOB)/100  ;READ AM PNRTIME FROM THE LOOKUP FUNCTION.
   @OP_MODE@    _PNRTIME  = STATION(2,_STANOB) + STATION(5,_STANOB)/100  ;READ OP PNRTIME FROM THE LOOKUP FUNCTION
   TRANTIME= _PNRTIME
  ENDIF

 IF (MODE = 12,13,14)   ; ADD STATION WALK TIME FOR RAIL STATION WALK ACCESS LINKS
   _STANOA = LI.1.A		    ;RETRIEVE THE PNR STATION NODE NUMBER
   _STANOB = LI.1.B		    ;RETRIEVE THE PNR STATION NODE NUMBER


   @AM_MODE@    _WALKTIME  =  STATION(5,_STANOA)/100 + STATION(5,_STANOB)/100 ;READ AM STATION WALK TIME
   @OP_MODE@    _WALKTIME  =  STATION(5,_STANOA)/100 + STATION(5,_STANOB)/100 ;READ OP STATION WALK TIME
   TRANTIME= TRANTIME + _WALKTIME
   WKTIME= WKTIME + _WALKTIME
  ENDIF


ENDRUN

; ********************************************************************************************************
; III: Create various Non-transit Leg files
; ********************************************************************************************************


;; **************************************
;; ***** A. Create Walk Acc and Egr Legs
;; **************************************

;; Step 1 ************* Walk Acc Link from Zone Centroid to Bus stops ***************
RUN PGM=PUBLIC TRANSPORT

  FILEI NETI       = "@itr@_@TIME_PERIOD@_PT.NET"
  FILEI LINEI[1]   = "@TIME_PERIOD@_Bus_Lines.lin"
  FILEI FACTORI[1] = "inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI    = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "Acc_WK2Bus_@TIME_PERIOD@.LEG", XN=N  ;Do not output nodes between the start and end nodes of
                                         ;nontransit legs.
  PARAMETERS TRANTIME = lw.GENTRSTIME

PROCESS PHASE = LINKREAD
        lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP
    GENERATE,
      NTLEGMODE = 20,
      COST=li.WKTIME,
      MAXCOST=10*30,
      FROMNODE=1-3675,
      TONODE=20000-54999,
      DIRECTION = 1,
      EXCLUDELINK = (li.MODE = 1-10),   ;Mode 1 to 10 cannot be a part of non-transit path.
      MAXNTLEGS = 10*10,
      SLACK = 10*10,
      LIST = Y
  ENDPROCESS

ENDRUN

;; Step 2 ************* Walk Egr Link from Bus Stops to zone Centroids ***************

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI       = "@itr@_@TIME_PERIOD@_PT.NET"
  FILEI LINEI[1]   = "@TIME_PERIOD@_Bus_Lines.lin"
  FILEI FACTORI[1] = "inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI    = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "Egr_WK2Bus_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
        lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP
    GENERATE,
      NTLEGMODE = 21,
      COST=li.WKTIME,
      MAXCOST=10*30,
      FROMNODE=1-3675,
      TONODE=20000-54999,
      DIRECTION = 2,
      EXCLUDELINK = (li.Mode = 1-10),    ;Mode 1 to 10 cannot be a part of non-transit path.
      MAXNTLEGS = 10*10,
      SLACK = 10*10,
      LIST = Y
  ENDPROCESS

ENDRUN


;; Step 3 ************* Walk Acc Link from Zone Centroid  to Metro/LRT stations ***************

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"

  FILEI LINEI[1]   = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI FACTORI[1] = "inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI    = "INPUTS\TSYSD.PTS"

  FILEO NTLEGO = "Acc_WK2MetLRT_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
        lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP
    GENERATE,
      NTLEGMODE = 20,
      COST=li.WKTIME,
      MAXCOST=10*45,
      FROMNODE=1-3675,
      TONODE=8001-8098,10001-10099,
      DIRECTION = 1,
      EXCLUDELINK = (li.Mode = 1-10),  ;Mode 1 to 10 cannot be a part of non-transit path.
      MAXNTLEGS = 10*10,
      SLACK = 10*10,
      LIST = Y
  ENDPROCESS

ENDRUN

;; Step 4 ************* Walk Egr Link from Metro/LRT stations to zone Centroids ***************

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"

  FILEI LINEI[1]   = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI FACTORI[1] = "inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI    = "Inputs\TSYSD.PTS"

  FILEO NTLEGO     = "Egr_WK2MetLRT_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
        lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP
    GENERATE,
      NTLEGMODE = 21,
      COST=li.WKTIME,
      MAXCOST=10*45,
      FROMNODE=1-3675,
      TONODE=8001-8098,10001-10099,
      DIRECTION = 2,
      EXCLUDELINK = (li.Mode = 1-10),    ;Mode 1 to 10 cannot be a part of non-transit path.
      MAXNTLEGS = 10*10,
      SLACK = 10*10,
      LIST = Y
  ENDPROCESS

ENDRUN

;; Step 5 ********* Walk Acc Link from Zone Centroid to Commuter rail stations **********

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"

  FILEI LINEI[1]   = "@TIME_PERIOD@_CRL_Lines.lin"
  FILEI FACTORI[1] = "inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI    = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "Acc_WK2Com_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
        lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP
    GENERATE,
      NTLEGMODE = 20,
      COST=li.WKTIME,
      MAXCOST=10*45,
      FROMNODE=1-3675,
      TONODE=9001-9098,
      DIRECTION = 1,
      EXCLUDELINK = (li.Mode = 1-10)|| ((li.mode = 12) && (li.distance >= 1) && (li.b = 9000-9999)),  ;Mode 1 to 10 cannot be a part of non-transit path.
      MAXNTLEGS = 10*10,
      SLACK = 10*10,
      LIST = Y
  ENDPROCESS

ENDRUN

;; Step 6 ********* Walk Egr Link from commuter rail stations to zone Centroids *********

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"

  FILEI LINEI[1] = "@TIME_PERIOD@_CRL_Lines.lin"
  FILEI FACTORI[1] = "inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "Egr_WK2Com_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
        lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP
    GENERATE,
      NTLEGMODE = 21,
      COST=li.WKTIME,
      MAXCOST=10*45,
      FROMNODE=1-3675,
      TONODE=9001-9098,
      DIRECTION = 2,
      EXCLUDELINK = (li.Mode = 1-10) || ((li.mode = 12) && (li.distance >= 1) && (li.b = 9000-9999)),    ;Mode 1 to 10 cannot be a part of non-transit path.
      MAXNTLEGS = 10*10,
      SLACK = 10*10,
      LIST = Y
  ENDPROCESS

ENDRUN



;; *********************************
;; *****  B. Create Walk Transfer Legs
;; *********************************

;; Step 1 ********** Transfer Walk links between bus stops ***************

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"
  FILEI LINEI[1] = "@TIME_PERIOD@_Bus_Lines.lin"
  FILEI FACTORI[1] = "Inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "WK_Bus2Bus_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
  	lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP	
    GENERATE,
      NTLEGMODE = 22,
      COST=li.WKTIME,
      MAXCOST=10*15,
      FROMNODE=20000-54999,
      TONODE=20000-54999,
	  DIRECTION = 3,
	  EXCLUDELINK = (li.MODE = 1-10, 11,14),
      MAXNTLEGS = 3,
      SLACK = 10*5,
      LIST = Y
  ENDPROCESS

ENDRUN

;; Step 2 ************* Transfer Walk links between buses and Metro  ***************

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"

  FILEI LINEI[1] = "@TIME_PERIOD@_Bus_Lines.lin"
  FILEI LINEI[2] = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "WK_Bus2Met_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
  	lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP	
    GENERATE,
      NTLEGMODE = 23,
      COST=li.WKTIME,
      MAXCOST=10*15,
      FROMNODE=8001-8098,
      TONODE=20000-54999,
      DIRECTION = 2,
	  EXCLUDELINK = (li.MODE = 1-10, 11),
      MAXNTLEGS = 10,
      SLACK = 10*5,
      LIST = Y
  ENDPROCESS

ENDRUN

;; Step 3 ************* Transfer Walk links between buses and Commuter rail  ***************

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"

  FILEI LINEI[1] = "@TIME_PERIOD@_Bus_Lines.lin"
  FILEI LINEI[2] = "@TIME_PERIOD@_CRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "WK_Bus2Com_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
  	lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP	
    GENERATE,
      NTLEGMODE = 24,
      COST=li.WKTIME,
      MAXCOST=10*15,
      FROMNODE=9001-9098,
      TONODE=20000-54999,
      DIRECTION = 2,
	  EXCLUDELINK = (li.MODE = 1-10, 11),
      MAXNTLEGS = 10,
      SLACK = 10*5,
      LIST = Y
  ENDPROCESS

ENDRUN

;; Step 4 ************* Transfer Walk links between buses and LRT  ***************

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"

  FILEI LINEI[1] = "@TIME_PERIOD@_Bus_Lines.lin"
  FILEI LINEI[2] = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "WK_Bus2LRT_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
  	lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP	
    GENERATE,
      NTLEGMODE = 25,
      COST=li.WKTIME,
      MAXCOST=10*15,
      FROMNODE=10001-10099,
	  TONODE=20000-54999,
      DIRECTION = 2,
	  EXCLUDELINK = (li.MODE = 1-10, 11),
      MAXNTLEGS = 10,
      SLACK = 10*5,
      LIST = Y
  ENDPROCESS

ENDRUN


;; Step 5 ************* Transfer Walk links between Metro Stations ***************

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"
  FILEI LINEI[1] = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "WK_Met2Met_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
  	lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP	
    GENERATE,
      NTLEGMODE = 33,
      COST=li.WKTIME,
      MAXCOST=10*15,
      FROMNODE=8001-8098,
      TONODE=8001-8098,
	  DIRECTION = 3,
	  EXCLUDELINK = (li.MODE = 1-10, 11),
      MAXNTLEGS = 3,
      SLACK = 10*5,
      LIST = Y
  ENDPROCESS

ENDRUN

;; Step 6 ************* Transfer Walk links between Metro and Bus ***************

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"

  FILEI LINEI[1] = "@TIME_PERIOD@_Bus_Lines.lin"
  FILEI LINEI[2] = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "WK_Met2Bus_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
  	lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP	
    GENERATE,
      NTLEGMODE = 32,
      COST=li.WKTIME,
      MAXCOST=10*15,
      FROMNODE=8001-8098,
      TONODE=20000-54999,
      DIRECTION = 1,
	  EXCLUDELINK = (li.MODE = 1-10, 11),
      MAXNTLEGS = 10,
      SLACK = 10*5,
      LIST = Y
  ENDPROCESS

ENDRUN

;; Step 7 ************* Transfer Walk links between Metro and Commuter rail ***************

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"
  FILEI LINEI[1] = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI LINEI[2] = "@TIME_PERIOD@_CRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "WK_Met2Com_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
  	lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP	
    GENERATE,
      NTLEGMODE = 34,
      COST=li.WKTIME + 5,    ; add 5 minutes to walk transfer time
      MAXCOST=10*30,
      FROMNODE=8001-8098,
      TONODE=9001-9098,
	  DIRECTION = 1,
	  EXCLUDELINK = (li.MODE = 1-10, 11),
      MAXNTLEGS = 3,
      SLACK = 10*5,
      LIST = Y
  ENDPROCESS

ENDRUN

;; Step 8************* Transfer Walk links between Metro and LRT ***************

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"
  FILEI LINEI[1] = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "WK_Met2LRT_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
  	lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP	
    GENERATE,
      NTLEGMODE = 35,
      COST=li.WKTIME,
      MAXCOST=10*15,
      FROMNODE=8001-8098,
      TONODE=10001-10099,
	  DIRECTION = 1,
	  EXCLUDELINK = (li.MODE = 1-10, 11),
      MAXNTLEGS = 3,
      SLACK = 10*5,
      LIST = Y
  ENDPROCESS

ENDRUN


;; Step 9 ************* Transfer Walk links between Commuter rail Stations ***************

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"
  FILEI LINEI[1] = "@TIME_PERIOD@_CRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "WK_Com2Com_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
  	lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP	
    GENERATE,
      NTLEGMODE = 44,
      COST=li.WKTIME,
      MAXCOST=10*15,
      FROMNODE=9001-8098,
      TONODE=9001-9098,
	  DIRECTION = 3,
	  EXCLUDELINK = (li.MODE = 1-10, 11),
      MAXNTLEGS = 3,
      SLACK = 10*5,
      LIST = Y
  ENDPROCESS

ENDRUN

;; Step 10 ************* Transfer Walk links between Commuter rail and buses ***************

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"

  FILEI LINEI[1] = "@TIME_PERIOD@_Bus_Lines.lin"
  FILEI LINEI[2] = "@TIME_PERIOD@_CRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "WK_Com2Bus_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
  	lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP	
    GENERATE,
      NTLEGMODE = 42,
      COST=li.WKTIME,
      MAXCOST=10*15,
      FROMNODE=9001-9098,
      TONODE=20000-54999,
      DIRECTION = 1,
	  EXCLUDELINK = (li.MODE = 1-10, 11),
      MAXNTLEGS = 10,
      SLACK = 10*5,
      LIST = Y
  ENDPROCESS

ENDRUN


;; Step 11 ************* Transfer Walk links between Commuter rail and Metro ***************

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"
  FILEI LINEI[1] = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI LINEI[2] = "@TIME_PERIOD@_CRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "WK_Com2Met_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
  	lw.GENTRSTIME = li.WKTIME ; add 5 minutes walk transfer time
  ENDPROCESS

  PROCESS PHASE = DATAPREP	
    GENERATE,
      NTLEGMODE = 43,
      COST=li.WKTIME + 5 ,  ; add 5 minutes walk transfer time
      MAXCOST=10*30,
      FROMNODE=8001-8098,
      TONODE=9001-9098,
	  DIRECTION = 2,
	  EXCLUDELINK = (li.MODE = 1-10, 11),
      MAXNTLEGS = 3,
      SLACK = 10*5,
      LIST = Y
  ENDPROCESS

ENDRUN

;; Step 12 ************* Transfer Walk links between Commuter rail and LRT Stations ***************

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"
  FILEI LINEI[1] = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI LINEI[2] = "@TIME_PERIOD@_CRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "WK_Com2LRT_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
  	lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP	
    GENERATE,
      NTLEGMODE = 45,
      COST=li.WKTIME,
      MAXCOST=10*15,
      FROMNODE=10001-10099,
      TONODE=9001-9098,
	  DIRECTION = 2,
	  EXCLUDELINK = (li.MODE = 1-10, 11),
      MAXNTLEGS = 3,
      SLACK = 10*5,
      LIST = Y
  ENDPROCESS

ENDRUN


;; Step 13 ************* Transfer Walk links between LRT Stations ***************

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"
  FILEI LINEI[1] = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "WK_LRT2LRT_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
  	lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP	
    GENERATE,
      NTLEGMODE = 55,
      COST=li.WKTIME,
      MAXCOST=10*15,
      FROMNODE=10001-10099,
      TONODE=10001-10099,
	  DIRECTION = 3,
	  EXCLUDELINK = (li.MODE = 1-10, 11),
      MAXNTLEGS = 3,
      SLACK = 10*5,
      LIST = Y
  ENDPROCESS

ENDRUN

;; Step 14 ************* Transfer Walk links between LRT and buses  ***************

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"

  FILEI LINEI[1] = "@TIME_PERIOD@_Bus_Lines.lin"
  FILEI LINEI[2] = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "WK_LRT2Bus_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
  	lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP	
    GENERATE,
      NTLEGMODE = 52,
      COST=li.WKTIME,
      MAXCOST=10*15,
      FROMNODE=10001-10099,
	  TONODE=20000-54999,
      DIRECTION = 1,
	  EXCLUDELINK = (li.MODE = 1-10, 11),
      MAXNTLEGS = 10,
      SLACK = 10*5,
      LIST = Y
  ENDPROCESS

ENDRUN

;; Step 15 ************* Transfer Walk links between LRT and Metro ***************

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"
  FILEI LINEI[1] = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "WK_LRT2Met_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
  	lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP	
    GENERATE,
      NTLEGMODE = 53,
      COST=li.WKTIME,
      MAXCOST=10*15,
      FROMNODE=8001-8098,
      TONODE=10001-10099,
	  DIRECTION = 2,
	  EXCLUDELINK = (li.MODE = 1-10, 11),
      MAXNTLEGS = 3,
      SLACK = 10*5,
      LIST = Y
  ENDPROCESS

ENDRUN

;; Step 16 ************* Transfer Walk links between LRT and Commuter rail Stations ***************

RUN PGM=PUBLIC TRANSPORT

  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"
  FILEI LINEI[1] = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI LINEI[2] = "@TIME_PERIOD@_CRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "WK_LRT2Com_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
  	lw.GENTRSTIME = li.WKTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP	
    GENERATE,
      NTLEGMODE = 54,
      COST=li.WKTIME,
      MAXCOST=10*15,
      FROMNODE=10001-10099,
      TONODE=9001-9098,
	  DIRECTION = 1,
	  EXCLUDELINK = (li.MODE = 1-10, 11),
      MAXNTLEGS = 3,
      SLACK = 10*5,
      LIST = Y
  ENDPROCESS

ENDRUN



;; ************* Combine Transit Lines ***************

; combine bus/streetcar lines 1,2,6,7,8,9,10 (non-rail modes) to AM_Bus_Lines.lin
*copy "Inputs\Mode1@TIME_PERIOD@.lin" + "Inputs\Mode2@TIME_PERIOD@.lin" + "Inputs\Mode6@TIME_PERIOD@.lin" +
   "Inputs\Mode7@TIME_PERIOD@.lin" + "Inputs\Mode8@TIME_PERIOD@.lin" + "Inputs\Mode9@TIME_PERIOD@.lin" +
   "Inputs\Mode10@TIME_PERIOD@.lin"  "@TIME_PERIOD@_Bus_Lines.lin"

; combine Metro and LRT 3,5 to @TIME_PERIOD@_MRL_Lines.lin
*copy "Inputs\Mode3@TIME_PERIOD@.lin" + "Inputs\Mode5@TIME_PERIOD@.lin"   "@TIME_PERIOD@_MRL_Lines.lin"


;; *********************************
;; ***** C. Create kiss-n-Ride Legs
;; *********************************
;;
;; Step 1 **** Create KNR links for Metrorail stations
;;
RUN PGM=PUBLIC TRANSPORT
  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"
  FILEI LINEI[1] = "@TIME_PERIOD@_Bus_Lines.lin"
  FILEI LINEI[2] = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "KNR_MR_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
        lw.GENTRSTIME = li.TRANTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP
    GENERATE,
      NTLEGMODE = 18,
      COST=li.TRANTIME + (li.toll+li.distance*@_opcost@)/100*@_MinPerDoll@,
      MAXCOST=10*15,           ; gallop
      FROMNODE=1-3675,
      TONODE=8001-8012,8019-8030,8034,8038-8040,8042-8065,8073-8087,8089,8091-8094,8096-8097,
      DIRECTION = 1,
      EXCLUDELINK = (li.Mode = 1-10, 11),
      MAXNTLEGS = 10*5,        ;gallop
      SLACK = 10*5,           ; gallop
      LIST = Y
  ENDPROCESS
ENDRUN
;;
;; Step 2 **** Create KNR links for commuter rail stations
;;
RUN PGM=PUBLIC TRANSPORT
  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"
  FILEI LINEI[1] = "@TIME_PERIOD@_Bus_Lines.lin"
  FILEI LINEI[2] = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI LINEI[3] = "@TIME_PERIOD@_CRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "KNR_CR_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
        lw.GENTRSTIME = li.TRANTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP
    GENERATE,
      NTLEGMODE = 18,
      COST=li.TRANTIME + (li.toll+li.distance*@_opcost@)/100*@_MinPerDoll@,
      MAXCOST=10*15,           ; gallop
      FROMNODE=1-3675,
      TONODE=9001-9098,
      DIRECTION = 1,
      EXCLUDELINK = (li.Mode = 1-10 ),  ; Need to use mode 11 links to build the knr NT
      MAXNTLEGS = 10*5,        ;gallop
      SLACK = 10*5,           ; gallop
      LIST = Y
  ENDPROCESS
ENDRUN
;;
;; Step 3 **** Create KNR links for LRT/BRT car stations
;;
RUN PGM=PUBLIC TRANSPORT
  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"
  FILEI LINEI[1] = "@TIME_PERIOD@_Bus_Lines.lin"
  FILEI LINEI[2] = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "KNR_LRT_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
        lw.GENTRSTIME = li.TRANTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP
    GENERATE,
      NTLEGMODE = 18,
      COST=li.TRANTIME + (li.toll+li.distance*@_opcost@)/100*@_MinPerDoll@,
      MAXCOST=10*10,           ; gallop
      FROMNODE=1-3675,
      TONODE=10001-10098,
      DIRECTION = 1,
      EXCLUDELINK = (li.Mode = 1-10),  ; Need to use mode 11 links to build the knr NT
      MAXNTLEGS = 10*5,        ;gallop
      SLACK = 10*5,           ; gallop
      LIST = Y
  ENDPROCESS
ENDRUN
;;
;; Step 4 **** Create KNR links for bus stations (Bus PNR stations only)
;;
RUN PGM=PUBLIC TRANSPORT
  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"
  FILEI LINEI[1] = "@TIME_PERIOD@_Bus_Lines.lin"
  FILEI LINEI[2] = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\@TIME_PERIOD@_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "KNR_BUS_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
        lw.GENTRSTIME = li.TRANTIME
  ENDPROCESS

  PROCESS PHASE = DATAPREP
    GENERATE,
      NTLEGMODE = 18,
      COST=li.TRANTIME + (li.toll+li.distance*@_opcost@)/100*@_MinPerDoll@,
      MAXCOST=10*10,           ; gallop
      FROMNODE=1-3675,
      TONODE=15001-15135,
      DIRECTION = 1,
      EXCLUDELINK = (li.Mode = 1-10, 11),   ; Need to use mode 11 links to build the knr NT legs
      MAXNTLEGS = 10*5,        ;gallop
      SLACK = 10*5,           ; gallop
      LIST = Y
  ENDPROCESS
ENDRUN
;;
;;
;; *********************************
;; ***** D. Create Park-n-Ride legs
;; *********************************
;;
;; Step 1 **** Create PNR links for Metrorail stations

RUN PGM=PUBLIC TRANSPORT
  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"
  FILEI LINEI[1] = "@TIME_PERIOD@_Bus_Lines.lin"
  FILEI LINEI[2] = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI LINEI[3] = "@TIME_PERIOD@_CRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\AM_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "PNR_MR_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
        lw.GENTRSTIME = li.TRANTIME
        LW.LIMIT = 0                              ; Set link restriction code "LIMIT"
 @AM_MODE@        IF (LI.AMLIMIT= 9) LW.LIMIT = 9
 @OP_MODE@        IF (LI.OPLIMIT= 9) LW.LIMIT = 9

  ENDPROCESS

  PROCESS PHASE = DATAPREP
    GENERATE,
      NTLEGMODE = 19,
      COST=li.TRANTIME + (li.toll+li.distance*@_opcost@)/100*@_MinPerDoll@,
      MAXCOST=10*60,        ; Revise max. cost in min. (note cost include pnr parking cost and walk time combined) - Gallop
      FROMNODE=1-3675,
      TONODE=8001-8098,
      DIRECTION = 1,
      EXCLUDELINK = (li.Mode = 1-10, 12-14)|| (LW.LIMIT = 9),     ; Also exclude Mode 13 (walk-xfer)
      MAXNTLEGS = 10*5,     ; Revise max. no. of legs to 5 for all transit modes, Gallop
      SLACK = 10*15,        ; Revise the "slack" value to 15 min. - Gallop
      LIST = Y
  ENDPROCESS
ENDRUN
;;
;; Step 2 **** Create PNR links for Commuter rail stations

RUN PGM=PUBLIC TRANSPORT
  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"
  FILEI LINEI[1] = "@TIME_PERIOD@_Bus_Lines.lin"
  FILEI LINEI[2] = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI LINEI[3] = "@TIME_PERIOD@_CRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\AM_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "PNR_CR_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
        lw.GENTRSTIME = li.TRANTIME
        LW.LIMIT = 0                              ; Set link restriction code "LIMIT"
 @AM_MODE@        IF (LI.AMLIMIT= 9) LW.LIMIT = 9
 @OP_MODE@        IF (LI.OPLIMIT= 9) LW.LIMIT = 9
  ENDPROCESS

  PROCESS PHASE = DATAPREP
    GENERATE,
      NTLEGMODE = 19,
      COST=li.TRANTIME + (li.toll+li.distance*@_opcost@)/100*@_MinPerDoll@,
      MAXCOST=10*60,        ; Revise max. cost in min. (note cost include pnr parking cost and walk time combined) - Gallop
      FROMNODE=1-3675,
      TONODE=9001-9098,
      DIRECTION = 1,
      EXCLUDELINK = (li.Mode = 1-10, 12-14)|| (LW.LIMIT = 9),     ; Also exclude Mode 13 (walk-xfer)
      MAXNTLEGS = 10*5,     ; Revise max. no. of legs to 5 for all transit modes, Gallop
      SLACK = 10*15,        ; Revise the "slack" value to 15 min. - Gallop
      LIST = Y
  ENDPROCESS
ENDRUN
;;
;; Step 3 **** Create PNR links for LRT stations

RUN PGM=PUBLIC TRANSPORT
  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"
  FILEI LINEI[1] = "@TIME_PERIOD@_Bus_Lines.lin"
  FILEI LINEI[2] = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI LINEI[3] = "@TIME_PERIOD@_CRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\AM_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "PNR_LRT_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
        lw.GENTRSTIME = li.TRANTIME
        LW.LIMIT = 0                              ; Set link restriction code "LIMIT"
 @AM_MODE@        IF (LI.AMLIMIT= 9) LW.LIMIT = 9
 @OP_MODE@        IF (LI.OPLIMIT= 9) LW.LIMIT = 9
  ENDPROCESS

  PROCESS PHASE = DATAPREP
    GENERATE,
      NTLEGMODE = 19,
      COST=li.TRANTIME + (li.toll+li.distance*@_opcost@)/100*@_MinPerDoll@,
      MAXCOST=10*30,        ; Revise max. cost in min. (note cost include pnr parking cost and walk time combined) - Gallop
      FROMNODE=1-3675,
      TONODE=10001-10098,
      DIRECTION = 1,
      EXCLUDELINK = (li.Mode = 1-10, 12-14)|| (LW.LIMIT = 9),     ; Also exclude Mode 13 (walk-xfer)                                                                                                        ; links - Gallop
      MAXNTLEGS = 10*5,     ; Revise max. no. of legs to 5 for all transit modes, Gallop
      SLACK = 10*10,        ; Revise the "slack" value to 10 min. for LRT stations - Gallop
      LIST = Y
  ENDPROCESS
ENDRUN
;;
;; Step 4 **** Create PNR links for Bus PnR stations

RUN PGM=PUBLIC TRANSPORT
  FILEI NETI = "@itr@_@TIME_PERIOD@_PT.NET"
  FILEI LINEI[1] = "@TIME_PERIOD@_Bus_Lines.lin"
  FILEI LINEI[2] = "@TIME_PERIOD@_MRL_Lines.lin"
  FILEI LINEI[3] = "@TIME_PERIOD@_CRL_Lines.lin"
  FILEI FACTORI[1] = "Inputs\AM_TRN.FAC"
  FILEI SYSTEMI = "Inputs\TSYSD.PTS"

  FILEO NTLEGO = "PNR_BUS_@TIME_PERIOD@.LEG", XN=N

  PARAMETERS TRANTIME = lw.GENTRSTIME

  PROCESS PHASE = LINKREAD
        lw.GENTRSTIME = li.TRANTIME
        LW.LIMIT = 0                              ; Set link restriction code "LIMIT"
 @AM_MODE@        IF (LI.AMLIMIT= 9) LW.LIMIT = 9
 @OP_MODE@        IF (LI.OPLIMIT= 9) LW.LIMIT = 9
  ENDPROCESS

  PROCESS PHASE = DATAPREP
    GENERATE,
      NTLEGMODE = 19,
      COST=li.TRANTIME +  (li.toll+li.distance*@_opcost@)/100*@_MinPerDoll@,
      MAXCOST=10*30,
      FROMNODE=1-3675,
      TONODE=15001-15135,
      DIRECTION = 1,
      EXCLUDELINK = (li.Mode = 1-10, 12-14)|| (LW.LIMIT = 9),   ; Also exclude Mode 13 (walk-xfer                                                                                                                                                         ; links - Gallop
      MAXNTLEGS = 10*5,     ; Revise max. no. of legs to 5 for all transit modes, Gallop
      SLACK = 10*10,        ; Revise the "slack" value to 10 min. for bus PnR stations - Gallop
      LIST = Y
  ENDPROCESS
ENDRUN

;; This additional step is performed after all the non-transit legs are generated to override the distance of Mode 15 (Parking lot to Station transfer links)
;; fxie@3/18/2020

RUN PGM = NETWORK
ZONES=3722

NETI[1] = @itr@_@TIME_PERIOD@_PT.NET
LINKI[2] = INPUTS\RAIL_LINKS.DBF

; Rail station data file for lookup function - Gallop
  FILEI LOOKUPI[1]= "_RAILSTATIONS.TXT"
  LOOKUP LOOKUPI=1, NAME= STATION, ;
  LOOKUP[1]= 1, RESULT=2, ;     AM peak PNR impedance
  LOOKUP[2]= 1, RESULT=3, ;     Off peak PNR impedance
  LOOKUP[3]= 1, RESULT=4, ;     AM parking cost
  LOOKUP[4]= 1, RESULT=5, ;     Off Peak parking cost
  LOOKUP[5]= 1, RESULT=6, ;     Station walk time
  INTERPOLATE=F, FAIL=0,0,0

 IF (MODE = 15)   ; REVISE THE PNR CONNECTOR IMPEDANCE AND ADD STATION WALK TIME
   _STANOB = LI.1.B		    ;RETRIEVE THE PNR STATION NODE NUMBER
   
   IF (@PERIOD@=1)
		_park = INT(max(1.0,(STATION(3,_STANOB)/2.0)))   ; One-way AM period parking cost
   ELSE
		_park = INT(max(1.0,(STATION(4,_STANOB)/2.0)))   ; One-way OP period parking cost
   ENDIF
   DISTANCE= _park ;to be consistent with the TRNBUILD process for Ver. 2.3 (parker.s), the distance attribute of PNR transfer links (mode 15) is overridden with pk/op parking cost in cents  - fxie@2/14/2020
   
  ENDIF

ENDRUN

;; ************* Combine walk access/egress/transfer Non-Transit Legs ************************************
 *copy "ACC_WK2BUS_@TIME_PERIOD@.LEG" + "ACC_WK2METLRT_@TIME_PERIOD@.LEG" + "ACC_WK2COM_@TIME_PERIOD@.LEG" "WACC_@TIME_PERIOD@.LEG"
 *copy "EGR_WK2BUS_@TIME_PERIOD@.LEG" + "EGR_WK2METLRT_@TIME_PERIOD@.LEG" + "EGR_WK2COM_@TIME_PERIOD@.LEG" "WEGR_@TIME_PERIOD@.LEG"
 *copy "WK_BUS2BUS_@TIME_PERIOD@.LEG" +"WK_BUS2COM_@TIME_PERIOD@.LEG" + "WK_BUS2LRT_@TIME_PERIOD@.LEG" + "WK_BUS2MET_@TIME_PERIOD@.LEG" +
   "WK_COM2BUS_@TIME_PERIOD@.LEG" + "WK_COM2COM_@TIME_PERIOD@.LEG" + "WK_COM2LRT_@TIME_PERIOD@.LEG" + "WK_COM2MET_@TIME_PERIOD@.LEG" + "WK_LRT2BUS_@TIME_PERIOD@.LEG" +
    "WK_LRT2COM_@TIME_PERIOD@.LEG" + "WK_LRT2LRT_@TIME_PERIOD@.LEG" + "WK_LRT2MET_@TIME_PERIOD@.LEG" +
  "WK_MET2BUS_@TIME_PERIOD@.LEG" + "WK_MET2COM_@TIME_PERIOD@.LEG" + "WK_MET2LRT_@TIME_PERIOD@.LEG" + "WK_MET2MET_@TIME_PERIOD@.LEG" "XFER_@TIME_PERIOD@.LEG"
;; ****************************************************************************


;; ************* Combine KNR Non-Transit Legs ************************************

;* COPY "KNR_CR_@TIME_PERIOD@.LEG" + "KNR_MR_@TIME_PERIOD@.LEG"  + "KNR_LRT_@TIME_PERIOD@.LEG" + "KNR_BUS_@TIME_PERIOD@.LEG" "KNR_@TIME_PERIOD@.LEG"
* COPY  "KNR_MR_@TIME_PERIOD@.LEG"  + "KNR_LRT_@TIME_PERIOD@.LEG" + "KNR_BUS_@TIME_PERIOD@.LEG" "KNR_@TIME_PERIOD@.LEG"

;; ********************************************************************************
;; ************* Combine PNR Non-Transit Legs ************************************

* COPY "PNR_CR_@TIME_PERIOD@.LEG" + "PNR_MR_@TIME_PERIOD@.LEG"  + "PNR_LRT_@TIME_PERIOD@.LEG" + "PNR_BUS_@TIME_PERIOD@.LEG" "PNR_@TIME_PERIOD@.LEG"
;; ********************************************************************************


ENDLOOP  ; --- END PERIOD LOOP ---



