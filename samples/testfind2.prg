//#include "hbcompat.ch"
#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

FUNCTION Main()

   LOCAL oServer, oQry, nRec

   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   ? "Query Loading"
   oQry = oServer:Query( "SELECT * FROM clientes ORDER BY first, last " )
   ? "Query Loaded"
   ? "Seeking AARON EDDY..."
   ? 
   ? "Locate using Soft"
   ? If( ( nRec := oQry:Locate( {"AARON","EDDY"}, {"first","last"}, , , , .T. ) ) > 0, "Found", "No found" ) + Str( nRec )
   ? "Locate without Soft"
   ? If( ( nRec := oQry:Locate( {"AARON","EDDY"}, {"first","last"}, , , , .F. ) ) > 0, "Found", "No found" ) + Str( nRec )
   ?
   ? "Find using Soft"
   ? If( ( nRec := oQry:Find( {"AARON","EDDY"}, {"first","last"}, , , , .T. ) ) > 0, "Found", "No found" ) + Str( nRec )
   ? "Find without Soft"
   ? If( ( nRec := oQry:Find( {"AARON","EDDY"}, {"first","last"}, , , , .F. ) ) > 0, "Found", "No found" ) + Str( nRec )
   ?
   

RETURN NIL

#include "connto.prg"