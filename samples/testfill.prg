//#include "hbcompat.ch"
#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL cText := ""
   LOCAL aData

   LOCAL aStruc, aRow, uItem
   LOCAL oQry, n, oServer
   
   SET CENTURY ON
   SET DATE FORMAT "dd/mm/yyyy"
   
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   cls
   

   oQry = TDolphinQry():New( "SELECT * FROM testman", oServer )
   aData = oQry:FillArray(, { "name", "last", "birth" } )
   ? "Array filled"
   ? "Total Items:" + Str( Len( aData ) )
   oQry:SetLimit( 10 )
   oQry:GoTop()
   aData = oQry:FillArray( { | aRow | qout( aRow[ 2 ] ) } )
   ? "Change Limit to 10, Array filled"
   ? "Total Items:" + Str( Len( aData ) )
   ?
      
      
   
RETURN

#include "connto.prg"