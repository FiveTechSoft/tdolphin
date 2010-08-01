#include "hbcompat.ch"
#include "tdolphin.ch"

FUNCTION Main()
  
   LOCAL oServer, oDlg, oQry, oBrw
   LOCAL oExp
  
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   cls
   oQry = oServer:Query( "SELECT * FROM president " )
   
   oExp = oQry:Export( 1 )
   oExp:bOnRow = {| n, cText| ShowLine( n, cText ) }
   
   oExp:Start()
   ?
   
RETURN NIL

PROCEDURE ShowLine( n, cText )

? cText

RETURN

#include "connto.prg"
