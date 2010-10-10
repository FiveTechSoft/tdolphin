// export to dbf

#include "hbcompat.ch"
#include "tdolphin.ch"

FUNCTION Main()
  
   LOCAL oServer, oQry
   LOCAL oExp, cTime
  
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   cls
   oQry = oServer:Query( "SELECT * FROM clientes LIMIT 100" )
   
   oExp = oQry:Export( EXP_HTML, "client.html" )
   oExp:bOnStart = { || QOut( "Started..."), QOut( ""), cTime := Time() }
   oExp:bOnRow = {| o, n | ShowLine( n, oQry:LastRec() ) }
   oExp:bOnEnd = { || QOut( "Elapse time: " + ElapTime( cTime, Time() ) ), QOut( "Finished...") }
   
   oExp:Start()
   ?
   
RETURN NIL


PROCEDURE ShowLine( n, nTotal )

@ Row(),1 say Str( n / nTotal * 100 ) + "%"

RETURN

#include "connto.prg"
