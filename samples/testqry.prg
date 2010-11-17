//#include "hbcompat.ch" // is necesary form compatibility with xharbour
#include "tdolphin.ch"


PROCEDURE Main()
   local oServer, oQry, aTables, aColumns, cQry, lError := .F.
   local aQuery := Array( 12 ) 
   
   D_SetCaseSensitive( .T. )
 
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   
   aTables = { "test", "testman" }
   aColumns = {"ID", "NAME", "LAST" }
   
   aQuery[ 1 ] = "SELECT * FROM test"
   aQuery[ 2 ] = "SELECT ID, NAME, LAST FROM test"
   aQuery[ 3 ] = "SELECT ID, NAME AS USER, LAST FROM test1"
   aQuery[ 4 ] = "SELECT test.ID, testman.NAME, testman.LAST FROM test, testman WHERE test.ID = testman.ID"
   aQuery[ 5 ] = "SELECT ID, NAME AS USER, LAST FROM test LIMIT 100"
   aQuery[ 6 ] = "SELECT ID, NAME AS USER, LAST FROM test ORDER BY NAME DESC LIMIT 100"
   
   
   //BuildQuery( aColumns, aTables, cWhere, cGroup, cHaving, cOrder, cLimit, cExt, lWithRoll )
   //"SELECT * FROM test"
   aQuery[ 7 ] = BuildQuery( {"*"}, {"test"} ) 
   
   //"SELECT ID, NAME, LAST FROM test"
   aQuery[ 8 ] = BuildQuery( aColumns, {aTables[ 1 ]} ) 
   
   //"SELECT ID, NAME AS USER, LAST FROM test1"
   aQuery[ 9 ] = BuildQuery( { "ID", "NAME AS USER", "LAST" }, {aTables[ 1 ]} ) 
   
   //"SELECT test.ID, testman.NAME, testman.LAST FROM test, testman WHERE test.ID = testman.ID"
   aQuery[ 10 ] = BuildQuery( {"test.ID", "testman.NAME", "testman.LAST"}, aTables, "test.ID = testman.ID" )
   
   //"SELECT ID, NAME, LAST FROM test LIMIT 100"
   aQuery[ 11 ] = BuildQuery( aColumns, {aTables[ 1 ]}, , , , , "100" ) 
   
   //"SELECT ID, NAME, LAST FROM test ORDER BY NAME DESC LIMIT 100"
   aQuery[ 12 ] = BuildQuery( aColumns, {aTables[ 1 ]}, , , , "NAME DESC", "100" ) 
   
   
   FOR EACH cQry IN aQuery
      TRY 
         // we can use
         // oQry = oServer:Query( cQry )
         oQry = TDolphinQry():New( cQry, oServer )
      CATCH oErr 
         ? "[N]", cQry
         ? 
         ATail( oServer:aQueries ):End()
         ? oErr:Description
         ?
         lError = .T.         
      END
      IF ! lError
         ? "[Y]", oQry:cQuery
         oQry:End()
      ENDIF
      lError = .F.
   NEXT
   ?

RETURN

#include "connto.prg"