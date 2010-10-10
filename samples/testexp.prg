#include "hbcompat.ch"
#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

FUNCTION Main()
  
   LOCAL oServer, oDlg, oQry, oBrw
   LOCAL oExp
   LOCAL cHead := "Testing Dolphin Export to TEXT" + CRLF
   LOCAL cEnd  := "End Of File -> Dolphin export testing" + CRLF
  
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   cls
   oQry = oServer:Query( "SELECT first, last FROM clientes limit 100" )
   
   oExp = oQry:Export( EXP_TEXT, "client.txt" )
   
   oExp:bOnStart = {| o | FWrite( o:hFile, Replicate( "=", Len( cHead ) ) + CRLF, Len( cHead ) + 1 ),;
                          FWrite( o:hFile, cHead, Len( cHead ) ),;
                          FWrite( o:hFile, Replicate( "=", Len( cHead ) ) + CRLF , Len( cHead ) + 1 ) }
   oExp:bOnRow = {| o, n, cText| ShowLine( o, n, cText, oQry:LastRec() ) }

   oExp:bOnEnd = {| o | FWrite( o:hFile, Replicate( "=", Len( cEnd ) ) + CRLF, Len( cEnd ) + 1 ),;
                        FWrite( o:hFile, cEnd, Len( cEnd ) ) }

   
   oExp:Start()
   ?
   
RETURN NIL

PROCEDURE ShowLine( o, n, cText, nTotal )

   @ 1,1 say Str( n / nTotal * 100 ) + "%"
   IF n = 1
      FWrite( o:hFile, Replicate( "=", 32 ) + CRLF, 33 )
   ENDIF


RETURN

#include "connto.prg"
