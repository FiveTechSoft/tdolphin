//#include "hbcompat.ch"
#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL oServer   := NIL

   LOCAL cText := ""

   LOCAL aStruc, aRow, uItem
   LOCAL oQry, n
   
   SET CENTURY ON
   SET DATE FORMAT "dd/mm/yyyy"
   
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN
   ENDIF

   oQry = TDolphinQry():New( "SELECT * FROM clientes limit 10", oServer )
   ? "Table created correctly test"
   ?
   aStruc = oQry:aStructure
   ? "NAME      TABLE     DEFAULT   TYPE      LENGTH    MAXLENGTH FLAGS     DECIMAL CLIP TYPE"
   ? "======================================================================================="
   ?
   FOR EACH aRow IN aStruc
     FOR EACH uItem IN aRow
        ?? If( ValType( uItem ) == "N", PadR( AllTrim( Str( uItem ) ), 10 ), PadR( uItem, 10 ) )
     NEXT 
     ? 
   NEXT  
   ? "======================================================================================="
   ?
   FOR EACH aRow IN aStruc
      ?? PadR( aRow[ 1 ], aRow[ 5 ] )
   NEXT
   ? "======================================================================================="
   ?
   FOR n = 1 TO oQry:FCount()
      ?? oQry:FieldGet( n ), "   "
   NEXT

   ? "Getting Blank Row"
   
   oQry:married = .T.
   oQry:Save()
   ?
/*
      oQry:GoBottom()
      oQry:name = "Name " + Str( oQry:ID )
      oQry:Save()
      oQry:GoBottom()
      */
   FOR n = 1 TO oQry:FCount()
      ?? oQry:FieldGet( n ), "   "
   NEXT      
   */
   oQry:End() 
             
   ? "ok"
   ?
   oServer:End()
   inkey(5)

RETURN

#include "connto.prg"