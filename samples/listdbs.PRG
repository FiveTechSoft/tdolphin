#include "hbcompat.ch"
#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL oServer
   LOCAL cServer := "localhost",;
         cUser   := "testing",;
         cPassword := "123456",;
         nPort   := 3306
   LOCAL cText := ""
   
   oServer = TDolphinSrv():New( cServer, ;
                                cUser, ;
                                cPassword, ;
                                nPort, , ;
                                {| oServer, nError, lInternal | GetError( oServer, nError, lInternal  ) } )
   
   IF ! oServer:lError 
      ListDBs( oServer )
      ? "Data Base: test01 is: " + IsExistDB( oServer, "test01" )
      ? "Data Base: test02 is: " + IsExistDB( oServer, "test02" )
      ?
      oServer:SelectDB( "test01" )
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
   