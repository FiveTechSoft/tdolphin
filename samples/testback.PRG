#include "hbcompat.ch"
#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL hIni      := HB_ReadIni( ".\connect.ini" )
   LOCAL oServer   := NIL
   LOCAL cServer   := hIni["mysql"]["host"],;
         cUser     := hIni["mysql"]["user"],;
         cPassword := hIni["mysql"]["psw"],;
         nPort     := val(hIni["mysql"]["port"]), ;
         cDBName   := hIni["mysql"]["dbname"], ;
         nFlags    := val(hIni["mysql"]["flags"])
   LOCAL cText := ""

   LOCAL aPriv, aRow, uItem
   
   oServer = TDolphinSrv():New( cServer, ;
                                cUser, ;
                                cPassword, ;
                                nPort, nFlags, "test03",;
                                {| oServer, nError, lInternal | GetError( oServer, nError, lInternal  ) } )

   IF ! oServer:lError 
      oServer:bOnbackup = {| nStatus, cTable, nTotTable, nCurrTable | OnBackup( nStatus, cTable, nTotTable, nCurrTable  ) }
      oServer:Backup( { "testman" }, "bcktest.txt", .T., .T., 500, "Custom header backup process", "Custom footer backup process" )  
      ? 
   ENDIF 

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
      
         
      