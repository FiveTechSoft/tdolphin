#include "hbcompat.ch"
#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL oServer   := NIL

   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   ? "Ping to server " , If( oServer:Ping(), "OK", "Failed" )
   ?

   oServer:end()
   inkey(5)

RETURN NIL

#include "connto.prg"
