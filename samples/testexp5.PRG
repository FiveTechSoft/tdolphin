#include "hbcompat.ch"
#include "tdolphin.ch"

#ifndef __XHARBOUR__
#xtranslate CurDrive() => hb_CurDrive()
#endif

FUNCTION Main()
  
   LOCAL oServer, oDlg, oQry, oBrw
   LOCAL oExp
  
   D_SetCaseSensitive( .T. )
   SET DATE FORMAT "dd/mm/yyyy"
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   cls
   oQry = oServer:Query( "SELECT FIRST, LAST, HIREDATE, STREET, CITY FROM clientes limit 20" )
   oExp = oQry:Export( EXP_WORD, CurDrive() + ":\" + CurDir() + "\client", , { "@!", "@!", "DD/MM/YY"} )
   
   oExp:bOnRow = {| o, n| ShowLine( n, oQry:LastRec() ) }
   
   oExp:Start()
   ?
   
RETURN NIL


PROCEDURE ShowLine( n, nTotal )

@ 1,1 say Str( n / nTotal * 100 ) + "%"

RETURN

#include "connto.prg"
