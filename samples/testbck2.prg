//#include "hbcompat.ch"
#include "tdolphin.ch"
#include "fileio.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   local oServer
   local cTime
   local lCancel := .F., oQry
   local h
   local cFile := "miprueba.txt"
   
   SET CENTURY ON
   SET DATE FORMAT "dd/mm/yyyy"   
      
   //Activated Case sensitive
   SET CASESENSITIVE ON
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN 
   ENDIF
   
   cTime := time()
   cls
   
   BACKUPMYSQL TABLES "president", "clientes";
               FILE "bcktest2.txt";
               OF oServer ;
               DROP OVERWRITE;
               STEP 5000 ;
               HEADER "Custom header backup process";
               FOOTER "Custom footer backup process";
               CANCEL lCancel;
               ON BACKUP OnBackup( nStatus, cTabFile, nTotTable, nCurrTable, nRecNo, oServer )
/*
   //? oServer:hMySql
   FClose( FCreate( cFile ) )
   h := FOpen( cFile, FO_WRITE ) 
   MyBackUp( oServer:hMySql, h, "SELECT * FROM president")
   FClose( h )
   //oQry := oServer:Query( "SELECT * FROM cadena" )
   //? oQry:RecCount()
   */
   ? "finished, Time " + elaptime( cTime, time() )
   ?
   oServer:end()
   inkey(5)

RETURN 

PROCEDURE OnBackup( nStatus, cTable, nTotTable, nCurrTable, nRecNo, oServer, lCancel  )

   local nRow 
   
   @ 6, 1 say nStatus
   SWITCH nStatus
      CASE ST_STARTBACKUP
         @ 1,1 say "Backup started"
         EXIT 
      CASE ST_LOADINGTABLE
         @ 2, 1 say "Backup Table: " + cTable 
         EXIT 
      CASE ST_FILLBACKUP

 //        nRow := oServer:GetRowsFromTable( cTable )
         @ 4, 1 say "Press ESC to cancel process" 
         @ 5, 1 say "Record Processed: " + Strzero( nRecNo, 7 ) //+ "/" + Strzero( nRow, 7 )
         INKEY( 0.1 )
         lCancel = LastKey() == 27 
         @ 7, 1 say lCancel
         EXIT 
         
      CASE ST_ENDBACKUP
         @ 6, 1 say "Backup finished"
   ENDSWITCH 

RETURN lCancel

#include "connto.prg"      
         