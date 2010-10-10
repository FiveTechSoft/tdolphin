#include "fivewin.ch"
#include "xbrowse.ch"
#include "ribbon.ch"
#include "hbcompat.ch"
#include "tdolphin.ch"

FUNCTION Main()

   LOCAL oDlg
   LOCAL aBtns := Array( 5 )
   LOCAL oBrw, oQry, oServer
   
   
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF

//   oServer:bDebug = {| cQry | LogFile( "debug.log", {cQry} ) }
   
   oQry = oServer:Query( "SELECT * FROM clientes limit 1000" )
   
   oQry:SetPages( 1000 )
   oQry:bOnChangePage = { || oBrw:Refresh(), ChangeTitle( oQry, oDlg ) }

   DEFINE DIALOG oDlg TITLE "Current Page: " + StrZero( oQry:nCurrentPage, 5 ) + " / " + StrZero( oQry:nMaxPages, 5 ) SIZE 565, 480 
   
   BuildButtons( aBtns, oDlg, oQry )

   @ 30, 10 XBROWSE oBrw OBJECT oQry ;
            AUTOCOLS AUTOSORT PIXEL SIZE 260, 200 LINES

// Uncomment this line for fivewin version < 10.7   
//   SetDolphin( oBrw, oQry )
   
   oBrw:CreateFromCode()
      
   ACTIVATE DIALOG oDlg CENTERED
   
   
RETURN NIL


PROCEDURE BuildButtons( aBtns, oDlg, oQry )
   LOCAL nPage


   @ 10, 10 RBBTN aBtns[ 1 ] PROMPT "&First" OF oDlg SIZE 20, 15 ;
            GROUPBUTTON FIRST  CENTER ;
            ROUND ROUNDSIZE 2;
            ACTION( oQry:FirstPage() ) ;
            WHEN( oQry:nCurrentPage > 1 )                    

   @ 10, 30 RBBTN  aBtns[ 2 ] PROMPT "&Prev" OF oDlg SIZE 20, 15 ;
            GROUPBUTTON  CENTER ;
            ROUND ROUNDSIZE 2;
            ACTION( oQry:PrevPage() ) ;
            WHEN( oQry:nCurrentPage > 1 )

   @ 10, 50 RBBTN aBtns[ 3 ] PROMPT "&Goto" OF oDlg SIZE 20, 15 ;
             GROUPBUTTON  CENTER ;
             ROUND ROUNDSIZE 2;
             ACTION( nPage := oQry:nCurrentPage,;
                     MsgGet( "Select Page:", "Page", @nPage ),;
                     oQry:GoToPage( nPage ) )

  
   @ 10, 70 RBBTN aBtns[ 4 ] PROMPT "&Next" OF oDlg SIZE 20, 15 ;
             GROUPBUTTON  CENTER ;
             ROUND ROUNDSIZE 2;
             ACTION( oQry:NextPage() ) ;
             WHEN( oQry:nCurrentPage < oQry:nMaxPages )

   @ 10, 90 RBBTN aBtns[ 5 ] PROMPT "&Last" OF oDlg SIZE 20, 15 ;
             GROUPBUTTON END  CENTER ;
             ROUND ROUNDSIZE 2;             
             ACTION( oQry:LastPage() ) ;
             WHEN( oQry:nCurrentPage < oQry:nMaxPages )


RETURN 

PROCEDURE ChangeTitle( oQry, oDlg )

   oDlg:cTitle = "Current Page: " + StrZero( oQry:nCurrentPage, 5 ) + " / " + StrZero( oQry:nMaxPages, 5 )
   
RETURN


#include "connto.prg"
#include "setbrw.prg"  
