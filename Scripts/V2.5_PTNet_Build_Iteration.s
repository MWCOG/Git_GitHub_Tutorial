
; ==============================================
;V2.5_PTNet_Build_Iteration.s
;RM
;Program: Build PT Network for individual iterations: 2.5
; This program is executed during I2, I3 and I4 and attaches the previous iteration highway times, speeds
; to the PT network used in skimming/assigning
; (the process is similar to the V2.5_PTNet_Build.s script used in the pp and i1 iterations)

*del voya*.prn
*del PT_Net.NET

RUN PGM = NETWORK
ZONES=3722

FILEI NODEI=Inputs\NODE.dbf
FILEI LINKI=Inputs\LINK.dbf

NETO=PT_NET.NET

ENDRUN

itr ='%_iter_%'  ; current  iteration
pre ='%_prev_%'  ; previous iteration

IF (itr  = 'i1') NETINP= 'inputs\i4_Assign_Output.NET' ; loaded highway networks for speeds in the transit network
IF (itr  = 'i2') NETINP= 'i1_HWY.NET' ;
IF (itr  = 'i3') NETINP= 'i2_HWY.NET' ;
IF (itr  = 'i4') NETINP= 'i3_HWY.NET' ;

IF (itr  = 'i1') iterno =1
IF (itr  = 'i2') iterno =2
IF (itr  = 'i3') iterno =3
IF (itr  = 'i4') iterno =4


IF (itr  = 'i1') spdvar ='i4'
IF (itr  = 'i2') spdvar ='i1'
IF (itr  = 'i3') spdvar ='i2'
IF (itr  = 'i4') spdvar ='i3'

LOOP period = 1,2
 IF (period=1)
  PRD = 'AM'
  time = 'AM'
 ELSE
  PRD = 'OP'
  time = 'MD'
 ENDIF

	RUN PGM=NETWORK
	
  NETI[1]  = PT_Net.NET
  NETI[2]  = @NETINP@

  NETO= @itr@_@PRD@_PT_INI.Net include = a,b,distance,jur,screen,FTYPE,
	                                        toll,tollgrp,amlane,amlimit,pmlane,pmlimit,oplane,oplimit, edgeid,
	                                        LINKID,NETYEAR,Shape_LENG,Projectid,TRANTIME,WKTIME,MODE,SPEED,
	                                        @itr@@PRD@SPD,@itr@@PRD@_HTIME
	  MERGE record = F
	
	  IF (li.1.a =li.2.a && li.1.b = li.2.b)

        @itr@@time@SPD     =  li.2.@spdvar@@time@SPD                         ; from the initial highway network (from inputs SD)
        @itr@@time@_HTIME  = (li.2.distance*60.0)/li.2.@spdvar@@time@SPD     ;
	       TRANTIME           = @itr@@time@_HTIME

   ENDIF

	
	ENDRUN

ENDLOOP






