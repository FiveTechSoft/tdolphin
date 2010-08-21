/*
 * $Id: 11-Jul-10 9:43:51 AM testfw1.PRG Z dgarciagil $
 */

#include "hbcompat.ch"
#include "tdolphin.ch"
#include "fivewin.ch"
#include "ribbon.ch"
#include "dtpicker.ch"

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
   LOCAL nSays 
   LOCAL oFont, oBrush
   
   
   DEFINE FONT oFont NAME "Times New Roman" SIZE 8, 12
   DEFINE BRUSH oBrush FILE "..\bitmaps\bluewhit.bmp"
   
   oQry = oServer:Query( "SELECT * FROM clientes ORDER BY first LIMIT 10" )
   
   DEFINE DIALOG oDlg RESOURCE "DATAS" OF oWnd FONT oFont BRUSH oBrush ;
          TITLE "TDolphin Build " + oServer:cBuild
   
   FOR nSays= 4001 TO 4007 //all says
      REDEFINE SAY ID nSays OF oDlg TRANSPARENT
   NEXT
   
   REDEFINE GET oGet[ 1 ] VAR oQry:first    ID 4008 OF oDlg  UPDATE WHEN( lNew .OR. lMod )
   REDEFINE GET oGet[ 2 ] VAR oQry:last     ID 4009 OF oDlg  UPDATE WHEN( lNew .OR. lMod )
   REDEFINE DTPICKER oGet[ 3 ] VAR oQry:hiredate ID 4010 OF oDlg  UPDATE WHEN( lNew .OR. lMod )
   REDEFINE GET oGet[ 4 ] VAR oQry:street   ID 4011 OF oDlg  UPDATE WHEN( lNew .OR. lMod )
   REDEFINE GET oGet[ 5 ] VAR oQry:city     ID 4012 OF oDlg  UPDATE WHEN( lNew .OR. lMod )
   REDEFINE GET oGet[ 6 ] VAR oQry:state    ID 4013 OF oDlg  UPDATE WHEN( lNew .OR. lMod )
   REDEFINE GET oGet[ 7 ] VAR oQry:salary   ID 4014 OF oDlg  UPDATE WHEN( lNew .OR. lMod ) PICTURE "999,999,999.99"

   REDEFINE CHECKBOX oGet[ 8 ] VAR oQry:married ID 4026 PROMPT "Married";
            OF oDlg       UPDATE WHEN( lNew .OR. lMod )  
   oGet[ 8 ]:lTransparent = .T.
   
   //top 
   REDEFINE RBBTN ID 4015 OF oDlg ;
            ACTION ( lNew := lMod := .F.,;
                     oQry:GoTop(), ;
                     oDlg:Update() );
            GROUPBUTTON FIRST ROUND ROUNDSIZE 2;
            BITMAP "..\bitmaps\top.bmp"
   
   //prev                        
   REDEFINE RBBTN ID 4016 OF oDlg;
            ACTION ( lNew := lMod := .F.,;
                     oQry:Skip( -1 ), ;
                     oDlg:Update() );
            GROUPBUTTON;
            BITMAP "..\bitmaps\prev.bmp" 
   //next                     
   REDEFINE RBBTN ID 4017 OF oDlg;
            ACTION ( lNew := lMod := .F.,;
                     oQry:Skip(), ;
                     oDlg:Update() );
            GROUPBUTTON;
            BITMAP "..\bitmaps\next.bmp"
                                 
   //bottom                     
   REDEFINE RBBTN ID 4018 OF oDlg;
            ACTION ( lNew := lMod := .F.,;
                     oQry:GoBottom(), ;
                     oDlg:Update() );
            GROUPBUTTON END ROUND ROUNDSIZE 2;
            BITMAP "..\bitmaps\bottom.bmp"
                     
   //new                  
   REDEFINE RBBTN ID 4019 OF oDlg;
            ACTION ( lNew := ! ( lMod := ! lMod ),;
                     oQry:GetBlankRow( .F. ),;
                     oDlg:Update(),;
                     oGet[ 1 ]:SetFocus() ) ;
            WHEN ! lNew;
            GROUPBUTTON FIRST ROUND ROUNDSIZE 2;
            BITMAP "..\bitmaps\new2.bmp"
   
   //Modify         
   REDEFINE RBBTN  ID 4020 OF oDlg ;
            ACTION ( lMod := ! ( lNew := ! lNew ),;
                     oDlg:Update() );
            WHEN ! lMod;
            GROUPBUTTON;
            BITMAP "..\bitmaps\edit.bmp"
   
   //save         
   REDEFINE RBBTN  ID 4021 OF oDlg;
            ACTION ( oQry:Save(), ;
                     oQry := oQry, ;
                     lNew := lMod := .F.,;
                     oDlg:Update() );
            WHEN lNew .OR. lMod;
            GROUPBUTTON;
            BITMAP "..\bitmaps\floppy.bmp"
   
   //delete
   REDEFINE RBBTN  ID 4022 OF oDlg;
            ACTION ( If( MsgYesNo( "Do want delete current record" ), ;
                         ( oQry:Delete(), oQry:Refresh(),oDlg:Update() ), ) ) ;
            WHEN ( ! lNew .AND. ! lMod );
            GROUPBUTTON;
            BITMAP "..\bitmaps\delete2.bmp"

   //cancel
   REDEFINE RBBTN  ID 4023 OF oDlg ;
            ACTION ( lNew := lMod := .F.,;
                     oQry:Refresh(), ;
                     oDlg:Update() );
            WHEN lNew .OR. lMod;
            GROUPBUTTON END ROUND ROUNDSIZE 2;
            BITMAP "..\bitmaps\repeat.bmp"
   
   //exit         
   REDEFINE RBBTN  ID 4024 OF oDlg;
            ACTION( oDlg:End() );
            BORDER ROUND ROUNDSIZE 2;
            BITMAP "..\bitmaps\exit.bmp"
            
   
   ACTIVATE DIALOG oDlg CENTERED
   
   oQry:End()
   oFont:End()
   oBrush:End()

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
