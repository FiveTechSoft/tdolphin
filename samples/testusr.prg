#include "hbcompat.ch"
#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL oServer
   LOCAL cServer, uItem
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF

   cServer := oServer:cHost

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

#include "connto.prg"