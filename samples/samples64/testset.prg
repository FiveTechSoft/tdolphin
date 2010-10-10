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