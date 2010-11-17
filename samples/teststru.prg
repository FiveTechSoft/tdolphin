//#include "hbcompat.ch"
#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL oServer   := NIL
   LOCAL aStruc, aRow, uItem
   LOCAL cDBName
   
   aStruc = { { "ID", "N", 10, 0, .T., NIL },;
              { "NAME", "C", 15, 0, .F., "First" },;
              { "LAST", "C", 15, 0, .F., "Last" },;
              { "BIRTH", "D", , ,.f. ,NIL },;
              { "ACTIVE", "L", , ,.f. ,.F. },;
              { "ANYNUMBER", "N", 10, 2, .T., 0 } }
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF   

   cDBName=oServer:cDBName

   IF oServer:DBCreate( cDBName )
      ? "Database created correctly " + cDBName
      ?
   ENDIF
   oServer:SelectDB( cDBName )
   IF oServer:CreateTable( "test", aStruc, "id", "id", "id" )
      ? "Table created correctly test"
      ?
      aStruc = oServer:TableStructure( "test" )
      ? "NAME      TABLE     DEFAULT   TYPE      LENGTH    MAXLENGTH FLAGS     DECIMAL"
      ? "============================================================================="
      ?
      FOR EACH aRow IN aStruc
        FOR EACH uItem IN aRow
           ?? If( ValType( uItem ) == "N", PadR( AllTrim( Str( uItem ) ), 10 ), PadR( uItem, 10 ) )
        NEXT 
        ? 
      NEXT  
      ? "ID AutoIncrement:" + If( oServer:IsAutoIncrement( "ID", "test" ), "Yes", "No" )
      ? "NAME AutoIncrement:" + If( oServer:IsAutoIncrement( "NAME", "test" ), "Yes", "No" )
      ?
      
      
   ENDIF      

   oServer:End()
   inkey(5)

RETURN

#include "connto.prg"