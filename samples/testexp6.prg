#include "hbcompat.ch"
#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

FUNCTION Main()
  
   LOCAL oServer
   LOCAL oExp, oQry
  
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   cls
   oQry = oServer:Query( "SELECT * FROM clientes limit 500" )
   
   oExp = oQry:Export( EXP_SQL, "client.sql" )
   oExp:bOnRow = {| n | ShowLine( n, oQry:LastRec() ) } 
   oExp:Start()
   ?
   
RETURN NIL

PROCEDURE ShowLine( n, nTotal )
   @ 1,1 say Str( n / nTotal * 100 ) + "%"

RETURN

#include "connto.prg"
