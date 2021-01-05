; ==============================================
;V2.5_PTNet_Build
;rogram: Build PT Network for Version 2.5
; rn	10-20-2017	Adding the external process to the model.


*del voya*prn

RUN PGM = NETWORK   ; PRNFILE = "PTNET_BUILD.PRN"
ZONES=3722

	FILEI NODEI=Inputs\NODE.dbf
	FILEI LINKI=Inputs\LINK.dbf
	
	NETO=PT_NET.NET


ENDRUN

LOOP period = 1,2
	IF (period=1)
		PRD = 'AM'
		time = 'AM'
	ELSE
		PRD = 'OP'
		time = 'MD'
	ENDIF
	
	RUN PGM=NETWORK
	
	  NETI[2]  = inputs\i4_Assign_Output.NET          ; Previous CLRP_Final Loaded Hwy Net of the same scenario year (e.g V2.3.66)
	  NETI[1]  = PT_Net.NET                    				

	  NETO= @PRD@_PT_Net.Net include = a,b,distance,jur,screen,FTYPE,
	                                              toll,tollgrp,amlane,amlimit,pmlane,pmlimit,oplane,oplimit, edgeid,
	                                              LINKID,NETYEAR,Shape_LENG,Projectid,TRANTIME,WKTIME,MODE,SPEED,
	                                              I4@PRD@SPD,I4@PRD@_HTIME
	  MERGE record = F
	
	  IF (li.1.a =li.2.a && li.1.b = li.2.b)
	     I4@time@SPD      = li.2.I4@time@SPD
	     I4@time@_HTIME   = (li.2.distance*60.0)/li.2.I4@time@SPD
	     TRANTIME     = I4@time@_HTIME
	  ENDIF
	ENDRUN

ENDLOOP






