; This script performs transit skim process and generates the skim files, route files and PT process network files by:
; i) time period (AM and OP)
; ii) access mode (Walk, PNR access); no KNR for CR
; A total of 4 transit skim files are generated.
; 8/23/18:  Added TOTAL transit time (actual, not perceived) to the transit skim output file (see lines with *RJM, RQN*)

itr ='%_iter_%'  ; current  iteration
READ FILE='TRN_Deflator.txt' ; transit deflator file

LOOP PERIOD=1,2

 IF (PERIOD = 1)
  TIME_PERIOD = 'AM'
  AM_MODE = ' '
  OP_MODE = ';'
 ELSE
  TIME_PERIOD = 'OP'
  AM_MODE = ';'
  OP_MODE = ' '
 ENDIF

; ****** Now start the access mode loop
;

LOOP ACCESS = 1,2 ;fxie 3/30/2020: it is assumed that there is no KNR for CR

  IF (ACCESS = 1)
   ACCESS_MODE = 'WK'
   WLK_MODEL = ' '
   PNR_MODEL = ';'
  ELSEIF (ACCESS = 2)
   ACCESS_MODE = 'DR'
   WLK_MODEL = ';'
   PNR_MODEL = ' '
  ENDIF


; Prepare the network for transit skimming for each transit submode (CR|MR|AB|BM)
; Commuter Rail (CR) - a trip that contains any CR leg is labeled as a CR trip
; Transit Links: include everything 
; Zonal Access Links (PNR); turn off access links to PNR lots or stations for other modes

RUN PGM = NETWORK
ZONES=3722

NETI[1] = @itr@_@TIME_PERIOD@_PT.NET
NETO=@itr@_@TIME_PERIOD@_PT_CR.NET, INCLUDE =DISTANCE,JUR,FTYPE,TOLL,TOLLGRP,AMLANE,AMLIMIT,PMLANE,PMLIMIT,OPLANE,OPLIMIT,
    TRANTIME,WKTIME,MODE,SPEED

  IF (MODE=11,14 && !(A=9001-9999,12000-12999 || B=9001-9999,12000-12999)) ; only keep drive access links to commuter rail stations (KNR) and to commuter rail parking lots (PNR)
	DELETE
  ENDIF
  
ENDRUN
;
;
; Now start the path-building and skimming process
; STEP I: Run the PT process for skimming process
;    Requires following files:
;     i) Transit network file (in highway network format)
;    ii) Non-Transit Leg files
;    iii) Transit line files
;    iv) Factor file
;    v) transit system file
;    vi) fare structure file

;;
;; Step 1: Perform PT route enumeration process and create the PT network file and PT route file
;;
RUN PGM = PUBLIC TRANSPORT
FILEI NETI = "@itr@_@TIME_PERIOD@_PT_CR.NET"
FILEO ROUTEO[1] = "@itr@_@TIME_PERIOD@_@ACCESS_MODE@_CR.RTE"
FILEO REPORTO = "@itr@_PT_Skims_@TIME_PERIOD@_@ACCESS_MODE@_CR.PRN"
FILEO NETO = "@itr@_@TIME_PERIOD@_@ACCESS_MODE@_CR.NET"
FILEO NTLEGO ="@itr@_NTLEG_@TIME_PERIOD@_@ACCESS_MODE@_CR.NT"
;--------
FILEO LINKO = "@itr@_@TIME_PERIOD@_@ACCESS_MODE@_CR_LINK.DBF", ONOFFS=N
;--------
;Input ModeAccess specific factors
FILEI FACTORI[1] = "Inputs\AM_TRN.FAC"
FILEI SYSTEMI = "Inputs\TSYSD.PTS"

;---- Non-Transit legs  ----
FILEI NTLEGI[1] = "WEGR_@TIME_PERIOD@.LEG"
FILEI NTLEGI[2] = "XFER_@TIME_PERIOD@.LEG"
@WLK_MODEL@FILEI NTLEGI[3] = "WACC_@TIME_PERIOD@.LEG"
@PNR_MODEL@FILEI NTLEGI[3] = "PNR_CR_@TIME_PERIOD@.LEG" ; changed from "PNR_@TIME_PERIOD@.LEG"
; fxie 3/30/2020: this change allows only a commuter rail station (PNR lot) to be the PNR access point for a PNR-access CR trip
; This change was made because PT built paths that park and ride at a bus PNR station and then transfer to commuter rail,
; which are very rare in reality. 
;
; Fare System Definition
FILEI FAREI = INPUTS\FARE_@TIME_PERIOD@.DAT
FILEI FAREMATI[1] = Metrorail_Fare.mat
FILEI FAREMATI[2] = VRE_Fare.mat
FILEI FAREMATI[3] = MARC_Fare.mat

;---- Transit modes (1 to 10 except commuter rail)  ----

FILEI LINEI[1] = "@TIME_PERIOD@_Bus_Lines.lin"      ; Read in bus line file for "cR" mode

FILEI LINEI[2] = "@TIME_PERIOD@_MRL_Lines.lin"   ; Read in Metrorail line file for "CR" mode

FILEI LINEI[3] = "@TIME_PERIOD@_CRL_Lines.lin"    ; Read in commuter rail line file for "CR" mode

zonemsg=50

; OVERALL PARAMETERS OF RUN
PARAMETERS FARE=T, HDWAYPERIOD=1,NOROUTEERRS=999999,
           NOROUTEMSGS=999999,SKIPBADLINES=Y,
           TRANTIME=LI.TRANTIME

REPORT LINES=T
PROCESS PHASE=LINKREAD
 ;LW.AMHTIME=LI.AMHTIME
 ;LW.WALKTIME=(LI.DISTANCE/3*60)
 ;LW.WALKDISTANCE=LI.DISTANCE
 ;LW.DISTANCE=LI.DISTANCE
ENDPROCESS

PROCESS PHASE=DATAPREP
    GENERATE READNTLEGI=1
    GENERATE READNTLEGI=2
    GENERATE READNTLEGI=3
    ;GENERATE READNTLEGI=4
    ;GENERATE READNTLEGI=5
ENDPROCESS
ENDRUN
;;
;;
;; Step 2: start the skim process to output the skim matrices
;;
;;
RUN PGM = PUBLIC TRANSPORT


FILEI NETI = "@itr@_@TIME_PERIOD@_@ACCESS_MODE@_CR.NET"
FILEI ROUTEI = "@itr@_@TIME_PERIOD@_@ACCESS_MODE@_CR.RTE"
FILEO REPORTO = "@itr@_@TIME_PERIOD@_@ACCESS_MODE@_CR_SKIM.PRN"
FILEO LINKO = "@itr@_@TIME_PERIOD@_@ACCESS_MODE@_CR_LINKVOL.DBF", ONOFFS=N

FILEO MATO[1] = "@itr@_@TIME_PERIOD@_@ACCESS_MODE@_CR_SKM.TMP", MO=1-26, ;; *RJM* changed 'MO=1-19,' to 'MO=1-20,'
  NAME = IVTLB, IVTXB, IVTMR, IVTCR, IVTLR, IVTBR, IWAIT, XWAIT, WALKT, DRVACCT, FARE, DRVACCD,
  PNRCOST, BRDLB, BRDXB, BRDMR, BRDCR, BRDLR, BRDBR, TOTTT, WALKACCT, WALKOTHT,XFERS, XFERPEN, PNRT,PNRC    ;; *RJM* added ',TOTTT' for name of 20th table Total Transit Time
																											;; add additional skims that will be used in the Ver. 2.3 Mode Choice model	 -fxie@2/14/2020						

; Fare System Definition
FILEI FAREI = INPUTS\FARE_@TIME_PERIOD@.DAT
FILEI FAREMATI[1] = Metrorail_Fare.mat
FILEI FAREMATI[2] = VRE_Fare.mat
FILEI FAREMATI[3] = MARC_Fare.mat

zonemsg=50
PARAMETERS FARE=T, HDWAYPERIOD=1,NOROUTEERRS=999999,
           NOROUTEMSGS=999999,SKIPBADLINES=Y,
           TRANTIME=LI.TRANTIME


PROCESS PHASE=SKIMIJ
;---- specify output skims ----

 MW[1] = TIMEA(0,1,6,8),                        ;---- ivt-local bus    (min)
 MW[2] = TIMEA(0,2,7,9),                        ;---- ivt-exp bus      ( min)
 MW[3] = TIMEA(0,3),                            ;---- ivt-metrorail    ( min)
 MW[4] = TIMEA(0,4),                            ;---- ivt-commuter rail( min)
 MW[5] = TIMEA(0,5),                            ;---- ivt-new rail mode( min)
 MW[6] = TIMEA(0,10),                           ;---- ivt-new bus mode ( min)
 MW[7] = IWAITA(0),                             ;---- ini.wait time    ( min)
 MW[8] = XWAITA(0),                             ;---- xfr wait time    ( min)
 MW[9] = TIMEA(0,20,21,22,23,24,25,33,34,35,44,45,55) ,                       ;---- walk acc time    ( min)
 MW[10] = TIMEA(0,18,19),                       ;---- drv acc time     ( min)
 MW[11] = FAREA(0)     						    ;---- fare (dollar)
 MW[12] = DIST(0,18,19),                        ;---- drv acc distance ( mile)
 MW[13] = 0,					;---- dummy
 MW[14] = BRDINGS(0,1,6,8),                     ;---- no. of boarding  - local bus
 MW[15] = BRDINGS(0,2,7,9),                     ;---- no. of boarding  - express bus
 MW[16] = BRDINGS(0,3),                         ;---- no. of boarding  - metro rail
 MW[17] = BRDINGS(0,4),                         ;---- no. of boarding  - commuter rail
 MW[18] = BRDINGS(0,5),                         ;---- no. of boarding  - light rail
 MW[19] = BRDINGS(0,10),                        ;---- no. of boarding  - brt
 MW[20] = TIMEA(0,ALLMODES) + IWAITA(0) + XWAITA(0),                    ; total actual transit time for all modes + waiting times/  *RJM, RQN* line added
 MW[21] = TIMEA(0,20,21),                       ;---- walk acc time    ( min)  ;differentiate walk access time (from/to zone centroids) and other walk time. fxie@2/13/2020
 MW[22] = TIMEA(0,22,23,24,25,33,34,35,44,45,55),;----  other walk time ( min) ;differentiate walk access time (from/to zone centroids) and other walk time. fxie@2/13/2020, MW[9]=MW[21]+MW[22]
 MW[23] = MW[14] + MW[15] + MW[16] + MW[17] + MW[18] + MW[19] - 1, ;---- no. of transfers fxie@2/13/2020
 MW[24] = XFERPENA(0, ALLMODES),				;---- transfer penalty for transit and non-transit modes ( min). Please note in TRNBUILD, XPEN applies to modes 1-16, including both transit and non-transit modes
 MW[25] = 0,
 MW[26] = 0
;---- perform adjustments to skims consistent with the Ver. 2.5 Post_Skim_PT process ----

; refer to lines 87-112 of Z:\ModelRuns\fy20\V2.5.13A\Scripts\Post_Skim_PT.S -fxie@2/28/2020
; while the Ver. 2.5 process performed three adjustments, the Ver.2.3 process only adopted the third one, for reasons below.

; Adjustment #1 (Skipped)
; the Ver. 2.5 process resets the initial wait time and transfer wait time by applying different weights (see below)
; I don't understand this process and think that actual wait times IWAITA(0) and XWAITA(0) should be fed into the mode choice model and they shouldn't be weighted. -fxie

; Here reset the initial wait time > 7 minutes and the xfer waiting due to the different weights in the wait time factors
; the value of 0.6 is the ratio of 1.5/2.5
;IF (MW[7] > 7) MW[7] = 7 + (MW[7] -7 )/0.6
;MW[8] = MW[8] / 0.6 

; Adjustment #2 (Skipped)
; the Ver. 2.5 process adjusts the drive access time to take out the parking cost component (see below)
; I think this is an error: driving access times never include parking cost component
; it may have meant to take out parking cost component from PNR time (Mode 15), but in the Ver. 2.3 PT implementation, the PNR time does not include the PNR cost component 
; IF (@ACCESS@ =2) 
; IF( MW[3] > 0 || MW[4] > 0) 

;  ISTA = mi.2.1   
;  MW[10] = max(2,MW[10] - PNRCOST*6/100)    ; Also need to 
                                            ; "6/100" is the factor of 6 mintues/dollar

;ENDIF
;ENDIF

; Adjustment #3
; The Ver. 2.5 process also deducts the distance-based highway operation cost from the access time matrix, which is also implemented here
  MW[10] = MW[10] - MW[12]*0.6   ; the factor 0.6 is the 0.6 min/mile, (i.e., 0.1 $/mile* 6 minutes/$)
; also update total transit time
  MW[20] = MW[20] - MW[12]*0.6

; Fare deflated to 2007 cents
  MW[11]=ROUND(MW[11]*100*@DeflationFTR@)
  

ENDPROCESS
ENDRUN

;;
;;
;; Step 3: rerun Step 1 and Step 2 to derive the skims of PNR transfer time and PNR parking cost
;;
;;
IF(ACCESS=2)

RUN PGM = PUBLIC TRANSPORT
FILEI NETI = "@itr@_@TIME_PERIOD@_PT_CR.NET"
FILEO ROUTEO[1] = "@itr@_@TIME_PERIOD@_@ACCESS_MODE@_CR_ALT.RTE"
FILEO REPORTO = "@itr@_PT_Skims_@TIME_PERIOD@_@ACCESS_MODE@_CR_ALT.PRN"
FILEO NETO = "@itr@_@TIME_PERIOD@_@ACCESS_MODE@_CR_ALT.NET"
;--------

;--------
;Input ModeAccess specific factors
FILEI FACTORI[1] = "Inputs\AM_TRN.FAC"
FILEI SYSTEMI = "Inputs\TSYSD.PTS"

;---- Non-Transit legs  ----
FILEI NTLEGI[1] = "WEGR_@TIME_PERIOD@.LEG"
FILEI NTLEGI[2] = "XFER_@TIME_PERIOD@.LEG"
FILEI NTLEGI[3] = "PNR_CR_@TIME_PERIOD@_ALT.LEG"
;
; Fare System Definition
FILEI FAREI = INPUTS\FARE_@TIME_PERIOD@.DAT
FILEI FAREMATI[1] = Metrorail_Fare.mat
FILEI FAREMATI[2] = VRE_Fare.mat
FILEI FAREMATI[3] = MARC_Fare.mat

;---- Transit modes (1 to 10 except commuter rail)  ----

FILEI LINEI[1] = "@TIME_PERIOD@_Bus_Lines.lin"      ; Read in bus line file for "cR" mode

FILEI LINEI[2] = "@TIME_PERIOD@_MRL_Lines.lin"   ; Read in Metrorail line file for "CR" mode

FILEI LINEI[3] = "@TIME_PERIOD@_CRL_Lines.lin"    ; Read in commuter rail line file for "CR" mode

zonemsg=50

; OVERALL PARAMETERS OF RUN
PARAMETERS FARE=T, HDWAYPERIOD=1,NOROUTEERRS=999999,
           NOROUTEMSGS=999999,SKIPBADLINES=Y,
           TRANTIME=LI.TRANTIME

REPORT LINES=T

PROCESS PHASE=DATAPREP
    GENERATE READNTLEGI=1
    GENERATE READNTLEGI=2
    GENERATE READNTLEGI=3
ENDPROCESS
ENDRUN
;;
;;
;;
;;
RUN PGM = PUBLIC TRANSPORT


FILEI NETI = "@itr@_@TIME_PERIOD@_@ACCESS_MODE@_CR_ALT.NET"
FILEI ROUTEI = "@itr@_@TIME_PERIOD@_@ACCESS_MODE@_CR_ALT.RTE"
FILEO REPORTO = "@itr@_@TIME_PERIOD@_@ACCESS_MODE@_CR_SKIM_ALT.PRN"
FILEO MATO[1] = "@itr@_@TIME_PERIOD@_@ACCESS_MODE@_CR_SKM_ALT.TMP", MO=2-3						

; Fare System Definition
FILEI FAREI = INPUTS\FARE_@TIME_PERIOD@.DAT
FILEI FAREMATI[1] = Metrorail_Fare.mat
FILEI FAREMATI[2] = VRE_Fare.mat
FILEI FAREMATI[3] = MARC_Fare.mat

zonemsg=50
PARAMETERS FARE=T, HDWAYPERIOD=1,NOROUTEERRS=999999,
           NOROUTEMSGS=999999,SKIPBADLINES=Y,
           TRANTIME=LI.TRANTIME


PROCESS PHASE=SKIMIJ
;---- specify output skims ----

 MW[1] = DIST(0,19),						  ; PNRParkingCost+PNRXferTime/100
 MW[2] = INT(MW[1])    		       	 	      ; PNRParkingCost in cents
 MW[3] = (MW[1]-MW[2])*100         	          ; PNRXferTime in min
 ;MW[4] = TIMEA(0,18,19)                      ; drv acc time  (min) for qc/qa only
 
ENDPROCESS
ENDRUN

ENDIF

;;
;;  Step 4: Generate skim files (.skm/.ttt) and fare files (.far) for CR|MR|AB|BM submodes. -fxie@9/17/2020
;;
RUN PGM = MATRIX
ZONES=3722
MATI[1]= "@itr@_@TIME_PERIOD@_@ACCESS_MODE@_CR_SKM.TMP"
@PNR_MODEL@MATI[2]= "@itr@_@TIME_PERIOD@_DR_CR_SKM_ALT.TMP"
MATO[1]=%_iter_%_@TIME_PERIOD@_@ACCESS_MODE@_CR.SKM, MO = 101-126,
		NAME = IVTLB, IVTXB, IVTMR, IVTCR, IVTLR, IVTBR, IWAIT, XWAIT, WALKT, DRVACCT, FARE, DRVACCD, PNRCOST, BRDLB, BRDXB, BRDMR, BRDCR, BRDLR, BRDBR, TOTTT, WALKACCT, WALKOTHT,XFERS, XFERPEN, PNRT,PNRC

; Export to .TTT files total transit time that includes travel times on all transit/non-transit legs as well as wait times. It does not include penalties or fares -fxie@2/14/2020
; please note that the TRNBUILD skimming process (Transit_Skims_CR|MR|BM|AB.s) includes all transit in-veh times, drive-access time, and transfer penalty (added transfer time) in total transit times.
; Specifically, the calculation in the TRNBUILD process is shown as follows:
; MW[100] =(MW[1]  +  MW[2]  +  MW[3]  +  MW[4] +  MW[5]   +
;           MW[6]  +  MW[7]  +  MW[8]  +  MW[9] +  MW[10]  +
;           MW[11] +  MW[13]) * 0.01   ;; Total Real Transit Time  in Whole Minutes (not incl. PNR 'impedance')
; The above calculation doesn't account for all components of real transit times (such as wait times, walk access times, walk transfer times, etc.), so although we can exactly replicate the above calculation,
; I used a different calculation, which may warrent a re-calibration of mode choice model, and it may affect the transit accessibility map which is developed based on .ttt travel times. - fxie

MATO[2]=%_iter_%_@TIME_PERIOD@_@ACCESS_MODE@_CR.ttt, MO = 120,NAME = sumtrntm
MATO[3]=%_iter_%_@TIME_PERIOD@_@ACCESS_MODE@_CR.FAR, MO = 111,NAME = FARE

FILLMW MW[1]=MI.1.1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
@PNR_MODEL@FILLMW MW[201]=MI.2.1,2

; CR
MW[100]= MW[4] 
JLOOP
IF (MW[100] = 0 ) ; if ivt for commuter rail is zero, then everything is zeroed out
   MW[101] = 0 MW[102] = 0 MW[103] = 0 MW[104] = 0 MW[105] = 0
   MW[106] = 0 MW[107] = 0 MW[108] = 0 MW[109] = 0 MW[110] = 0
   MW[111] = 0 MW[112] = 0 MW[113] = 0 MW[114] = 0 MW[115] = 0
   MW[116] = 0 MW[117] = 0 MW[118] = 0 MW[119] = 0 MW[120] = 0
   MW[121] = 0 MW[122] = 0 MW[123] = 0 MW[124] = 0 MW[125] = 0 MW[126] = 0
ELSE
   MW[101] = MW[1] MW[102] = MW[2] MW[103] = MW[3] MW[104] = MW[4] MW[105] = MW[5]
   MW[106] = MW[6] MW[107] = MW[7] MW[108] = MW[8] MW[109] = MW[9] MW[110] = MW[10]
   MW[111] = MW[11] MW[112] = MW[12] MW[113] = MW[13] MW[114] = MW[14] MW[115] = MW[15]
   MW[116] = MW[16] MW[117] = MW[17] MW[118] = MW[18] MW[119] = MW[19] MW[120] = MW[20]
   MW[121] = MW[21] MW[122] = MW[22] MW[123] = MW[23] MW[124] = MW[24] MW[125] = MW[25] MW[126] = MW[26]   
@PNR_MODEL@MW[125]=MW[202]
@PNR_MODEL@MW[126]=MW[201]
   
ENDIF
ENDJLOOP

ENDRUN

ENDLOOP  ;----- End of Access Mode Loop


ENDLOOP  ;----- End of Time Period Loop
