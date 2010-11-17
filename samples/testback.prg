//#include "hbcompat.ch"
#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   local oServer
   local cTime
   
   SET CENTURY ON
   SET DATE FORMAT "dd/mm/yyyy"   
      
   //Activated Case sensitive
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN 
   ENDIF
   
   cTime := time()
   oServer:bOnbackup = {| nStatus, cTable, nTotTable, nCurrTable | OnBackup( nStatus, cTable, nTotTable, nCurrTable  ) }
   oServer:Backup( { "testman" }, "bcktest.txt", .T., .T., 500, "Custom header backup process", "Custom footer backup process" )  
   ? "finished, Time " + elaptime( cTime, time() )
   ?
   oServer:end()
   inkey(5)

RETURN 

PROCEDURE OnBackup( nStatus, cTable, nTotTable, nCurrTable  )

   SWITCH nStatus
      CASE ST_STARTBACKUP
         ? "Backup started"
         EXIT 
      CASE ST_LOADINGTABLE
         ? "Backup Table: " + cTable 
         EXIT 
      CASE ST_ENDBACKUP
         ? "Backup finished"
   ENDSWITCH 

RETURN

#include "connto.prg"      
         
      