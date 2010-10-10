#include "hbcompat.ch"
#include "tdolphin.ch"
#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL oServer   := NIL
   LOCAL cText := ""

   IF ( oServer := ConnectTo() ) == NIL
      RETURN 
   ENDIF

   IF ! oServer:lError 
      cText += "Connection OK" + CRLF
      cText += "Host: " + oServer:cHost +CRLF
      cText += "Database: " +oServer:cDBName + CRLF

      ? oServer:Query( "select * from test")
      ? oServer:query( "select get_lock('2',180 )" )
      ? oServer:query( "select release_lock('2')" )
      ? cText 

   ENDIF
   inkey(180)

   oServer:End()

RETURN

#include "connto.prg"