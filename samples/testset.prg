//#include "hbcompat.ch"
#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL oServer   := NIL

   LOCAL aStruc, aRow, uItem
   LOCAL oQry, n
   
   SET CENTURY ON
   SET DATE FORMAT "dd/mm/yyyy"
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN 
   ENDIF

   oQry = TDolphinQry():New( "SELECT * FROM test", oServer )
   ?
   ? "Current Query: " 
   ? oQry:cQuery
   ? "Record Count:" + Str( oQry:LastRec() )
   ?
   oQry:SetWhere( "ID > 3 AND ID < 5" )
   ? "Where Changed:"
   ? oQry:cQuery
   ? "Record Count:" + Str( oQry:LastRec() )
   ?
   oQry:SetWhere( "" )
   ? "Where Deleted:"
   ? oQry:cQuery
   ? "Record Count:" + Str( oQry:LastRec() )
   ?
   oQry:SetOrder( "NAME ASC" )
   ? "Order Change:"
   ? oQry:cQuery
   ?      
   oQry:SetLimit( 3 )
   ? "Limit Change:"
   ? oQry:cQuery
   ? "Record Count:" + Str( oQry:LastRec() )
   ?
      

RETURN
   
#include "connto.prg"