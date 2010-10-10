#include "tdolphin.ch"
#include "hbcompat.ch"
#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL oServer   := NIL
   LOCAL cDBName
   LOCAL cText := ""
   

   D_SetCaseSensitive( .T. )   
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN
   ENDIF
   
   cDBName = oServer:cDBName
   ListDBs( oServer )
   ? "Data Base: "+ cDBName +" is: " + IsExistDB( oServer, cDBName )
   ? "Data Base: test02 is: " + IsExistDB( oServer, "test02" )
   ?
   oServer:SelectDB( cDBName )
   ListTables( oServer )
   ? "Table: test is: " + IsExistTB( oServer, "test" )
   ? "Table: test02 is: " + IsExistTB( oServer, "test02" )
   ?

   oServer:End()
   inkey(5)

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

#include "connto.prg"
   