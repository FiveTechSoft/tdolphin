#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL cText := ""
   LOCAL oQry, oServer
   
   SET CENTURY ON
   SET DATE FORMAT "dd/mm/yyyy"
   
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   cls
   
   cText = "CALL born_in_year( 1908 )"

   oQry := oServer:Query( cText )
   
   DolphinBrw( oQry, "Test" )
   
   oServer:NextResult()
   
   oQry:End()

   cText = "CALL born_in_year( 1913 )"

   oQry := oServer:Query( cText )
   
   DolphinBrw( oQry, "Test" )
   
   oServer:NextResult()
   
   oQry:End()

   cText = "call count_born_in_year( 1913, @count )"

   oQry := oServer:Execute( cText )
   
   oServer:NextResult()
   
   oQry := oServer:Query( "select @count as count" )
      
   ? "count is:" 
   ?? oQry:count
   
   oQry:End()
   
   
   
RETURN

#include "connto.prg"
#include "brw.prg"