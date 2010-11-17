//#include "hbcompat.ch"
#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL oServer, oQry
  
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN 
   ENDIF
   

   oQry = TDolphinQry():New( "SELECT * FROM test ORDER BY id", oServer )
   ? If( oQry:Seek( "3", "ID" ) > 0, "Found 3", "No found 3" )
   ? If( oQry:Seek( "10", "ID" ) > 0, "Found 10", "No found 10" )
   ? If( oQry:Seek( "WILLIAM", "name" ) > 0, "Found William", "No found William" )
   ?
      

RETURN
   
#include "connto.prg"