//#include "hbcompat.ch"
#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL oServer   := NIL
   
   LOCAL oQry
   
   LOCAL oWnd, oBrw
   
   LOCAL cTime 

   IF ( oServer := ConnectTo() ) == NIL
      RETURN 
   ENDIF   

   
   cTime := time()
   oServer:bOnRestore = {| nStatus, cTable, nTotLine, nIdx | OnRestore( nStatus, cTable, nTotLine, nIdx ) }
   oServer:Restore( "bcktest.txt" )
   ? "finished, Time " + elaptime( cTime, time() )
   ?
   oServer:end()
   inkey(5)

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
      
         
#include "connto.prg"      