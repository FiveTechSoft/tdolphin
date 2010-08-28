#include "hbcompat.ch"
#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   local oServer
   local cTime := time()
   local lCancel
   
   SET CENTURY ON
   SET DATE FORMAT "dd/mm/yyyy"   
      
   //Activated Case sensitive
   SET CASESENSITIVE ON
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN 
   ENDIF
   cls
   RESTOREMYSQL FILE "bcktest2.txt" ;
                ON RESTORE OnRestore( nStatus, cTable, nTotLine, nIdx )
                
   ? "finished, Time " + elaptime( cTime, time() )
   ?
   oServer:end()
   inkey(5)

RETURN 

PROCEDURE OnRestore( nStatus, cTable, nTotLine, nIdx  )

   SWITCH nStatus
      CASE ST_STARTRESTORE
         @ 1,1 say  "Restore started"
         EXIT 
      CASE ST_LOADING
         @ 2,1 say  "Loading... " 
         EXIT 
      CASE ST_RESTORING
         @ 3,1 say  "Restoring...: " + Strzero( nIdx, 7 ) + "/" + Strzero( nTotLine, 7 )
         EXIT       
      CASE ST_ENDBACKUP
         @ 4,1 say  "Restore finished"
   ENDSWITCH 

RETURN
      
#include "connto.prg"