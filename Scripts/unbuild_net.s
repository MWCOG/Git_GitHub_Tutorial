*del tppl*.prn
;-------------------------------------------------------------------------------
; unbuild_net.s
;   Unbuilds a highway network (converts from TP+ binary to DBF format)
;   Output files are in the format needed for the Version 2.3 travel model
;
; fxie 3/1/22: Updated to unbuild zonehwy_unbuild.net from a Ver.2.4_PT or Gen3 Model
; - Included new variables in the link and node files
; - Changed "edgeid(10)" to "edgeid(12)" as some edgeids exceed 1000000000
; - Changed "Shape_Leng(7.2)" to "Shape_Leng(12.5)" as some lengths exceed 10000.00
; - Changed all link attributes with fractional values (e.g., distance, Shape_Leng)
;   to 5 decimal digits to be consistent with the original link.dbf file exported
;   from the COG/TPB network database.
;-------------------------------------------------------------------------------
pageheight=32767  ; Set the page height to a large value to minimize page breaks


basepath  = '.'
inhwy     = 'zonehwy_unbuild.net'
out_link  = 'Link.dbf'
out_node  = 'Node.dbf'


run pgm = hwynet

neti = @basepath@\@inhwy@

/* Write out link file */

linko= @basepath@\@out_link@,
  format=DBF,
  include=a(12.5),b(12.5),distance(10.5),spdclass(7),capclass(7),jur(7),Screen(5),ftype(7),toll(15.5),tollgrp(5),
           amlane(3),amlimit(3),pmlane(3),pmlimit(3),oplane(3),oplimit(3),edgeid(12),linkid(10),netyear(8),Shape_Leng(12.5),
           projectid(10),TRANTIME(10.5),WKTIME(10.5),MODE(3),SPEED(10.5),STREETNAME(10)

/* Write out node file */

nodeo= @basepath@\@out_node@,
  format=DBF,
  include=n(6),x(8),y(8),MRFZONE(3),CRMFZONE(3),CRVFZONE(3)

endrun

*copy tppl*.prn  unbuild_net.rpt
