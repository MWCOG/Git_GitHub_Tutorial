;Post_Skim_PT.s
; This script generates the final skim matrix file, with updating the drive access time, wait time and include the transit fare skim data
; derived from the MFARE programs.
;
; To adapt to the Ver. 2.3/Ver. 2.4 Model, the Ver. 2.5 process is replaced with the Ver. 2.3 TRNBUILD processes in Assemble_Skim_CR|MR|BM|AB.s, with appropriate modifications - fxie@2/13/2020

; Read Deflation Factor
READ FILE=TRN_Deflator.txt

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

; ****** Now start the MR|BM|AB mode loop
; ****** CR mode will be run later

LOOP MODE = 1,3

  IF (MODE = 1)
   MOD = 'MR'
  ELSEIF (MODE = 2)
   MOD = 'BM'  
  ELSE
   MOD = 'AB'
  ENDIF

;---------------------------------------------------------------------------
;Assemble Skims & Fares into Files for Mode Choice for MR|BM|AB
;---------------------------------------------------------------------------
RUN PGM=MATRIX
 MATI[1]=%_iter_%_@TIME_PERIOD@_WK_@MOD@.SKM
 MATI[2]=%_iter_%_@TIME_PERIOD@_WK_@MOD@.FAR 
 MATI[3]=%_iter_%_@TIME_PERIOD@_DR_@MOD@.SKM
 MATI[4]=%_iter_%_@TIME_PERIOD@_DR_@MOD@.FAR
 MATI[5]=%_iter_%_@TIME_PERIOD@_KR_@MOD@.SKM
 MATI[6]=%_iter_%_@TIME_PERIOD@_KR_@MOD@.FAR
 MATO[1]=%_iter_%_TRN@TIME_PERIOD@_@MOD@.SKM, MO = 1-48,
  NAME = WWAET, WWLKT, WINIT, WXFRT, WIVTT, WIVCR, WIVXB, WIVMR, WIVN1,
  WIVN2, WIVLB, WNXFR, WFARE, WXPEN,
         DWAET, DWLKT, DINIT, DXFRT, DIVTT, DIVCR, DIVXB, DIVMR, DIVN1,
  DIVN2, DIVLB, DNXFR, DFARE, DXPEN, DACCT, DACCD, DPRKC, DPRKT,
         KWAET, KWLKT, KINIT, KXFRT, KIVTT, KIVCR, KIVXB, KIVMR, KIVN1,
  KIVN2, KIVLB, KNXFR, KFARE, KXPEN, KACCT, KACCD
MW[1] = MI.1.21 * 100   ;---- wlk walk acc time    (0.01 min)
MW[2] = MI.1.22 * 100   ;---- wlk other walk time  (0.01 min)
MW[3] = MI.1.7 * 100    ;---- wlk ini.wait time    (0.01 min)
MW[4] = MI.1.8 * 100    ;---- wlk xfr wait time    (0.01 min)
MW[5] = MI.1.3 * 100    ;---- wlk ivt-total        (0.01 min) ; will be overridden below -fxie
MW[6] = MI.1.4 * 100    ;---- wlk ivt-commuter rail(0.01 min)
MW[7] = MI.1.2 * 100    ;---- wlk ivt-exp bus      (0.01 min)
MW[8] = MI.1.3 * 100    ;---- wlk ivt-metrorail    (0.01 min)
MW[9] = MI.1.5 * 100    ;---- wlk ivt-new rail mode(0.01 min)
MW[10] = MI.1.6 * 100   ;---- wlk ivt-new bus mode (0.01 min)
MW[11] = MI.1.1 * 100   ;---- wlk ivt-local bus    (0.01 min)
MW[12] = MI.1.23        ;---- wlk transfers        (0+)
MW[13] = MI.2.1         ;---- wlk fare             (2007 cents) ; use MFARE2 fare although PT also calculates fare in MI.1.11
MW[14] = MI.1.24 * 100  ;---- wlk added board time (0.01 min)
MW[15] = MI.3.21 * 100  ;---- drv walk acc time    (0.01 min)
MW[16] = MI.3.22 * 100  ;---- drv other walk time  (0.01 min)
MW[17] = MI.3.7 * 100   ;---- drv ini.wait time    (0.01 min)
MW[18] = MI.3.8 * 100   ;---- drv xfr wait time    (0.01 min)
MW[19] = MI.3.3 * 100   ;---- drv ivt-total        (0.01 min) ; will be overridden below -fxie
MW[20] = MI.3.4 * 100   ;---- drv ivt-commuter rail(0.01 min)
MW[21] = MI.3.2 * 100   ;---- drv ivt-exp bus      (0.01 min)
MW[22] = MI.3.3 * 100   ;---- drv ivt-metrorail    (0.01 min)
MW[23] = MI.3.5 * 100   ;---- drv ivt-new rail mode(0.01 min)
MW[24] = MI.3.6 * 100   ;---- drv ivt-new bus mode (0.01 min)
MW[25] = MI.3.1 * 100   ;---- drv ivt-local bus    (0.01 min)
MW[26] = MI.3.23        ;---- drv transfers        (0+)
MW[27] = MI.4.1         ;---- drv fare             (2007 cents) ; use MFARE2 fare although PT also calculates fare in MI.3.11
MW[28] = MI.3.24 * 100  ;---- drv added board time (0.01 min)
MW[29] = MI.3.10 * 100  ;---- drv acc time         (0.01 min)
MW[30] = MI.3.12 * 100  ;---- drv acc distance     (0.01 mile)
MW[31] = MI.3.26        ;---- drv park cost        (2007 cents)
MW[32] = MI.3.25 * 100  ;---- drv park time        (0.01 min)
MW[33] = MI.5.21 * 100  ;---- knr walk acc time    (0.01 min)
MW[34] = MI.5.22 * 100  ;---- knr other walk time  (0.01 min)
MW[35] = MI.5.7 * 100   ;---- knr ini.wait time    (0.01 min)
MW[36] = MI.5.8 * 100   ;---- knr xfr wait time    (0.01 min)
MW[37] = MI.5.3 * 100   ;---- knr ivt-total        (0.01 min) ; will be overridden below -fxie
MW[38] = MI.5.4 * 100   ;---- knr ivt-commuter rail(0.01 min)
MW[39] = MI.5.2 * 100   ;---- knr ivt-exp bus      (0.01 min)
MW[40] = MI.5.3 * 100   ;---- knr ivt-metrorail    (0.01 min)
MW[41] = MI.5.5 * 100   ;---- knr ivt-new rail mode(0.01 min)
MW[42] = MI.5.6 * 100   ;---- knr ivt-new bus mode (0.01 min)
MW[43] = MI.5.1 * 100   ;---- knr ivt-local bus    (0.01 min)
MW[44] = MI.5.23        ;---- knr transfers        (0+)
MW[45] = MI.6.1         ;---- knr fare             (2007 cents) ; use MFARE2 fare although PT also calculates fare in MI.5.11
MW[46] = MI.5.24 * 100  ;---- knr added board time (0.01 min)
MW[47] = MI.5.10 * 100  ;---- knr acc time         (0.01 min)
MW[48] = MI.5.12 * 100  ;---- knr acc distance     (0.01 mile)

JLOOP

; assemble total IVTT

  MW[05] = MW[06]+MW[07]+MW[08]+MW[09]+MW[10]+MW[11]
  MW[19] = MW[20]+MW[21]+MW[22]+MW[23]+MW[24]+MW[25]
  MW[37] = MW[38]+MW[39]+MW[40]+MW[41]+MW[42]+MW[43]

; zero-out fares for IVTT=0

  IF (MW[05]=0 ) MW[13]=0
  IF (MW[19]=0 ) MW[27]=0
  IF (MW[37]=0 ) MW[45]=0

; deflate parking costs to 2007

  MW[31] = @DEFLATIONFTR@*MW[31]

ENDJLOOP

ENDRUN

ENDLOOP  ;----- End of Transit Mode Loop

;---------------------------------------------------------------------------
;Assemble Skims & Fares into Files for Mode Choice for CR
;---------------------------------------------------------------------------
RUN PGM=MATRIX
 MATI[1]=%_iter_%_@TIME_PERIOD@_WK_CR.SKM
 MATI[2]=%_iter_%_@TIME_PERIOD@_WK_CR.FAR 
 MATI[3]=%_iter_%_@TIME_PERIOD@_DR_CR.SKM
 MATI[4]=%_iter_%_@TIME_PERIOD@_DR_CR.FAR
 MATO[1]=%_iter_%_TRN@TIME_PERIOD@_CR.SKM, MO = 1-32,
  NAME = WWAET, WWLKT, WINIT, WXFRT, WIVTT, WIVCR, WIVXB, WIVMR, WIVN1,
  WIVN2, WIVLB, WNXFR, WFARE, WXPEN,
         DWAET, DWLKT, DINIT, DXFRT, DIVTT, DIVCR, DIVXB, DIVMR, DIVN1,
  DIVN2, DIVLB, DNXFR, DFARE, DXPEN, DACCT, DACCD, DPRKC, DPRKT
MW[1] = MI.1.21 * 100   ;---- wlk walk acc time    (0.01 min)
MW[2] = MI.1.22 * 100   ;---- wlk other walk time  (0.01 min)
MW[3] = MI.1.7 * 100    ;---- wlk ini.wait time    (0.01 min)
MW[4] = MI.1.8 * 100    ;---- wlk xfr wait time    (0.01 min)
MW[5] = MI.1.3 * 100    ;---- wlk ivt-total        (0.01 min) ; will be overriden below -fxie
MW[6] = MI.1.4 * 100    ;---- wlk ivt-commuter rail(0.01 min)
MW[7] = MI.1.2 * 100    ;---- wlk ivt-exp bus      (0.01 min)
MW[8] = MI.1.3 * 100    ;---- wlk ivt-metrorail    (0.01 min)
MW[9] = MI.1.5 * 100    ;---- wlk ivt-new rail mode(0.01 min)
MW[10] = MI.1.6 * 100   ;---- wlk ivt-new bus mode (0.01 min)
MW[11] = MI.1.1 * 100   ;---- wlk ivt-local bus    (0.01 min)
MW[12] = MI.1.23        ;---- wlk transfers        (0+)
MW[13] = MI.2.1         ;---- wlk fare             (2007 cents) ; use MFARE2 fare although PT also calculates fare in MI.1.11
MW[14] = MI.1.24 * 100  ;---- wlk added board time (0.01 min)
MW[15] = MI.3.21 * 100  ;---- drv walk acc time    (0.01 min)
MW[16] = MI.3.22 * 100  ;---- drv other walk time  (0.01 min)
MW[17] = MI.3.7 * 100   ;---- drv ini.wait time    (0.01 min)
MW[18] = MI.3.8 * 100   ;---- drv xfr wait time    (0.01 min)
MW[19] = MI.3.3 * 100   ;---- drv ivt-total        (0.01 min) ; will be overriden below -fxie
MW[20] = MI.3.4 * 100   ;---- drv ivt-commuter rail(0.01 min)
MW[21] = MI.3.2 * 100   ;---- drv ivt-exp bus      (0.01 min)
MW[22] = MI.3.3 * 100   ;---- drv ivt-metrorail    (0.01 min)
MW[23] = MI.3.5 * 100   ;---- drv ivt-new rail mode(0.01 min)
MW[24] = MI.3.6 * 100   ;---- drv ivt-new bus mode (0.01 min)
MW[25] = MI.3.1 * 100   ;---- drv ivt-local bus    (0.01 min)
MW[26] = MI.3.23        ;---- drv transfers        (0+)
MW[27] = MI.4.1         ;---- drv fare             (2007 cents) ; use MFARE2 fare although PT also calculates fare in MI.3.11
MW[28] = MI.3.24 * 100  ;---- drv added board time (0.01 min)
MW[29] = MI.3.10 * 100  ;---- drv acc time         (0.01 min)
MW[30] = MI.3.12 * 100  ;---- drv acc distance     (0.01 mile)
MW[31] = MI.3.26        ;---- drv park cost        (2007 cents)
MW[32] = MI.3.25 * 100  ;---- drv park time        (0.01 min)


JLOOP

; assemble total IVTT

  MW[05] = MW[06]+MW[07]+MW[08]+MW[09]+MW[10]+MW[11]
  MW[19] = MW[20]+MW[21]+MW[22]+MW[23]+MW[24]+MW[25]

; zero-out fares for IVTT=0

  IF (MW[05]=0 ) MW[13]=0
  IF (MW[19]=0 ) MW[27]=0

; deflate parking costs to 2007

  MW[31] = @DEFLATIONFTR@*MW[31]

ENDJLOOP

ENDRUN

ENDLOOP  ;----- End of Time Period Loop
