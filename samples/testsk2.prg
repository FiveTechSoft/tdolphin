#include "fivewin.ch"
#include "xbrowse.ch"
#include "tdolphin.ch"
//#include "hbcompat.ch"

FUNCTION Main()
  
   LOCAL oServer, oDlg, oQry, oBrw
  
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   
   oQry = oServer:Query( "SELECT * FROM president ORDER BY first_name " )
   
   DEFINE DIALOG oDlg  SIZE 565, 480 
   
   @ 30, 10 XBROWSE oBrw OBJECT oQry ;
            AUTOCOLS AUTOSORT PIXEL SIZE 260, 200 

// Uncomment this line for fivewin version < 10.7   
//   SetDolphin( oBrw, oQry )
   
   oBrw:CreateFromCode()
      
   ACTIVATE DIALOG oDlg CENTERED
   
   
RETURN NIL

#include "connto.prg"
#include "setbrw.prg"  
