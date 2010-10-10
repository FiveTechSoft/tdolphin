#include "hbcompat.ch"
#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL oServer, oQry
  
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN 
   ENDIF
   

   oQry = TDolphinQry():New( "SELECT * FROM test", oServer )
   ? If( oQry:Find( {"3"}, {"ID"} ) > 0, "Found 3", "No found 3" )
   ? If( oQry:Find( {"10"}, {"ID"} ) > 0, "Found 10", "No found 10" )
   ? If( oQry:Find( {"WILLIAM"}, {"name"} ) > 0, "Found William", "No found William" )
   ?
      

RETURN
   
#include "connto.prg"