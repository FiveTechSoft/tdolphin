#include "hbcompat.ch"
#include "tdolphin.ch"
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

   LOCAL oDlg
   LOCAL oQry
   LOCAL lNew := .F.
   LOCAL lMod := .F.
   LOCAL oGet := Array( 8 )
   
   
   oQry = oServer:Query( "SELECT * FROM clientes ORDER BY first LIMIT 1000" )
   
   DEFINE DIALOG oDlg RESOURCE "DATAS" OF oWnd
   
   REDEFINE GET oGet[ 1 ] VAR oQry:first    ID 4016 OF oDlg  UPDATE WHEN( lNew .OR. lMod )
   REDEFINE GET oGet[ 2 ] VAR oQry:last     ID 4017 OF oDlg  UPDATE WHEN( lNew .OR. lMod )
   REDEFINE GET oGet[ 3 ] VAR oQry:street   ID 4018 OF oDlg  UPDATE WHEN( lNew .OR. lMod )
   REDEFINE GET oGet[ 4 ] VAR oQry:city     ID 4019 OF oDlg  UPDATE WHEN( lNew .OR. lMod )
   REDEFINE GET oGet[ 5 ] VAR oQry:state    ID 4020 OF oDlg  UPDATE WHEN( lNew .OR. lMod )
   REDEFINE GET oGet[ 6 ] VAR oQry:hiredate ID 4025 OF oDlg  UPDATE WHEN( lNew .OR. lMod )
   REDEFINE GET oGet[ 7 ] VAR oQry:salary   ID 4022 OF oDlg  UPDATE WHEN( lNew .OR. lMod ) PICTURE "999,999,999.99"
   REDEFINE CHECKBOX oGet[ 7 ] VAR oQry:married ID 4026 PROMPT "Married";
            OF oDlg       UPDATE WHEN( lNew .OR. lMod )   
   
   //top 
   REDEFINE BUTTON ID 4001 OF oDlg ;
            ACTION ( lNew := lMod := .F.,;
                     oQry:GoTop(), ;
                     oDlg:Update() )
   
   //prev                        
   REDEFINE BUTTON ID 4002 OF oDlg;
            ACTION ( lNew := lMod := .F.,;
                     oQry:Skip( -1 ), ;
                     oDlg:Update() )
   //next                     
   REDEFINE BUTTON ID 4003 OF oDlg;
            ACTION ( lNew := lMod := .F.,;
                     oQry:Skip(), ;
                     oDlg:Update() )
   //bottom                     
   REDEFINE BUTTON ID 4004 OF oDlg;
            ACTION ( lNew := lMod := .F.,;
                     oQry:GoBottom(), ;
                     oDlg:Update() )   
   //new                  
   REDEFINE BUTTON ID 4005 OF oDlg;
            ACTION ( lNew := ! ( lMod := ! lMod ),;
                     oQry:GetBlankRow(),;
                     oDlg:Update(),;
                     oGet[ 1 ]:SetFocus() ) ;
            WHEN ! lNew
   
   //Modify         
   REDEFINE BUTTON ID 4006 OF oDlg ;
            ACTION ( lMod := ! ( lNew := ! lNew ),;
                     oDlg:Update() );
            WHEN ! lMod
   
   //save         
   REDEFINE BUTTON ID 4007 OF oDlg;
            ACTION ( oQry:Save(), ;
                     oQry := oQry, ;
                     lNew := lMod := .F.,;
                     oDlg:Update() );
            WHEN lNew .OR. lMod
   
   //cancel
   REDEFINE BUTTON ID 4008 OF oDlg ;
            ACTION ( lNew := lMod := .F.,;
                     oQry:Refresh(), ;
                     oDlg:Update() );
            WHEN lNew .OR. lMod
   
   //exit         
   REDEFINE BUTTON ID 4023 OF oDlg;
            ACTION( oDlg:End() )
   
   ACTIVATE DIALOG oDlg CENTERED
   
   oQry:End()

RETURN 

//--------------------------------------//

FUNCTION ConnectTo()
   LOCAL hIni      := HB_ReadIni( ".\connect.ini" )
   LOCAL oServer   := NIL
   LOCAL cServer   := hIni["mysql"]["host"],;
         cUser     := hIni["mysql"]["user"],;
         cPassword := hIni["mysql"]["psw"],;
         nPort     := val(hIni["mysql"]["port"]), ;
         cDBName   := hIni["mysql"]["dbname"], ;
         nFlags    := val(hIni["mysql"]["flags"])
   LOCAL oErr
   
   
   
   TRY
   
      oServer = TDolphinSrv():New( cServer, ;
                                cUser, ;
                                cPassword, ;
                                nPort, nFlags, cDBName )
                                
   CATCH oErr 
     RETURN NIL
   END
   
RETURN oServer
