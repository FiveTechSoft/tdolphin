// export to dbf

#include "hbcompat.ch"
#include "tdolphin.ch"
#include "fivewin.ch"

FUNCTION Main()
  
   LOCAL oServer, oDlg, oQry, oBrw
   LOCAL oExp
  
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   cls
   oQry = oServer:Query( "SELECT * FROM clientes limit 20" )
   oExp = oQry:Export( EXP_DBF, "client.dbf")
   oExp:bOnRow = {| n, cText| ShowLine( n, cText, oQry:LastRec() ) }
   
   oExp:Start()
   ?
   
RETURN NIL


PROCEDURE ShowLine( n, cText, nTotal )

@ 1,1 say Str( n / nTotal * 100 ) + "%"

RETURN

#include "connto.prg"
