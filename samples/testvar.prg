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
   
   
   oServer:Execute( "set @balance:=0, @val1:=20, @val2:=100" )
   oQry = oServer:Query( "select credit, debit, @balance:=@balance+credit-debit as balance, @val1, @VAL2 from test" )
   oQry:bOnLoadQuery = {|| oServer:Execute( "set @balance:=0" ) }
   
   DEFINE DIALOG oDlg SIZE 700,300 OF oWnd

   @ 0, 0 XBROWSE oBrw 
   
   SetDolphin( oBrw, oQry )
      
   oBrw:CreateFromCode()
  
   oDlg:oClient = oBrw 
   
   ACTIVATE DIALOG oDlg CENTERED ON INIT oDlg:Resize()
   
   oQry:End()

RETURN 

//--------------------------------------//
#include "connto.prg"

#include "setbrw.prg"