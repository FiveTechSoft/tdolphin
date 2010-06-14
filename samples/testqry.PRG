#include "hbcompat.ch"
#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL oServer
   LOCAL hIni      := HB_ReadIni( ".\connect.ini" )
   LOCAL oServer   := NIL
   LOCAL cServer   := hIni["mysql"]["host"],;
         cUser     := hIni["mysql"]["user"],;
         cPassword := hIni["mysql"]["psw"],;
         nPort     := val(hIni["mysql"]["port"]), ;
         cDBName   := hIni["mysql"]["dbname"], ;
         nFlags    := val(hIni["mysql"]["flags"])
   LOCAL cText := ""
   
   oServer = TDolphinSrv():New( cServer, ;
                                cUser, ;
                                cPassword, ;
                                nPort, nFlags, ;
                                {| oServer, nError, lInternal | GetError( oServer, nError, lInternal  ) } )
   
   IF ! oServer:lError 
      oServer:SelectDB( cDBName )
      IF oServer:SqlQuery( "SELECT * FROM TEST" )
         ? "Query exectuted correctly" 
         ?
      ENDIF
   ENDIF
   
   oServer:End()
   

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
