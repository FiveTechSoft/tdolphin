#include "hbcompat.ch"
#include "tdolphin.ch"

#ifndef __XHARBOUR__
#xtranslate CurDrive() => hb_CurDrive()
#endif

FUNCTION Main()
  
   LOCAL oServer, oDlg, oQry, oBrw
   LOCAL oExp
  
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   cls
   oQry = oServer:Query( "SELECT first, last, salary FROM clientes limit 20" )
   oExp = oQry:Export( EXP_EXCEL, CurDrive() + ":\" + CurDir() + "\client", , { , , "999,999.99" } )
   oExp:lMakeTotals = .T.   
   oExp:bOnStart = {| o | Header( o ) }
   oExp:bOnRow = {| n, cText| ShowLine( n, cText, oQry:LastRec() ) }
   
   oExp:Start()
   ?
   
RETURN NIL

PROCEDURE Header( o )
   
   LOCAL oSheet := o:oExcel:ActiveSheet()

   oSheet:Cells( 1, 1 ):value = "Testing Dolphin Export"
   oSheet:Rows( 1 ):RowHeight = 30
   oSheet:Rows( 1 ):Font:Size = 30
   o:nRow++

RETURN 

PROCEDURE ShowLine( n, cText, nTotal )

@ 1,1 say Str( n / nTotal * 100 ) + "%"

RETURN

#include "connto.prg"
