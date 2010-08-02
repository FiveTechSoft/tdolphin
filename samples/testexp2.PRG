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
   oExp = oQry:Export( EXP_EXCEL, CurDrive() + ":\" + CurDir() + "\client.xls", , { , , "999,999.99" } )
   oExp:lMakeTotals = .T.   
  // oExp:bOnRow = {| n, cText| ShowLine( n, cText, oQry:LastRec() ) }
   
   oExp:Start()
   ?
   
RETURN NIL

PROCEDURE ShowLine( n, cText, nTotal )

@ 1,1 say Str( n / nTotal * 100 ) + "%"

RETURN

#include "connto.prg"
