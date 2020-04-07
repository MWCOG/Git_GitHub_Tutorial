*del voya*.prn
;
;=====================================================================================================
;  Prepare_Ext_Auto_Ends.s                                                                            =
;  This process prepares Auto-related external Ps, As for the External Trip Distribution Process      =
;  The zonal level internal Ps & As are scaled (or balanced) to match external As & Ps, respectively  =
; 04/26/2018 RJM                                                                                      =
; Added section to adjust scaled external Ps and As to make sure the internal distribution of I/X and =
; X/I trips matched jurisdictional distribution indicated by AirSage data                             =
;=====================================================================================================

ZONESIZE       =  3722                       ;  No. of TAZs
Purps          =  5                          ;  No. of purposes
LastIZn        =  3675                       ;  Last Internal TAZ no.
Scaled_IntPsAs    ='%_iter_%_Ext_Trip_Gen_PsAs.dbf'  ;; OUTPUT external zonal Ps,As file, HBW,HBS,HBO,NHW,NHO purposes
ScaledAdj_IntPsAs ='%_iter_%_Ext_Trip_Gen_PsAs_Adj.dbf' ;; OUTPUT external Adj. zonal Ps,As file, HBW,HBS,HBO,NHW,NHO purposes

RUN PGM=MATRIX
ZONES=1

Fileo printo[1] ='%_iter_%_Prepare_Ext_Auto_Ends1.txt' ;; report file

Array ZProdA   = 5,3722     ; input zonal productions array /Unscaled
Array ZAttrA   = 5,3722     ; input zonal attractions array /Unscaled

Array S_ZProdA = 5,3722     ; output zonal productions /  intls  scaled to extl attr. totals
Array S_ZAttrA = 5,3722     ; output zonal attractions /  intls  scaled to extl prod. totals

Array TotProda=5, IntProda=5, ExtProda=5, TotscaleP=5, TotscaleA=5
Array TotAttra=5, IntAttra=5, ExtAttra=5, Pscale=5,Ascale=5, IntScaleP=5, IntScaleA=5

;; INPUT Zonal trip productions
FILEI DBI[1] = "%_iter_%_Trip_Gen_productions_Comp.dbf"
;; variables in file:
;;TAZ     HBW_MTR_PS      HBW_NMT_PS      HBW_ALL_PS      HBWMTRP_I1      HBWMTRP_I2      HBWMTRP_I3      HBWMTRP_I4
;;        HBS_MTR_PS      HBS_NMT_PS      HBS_ALL_PS      HBSMTRP_I1      HBSMTRP_I2      HBSMTRP_I3      HBSMTRP_I4
;;        HBO_MTR_PS      HBO_NMT_PS      HBO_ALL_PS      HBOMTRP_I1      HBOMTRP_I2      HBOMTRP_I3      HBOMTRP_I4
;;        NHW_MTR_PS      NHW_NMT_PS      NHW_ALL_PS      NHO_MTR_PS      NHO_NMT_PS      NHO_ALL_PS

;;INPUT Zonal final/scaled trip attractions
FILEI DBI[2] = "%_iter_%_Trip_Gen_Attractions_Comp.dbf"
;; variables in file:
;;TAZ     HBW_MTR_AS      HBW_NMT_AS      HBW_ALL_AS      HBWMTRA_I1      HBWMTRA_I2      HBWMTRA_I3      HBWMTRA_I4
;;        HBS_MTR_AS      HBS_NMT_AS      HBS_ALL_AS      HBSMTRA_I1      HBSMTRA_I2      HBSMTRA_I3      HBSMTRA_I4
;;        HBO_MTR_AS      HBO_NMT_AS      HBO_ALL_AS      HBOMTRA_I1      HBOMTRA_I2      HBOMTRA_I3      HBOMTRA_I4
;;        NHW_MTR_AS      NHW_NMT_AS      NHW_ALL_AS      NHO_MTR_AS      NHO_NMT_AS      NHO_ALL_AS



;; Read productions into zonal array and accumulate, totals, internals, and externals by purpose
LOOP K = 1,dbi.1.NUMRECORDS
         x = DBIReadRecord(1,k)
              ZProda[1][di.1.TAZ]    =   di.1.HBW_Mtr_Ps
              ZProda[2][di.1.TAZ]    =   di.1.HBS_Mtr_Ps
              ZProda[3][di.1.TAZ]    =   di.1.HBO_Mtr_Ps
              ZProda[4][di.1.TAZ]    =   di.1.NHW_Mtr_Ps
              ZProda[5][di.1.TAZ]    =   di.1.NHO_Mtr_Ps

;;       Accumulate total, internal and external P's by purpose
              TotProda[1]  =  TotProda[1]  +  ZProda[1][di.1.TAZ]
              TotProda[2]  =  TotProda[2]  +  ZProda[2][di.1.TAZ]
              TotProda[3]  =  TotProda[3]  +  ZProda[3][di.1.TAZ]
              TotProda[4]  =  TotProda[4]  +  ZProda[4][di.1.TAZ]
              TotProda[5]  =  TotProda[5]  +  ZProda[5][di.1.TAZ]
              TotProdaSum  =  TotProdaSum  +  ZProda[1][di.1.TAZ] + ZProda[2][di.1.TAZ] + ZProda[3][di.1.TAZ] + ZProda[4][di.1.TAZ] + ZProda[5][di.1.TAZ]

          IF (K <= @LastIZn@)
              IntProda[1]  =  IntProda[1]  +  ZProda[1][di.1.TAZ]
              IntProda[2]  =  IntProda[2]  +  ZProda[2][di.1.TAZ]
              IntProda[3]  =  IntProda[3]  +  ZProda[3][di.1.TAZ]
              IntProda[4]  =  IntProda[4]  +  ZProda[4][di.1.TAZ]
              IntProda[5]  =  IntProda[5]  +  ZProda[5][di.1.TAZ]
              IntProdaSum  =  IntProdaSum  +  ZProda[1][di.1.TAZ] + ZProda[2][di.1.TAZ] + ZProda[3][di.1.TAZ] + ZProda[4][di.1.TAZ] + ZProda[5][di.1.TAZ]
           ELSE
              ExtProda[1]  =  ExtProda[1]  +  ZProda[1][di.1.TAZ]
              ExtProda[2]  =  ExtProda[2]  +  ZProda[2][di.1.TAZ]
              ExtProda[3]  =  ExtProda[3]  +  ZProda[3][di.1.TAZ]
              ExtProda[4]  =  ExtProda[4]  +  ZProda[4][di.1.TAZ]
              ExtProda[5]  =  ExtProda[5]  +  ZProda[5][di.1.TAZ]
              ExtProdaSum  =  ExtProdaSum  +  ZProda[1][di.1.TAZ] + ZProda[2][di.1.TAZ] + ZProda[3][di.1.TAZ] + ZProda[4][di.1.TAZ] + ZProda[5][di.1.TAZ]
          ENDIF
 ENDLOOP

;; Read attractions into zonal array and accumulate, totals, internals, and externals by purpose
LOOP K = 1,dbi.2.NUMRECORDS
         x = DBIReadRecord(2,k)
              ZAttra[1][di.2.TAZ]    =   di.2.HBW_Mtr_As
              ZAttra[2][di.2.TAZ]    =   di.2.HBS_Mtr_As
              ZAttra[3][di.2.TAZ]    =   di.2.HBO_Mtr_As
              ZAttra[4][di.2.TAZ]    =   di.2.NHW_Mtr_As
              ZAttra[5][di.2.TAZ]    =   di.2.NHO_Mtr_As

;;       Accumulate total, internal and external P's by purpose
              TotAttra[1]  =  TotAttra[1]  +  ZAttra[1][di.2.TAZ]
              TotAttra[2]  =  TotAttra[2]  +  ZAttra[2][di.2.TAZ]
              TotAttra[3]  =  TotAttra[3]  +  ZAttra[3][di.2.TAZ]
              TotAttra[4]  =  TotAttra[4]  +  ZAttra[4][di.2.TAZ]
              TotAttra[5]  =  TotAttra[5]  +  ZAttra[5][di.2.TAZ]
              TotAttraSum  =  TotAttraSum  +  ZAttra[1][di.2.TAZ] + ZAttra[2][di.2.TAZ] + ZAttra[3][di.2.TAZ] + ZAttra[4][di.2.TAZ] + ZAttra[5][di.2.TAZ]

          IF (K <= @LastIZn@)
              IntAttra[1]  =  IntAttra[1]  +  ZAttra[1][di.2.TAZ]
              IntAttra[2]  =  IntAttra[2]  +  ZAttra[2][di.2.TAZ]
              IntAttra[3]  =  IntAttra[3]  +  ZAttra[3][di.2.TAZ]
              IntAttra[4]  =  IntAttra[4]  +  ZAttra[4][di.2.TAZ]
              IntAttra[5]  =  IntAttra[5]  +  ZAttra[5][di.2.TAZ]
              IntAttraSum  =  IntAttraSum  +  ZAttra[1][di.2.TAZ] + ZAttra[2][di.2.TAZ] + ZAttra[3][di.2.TAZ] + ZAttra[4][di.2.TAZ] + ZAttra[5][di.2.TAZ]
           ELSE
              ExtAttra[1]  =  ExtAttra[1]  +  ZAttra[1][di.2.TAZ]
              ExtAttra[2]  =  ExtAttra[2]  +  ZAttra[2][di.2.TAZ]
              ExtAttra[3]  =  ExtAttra[3]  +  ZAttra[3][di.2.TAZ]
              ExtAttra[4]  =  ExtAttra[4]  +  ZAttra[4][di.2.TAZ]
              ExtAttra[5]  =  ExtAttra[5]  +  ZAttra[5][di.2.TAZ]
              ExtAttraSum  =  ExtAttraSum  +  ZAttra[1][di.2.TAZ] + ZAttra[2][di.2.TAZ] + ZAttra[3][di.2.TAZ] + ZAttra[4][di.2.TAZ] + ZAttra[5][di.2.TAZ]
          ENDIF
 ENDLOOP

;; compute scaling  factors by purpose

    Loop pp= 1, @Purps@

         If (IntProda[pp]!= 0)  Pscale[pp] = ExtAttra[pp]/IntProda[pp]
         If (IntAttra[pp]!= 0)  Ascale[pp] = ExtProda[pp]/IntAttra[pp]

    ENDLOOP

;;print input P/A results by intl, external groups
   print printo=1            List =  ' Listing of INPUT P/A Totals by Purpose and computed scaling factors '
   print printo= 1 form=12.2 list = '            '

   print printo =1              list = ' Purpose>>>                     ','            HBW              HBS            HBO             NHW             NHO             ALL'
   print printo= 1              list = '            '
   print printo= 1 form=16.2csv list = ' Total Internal  Ps by purpose: ', IntProda[1],  IntProda[2], IntProda[3], IntProda[4], IntProda[5],  IntProdaSum
   print printo= 1 form=16.2csv list = ' Total External  Ps by purpose: ', ExtProda[1],  ExtProda[2], ExtProda[3], ExtProda[4], ExtProda[5],  ExtProdaSum
   print printo= 1 form=16.2csv list = ' Total Intl&Extl Ps by purpose: ', TotProda[1],  TotProda[2], TotProda[3], TotProda[4], TotProda[5],  TotProdaSum
   print printo= 1              list = '            '
   print printo= 1 form=16.2csv list = ' Total Internal  As by purpose: ', IntAttra[1],  IntAttra[2], IntAttra[3], IntAttra[4], IntAttra[5],  IntAttraSum
   print printo= 1 form=16.2csv list = ' Total External  As by purpose: ', ExtAttra[1],  ExtAttra[2], ExtAttra[3], ExtAttra[4], ExtAttra[5],  ExtAttraSum
   print printo= 1 form=16.2csv list = ' Total Intl&Extl As by purpose: ', TotAttra[1],  TotAttra[2], TotAttra[3], TotAttra[4], TotAttra[5],  TotAttraSum
   print printo= 1              list = '            '
   print printo= 1 form=16.6csv list = 'Prod_scale fts ExtAs/IntlPs:    ',   Pscale[1], Pscale[2], Pscale[3], Pscale[4], Pscale[5]
   print printo= 1 form=16.6csv list = 'Attr_scale fts ExtPs/ExtlPs:    ',   Ascale[1], Ascale[2], Ascale[3], Ascale[4], Ascale[5]
   print printo= 1              list = '            '
   print printo= 1              list = '            '
   print printo= 1              list = '            '


;;set up out file


 ;; DEFINE OUTPUT FILE & VARIABLES
 FILEO RECO[1]    = "@Scaled_IntPsAs@",
                     fields = TAZ(5),
                              SHBW_MtrPs(15.2), SHBS_MtrPs(15.2), SHBO_MtrPs(15.2), SNHW_MtrPs(15.2), SNHO_MtrPs(15.2),
                              SHBW_MtrAs(15.2), SHBS_MtrAs(15.2), SHBO_MtrAs(15.2), SNHW_MtrAs(15.2), SNHO_MtrAs(15.2),
                              NHWIIAs(15.2), NHOIIAs(15.2)

 ;;
 ;; Now loop through each internal TAZ and
 ;;   1)  scale INT Attractions to EXT productions
 ;;   2)  scale INT Productions to EXT attractions
 ;;   3)  write out scaled/INT Ps As and unscaled EXT P's, As

 Loop zz= 1, @ZONESIZE@

    Loop pp= 1, @Purps@

          IF (zz <= @LastIZn@)      ;;if TAZ is internal, then scale and accumulate
            S_ZProda[pp][zz] =  ZProda[pp][zz] *   Pscale[pp]
            S_ZAttra[pp][zz] =  ZAttra[pp][zz] *   Ascale[pp]

;;          accumulate scaled internal Ps, As by purpose and for total
            IntScaleP[pp] = IntScaleP[pp] +   S_ZProda[pp][zz]
            IntScaleA[pp] = IntScaleA[pp] +   S_ZAttra[pp][zz]

            IntScalePSum  = IntScalePSum  +   S_ZProda[pp][zz]
            IntScaleASum  = IntScaleASum  +   S_ZAttra[pp][zz]

           ELSE                    ;; Else TAZ is external, final scaled P/S equals input P,A
             S_ZProda[pp][zz] =  ZProdA[pp][zz]
             S_ZAttra[pp][zz] =  ZAttrA[pp][zz]

          ENDIF                    ;;
            ;; Accum. total of scaled intls and untouched extls for reporting, by purpose and for total
            TotScaleP[pp] = TotScaleP[pp] +   S_ZProda[pp][zz]
            TotScaleA[pp] = TotScaleA[pp] +   S_ZAttra[pp][zz]

            TotScalePSum  = TotScalePSum  +   S_ZProda[pp][zz]
            TotScaleASum  = TotScaleASum  +   S_ZAttra[pp][zz]
    ENDLOOP




;;       Write out the unscaled and scaled Ps,As by purpose
;;       The scaled internal productions will equal the sum of external attractions
;;       The scaled internal attractions will equal the sum of external productions
;;       The external Ps, As will remain unchanged
          ro.TAZ        =  zz
          ro.SHBW_MtrPs = S_ZProda[1][zz]
          ro.SHBS_MtrPs = S_ZProda[2][zz]
          ro.SHBO_MtrPs = S_ZProda[3][zz]
          ro.SNHW_MtrPs = S_ZAttra[4][zz]
          ro.SNHO_MtrPs = S_ZAttra[5][zz]

          ro.SHBW_MtrAs = S_ZAttra[1][zz]
          ro.SHBS_MtrAs = S_ZAttra[2][zz]
          ro.SHBO_MtrAs = S_ZAttra[3][zz]
          ro.SNHW_MtrAs = S_ZAttra[4][zz]
          ro.SNHO_MtrAs = S_ZAttra[5][zz]

          IF (ZZ <= @LastIZn@)
                ro.NHWIIAs = ZAttra[4][zz]
                ro.NHOIIAs = ZAttra[5][zz]
            ELSE
                ro.NHWIIAs = 0.0
                ro.NHOIIAs = 0.0
          ENDIF


          WRITE RECO=1

ENDLOOP



print printo=1            List =  ' Listing of OUTPUT P/A Totals by purpose to be used in the External Trip Distribution Process '
;;print input P/A results by intl, external groups

   print printo= 1              list = '            '
   print printo =1              list = ' Purpose>>>                     ','            HBW              HBS            HBO             NHW             NHO             ALL'
   print printo= 1              list = '            '
   print printo= 1 form=16.2csv list = ' Internal Ps, scaled to Extl As:', IntScaleP[1], IntScaleP[2],IntScaleP[3], IntScaleP[4], IntScaleP[5],  IntScalePSum
   print printo= 1 form=16.2csv list = ' External Ps by purpose:        ',  ExtProda[1],  ExtProda[2], ExtProda[3], ExtProda[4],  ExtProda[5],   ExtProdaSum
   print printo= 1 form=16.2csv list = ' Total    Ps by purpose:        ', TotScaleP[1], TotScaleP[2],TotScaleP[3], TotScaleP[4], TotScaleP[5],  TotScalePSum
   print printo= 1              list = '            '
   print printo= 1 form=16.2csv list = ' Internal As, scaled to Extl Ps:', IntScaleA[1], IntScaleA[2],IntScaleA[3], IntScaleA[4], IntScaleA[5],  IntScaleASum
   print printo= 1 form=16.2csv list = ' Total External  As by purpose: ',  ExtAttra[1],  ExtAttra[2], ExtAttra[3], ExtAttra[4],  ExtAttra[5],   ExtAttraSum
   print printo= 1 form=16.2csv list = ' Total Intl&Extl As by purpose: ', TotScaleA[1], TotScaleA[2],TotScaleA[3], TotScaleA[4], TotScaleA[5],  TotScaleASum
   print printo= 1              list = '            '

ENDRUN



;===========================================================================================================
;  Prepare_Ext_Auto_Ends2.s                                                                                =
;  This process reads Auto-related external Ps, As for the External Trip Distribution Process              =
;  developed by the Prepare_Ext_Auto_Ends.s process and alters the jurisdictional distribution             =
;  of the INTERNAL ends such that they approximate the distribution reflected by AirSage trip tables       =
;  The redistribution will essentially orient external trip-ends more to Anne Arundel, Howard and          =
;  Carroll counties and less towards other counties which is what AirSage and CTPP data appears to suggest =
;===========================================================================================================


RUN PGM=MATRIX
ZONES=1

Fileo printo[1] ='%_iter_%_Prepare_Ext_Auto_Ends2.txt' ;; report file

Array S_ZP_IXA      = 5,3722      ; input zonal productions array by purpose (5)
Array S_ZP_XIA      = 5,3722      ; input zonal attractions array by purpose (5)

Array S_TotIX = 5, S_TotXI =5     ; input Extl Ps and As by purpose

Array S_ZPJ_IXA     = 5,21,3722   ; input zonal productions array by purpose (5) and juris code (21)
Array S_ZPJ_XIA     = 5,21,3722   ; input zonal attractions array by purpose (5) and juris code (21)

Array S_PJ_IXA      = 5,21        ; input IX Trip Productions array by Purpose(5)and Juris (21)
Array S_PJ_XIA      = 5,21        ; input XI Trip Attractions array by Purpose(5)and Juris (21)

Array S_PJ_IXShareA = 5,21        ; input  IX jurisdictional Trip Prod. Share by Purpose(5) array
Array S_PJ_XIShareA = 5,21        ; input  XI jurisdictional Trip Attr. Share by Purpose(5) array

Array SA_PJ_IXA     = 5,21        ; Adjusted IX Trip Productions array by Purpose(5)and Juris (21)
Array SA_PJ_XIA     = 5,21        ; Adjusted XI Trip Attractions array by Purpose(5)and Juris (21)

Array SA_PJ_IXShareA= 5,21        ; output IX jurisdictional Trip Prod. Share by Purpose(5) array
Array SA_PJ_XIShareA= 5,21        ; output XI jurisdictional Trip Attr. Share by Purpose(5) array

Array SA_ZPJ_IXA    = 5,21,3722   ; output zonal productions array by purpose (5) and juris code (21)
Array SA_ZPJ_XIA    = 5,21,3722   ; output zonal attractions array by purpose (5) and juris code (21)

Array SA_ZP_IXA     = 5,3722      ; output zonal productions array by purpose (5)
Array SA_ZP_XIA     = 5,3722      ; output zonal attractions array by purpose (5)

Array SA_TotIX = 5, SA_TotXI =5   ; output Extl Ps and As by purpose


;=============================================================================
; Internal Jurisdictional Distributions of I-X, X-I trips by purpose         =
; indexed by Jurisdiction Code 1-21  (TAZ Ranges are also included           =
;=============================================================================
;
LOOKUP Name=JurDstLkp,
       LOOKUP[1]   = 1,Result = 1,  ; Juris Code 1-21
       LOOKUP[2]   = 1,Result = 2,  ; Obs HBW_IX  jurisdictional share of productions
       LOOKUP[3]   = 1,Result = 3,  ; Obs HBW_XI  jurisdictional share of attractions
       LOOKUP[4]   = 1,Result = 4,  ; Obs HBNW_IX jurisdictional share of productions
       LOOKUP[5]   = 1,Result = 5,  ; Obs HBNW_XI jurisdictional share of attractions
       LOOKUP[6]   = 1,Result = 6,  ; Obs NHW_IX  jurisdictional share of productions
       LOOKUP[7]   = 1,Result = 7,  ; Obs NHW_XI  jurisdictional share of attractions
       LOOKUP[8]   = 1,Result = 8,  ; Obs NHO_IX  jurisdictional share of productions
       LOOKUP[9]   = 1,Result = 9,  ; Obs NHO_XI  jurisdictional share of attractions
       LOOKUP[10]  = 1,Result =10,  ; TAZ Range(1)/ MIN
       LOOKUP[11]  = 1,Result =11,  ; TAZ Range(1)/ MAX
       LOOKUP[12]  = 1,Result =12,  ; TAZ Range(2)/ MIN   (Some jurs have two discrete TAZ ranges)
       LOOKUP[13]  = 1,Result =13,  ; TAZ Range(2)/ MAX
       Interpolate = N, FAIL=0,0,0, ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; August 2018 Adjustments that are superseded
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; JUR#  HBW_IX, HBW_XI,HBNW_IX,HBNW_XI, NHW_IX, NHW_XI, NHO_IX, NHO_XI, TZLO1, TZHI1, TZLO2, TZHI2
;R="1,  0.0223, 0.0504, 0.0678, 0.0376, 0.0100, 0.0596, 0.0730, 0.0750,     1,   393,  9999,  9999", ;<< DC
; " 2,  0.0784, 0.0503, 0.0661, 0.0646, 0.0607, 0.0724, 0.0512, 0.0516,   394,   769,  9999,  9999", ;<< MTG
; " 3,  0.0845, 0.0545, 0.0759, 0.0801, 0.0801, 0.0655, 0.0651, 0.0657,   770,  1404,  9999,  9999", ;<< PG
; " 4,  0.0029, 0.0079, 0.0096, 0.0047, 0.0042, 0.0149, 0.0126, 0.0155,  1405,  1545,  9999,  9999", ;<< ARL
; " 5,  0.0026, 0.0023, 0.0042, 0.0029, 0.0029, 0.0062, 0.0077, 0.0093,  1546,  1610,  9999,  9999", ;<< ALX
; " 6,  0.0193, 0.0390, 0.0355, 0.0231, 0.0228, 0.0715, 0.0478, 0.0528,  1611,  2159,  9999,  9999", ;<< FFX
; " 7,  0.0111, 0.0341, 0.0245, 0.0111, 0.0090, 0.0456, 0.0218, 0.0221,  2160,  2441,  9999,  9999", ;<< LDN
; " 8,  0.0081, 0.0277, 0.0211, 0.0111, 0.0107, 0.0366, 0.0324, 0.0323,  2442,  2819,  9999,  9999", ;<< PW
; " 9,  0.0300, 0.0402, 0.0376, 0.0340, 0.0446, 0.0962, 0.0371, 0.0366,  2820,  2949,  9999,  9999", ;<< FRD
; "10,  0.1459, 0.0798, 0.0842, 0.1427, 0.1943, 0.0554, 0.0830, 0.0851,  3230,  3287,  9999,  9999", ;<< CAR
; "11,  0.2407, 0.1900, 0.1836, 0.1964, 0.2337, 0.1829, 0.1401, 0.1373,  2950,  3017,  9999,  9999", ;<< HOW
; "12,  0.2760, 0.2738, 0.2625, 0.2838, 0.2927, 0.2399, 0.2677, 0.2628,  3018,  3116,  9999,  9999", ;<< AAR
; "13,  0.0031, 0.0009, 0.0025, 0.0045, 0.0036, 0.0006, 0.0030, 0.0032,  3288,  3334,  9999,  9999", ;<< CAL
; "14,  0.0022, 0.0024, 0.0035, 0.0039, 0.0025, 0.0015, 0.0040, 0.0044,  3335,  3409,  9999,  9999", ;<< STM
; "15,  0.0034, 0.0064, 0.0061, 0.0062, 0.0062, 0.0022, 0.0071, 0.0071,  3117,  3229,  9999,  9999", ;<< CHS
; "16,  0.0141, 0.0274, 0.0236, 0.0185, 0.0104, 0.0245, 0.0300, 0.0279,  3604,  3653,  9999,  9999", ;<< FAU
; "17,  0.0066, 0.0247, 0.0176, 0.0110, 0.0081, 0.0155, 0.0234, 0.0221,  3449,  3541,  9999,  9999", ;<< STA
; "18,  0.0171, 0.0125, 0.0104, 0.0091, 0.0001, 0.0001, 0.0137, 0.0138,  3654,  3675,  9999,  9999", ;<< CL/JF
; "19,  0.0271, 0.0635, 0.0523, 0.0468, 0.0001, 0.0001, 0.0691, 0.0659,  3435,  3448,  3542,  3603", ;<< SP/FB
; "20,  0.0046, 0.0122, 0.0114, 0.0082, 0.0035, 0.0089, 0.0102, 0.0093,  3410,  3434,  9999,  9999"  ;<< KGEO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; December 2018 Adjustments
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Updated Lookup Table for target jurisdictional XI/IX distributions: based on AirSage Trips - (Rounded & Normalized)
;;
;;JUR#  HBW_IX,   HBW_XI,   HBNW_IX,  HBNW_XI,  NHW_IX,   NHW_XI,   NHO_IX,   NHO_XI,  TZLO1,  TZHI1,  TZLO2,  TZHI2
R=" 1,  0.022343, 0.050441, 0.033481, 0.070119, 0.067782, 0.037619, 0.056433, 0.031022,    1,    393,   9999,   9999",  ;<<     DC
  " 2,  0.078371, 0.050332, 0.084063, 0.070308, 0.066131, 0.064571, 0.071216, 0.065744,  394,    769,   9999,   9999",  ;<<     MTG
  " 3,  0.084512, 0.054472, 0.089733, 0.071074, 0.075902, 0.080060, 0.085277, 0.084146,  770,   1404,   9999,   9999",  ;<<     PG
  " 4,  0.002904, 0.007859, 0.007572, 0.010596, 0.009554, 0.004708, 0.009239, 0.006322, 1405,   1545,   9999,   9999",  ;<<     ARL
  " 5,  0.002633, 0.002290, 0.005200, 0.005140, 0.004219, 0.002889, 0.004779, 0.003382, 1546,   1610,   9999,   9999",  ;<<     ALX
  " 6,  0.019323, 0.038963, 0.039729, 0.046425, 0.035500, 0.023085, 0.035173, 0.029012, 1611,   2159,   9999,   9999",  ;<<     FFX
  " 7,  0.011076, 0.034067, 0.018740, 0.034362, 0.024495, 0.011076, 0.022769, 0.015290, 2160,   2441,   9999,   9999",  ;<<     LDN
  " 8,  0.008121, 0.027673, 0.022284, 0.032246, 0.021110, 0.011122, 0.023937, 0.019432, 2442,   2819,   9999,   9999",  ;<<     PW
  " 9,  0.029983, 0.040182, 0.040575, 0.044733, 0.037584, 0.033935, 0.039973, 0.043004, 2820,   2949,   9999,   9999",  ;<<     FRD
  "10,  0.145927, 0.079818, 0.116304, 0.079248, 0.084156, 0.142698, 0.088335, 0.119407, 3230,   3287,   9999,   9999",  ;<<     CAR
  "11,  0.240677, 0.190024, 0.173720, 0.148935, 0.183619, 0.196420, 0.159339, 0.167581, 2950,   3017,   9999,   9999",  ;<<     HOW
  "12,  0.276043, 0.273809, 0.233320, 0.201356, 0.262489, 0.283781, 0.236927, 0.262509, 3018,   3116,   9999,   9999",  ;<<     AAR
  "13,  0.003085, 0.000872, 0.004619, 0.003232, 0.002518, 0.004435, 0.004184, 0.005048, 3288,   3334,   9999,   9999",  ;<<     CAL
  "14,  0.002160, 0.002383, 0.005630, 0.006311, 0.003518, 0.003889, 0.007965, 0.009532, 3335,   3409,   9999,   9999",  ;<<     STM
  "15,  0.003443, 0.006434, 0.007636, 0.010911, 0.006120, 0.006186, 0.010068, 0.008478, 3117,   3229,   9999,   9999",  ;<<     CHS
  "16,  0.014117, 0.027418, 0.027468, 0.037324, 0.023594, 0.018468, 0.029778, 0.026856, 3604,   3653,   9999,   9999",  ;<<     FAU
  "17,  0.006567, 0.024707, 0.014953, 0.022128, 0.017575, 0.010917, 0.017544, 0.015217, 3449,   3541,   9999,   9999",  ;<<     STA
  "18,  0.017090, 0.012496, 0.018321, 0.010524, 0.010438, 0.009143, 0.010705, 0.011027, 3654,   3675,   9999,   9999",  ;<<     CL/JF
  "19,  0.027071, 0.063537, 0.046541, 0.081120, 0.052341, 0.046808, 0.071407, 0.063734, 3435,   3448,   3542,   3603",  ;<<     SP/FB
  "20,  0.004554, 0.012223, 0.010111, 0.013908, 0.011355, 0.008190, 0.014952, 0.013257, 3410,   3434,   9999,   9999"   ;<<     KGEO

;; INPUT Zonal scaled XI/IX trip Ps and As
FILEI DBI[1] = "@Scaled_IntPsAs@"
;; variables in file:
;   TAZ SHBW_MtrPs  SHBS_MtrPs  SHBO_MtrPs  SNHW_MtrPs SNHO_MtrPs
;       SHBW_MtrAs  SHBS_MtrAs  SHBO_MtrAs  SNHW_MtrAs SNHO_MtrAs

;; Read in Input, Scaled, Unadjusted External Ps & As
LOOP K = 1,dbi.1.NUMRECORDS
         x = DBIReadRecord(1,k)
              S_ZP_IXA[1][di.1.TAZ]    =   di.1.SHBW_MtrPs
              S_ZP_IXA[2][di.1.TAZ]    =   di.1.SHBS_MtrPs
              S_ZP_IXA[3][di.1.TAZ]    =   di.1.SHBO_MtrPs
              S_ZP_IXA[4][di.1.TAZ]    =   di.1.SNHW_MtrPs
              S_ZP_IXA[5][di.1.TAZ]    =   di.1.SNHO_MtrPs

              S_ZP_XIA[1][di.1.TAZ]    =   di.1.SHBW_MtrAs
              S_ZP_XIA[2][di.1.TAZ]    =   di.1.SHBS_MtrAs
              S_ZP_XIA[3][di.1.TAZ]    =   di.1.SHBO_MtrAs
              S_ZP_XIA[4][di.1.TAZ]    =   di.1.SNHW_MtrAs
              S_ZP_XIA[5][di.1.TAZ]    =   di.1.SNHO_MtrAs

 ;;  Identify Jurisdiction Code (JC) of the current TAZ

 IF  (di.1.TAZ >=      1 && di.1.TAZ <=  393)  jc=1              ;<< DC
 IF  (di.1.TAZ >=    394 && di.1.TAZ <=  769)  jc=2              ;<< MTG
 IF  (di.1.TAZ >=    770 && di.1.TAZ <= 1404)  jc=3              ;<< PG
 IF  (di.1.TAZ >=   1405 && di.1.TAZ <= 1545)  jc=4              ;<< ARL
 IF  (di.1.TAZ >=   1546 && di.1.TAZ <= 1610)  jc=5              ;<< ALX
 IF  (di.1.TAZ >=   1611 && di.1.TAZ <= 2159)  jc=6              ;<< FFX
 IF  (di.1.TAZ >=   2160 && di.1.TAZ <= 2441)  jc=7              ;<< LDN
 IF  (di.1.TAZ >=   2442 && di.1.TAZ <= 2819)  jc=8              ;<< PW
 IF  (di.1.TAZ >=   2820 && di.1.TAZ <= 2949)  jc=9              ;<< FRD
 IF  (di.1.TAZ >=   3230 && di.1.TAZ <= 3287)  jc=10             ;<< CAR
 IF  (di.1.TAZ >=   2950 && di.1.TAZ <= 3017)  jc=11             ;<< HOW
 IF  (di.1.TAZ >=   3018 && di.1.TAZ <= 3116)  jc=12             ;<< AAR
 IF  (di.1.TAZ >=   3288 && di.1.TAZ <= 3334)  jc=13             ;<< CAL
 IF  (di.1.TAZ >=   3335 && di.1.TAZ <= 3409)  jc=14             ;<< STM
 IF  (di.1.TAZ >=   3117 && di.1.TAZ <= 3229)  jc=15             ;<< CHS
 IF  (di.1.TAZ >=   3604 && di.1.TAZ <= 3653)  jc=16             ;<< FAU
 IF  (di.1.TAZ >=   3449 && di.1.TAZ <= 3541)  jc=17             ;<< STA
 IF  (di.1.TAZ >=   3654 && di.1.TAZ <= 3675)  jc=18             ;<< CL/JF
 IF  (di.1.TAZ >=   3435 && di.1.TAZ <= 3448)  jc=19             ;<< SP/FB
 IF  (di.1.TAZ >=   3542 && di.1.TAZ <= 3603)  jc=19             ;<< SP/FB
 IF  (di.1.TAZ >=   3410 && di.1.TAZ <= 3434)  jc=20             ;<< KGEO
 IF  (di.1.TAZ >=   3676 && di.1.TAZ <= 3722)  jc=21             ;<< EXTL

 IF (JC =21) GOTO :SKIPREC

              S_ZPJ_IXA[1][JC][di.1.TAZ] = di.1.SHBW_MtrPs
              S_ZPJ_IXA[2][JC][di.1.TAZ] = di.1.SHBS_MtrPs
              S_ZPJ_IXA[3][JC][di.1.TAZ] = di.1.SHBO_MtrPs
              S_ZPJ_IXA[4][JC][di.1.TAZ] = di.1.SNHW_MtrPs
              S_ZPJ_IXA[5][JC][di.1.TAZ] = di.1.SNHO_MtrPs

              S_ZPJ_XIA[1][JC][di.1.TAZ] = di.1.SHBW_MtrAs
              S_ZPJ_XIA[2][JC][di.1.TAZ] = di.1.SHBS_MtrAs
              S_ZPJ_XIA[3][JC][di.1.TAZ] = di.1.SHBO_MtrAs
              S_ZPJ_XIA[4][JC][di.1.TAZ] = di.1.SNHW_MtrAs
              S_ZPJ_XIA[5][JC][di.1.TAZ] = di.1.SNHO_MtrAs


              S_PJ_IXA[1][JC] = S_PJ_IXA[1][JC] + di.1.SHBW_MtrPs
              S_PJ_IXA[2][JC] = S_PJ_IXA[2][JC] + di.1.SHBS_MtrPs
              S_PJ_IXA[3][JC] = S_PJ_IXA[3][JC] + di.1.SHBO_MtrPs
              S_PJ_IXA[4][JC] = S_PJ_IXA[4][JC] + di.1.SNHW_MtrPs
              S_PJ_IXA[5][JC] = S_PJ_IXA[5][JC] + di.1.SNHO_MtrPs

              S_PJ_XIA[1][JC] = S_PJ_XIA[1][JC] + di.1.SHBW_MtrAs
              S_PJ_XIA[2][JC] = S_PJ_XIA[2][JC] + di.1.SHBS_MtrAs
              S_PJ_XIA[3][JC] = S_PJ_XIA[3][JC] + di.1.SHBO_MtrAs
              S_PJ_XIA[4][JC] = S_PJ_XIA[4][JC] + di.1.SNHW_MtrAs
              S_PJ_XIA[5][JC] = S_PJ_XIA[5][JC] + di.1.SNHO_MtrAs

;;       Accumulate total, internal and external P's by purpose
              S_TotIX[1]   =  S_TotIX[1]   +  di.1.SHBW_MtrPs
              S_TotIX[2]   =  S_TotIX[2]   +  di.1.SHBS_MtrPs
              S_TotIX[3]   =  S_TotIX[3]   +  di.1.SHBO_MtrPs
              S_TotIX[4]   =  S_TotIX[4]   +  di.1.SNHW_MtrPs
              S_TotIX[5]   =  S_TotIX[5]   +  di.1.SNHO_MtrPs
              S_TotIXSum   =  S_TotIXSum   +  di.1.SHBW_MtrPs + di.1.SHBS_MtrPs + di.1.SHBO_MtrPs + di.1.SNHW_MtrPs + di.1.SNHO_MtrPs

              S_TotXI[1]   =  S_TotXI[1]   +  di.1.SHBW_MtrAs
              S_TotXI[2]   =  S_TotXI[2]   +  di.1.SHBS_MtrAs
              S_TotXI[3]   =  S_TotXI[3]   +  di.1.SHBO_MtrAs
              S_TotXI[4]   =  S_TotXI[4]   +  di.1.SNHW_MtrAs
              S_TotXI[5]   =  S_TotXI[5]   +  di.1.SNHO_MtrAs
              S_TotXISum   =  S_TotXISum   +  di.1.SHBW_MtrAs + di.1.SHBS_MtrAs + di.1.SHBO_MtrAs + di.1.SNHW_MtrAs + di.1.SNHO_MtrAs
 :SKIPREC
 ENDLOOP


 LOOP KK= 1,20

 IF (kk=1)
    ;Tab1
    print printo =1    list = 'Initial/Input Trip Summary                                                                                  '
    print printo= 1    list = '     '
    print printo =1    list = '     ','       IX Trips  -------------------------------->  XI Trips--------------------------------------> '
    print printo =1    list = ' Jur ','       HBW       HBS       HBO       NHW       NHO       HBW       HBS       HBO       NHW       NHO'
    print printo= 1    list = '     '
 ENDIF

 if (kk= 1)jname='DC   '
 if (kk= 2)jname='MTG  '
 if (kk= 3)jname='PG   '
 if (kk= 4)jname='ARL  '
 if (kk= 5)jname='ALX  '
 if (kk= 6)jname='FFX  '
 if (kk= 7)jname='LDN  '
 if (kk= 8)jname='PW   '
 if (kk= 9)jname='FRD  '
 if (kk=10)jname='CAR  '
 if (kk=11)jname='HOW  '
 if (kk=12)jname='AAR  '
 if (kk=13)jname='CAL  '
 if (kk=14)jname='STM  '
 if (kk=15)jname='CHS  '
 if (kk=16)jname='FAU  '
 if (kk=17)jname='STA  '
 if (kk=18)jname='CL/JF'
 if (kk=19)jname='SP/FB'
 if (kk=20)jname='KGEO '
 if (kk=21)jname='EXTL '

  print printo= 1 form=10.0csv list = Jname(5),S_PJ_IXA[1][kk],S_PJ_IXA[2][kk],S_PJ_IXA[3][kk],S_PJ_IXA[4][kk],S_PJ_IXA[5][kk],
                                               S_PJ_XIA[1][kk],S_PJ_XIA[2][kk],S_PJ_XIA[3][kk],S_PJ_XIA[4][kk],S_PJ_XIA[5][kk]

ENDLOOP

  print printo= 1    list = '     '
  print printo= 1 form=10.0csv list = 'SUM  ', S_TotIX[1],S_TotIX[2],S_TotIX[3],S_TotIX[4],S_TotIX[5],
                                               S_TotXI[1],S_TotXI[2],S_TotXI[3],S_TotXI[4],S_TotXI[5]
  print printo= 1    list = '     '

;;  Now let';s work at the jurisdictional level here-
;;  Calculate the existing Jurisdictional distributions of IE & IE trips by purpose
;;  Then calculate adjustment to arrive at the more correct observed share

LOOP KK= 1,20
; Initial Internal trip-end shares
 IF (S_TotIX[1] > 0) S_PJ_IXShareA[1][kk] = S_PJ_IXA[1][kk]/S_TotIX[1] ; IXHBW trip shares
 IF (S_TotIX[2] > 0) S_PJ_IXShareA[2][kk] = S_PJ_IXA[2][kk]/S_TotIX[2] ; IXHBS trip shares
 IF (S_TotIX[3] > 0) S_PJ_IXShareA[3][kk] = S_PJ_IXA[3][kk]/S_TotIX[3] ; IXHBO trip shares
 IF (S_TotIX[4] > 0) S_PJ_IXShareA[4][kk] = S_PJ_IXA[4][kk]/S_TotIX[4] ; IXNHW trip shares
 IF (S_TotIX[5] > 0) S_PJ_IXShareA[5][kk] = S_PJ_IXA[5][kk]/S_TotIX[5] ; IXNHO trip shares

 IF (S_TotXI[1] > 0) S_PJ_XIShareA[1][kk] = S_PJ_XIA[1][kk]/S_TotXI[1] ; XIHBW trip shares
 IF (S_TotXI[2] > 0) S_PJ_XIShareA[2][kk] = S_PJ_XIA[2][kk]/S_TotXI[2] ; XIHBS trip shares
 IF (S_TotXI[3] > 0) S_PJ_XIShareA[3][kk] = S_PJ_XIA[3][kk]/S_TotXI[3] ; XIHBO trip shares
 IF (S_TotXI[4] > 0) S_PJ_XIShareA[4][kk] = S_PJ_XIA[4][kk]/S_TotXI[4] ; XINHW trip shares
 IF (S_TotXI[5] > 0) S_PJ_XIShareA[5][kk] = S_PJ_XIA[5][kk]/S_TotXI[5] ; XINHO trip shares

; Put Target shares in an array
                    SA_PJ_IXShareA[1][kk] =JurDstLkp(2,kk)
                    SA_PJ_IXShareA[2][kk] =JurDstLkp(4,kk)
                    SA_PJ_IXShareA[3][kk] =JurDstLkp(4,kk)
                    SA_PJ_IXShareA[4][kk] =JurDstLkp(6,kk)
                    SA_PJ_IXShareA[5][kk] =JurDstLkp(8,kk)

                    SA_PJ_XIShareA[1][kk] =JurDstLkp(3,kk)
                    SA_PJ_XIShareA[2][kk] =JurDstLkp(5,kk)
                    SA_PJ_XIShareA[3][kk] =JurDstLkp(5,kk)
                    SA_PJ_XIShareA[4][kk] =JurDstLkp(7,kk)
                    SA_PJ_XIShareA[5][kk] =JurDstLkp(9,kk)

; Calculate Adjusted IX,XI Trips
                    SA_PJ_IXA[1][kk]      =JurDstLkp(2,kk) * S_TotIX[1]
                    SA_PJ_IXA[2][kk]      =JurDstLkp(4,kk) * S_TotIX[2]
                    SA_PJ_IXA[3][kk]      =JurDstLkp(4,kk) * S_TotIX[3]
                    SA_PJ_IXA[4][kk]      =JurDstLkp(6,kk) * S_TotIX[4]
                    SA_PJ_IXA[5][kk]      =JurDstLkp(8,kk) * S_TotIX[5]

                    SA_PJ_XIA[1][kk]      =JurDstLkp(3,kk) * S_TotXI[1]
                    SA_PJ_XIA[2][kk]      =JurDstLkp(5,kk) * S_TotXI[2]
                    SA_PJ_XIA[3][kk]      =JurDstLkp(5,kk) * S_TotXI[3]
                    SA_PJ_XIA[4][kk]      =JurDstLkp(7,kk) * S_TotXI[4]
                    SA_PJ_XIA[5][kk]      =JurDstLkp(9,kk) * S_TotXI[5]

ENDLOOP



 LOOP KK= 1,20
 IF (KK=1)
    ;Tab2
    print printo =1    list = 'Initial/Input Trip Distribution                                                                             '
    print printo= 1    list = '     '
    print printo =1    list = '     ','       IX Trips  -------------------------------->  XI Trips--------------------------------------> '
    print printo =1    list = ' Jur ','       HBW       HBS       HBO       NHW       NHO       HBW       HBS       HBO       NHW       NHO'
    print printo= 1    list = '     '
 ENDIF

 if (kk= 1)jname='DC   '
 if (kk= 2)jname='MTG  '
 if (kk= 3)jname='PG   '
 if (kk= 4)jname='ARL  '
 if (kk= 5)jname='ALX  '
 if (kk= 6)jname='FFX  '
 if (kk= 7)jname='LDN  '
 if (kk= 8)jname='PW   '
 if (kk= 9)jname='FRD  '
 if (kk=10)jname='CAR  '
 if (kk=11)jname='HOW  '
 if (kk=12)jname='AAR  '
 if (kk=13)jname='CAL  '
 if (kk=14)jname='STM  '
 if (kk=15)jname='CHS  '
 if (kk=16)jname='FAU  '
 if (kk=17)jname='STA  '
 if (kk=18)jname='CL/JF'
 if (kk=19)jname='SP/FB'
 if (kk=20)jname='KGEO '

  print printo= 1 form=10.4csv list = Jname(5),S_PJ_IXShareA[1][kk],S_PJ_IXShareA[2][kk],S_PJ_IXShareA[3][kk],S_PJ_IXShareA[4][kk],S_PJ_IXShareA[5][kk],
                                               S_PJ_XIShareA[1][kk],S_PJ_XIShareA[2][kk],S_PJ_XIShareA[3][kk],S_PJ_XIShareA[4][kk],S_PJ_XIShareA[5][kk]
                                               sumIX1 = sumIX1 + S_PJ_IXShareA[1][kk]    sumXI1 = sumXI1 + S_PJ_XIShareA[1][kk]
                                               sumIX2 = sumIX2 + S_PJ_IXShareA[2][kk]    sumXI2 = sumXI2 + S_PJ_XIShareA[2][kk]
                                               sumIX3 = sumIX3 + S_PJ_IXShareA[3][kk]    sumXI3 = sumXI3 + S_PJ_XIShareA[3][kk]
                                               sumIX4 = sumIX4 + S_PJ_IXShareA[4][kk]    sumXI4 = sumXI4 + S_PJ_XIShareA[4][kk]
                                               sumIX5 = sumIX5 + S_PJ_IXShareA[5][kk]    sumXI5 = sumXI5 + S_PJ_XIShareA[5][kk]
ENDLOOP

  print printo= 1    list = '     '
  print printo= 1 form=10.4csv list = 'SUM  ', sumIX1,sumIX2,sumIX3,sumIX4,sumIX5, sumXI1,sumXI2,sumXI3,sumXI4,sumXI5
  print printo= 1    list = '     '
  sumIX1=0 sumIX2=0 sumIX3=0 sumIX4=0 sumIX5=0   sumXI1=0 sumXI2=0 sumXI3=0 sumXI4=0 sumXI5=0

 LOOP KK= 1,20
 IF (KK=1)
    ;Tab3
    print printo =1    list = 'Adjusted / Target Trip Distribution                                                                             '
    print printo= 1    list = '     '
    print printo =1    list = '     ','       IX Trips  -------------------------------->  XI Trips--------------------------------------> '
    print printo =1    list = ' Jur ','       HBW       HBS       HBO       NHW       NHO       HBW       HBS       HBO       NHW       NHO'
    print printo= 1    list = '     '
 ENDIF

 if (kk= 1)jname='DC   '
 if (kk= 2)jname='MTG  '
 if (kk= 3)jname='PG   '
 if (kk= 4)jname='ARL  '
 if (kk= 5)jname='ALX  '
 if (kk= 6)jname='FFX  '
 if (kk= 7)jname='LDN  '
 if (kk= 8)jname='PW   '
 if (kk= 9)jname='FRD  '
 if (kk=10)jname='CAR  '
 if (kk=11)jname='HOW  '
 if (kk=12)jname='AAR  '
 if (kk=13)jname='CAL  '
 if (kk=14)jname='STM  '
 if (kk=15)jname='CHS  '
 if (kk=16)jname='FAU  '
 if (kk=17)jname='STA  '
 if (kk=18)jname='CL/JF'
 if (kk=19)jname='SP/FB'
 if (kk=20)jname='KGEO '

  print printo= 1 form=10.4csv list = Jname(5),SA_PJ_IXShareA[1][kk],SA_PJ_IXShareA[2][kk],SA_PJ_IXShareA[3][kk],SA_PJ_IXShareA[4][kk],SA_PJ_IXShareA[5][kk],
                                               SA_PJ_XIShareA[1][kk],SA_PJ_XIShareA[2][kk],SA_PJ_XIShareA[3][kk],SA_PJ_XIShareA[4][kk],SA_PJ_XIShareA[5][kk]
                                               sumIX1 = sumIX1 + SA_PJ_IXShareA[1][kk]    sumXI1 = sumXI1 + SA_PJ_XIShareA[1][kk]
                                               sumIX2 = sumIX2 + SA_PJ_IXShareA[2][kk]    sumXI2 = sumXI2 + SA_PJ_XIShareA[2][kk]
                                               sumIX3 = sumIX3 + SA_PJ_IXShareA[3][kk]    sumXI3 = sumXI3 + SA_PJ_XIShareA[3][kk]
                                               sumIX4 = sumIX4 + SA_PJ_IXShareA[4][kk]    sumXI4 = sumXI4 + SA_PJ_XIShareA[4][kk]
                                               sumIX5 = sumIX5 + SA_PJ_IXShareA[5][kk]    sumXI5 = sumXI5 + SA_PJ_XIShareA[5][kk]
ENDLOOP

  print printo= 1    list = '     '
  print printo= 1 form=10.4csv list = 'SUM  ', sumIX1,sumIX2,sumIX3,sumIX4,sumIX5, sumXI1,sumXI2,sumXI3,sumXI4,sumXI5
  print printo= 1    list = '     '
  sumIX1=0 sumIX2=0 sumIX3=0 sumIX4=0 sumIX5=0   sumXI1=0 sumXI2=0 sumXI3=0 sumXI4=0 sumXI5=0

 LOOP KK= 1,20

 IF (kk=1)
    ;Tab4
    print printo =1    list = 'Adjusted / Target Trip Summary                                                                                  '
    print printo= 1    list = '     '
    print printo =1    list = '     ','       IX Trips  -------------------------------->  XI Trips--------------------------------------> '
    print printo =1    list = ' Jur ','       HBW       HBS       HBO       NHW       NHO       HBW       HBS       HBO       NHW       NHO'
    print printo= 1    list = '     '
 ENDIF

 if (kk= 1)jname='DC   '
 if (kk= 2)jname='MTG  '
 if (kk= 3)jname='PG   '
 if (kk= 4)jname='ARL  '
 if (kk= 5)jname='ALX  '
 if (kk= 6)jname='FFX  '
 if (kk= 7)jname='LDN  '
 if (kk= 8)jname='PW   '
 if (kk= 9)jname='FRD  '
 if (kk=10)jname='CAR  '
 if (kk=11)jname='HOW  '
 if (kk=12)jname='AAR  '
 if (kk=13)jname='CAL  '
 if (kk=14)jname='STM  '
 if (kk=15)jname='CHS  '
 if (kk=16)jname='FAU  '
 if (kk=17)jname='STA  '
 if (kk=18)jname='CL/JF'
 if (kk=19)jname='SP/FB'
 if (kk=20)jname='KGEO '
 if (kk=21)jname='EXTL '

  print printo= 1 form=10.0csv list = Jname(5),SA_PJ_IXA[1][kk],SA_PJ_IXA[2][kk],SA_PJ_IXA[3][kk],SA_PJ_IXA[4][kk],SA_PJ_IXA[5][kk],
                                               SA_PJ_XIA[1][kk],SA_PJ_XIA[2][kk],SA_PJ_XIA[3][kk],SA_PJ_XIA[4][kk],SA_PJ_XIA[5][kk]
                                               sumIX1 = sumIX1 + SA_PJ_IXA[1][kk]    sumXI1 = sumXI1 + SA_PJ_XIA[1][kk]
                                               sumIX2 = sumIX2 + SA_PJ_IXA[2][kk]    sumXI2 = sumXI2 + SA_PJ_XIA[2][kk]
                                               sumIX3 = sumIX3 + SA_PJ_IXA[3][kk]    sumXI3 = sumXI3 + SA_PJ_XIA[3][kk]
                                               sumIX4 = sumIX4 + SA_PJ_IXA[4][kk]    sumXI4 = sumXI4 + SA_PJ_XIA[4][kk]
                                               sumIX5 = sumIX5 + SA_PJ_IXA[5][kk]    sumXI5 = sumXI5 + SA_PJ_XIA[5][kk]

ENDLOOP
  print printo= 1    list = '     '
  print printo= 1 form=10.0csv list = 'SUM  ', sumIX1,sumIX2,sumIX3,sumIX4,sumIX5, sumXI1,sumXI2,sumXI3,sumXI4,sumXI5
  print printo= 1    list = '     '
  sumIX1=0 sumIX2=0 sumIX3=0 sumIX4=0 sumIX5=0   sumXI1=0 sumXI2=0 sumXI3=0 sumXI4=0 sumXI5=0

;;------------------------------------------------------------------------------------------------------------
;; Now we'll apply the target adjutments to the Zonal internal TAZs
;;------------------------------------------------------------------------------------------------------------

LOOP ZZ = 1,@LastIZn@

 ;;  Identify Jurisdiction Code (JC) of the current TAZ

 IF  (ZZ >=      1 && ZZ <=  393)  JJ=1              ;<< DC
 IF  (ZZ >=    394 && ZZ <=  769)  JJ=2              ;<< MTG
 IF  (ZZ >=    770 && ZZ <= 1404)  JJ=3              ;<< PG
 IF  (ZZ >=   1405 && ZZ <= 1545)  JJ=4              ;<< ARL
 IF  (ZZ >=   1546 && ZZ <= 1610)  JJ=5              ;<< ALX
 IF  (ZZ >=   1611 && ZZ <= 2159)  JJ=6              ;<< FFX
 IF  (ZZ >=   2160 && ZZ <= 2441)  JJ=7              ;<< LDN
 IF  (ZZ >=   2442 && ZZ <= 2819)  JJ=8              ;<< PW
 IF  (ZZ >=   2820 && ZZ <= 2949)  JJ=9              ;<< FRD
 IF  (ZZ >=   3230 && ZZ <= 3287)  JJ=10             ;<< CAR
 IF  (ZZ >=   2950 && ZZ <= 3017)  JJ=11             ;<< HOW
 IF  (ZZ >=   3018 && ZZ <= 3116)  JJ=12             ;<< AAR
 IF  (ZZ >=   3288 && ZZ <= 3334)  JJ=13             ;<< CAL
 IF  (ZZ >=   3335 && ZZ <= 3409)  JJ=14             ;<< STM
 IF  (ZZ >=   3117 && ZZ <= 3229)  JJ=15             ;<< CHS
 IF  (ZZ >=   3604 && ZZ <= 3653)  JJ=16             ;<< FAU
 IF  (ZZ >=   3449 && ZZ <= 3541)  JJ=17             ;<< STA
 IF  (ZZ >=   3654 && ZZ <= 3675)  JJ=18             ;<< CL/JF
 IF  (ZZ >=   3435 && ZZ <= 3448)  JJ=19             ;<< SP/FB
 IF  (ZZ >=   3542 && ZZ <= 3603)  JJ=19             ;<< SP/FB
 IF  (ZZ >=   3410 && ZZ <= 3434)  JJ=20             ;<< KGEO


   LOOP PP = 1,5
          SA_ZPJ_IXA[PP][JJ][ZZ]  =  S_ZPJ_IXA[PP][JJ][ZZ] * (SA_PJ_IXA[PP][JJ]/S_PJ_IXA[PP][JJ])
          SA_ZPJ_XIA[PP][JJ][ZZ]  =  S_ZPJ_XIA[PP][JJ][ZZ] * (SA_PJ_XIA[PP][JJ]/S_PJ_XIA[PP][JJ])

          SA_ZP_IXA[PP][ZZ]       =  SA_ZPJ_IXA[PP][JJ][ZZ]
          SA_ZP_XIA[PP][ZZ]       =  SA_ZPJ_XIA[PP][JJ][ZZ]


   ENDLOOP
ENDLOOP

LOOP ZZ = 3676,3722
   LOOP PP = 1,5
      SA_ZP_IXA[PP][ZZ] =  S_ZP_IXA[PP][ZZ]
      SA_ZP_XIA[PP][ZZ] =  S_ZP_XIA[PP][ZZ]
   ENDLOOP
ENDLOOP


; Write out final/adjusted External Ps/As

; DEFINE OUTPUT FILE & VARIABLES
 FILEO RECO[1]    = "@ScaledAdj_IntPsAs@",
                     fields = TAZ(5),
                              SHBW_MtrPs(15.2), SHBS_MtrPs(15.2), SHBO_MtrPs(15.2), SNHW_MtrPs(15.2), SNHO_MtrPs(15.2),
                              SHBW_MtrAs(15.2), SHBS_MtrAs(15.2), SHBO_MtrAs(15.2), SNHW_MtrAs(15.2), SNHO_MtrAs(15.2),
                              NHWIIAs(15.2),    NHOIIAs(15.2)
LOOP ZZ = 1,3722

          ro.TAZ        = zz
          ro.SHBW_MtrPs = SA_ZP_IXA[1][zz]
          ro.SHBS_MtrPs = SA_ZP_IXA[2][zz]
          ro.SHBO_MtrPs = SA_ZP_IXA[3][zz]
          ro.SNHW_MtrPs = SA_ZP_IXA[4][zz]
          ro.SNHO_MtrPs = SA_ZP_IXA[5][zz]

          ro.SHBW_MtrAs = SA_ZP_XIA[1][zz]
          ro.SHBS_MtrAs = SA_ZP_XIA[2][zz]
          ro.SHBO_MtrAs = SA_ZP_XIA[3][zz]
          ro.SNHW_MtrAs = SA_ZP_XIA[4][zz]
          ro.SNHO_MtrAs = SA_ZP_XIA[5][zz]

          IF (ZZ <= @LastIZn@)
                ro.NHWIIAs = SA_ZP_XIA[4][zz]
                ro.NHOIIAs = SA_ZP_XIA[5][zz]
            ELSE
                ro.NHWIIAs = 0.0
                ro.NHOIIAs = 0.0
          ENDIF


          WRITE RECO=1
ENDLOOP

ENDRUN

*copy %_iter_%_Prepare_Ext_Auto_Ends1.txt+%_iter_%_Prepare_Ext_Auto_Ends2.txt  %_iter_%_Prepare_Ext_Auto_Ends.txt
*del  %_iter_%_Prepare_Ext_Auto_Ends1.txt
*del  %_iter_%_Prepare_Ext_Auto_Ends2.txt

