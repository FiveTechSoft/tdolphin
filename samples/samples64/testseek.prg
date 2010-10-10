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

      oQry = TDolphinQry():New( "SELECT * FROM test", oServer )
      n = 1
      ? Empty( n )
      ? If( oQry:Seek( 3, "ID", , , .T. ) > 0, "Found 3", "No found 3" )
      ? If( oQry:Seek( 10, "ID" ) > 0, "Found 10", "No found 10" )
      ? If( oQry:Seek( "nombre", 2 ) > 0, "Found nombre", "No found nombre" )
      ? If( oQry:Seek( "N", "name", , , .t. ) > 0, "Found N", "No found N" )
      ?
      
      
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

