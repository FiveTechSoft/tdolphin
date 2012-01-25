//#include "hbcompat.ch"
//#include "fivewin.ch"
#include "tdolphin.ch"
#define CRLF Chr( 13 ) + Chr( 10 )

//REQUEST DBFCDX


PROCEDURE Main()
   
   LOCAL oServer   := NIL
   LOCAL ctext := ""
   LOCAL cDBName
   LOCAL cAlias := "customer"
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN 
   ENDIF   
   
   cDBName = oServer:cDBName
   oServer:SelectDB( cDBName )

   USE ( cAlias ) ALIAS ( cAlias )
   cls
   ? "Started"
   oServer:Execute( "TRUNCATE TABLE custo" )
//   oServer:InsertFromDbf( "custo", cAlias )   
   oServer:InsertFromDbf( "custo", cAlias, 100, { "FIRST", "LAST", "CITY" }, {|| conteo( cAlias ) } )   
   ? "End"
   oServer:End()
   inkey(5)

RETURN

PROCEDURE conteo( cAlias )

   @ 2, 2 SAY ( cAlias )->( RecNo() )

RETURN

#include "connto.prg"