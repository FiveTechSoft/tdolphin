

#ifdef __XHARBOUR__ 
   #include "fivewin.ch"
#else 
   #include "hbcompat.ch"
   #define CRLF Chr( 13 ) + Chr( 10 )
#endif

PROCEDURE Main()
   
   LOCAL oServer
   LOCAL cServer := "localhost",;
         cUser   := "testing",;
         cPassword := "123456",;
         nPort   := 3306
   LOCAL cText := ""
   
   oServer = TDolphinSrv():New( cServer, ;
                                cUser, ;
                                cPassword, ;
                                nPort, , ;
                                {| oServer, nError, lInternal | GetError( oServer, nError, lInternal  ) } )
   
   IF ! oServer:lError 
      cText += "Connection OK" + CRLF
      oServer:SelectDB( "test01" )
      
      ? cText
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
   