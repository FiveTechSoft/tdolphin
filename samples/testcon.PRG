

#ifdef __XHARBOUR__ 
   #include "fivewin.ch"
#else 
   #include "hbcompat.ch"
   #define CRLF Chr( 13 ) + Chr( 10 )
#endif

PROCEDURE Main()
   
   LOCAL oServer
   LOCAL cServer := "localhost1",;
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
      cText += Str( oServer:hMySql )
      ? cText + CRLF
   ENDIF
   

RETURN

PROCEDURE GetError( oServer, nError, lInternal )
   LOCAL cText := ""
   
   IF nError == 2005 
      cText += "Connection Error" + CRLF
      cText += "Unknow Host" + CRLF
   ENDIF
   
   ? cText + CRLF
   
RETURN
   