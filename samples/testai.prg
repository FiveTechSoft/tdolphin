#include "hbcompat.ch"
#include "tdolphin.ch"

PROCEDURE Main()
   
   LOCAL oServer   := NIL
   
   SET CENTURY ON
   SET DATE FORMAT "dd/mm/yyyy"
   
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF   

   ? "Next Auto increment in TESTMAN:" + Str( oServer:GetAutoIncrement( "testman" ) )
   ? "Next Auto increment in TEST:" + Str( oServer:GetAutoIncrement( "test" ) )
             
   ? "ok"
   ?
   oServer:End()
   inkey(5)

RETURN

#include "connto.prg"