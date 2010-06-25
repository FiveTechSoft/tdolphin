#include "hbcompat.ch"
#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL hIni      := HB_ReadIni( ".\connect.ini" )
   LOCAL oServer   := NIL
   LOCAL cServer   := hIni["mysql"]["host"],;
         cUser     := hIni["mysql"]["user"],;
         cPassword := hIni["mysql"]["psw"],;
         nPort     := val(hIni["mysql"]["port"]), ;
         cDBName   := hIni["mysql"]["dbname"], ;
         nFlags    := val(hIni["mysql"]["flags"])
   LOCAL cText := ""

   LOCAL aStruc, aRow, uItem
   LOCAL oQry, n
   
   SET CENTURY ON
   SET DATE FORMAT "dd/mm/yyyy"
   
   oServer = TDolphinSrv():New( cServer, ;
                                cUser, ;
                                cPassword, ;
                                nPort, nFlags, cDBName,;
                                {| oServer, nError, lInternal | GetError( oServer, nError, lInternal  ) } )
   
   IF ! oServer:lError 

      oQry = TDolphinQry():New( "SELECT * FROM testman", oServer )
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
      ?
      oQry:GetBlankRow()
      FOR n = 1 TO oQry:FCount()
         ?? oQry:FieldGet( n ), "   "
      NEXT
      oQry:Birth = Date()
      oQry:Save()

      oQry:End() 
             
   ENDIF
   ? "ok"
   ?
   oServer:End()
   inkey(5)

RETURN

PROCEDURE GetError( oServer, nError, lInternal )
   LOCAL cText := ""
   
   cText += "Error from Custom Error Message" + CRLF
   cText += "================================" + CRLF
   cText += oServer:ErrorTxt() + CRLF
   cText += "ERROR No: " + Str( nError ) + CRLF
   cText += "Internal: " + If( lInternal, "Yes", "No" ) + CRLF
   
   ? cText + CRLF
   
   
RETURN
   