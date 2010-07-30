#include "fivewin.ch"
#include "xbrowse.ch"
#include "ribbon.ch"
#include "hbcompat.ch"



FUNCTION Main()

   LOCAL oDlg
   LOCAL aBtns := Array( 13 )
   LOCAL oBrw, oQry, oServer
   
   
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   
   
   oQry = oServer:Query( "SELECT * FROM clientes ORDER BY first LIMIT 10000" )
   
   oQry:SetPages( 10000 )
   oQry:bOnChangePage = { || oBrw:Refresh() }

   DEFINE DIALOG oDlg TITLE "Current Page: " + StrZero( oQry:nCurrentPage, 5 ) + " / " + StrZero( oQry:nMaxPages, 5 ) SIZE 565, 480 
   
   BuildButtons( aBtns, oDlg, oQry )

   @ 30, 10 XBROWSE oBrw OBJECT oQry ;
            AUTOCOLS AUTOSORT PIXEL SIZE 260, 200 LINES
   
   oBrw:CreateFromCode()


      
   ACTIVATE DIALOG oDlg CENTERED
   
   
RETURN NIL


PROCEDURE BuildButtons( aBtns, oDlg, oQry )

   LOCAL nSelected := 3

   @ 10, 10 RBBTN aBtns[ 1 ] PROMPT "&First" OF oDlg SIZE 20, 15 ;
            GROUPBUTTON FIRST  CENTER ;
            ROUND ROUNDSIZE 2;
            ACTION( oQry:FirstPage(), ;
                    ChangeTitle( oQry, oDlg ),;
                    nSelected := ChangeBtnStatus( aBtns, oQry, 3 ) )

   @ 10, 30 RBBTN  aBtns[ 2 ] PROMPT "&Prev" OF oDlg SIZE 20, 15 ;
            GROUPBUTTON  CENTER ;
            ROUND ROUNDSIZE 2;
            ACTION( oQry:PrevPage(), ;
            ChangeTitle( oQry, oDlg ),;
            nSelected := ChangeBtnStatus( aBtns, oQry, --nSelected ) )
            
   @ 10, 50 RBBTN aBtns[ 3 ] PROMPT "&1" OF oDlg SIZE 20, 15 ;
         GROUPBUTTON  CENTER ;
         ROUND ROUNDSIZE 2;
         ACTION( oQry:GotoPage( oQry:nCurrentPage - ( nSelected - 3 ) ),;
         ChangeTitle( oQry, oDlg ),;
         nSelected := ChangeBtnStatus( aBtns, oQry, 3 ) )

   @ 10, 70 RBBTN aBtns[ 4 ] PROMPT "&2" OF oDlg SIZE 20, 15 ;
         GROUPBUTTON  CENTER ;
         ROUND ROUNDSIZE 2;
         ACTION( oQry:GotoPage( oQry:nCurrentPage - ( nSelected - 3 ) + 1 ),;
         ChangeTitle( oQry, oDlg ),;
         nSelected := ChangeBtnStatus( aBtns, oQry, 4 ) )

   @ 10, 90 RBBTN aBtns[ 5 ] PROMPT "&3" OF oDlg SIZE 20, 15 ;
         GROUPBUTTON  CENTER ;
         ROUND ROUNDSIZE 2;
         ACTION( oQry:GotoPage( oQry:nCurrentPage - ( nSelected - 3 ) + 2 ),;
         ChangeTitle( oQry, oDlg ),;
         nSelected := ChangeBtnStatus( aBtns, oQry, 5 ) )

   @ 10, 110 RBBTN aBtns[ 6 ] PROMPT "&4" OF oDlg SIZE 20, 15 ;
         GROUPBUTTON  CENTER ;
         ROUND ROUNDSIZE 2;
         ACTION( oQry:GotoPage( oQry:nCurrentPage - ( nSelected - 3 ) + 3 ),;
         ChangeTitle( oQry, oDlg ),;
         nSelected := ChangeBtnStatus( aBtns, oQry, 6 ) )

   @ 10, 130 RBBTN aBtns[ 7 ] PROMPT "&5" OF oDlg SIZE 20, 15 ;
         GROUPBUTTON  CENTER ;
         ROUND ROUNDSIZE 2;
         ACTION( oQry:GotoPage( oQry:nCurrentPage - ( nSelected - 3 ) + 4 ),;
         ChangeTitle( oQry, oDlg ),;
         nSelected := ChangeBtnStatus( aBtns, oQry, 7 ) )

   @ 10, 150 RBBTN aBtns[ 8 ] PROMPT "&6" OF oDlg SIZE 20, 15 ;
         GROUPBUTTON  CENTER ;
         ROUND ROUNDSIZE 2;
         ACTION( oQry:GotoPage( oQry:nCurrentPage - ( nSelected - 3 ) + 5),;
         ChangeTitle( oQry, oDlg ),;
         nSelected := ChangeBtnStatus( aBtns, oQry, 8 ) )

   @ 10, 170 RBBTN aBtns[ 9 ] PROMPT "&7" OF oDlg SIZE 20, 15 ;
         GROUPBUTTON  CENTER ;
         ROUND ROUNDSIZE 2;
         ACTION( oQry:GotoPage( oQry:nCurrentPage - ( nSelected - 3 ) + 6 ),;
         nSelected := ChangeBtnStatus( aBtns, oQry, 9 ) )

   @ 10, 190 RBBTN aBtns[ 10 ] PROMPT "&8" OF oDlg SIZE 20, 15 ;
         GROUPBUTTON  CENTER ;
         ROUND ROUNDSIZE 2;
         ACTION( oQry:GotoPage( oQry:nCurrentPage - ( nSelected - 3 ) + 7),;
         ChangeTitle( oQry, oDlg ),;
         nSelected := ChangeBtnStatus( aBtns, oQry, 10 ) )

   @ 10, 210 RBBTN aBtns[ 11 ] PROMPT "&9" OF oDlg SIZE 20, 15 ;
         GROUPBUTTON  CENTER ;
         ROUND ROUNDSIZE 2;
         ACTION( oQry:GotoPage( oQry:nCurrentPage - ( nSelected - 3 ) + 8 ),;
         ChangeTitle( oQry, oDlg ),;
         nSelected := ChangeBtnStatus( aBtns, oQry, 11 ) )

   @ 10, 230 RBBTN aBtns[ 12 ] PROMPT "&Next" OF oDlg SIZE 20, 15 ;
         GROUPBUTTON  CENTER ;
         ROUND ROUNDSIZE 2;
         ACTION( oQry:NextPage(), ;
                 ChangeTitle( oQry, oDlg ),;
                 nSelected := ChangeBtnStatus( aBtns, oQry, ++nSelected ) )

   @ 10, 250 RBBTN aBtns[ 13 ] PROMPT "&Last" OF oDlg SIZE 20, 15 ;
         GROUPBUTTON END  CENTER ;
         ROUND ROUNDSIZE 2



   aBtns[ nSelected ]:lSelected = .T.

RETURN 

PROCEDURE ChangeTitle( oQry, oDlg )

   oDlg:cTitle = "Current Page: " + StrZero( oQry:nCurrentPage, 5 ) + " / " + StrZero( oQry:nMaxPages, 5 )
   
RETURN

FUNCTION ChangeBtnStatus( aBtns, oQry, nSelected )

   LOCAL nAt, nNewAt
   
   nAt = AScan( aBtns, {| o | o:lSelected } ) 
   
   nSelected = Min( Max( 3, nSelected ), 11 ) 

   IF nAt != nNewAt
      aBtns[ nAt ]:lSelected := .F.
      aBtns[ nAt ]:Refresh()    
      aBtns[ nSelected ]:lSelected := .T.
      aBtns[ nSelected ]:Refresh()
   ENDIF
         

RETURN nSelected


#include "connto.prg"
   
