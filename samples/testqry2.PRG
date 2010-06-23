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
   LOCAL oQry
   
   oServer = TDolphinSrv():New( cServer, ;
                                cUser, ;
                                cPassword, ;
                                nPort, nFlags, cDBName,;
                                {| oServer, nError, lInternal | GetError( oServer, nError, lInternal  ) } )
   
   IF ! oServer:lError 

      oQry = TDolphinQry():New( "SELECT * FROM testman", oServer )
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
      oQry:Goto( 100 )
      ? "ID (hash):" + Str( oQry:ID )
      ? "FieldGet( 'ID' ): " + Str( oQry:FieldGet( "ID" ) )
      ? "FieldGet( 1 ): " + Str( oQry:FieldGet( 1 ) )
      ? "Field Clipper Type BIRTH: " + oQry:FieldType( "birth" )
      ? "Field MySql Type BIRTH: " + Str( oQry:FieldMySqlType( "birth" ) )
      ? "Field MySql2Char Type BIRTH: " + SqlType2Char( oQry:FieldMySqlType( "birth" ) )
      ? "FieldPos( 'name' ): " + Str( oQry:FieldPos( "name" ) )
              
      oQry:End() 
             
   ENDIF
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
   