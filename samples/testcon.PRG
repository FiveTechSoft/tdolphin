

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
   
   oServer = TDolphinSrv():New( cServer, cUser, cPassword, nPort )
   
   IF oServer:lError 
      cText += "Error Conection"
   ELSE
      cText += "Connection OK" + CRLF
      cText += Str( oServer:hMySql )
   ENDIF
   
   ? cText + CRLF


RETURN