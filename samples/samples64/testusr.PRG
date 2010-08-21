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

   LOCAL aPriv, aRow, uItem
   
   oServer = TDolphinSrv():New( cServer, ;
                                cUser, ;
                                cPassword, ;
                                nPort, nFlags, "test03",;
                                {| oServer, nError, lInternal | GetError( oServer, nError, lInternal  ) } )

   IF ! oServer:lError 
   
      //we can use array or list in privileges
      IF oServer:AddUser( , "usertest", "123456", "test03", , "CREATE,DELETE,SELECT,UPDATE, DROP" )
         ? "User created successful"
      ENDIF
      IF oServer:RevokePrivileges( , "usertest", "test03", "DROP" )
         ? "revoke DROP provileges: successful"
      ENDIF
      IF oServer:RenameUser( "usertest", cServer, "testuser" )
         ? "Rename user usertest ->testuser: successful"
      ENDIF

      aPriv = oServer:GetPrivileges( PRIV_TABLE )

      ? "TABLE PRIVILEGES"
      ? "================="
      FOR EACH uItem IN aPriv
        ? uItem
      NEXT        
      
      ?
   ENDIF 

   oServer:end()
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