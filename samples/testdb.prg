//#include "hbcompat.ch"
#include "tdolphin.ch"
#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL oServer   := NIL
   LOCAL ctext := ""
   LOCAL cDBName
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN 
   ENDIF   
   
   cDBName = oServer:cDBName
   
   cText += "Connection OK" + CRLF
   cText += "DATABASE of INI " + cDBName + CRLF
   cText += "DATABASE of oServer " + oServer:cDBName + CRLF
   oServer:SelectDB( cDBName )
   ? cText

   oServer:End()
   inkey(5)

RETURN

#include "connto.prg"