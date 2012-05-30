//#include "hbcompat.ch"
#include "tdolphin.ch"
#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL oServer   := NIL
   LOCAL cText := ""
   
   local chost:="dolphintest.sitasoft.net"
   local cuser:="test_dolphin"
   local cpsw:="123456"
   local cflags:=0
   local cport:=3306
   local cdbname:="dolphin_man"
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN 
   ENDIF

   IF ! oServer:lError 
      cText += "Connection OK" + CRLF
      cText += "Host: " + oServer:cHost +CRLF
      cText += "Database: " +oServer:cDBName + CRLF
      cText += oServer:GetServerInfo() + CRLF 
      cText += oServer:GetClientInfo()

      ? cText + CRLF

   ENDIF

   oServer:End()

RETURN

#include "connto.prg"