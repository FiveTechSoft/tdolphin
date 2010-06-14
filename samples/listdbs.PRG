#include "hbcompat.ch"
#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL oServer
   LOCAL hIni      := HB_ReadIni( ".\connect.ini" )
   LOCAL oServer   := NIL
   LOCAL cServer   := hIni["mysql"]["host"],;
         cUser     := hIni["mysql"]["user"],;
         cPassword := hIni["mysql"]["psw"],;
         nPort     := val(hIni["mysql"]["port"]), ;
         cDBName   := hIni["mysql"]["dbname"], ;
         nFlags    := val(hIni["mysql"]["flags"])
   LOCAL cText := ""
   
   oServer = TDolphinSrv():New( cServer, ;
                                cUser, ;
                                cPassword, ;
                                nPort, nFlags, ;
                                {| oServer, nError, lInternal | GetError( oServer, nError, lInternal  ) } )
   
   IF ! oServer:lError 
      ListDBs( oServer )
      ? "Data Base: "+ cDBName +" is: " + IsExistDB( oServer, cDBName )
      ? "Data Base: test02 is: " + IsExistDB( oServer, "test02" )
      ?
      oServer:SelectDB( cDBName )
      ListTables( oServer )
      ? "Table: test is: " + IsExistTB( oServer, "test" )
      ? "Table: test02 is: " + IsExistTB( oServer, "test02" )
      ?
   ENDIF
   
   oServer:End()
   

RETURN

FUNCTION IsExistDB( oServer, cDB )
RETURN  If( oServer:DBExist( cDB ), "Valid", "Invalid" )

FUNCTION IsExistTB( oServer, cTable )
RETURN  If( oServer:TableExist( cTable ), "Valid", "Invalid" )


PROCEDURE ListDBs( oServer )

   LOCAL aList
   LOCAL n
   
   aList = oServer:ListDBs()
   
   ? "Total Data Bases" + Str( Len( aList ) )
   
   FOR n = 1 TO Len( aList )
      ? aList[ n ]
   NEXT
   ? "================="
   
   aList = oServer:ListDBs( "t%" )
   
   ? "Wild: t%" 
   ? "Total Data Bases" + Str( Len( aList ) )
   
   FOR n = 1 TO Len( aList )
      ? aList[ n ]
   NEXT
   ?
   

RETURN 

PROCEDURE ListTables( oServer )

   LOCAL aList
   LOCAL n
   
   aList = oServer:ListTables()
   
   ? "Total Tables" + Str( Len( aList ) )
   
   FOR n = 1 TO Len( aList )
      ? aList[ n ]
   NEXT
   ? "================="
   
   aList = oServer:ListTables( "a%" )
   
   ? "Wild: a%" 
   ? "Total Tables" + Str( Len( aList ) )
   
   FOR n = 1 TO Len( aList )
      ? aList[ n ]
   NEXT
   ?
   

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
   