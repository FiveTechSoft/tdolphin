//#include "hbcompat.ch"
#include "tdolphin.ch"

#define CONNECT1 1
#define CONNECT2 2

PROCEDURE Main()
   LOCAL aServer := Array( 2 ), aQuery := Array( 2 ), n
   LOCAL aColumns := {}, aValues := {}

   IF ( aServer := ConnectTo2() ) == NIL
      RETURN 
   ENDIF   
   

   SELECTDB "dolphin_man" OF aServer[ CONNECT1 ]
   
   //we already selected CONNECT2, was last connection opened
   SELECTDB "tdolphin_test" 
   
   DEFINE QUERY aQuery[ CONNECT1 ] "SELECT * FROM testman LIMIT 5" OF "CONNECT1"
   
   //we already selected CONNECT2, was last connection opened
   DEFINE QUERY aQuery[ CONNECT2 ] "SELECT * FROM testman"
   aQuery[ CONNECT2 ]:Zap()
   
   AEval( aQuery[ CONNECT1 ]:aStructure, {| aRow | AAdd( aColumns, aRow[ MYSQL_FS_NAME ] ) } )
   
   BEGINMYSQL     
   DO WHILE ! aQuery[ CONNECT1 ]:Eof()
      FOR n = 1 TO Len( aQuery[ CONNECT1 ]:aStructure )
         AAdd( aValues, aQuery[ CONNECT1 ]:FieldGet( n ) )
      NEXT 
      
      //we already selected CONNECT2, was last connection opened
      INSERTMYSQL TO aQuery[ CONNECT1 ]:aTables[ 1 ] COLUMNS aColumns VALUES aValues
      aValues = {}
      ? aQuery[ CONNECT1 ]:nRecNo
      aQuery[ CONNECT1 ]:Skip() 
   ENDDO     
   
   //ROLLBACKMYSQL
   COMMITMYSQL
   
   ? "END"
   ?
   CLOSEMYSQL ALL
   
RETURN

#include "connto.prg"