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
   
   
   aStruc = { { "ID", "N", 10, 0, .T., NIL },;
              { "NAME", "C", 15, 0, .F., "First" },;
              { "LAST", "C", 15, 0, .F., "Last" },;
              { "BIRTH", "D", , ,.f. ,NIL },;
              { "ACTIVE", "L", , ,.f. ,.F. },;
              { "ANYNUMBER", "N", 10, 2, .T., 0 } }
   
   oServer = TDolphinSrv():New( cServer, ;
                                cUser, ;
                                cPassword, ;
                                nPort, nFlags, ;
                                {| oServer, nError, lInternal | GetError( oServer, nError, lInternal  ) } )
   
   IF ! oServer:lError 
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
   ENDIF

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
   