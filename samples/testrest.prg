#include "hbcompat.ch"
#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL oServer   := NIL
   
   LOCAL cServer   := "dolphintest.sitasoft.net",;
         cUser     := "test_dolphin",;
         cPassword := "123456",;
         nPort     := 3306, ;
         cDBName   := "dolphin_man", ;
         nFlags    := 0
   LOCAL oQry
   
   LOCAL oWnd, oBrw
   
   LOCAL cTime 
   
   oServer = TDolphinSrv():New( cServer, ;
                                cUser, ;
                                cPassword, ;
                                nPort, nFlags, cDBName,;
                                {| oServer, nError, lInternal | GetError( oServer, nError, lInternal  ) } )
   

   IF ! oServer:lError 
      cTime := time()
      oServer:bOnRestore = {| nStatus, cTable, nTotLine, nIdx | OnRestore( nStatus, cTable, nTotLine, nIdx ) }
      oServer:Restore( "bcktest.txt" )
      ? "finished, Time " + elaptime( cTime, time() )
   ENDIF 
   ?
   oServer:end()
   inkey(5)

RETURN 

PROCEDURE GetError( oServer, nError, lInternal )
   LOCAL cText := ""
   
   cText += "Error from Custom Error Message" + CRLF
   cText += "================================" + CRLF
   cText += oServer:ErrorTxt() + CRLF
   cText += "ERROR No: " + Str( nError ) + CRLF
   cText += "Internal: " + If( lInternal, "Yes", "No" ) + CRLF
   
   ? cText + CRLF
   
   
RETURN

PROCEDURE OnRestore( nStatus, cTable, nTotLine, nIdx  )

   SWITCH nStatus
      CASE ST_STARTRESTORE
         ? "Restore started"
         EXIT 
      CASE ST_LOADING
         ? "Loading... " 
         EXIT 
      CASE ST_RESTORING
         ? "Restoring...: " + cTable 
         EXIT       
      CASE ST_ENDBACKUP
         ? "Restore finished"
   ENDSWITCH 

RETURN
      
         
      