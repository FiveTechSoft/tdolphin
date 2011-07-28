#include "tdolphin.ch"
#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL oServer:= NIL
   LOCAL cText  := ""
   LOCAL nFlags  := 0
   LOCAL nPort   := 3306
   LOCAL cServer   := "646F6C7068696E746573742E73697461736F66742E6E6574"//"dolphintest.sitasoft.net"
   LOCAL cUser   := "746573745F646F6C7068696E"//"test_dolphin"
   LOCAL cPassword    := "313233343536"//"123456"
   LOCAL cDBName := "646F6C7068696E5F6D616E" //"dolphin_man"
   LOCAL oErr

   TRY
      CONNECT oServer HOST cServer ;
                      USER cUser ;
                      PASSWORD cPassword ;
                      PORT nPort ;
                      FLAGS nFlags;
                      DATABASE cDBName;
                      DECRYPT hb_hextostr( cValue )
                      
      cText += "Connection OK" + CRLF
      cText += "Host: " + Eval( oServer:bDecrypt, oServer:cHost ) +CRLF
      cText += "Database: " + Eval( oServer:bDecrypt, oServer:cDBName ) + CRLF
      cText += oServer:GetServerInfo() + CRLF 
      cText += oServer:GetClientInfo()

      ? cText + CRLF

   CATCH oErr
      ? "Error", oErr:Description
      RETURN NIL 
   END

   oServer:End()

RETURN
