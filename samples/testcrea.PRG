#include "hbcompat.ch"
#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL oServer
   LOCAL cServer := "192.168.0.200",;
         cUser   := "testing",;
         cPassword := "123456",;
         nPort   := 3306
   LOCAL cText := ""

   LOCAL aStruc 
   
   
   aStruc = { { "ID", "N", 10, 0, .T., NIL },;
              { "NAME", "C", 15, 0, .F., "First" },;
              { "LAST", "C", 15, 0, .F., "Last" },;
              { "BIRTH", "D", , , , },;
              { "ACTIVE", "L", , , ,.F. } }
   
   oServer = TDolphinSrv():New( cServer, ;
                                cUser, ;
                                cPassword, ;
                                nPort, , ;
                                {| oServer, nError, lInternal | GetError( oServer, nError, lInternal  ) } )
   
   IF ! oServer:lError 
      IF oServer:DBCreate( "test02" )
         ? "Database created correctly"
         ?
      ENDIF
      oServer:SelectDB( "test02" )
      IF oServer:CreateTable( "test", aStruc, "id", "id", "id" )
         ? "Table created correctly"
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
