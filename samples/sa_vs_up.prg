#include "hbcompat.ch"
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
   LOCAL oData, oCol
   LOCAL lNew := .F.
   LOCAL lMod := .F.
   LOCAL oBtnSave
   
   
   oQry = oServer:Query( "SELECT * FROM president ORDER BY last_name" )
   
   oData = oQry
   
   DEFINE DIALOG oDlg RESOURCE "DATAS" OF oWnd
   
   REDEFINE GET oData:last_name ID 4008 OF oDlg   UPDATE WHEN lNew .OR. lMod
   REDEFINE GET oData:first_name ID 4009 OF oDlg  UPDATE WHEN lNew .OR. lMod
   REDEFINE GET oData:suffix ID 4010 OF oDlg      UPDATE WHEN lNew .OR. lMod
   REDEFINE GET oData:city ID 4011 OF oDlg        UPDATE WHEN lNew .OR. lMod
   REDEFINE GET oData:state ID 4012 OF oDlg       UPDATE WHEN lNew .OR. lMod
   REDEFINE GET oData:birth ID 4013 OF oDlg       UPDATE WHEN lNew .OR. lMod
   REDEFINE GET oData:death ID 4014 OF oDlg       UPDATE WHEN lNew .OR. lMod
                                                 
   REDEFINE BUTTON ID 4016 OF oDlg ;
            ACTION ( lNew := ! ( lMod := ! lMod ),;
                     oData := oQry:GetBlankRow(), ;
                     oDlg:Update() ) ;
            WHEN ! lNew

   REDEFINE BUTTON ID 4019 OF oDlg ;
            ACTION ( lMod := ! ( lNew := ! lNew ),;
                     oData := oQry:GetRowObj(), ;
                     oDlg:Update() );
            WHEN ! lMod
            
   REDEFINE BUTTON ID 4017 OF oDlg ;
            ACTION ( lNew := lMod := .F.,;
                     oQry:Refresh(), ;
                     oData := oQry, ;
                     oDlg:Update() );
            WHEN lNew .OR. lMod
   
   REDEFINE BUTTON oBtnSave ID 4018 OF oDlg ;
            ACTION ( MenuPop( oBtnSave, oData ),;
                     oData := oQry, ;
                     lNew := lMod := .F.,;
                     oBrw:Refresh(),;
                     oDlg:Update() );
            WHEN lNew .OR. lMod
                                              
   REDEFINE XBROWSE oBrw ;
            FIELDS oData:last_name,;
                   oData:first_name,;
                   oData:suffix,;
                   oData:city,;
                   oData:state,;
                   oData:birth,;
                   oData:death ;
           HEADERS "Last Name",;
                   "First Name",;
                   "Suffix",;
                   "City",;
                   "State",;
                   "Birth Day",;
                   "Death Day"
   
   oBrw:SetDolphin( oQry, .F. )
   
   oBrw:CreateFromResource( 4015 )
   
   oBrw:bChange = {|| oDlg:Update() }
   
   ACTIVATE DIALOG oDlg CENTERED
   
   oQry:End()

RETURN 

PROCEDURE MenuPop( oBtn, oData ) 
   LOCAL oPop
   LOCAL cTime 
   
   MENU oPop POPUP
      MENUITEM "METHOD Save" ACTION ( cTime := Time(), ;
                                      oData:Save(),;
                                      MsgInfo( "Process Time: " + ElapTime( cTime, time() ), "Method Save" ) )
      MENUITEM "Sentence UPDATE" ACTION ( cTime := Time(), ;
                                      MethodUpdate( oData ),;
                                      MsgInfo( "Process Time: " + ElapTime( cTime, time() ), "Sentence UPDATE" ) )
  ENDMENU  
        
ACTIVATE POPUP oPop AT oBtn:nHeight, 0 OF oBtn

RETURN 

PROCEDURE MethodUpdate( oData )
   LOCAL aColumns
   LOCAL aValues
   LOCAL cWhere := ""
   LOCAL cData
   LOCAL cQry   := ""
   
   cQry += "UPDATE president SET "

   cQry += "last_name=" + ClipValue2SQL( oData:last_name ) + ","
   cQry += "first_name=" + ClipValue2SQL( oData:first_name ) + ","
   cQry += "suffix=" + ClipValue2SQL( oData:suffix ) + ","
   cQry += "city=" + ClipValue2SQL( oData:city ) + ","
   cQry += "state=" + ClipValue2SQL( oData:state ) + ","
   cQry += "birth=" + ClipValue2SQL( oData:birth ) + ","
   cQry += "death=" + ClipValue2SQL( oData:death )  + " WHERE "
 
               
   cWhere += "last_name" + ;
              If( ( cData := ClipValue2SQL( oData:oQuery:hRow[ '_last_name' ] ) ) == "NULL", " IS ", " = " ) +;
              cData + " AND "
              
   cWhere += "first_name" + ;
              If( ( cData := ClipValue2SQL( oData:oQuery:hRow[ '_first_name' ] ) ) == "NULL", " IS ", " = " ) +;
              cData + " AND "

   cWhere += "suffix" + ;
              If( ( cData := ClipValue2SQL( oData:oQuery:hRow[ '_suffix' ] ) ) == "NULL", " IS ", " = " ) +;
              cData + " AND "

   cWhere += "state" + ;
              If( ( cData := ClipValue2SQL( oData:oQuery:hRow[ '_state' ] ) ) == "NULL", " IS ", " = " ) +;
              cData + " AND "

   cWhere += "city" + ;
              If( ( cData := ClipValue2SQL( oData:oQuery:hRow[ '_city' ] ) ) == "NULL", " IS ", " = " ) +;
              cData + " AND "

   cWhere += "birth" + ;
              If( ( cData := ClipValue2SQL( oData:oQuery:hRow[ '_birth' ] ) ) == "NULL", " IS ", " = " ) +;
              cData + " AND "

   cWhere += "death" + ;
              If( ( cData := ClipValue2SQL( oData:oQuery:hRow[ '_death' ] ) ) == "NULL", " IS ", " = " ) +;
              cData

   cQry += cWhere
   
   oData:oServer:SqlQuery( cQry )
   
   oData:LoadQuery()

RETURN

//--------------------------------------//

#include "connto.prg"
#include "setbrw.prg"