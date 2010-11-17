//#include "hbcompat.ch"
#include "tdolphin.ch"
#include "xbrowse.ch"
#include "fivewin.ch"


#ifndef __XHARBOUR__
#define CurDrive  hb_curdrive
#endif   


FUNCTION Main() 

   LOCAL oWnd 
   LOCAL oMenu
   LOCAL oServer
   
   MENU oMenu 2007
      MENUITEM "Files"
         MENU
            MENUITEM "Load File" ACTION LoadFile( oServer )
            MENUITEM "Browse" ACTION DataBrowse( oServer )
         ENDMENU             
   ENDMENU

      
   //Activated Case sensitive
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   
   DEFINE WINDOW oWnd TITLE "Testing Dolphin - Fivewin" MENU oMenu
   
   ACTIVATE WINDOW oWnd 
   
   oServer:End()
   
RETURN NIL


PROCEDURE LoadFile( oServer )

   LOCAL cFile := cGetFile( "*.*", "Select a File" ) 
   LOCAL uData
   LOCAL oDlg
   
   IF ! Empty( cFile )
   
      uData = D_ReadFile( cFile )

      DEFINE DIALOG oDlg TITLE "File <" + cFile + "> already loaded" SIZE 330, 60 PIXEL
      
      @ 5, 5 BUTTON "Save" SIZE 75, 20 OF oDlg PIXEL ;
              ACTION ( If( oServer:Insert( "files", { "filename", "file" }, { GetOnlyName( cFile ), uData } ),;
                        MsgInfo( "File Saved in Table" ), MsgInfo( "Record no Saved" ) ), oDlg:End() )
      @ 5, 85 BUTTON "Cancel" SIZE 75, 20 OF oDlg PIXEL ;
              ACTION oDlg:End()
      
      ACTIVATE DIALOG oDlg CENTERED

   ENDIF
      

RETURN 



FUNCTION GetOnlyName( cFile )

   LOCAL nRat

   IF ! Empty( cFile )
      nRat = RAt( "\", cFile )
      cFile = SubStr( cFile, nRat + 1 )
   ENDIF

RETURN cFile
   


PROCEDURE DataBrowse( oServer )

   LOCAL oQry 
   LOCAL oDlg
   LOCAL oBrw

   
   oQry = oServer:Query( "SELECT id, filename FROM files" )
   
   
   DEFINE DIALOG oDlg TITLE "Browsing Records" SIZE 300, 480
   
   @ 0, 0 XBROWSE oBrw FIELDS oQry:id, AllTrim( oQry:filename ) ;
          HEADERS "ID", "File Name";
          COLSIZES 50, 200 ;
          LINES
   
   SetDolphin( oBrw, oQry, .F.)

   oBrw:bPopUp    := { |o| ColMenu( o, oQry ) }
   oBrw:nMarqueeStyle = MARQSTYLE_HIGHLROW
   oBrw:CreateFromCode()
   
   oDlg:oClient = oBrw
   
   ACTIVATE DIALOG oDlg ;
            ON INIT ( oDlg:Resize() ) ;
            CENTERED
   
   oQry:End()

RETURN 

//--------------------------------------//

#include "connto.prg"

#include "setbrw.prg"

static function ColMenu( oCol, oQry )

   local oPop

   MENU oPop POPUP 2007
      MENUITEM "Save To Disk" ACTION SaveToDisk( oCol:oBrw:aCols[ 1 ]:Value, oQry )

   ENDMENU

return oPop


PROCEDURE SaveToDisk( uValue, oQry )

   LOCAL nHandle
   LOCAL cDir := cGetDir( "Select a directory",;
                          CurDrive() + ":\" + GetCurDir() + "\" )
   LOCAL oQryFind
   
   IF ! Empty( cDir )
   
      oQry:Seek( uValue, "id", , , , .F. )
      
      oQryFind = TDolphinQry():New( "select file from files where id=" + ClipValue2Sql( uValue ), oQry:oServer )
   
      nHandle := FCreate( cDir + "\" + AllTrim( oQry:filename ) )
      IF FError() # 0       
         MsgInfo( "Error saving file " + cDir + "\" + AllTrim( oQry:filename ) )
         RETURN
      ENDIF
      FWrite( nHandle, oQryFind:file, Len( oQryFind:file ) )
      FClose( nHandle )
      
      MsgInfo( "Filed Saved in: " + cDir )
      oQryFind:End()
   
   ENDIF

RETURN 


