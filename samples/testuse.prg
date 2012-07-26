//#include "hbcompat.ch"
#include "tdolphin.ch"
#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL oServer   := NIL
   LOCAL cText := ""
   LOCAL oQry 
   LOCAL aDatas := {}
   LOCAL hResult, row
   LOCAL aStructure
   LOCAL nLimite := 1000
   LOCAL n := 0
   LOCAL aFields := {}
   LOCAL cTime
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN 
   ENDIF
   IF ( oServer2 := ConnectTo() ) == NIL
      RETURN 
   ENDIF
   
   IF ! oServer:lError 
      cText += "Connection OK" + CRLF
      cText += "Host: " + oServer:cHost +CRLF
      cText += "Database: " +oServer:cDBName + CRLF     
      ? cText + CRLF
      cText = "SELECT * FROM clientes LIMIT 1000"
      oServer:Execute( "truncate table clientes_copy2" )
      cTime = time()
      IF mysqlquery( oServer:hMySql, cText, Len( cText ) ) == 0
         hResult = mysqluseresult( oServer:hMySql )
         aStructure = MySqlResultStructure( hResult, D_SetCaseSensitive(), D_LogicalValue() ) 
         for each row in aStructure
            AAdd( aFields, row[ MYSQL_FS_NAME ] )
         next
         hb_ADel( aFields, 1, .T. )                   
         DO WHILE .t.
            aRow = mysqlfetchrow( hResult )
            aRow = hb_ADel( aRow, 1, .T. ) 
            IF Len( aRow ) == 0 
            	exit 
            ELSE 
            	AAdd( aDatas, aRow )
            	n++
            	IF n == nLimite
            	   n = 0
            	   oServer2:Insert( "clientes_copy2", aFields, aDatas )
            	   aDatas = {}
            	ENDIF
            ENDIF            
         ENDDO
         IF n != nLimite .AND. n > 0
            oServer:Insert( "clientes_copy2", aFields, aDatas )
         ENDIF            		         
         ? "termino en: " + ElapTime( cTime, time() ) 
      ENDIF
   ENDIF

   oServer:End()

RETURN

#include "connto.prg"
