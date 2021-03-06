//#include "hbcompat.ch"
#include "tdolphin.ch"
#include "xbrowse.ch"
#include "fivewin.ch"

FUNCTION Main() 

   LOCAL oWnd 
   LOCAL oMenu
   LOCAL oServer
   MENU oMenu 2007
      MENUITEM "testing" ACTION DataBrowse( oServer, oWnd )
   ENDMENU
   
   SET CENTURY ON
   SET DATE FORMAT "dd/mm/yyyy"   
      
   //Activated Case sensitive
   D_SetCaseSensitive( .T. )
   Set_MyLang( "esp" )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   
   DEFINE WINDOW oWnd TITLE "Testing Dolphin - Fivewin" MENU oMenu
   
   ACTIVATE WINDOW oWnd 
   
   oServer:End()
   
RETURN NIL

PROCEDURE DataBrowse( oServer, oWnd )

   LOCAL oQry 
   LOCAL oDlg
   LOCAL oBrw
   LOCAL oData, oCol
   
   
   oQry = oServer:Query( "SELECT * FROM president ORDER BY last_name ASC" )
   
   DEFINE DIALOG oDlg SIZE 700,300 OF oWnd

   @ 0, 0 XBROWSE oBrw OF oDlg
   
   SetDolphin( oBrw, oQry )
      
   oBrw:CreateFromCode()
  
   oDlg:oClient = oBrw 
   
   ACTIVATE DIALOG oDlg CENTERED ON INIT oDlg:Resize()
   
   oQry:End()

RETURN 

#include "connto.prg"
#include "setbrw.prg"