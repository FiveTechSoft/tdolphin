#include "tdolphin.ch"
#include "hbcompat.ch"


FUNCTION Main()
  
   LOCAL oServer, oDlg, oQry, oBrw
   LOCAL cTime
  
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   ? "Query Loading"
   oQry = oServer:Query( "SELECT * FROM clientes ORDER BY first, last " )
   ? "Query Loaded"
   ? "Seeking Vincent, Brook ..."
   ?"Using Locate"
   cTime = Time()
   ? "found:", oQry:Locate( { "Vincent", "Brook" }, {"first", "last" } ) , "Time " + ElapTime( cTime, Time() )
   ?"Using Find"
   cTime = Time()
   ? "found:", oQry:Find( { "Vincent", "Brook" }, {"first", "last" } ), "Time " + ElapTime( cTime, Time() )
   ?
   
   
RETURN NIL

#include "connto.prg"

