#include "hbcompat.ch"
#include "tdolphin.ch"

#define CONNECT1 1
#define CONNECT2 2

PROCEDURE Main()
   
   LOCAL hIni      := HB_ReadIni( ".\connect.ini" )
   LOCAL aServer   := {NIL, NIL}
   LOCAL aHost     := { hIni["mysql"]["host"], hIni["mysql2"]["host"] } ,;
         aUser     := { hIni["mysql"]["user"], hIni["mysql2"]["user"] },;
         aPassword := { hIni["mysql"]["psw"],  hIni["mysql2"]["psw"] },;
         aPort     := { val(hIni["mysql"]["port"]), val(hIni["mysql2"]["port"])}, ;
         aDBName   := { hIni["mysql"]["dbname"], hIni["mysql2"]["dbname"] },;
         aFlags    := { val(hIni["mysql"]["flags"]), val(hIni["mysql2"]["flags"])}
   LOCAL oError
   LOCAL aQuery    := {NIL, NIL}
   LOCAL aColumns  := {}, aValues :=  {}, n




   TRY 

      CONNECT aServer[ CONNECT1 ] HOST aHost[  CONNECT1 ] ;
                      USER aUser[  CONNECT1 ] ;
                      PASSWORD aPassword[  CONNECT1 ] ;
                      PORT aPort[  CONNECT1 ] ;
                      FLAGS aFlags[  CONNECT1 ];
                      NAME "CONNECT1"
   
      CONNECT aServer[ CONNECT2 ] HOST aHost[  CONNECT2 ] ;
                      USER aUser[  CONNECT2 ] ;
                      PASSWORD aPassword[  CONNECT2 ] ;
                      PORT aPort[  CONNECT2 ] ;
                      FLAGS aFlags[  CONNECT2 ];
                      NAME "CONNECT2"
                          
    CATCH oError
       IF aServer[ CONNECT1 ] != NIL 
         aServer[ CONNECT1 ]:End()
       ENDIF
       return
    END  

     SELECTDB "dolphin_man" OF aServer[ CONNECT1 ]
     
     //we already selected CONNECT2, was last connection opened
     SELECTDB "tdolphin_test" 
     
     DEFINE QUERY aQuery[ CONNECT1 ] "SELECT * FROM testman LIMIT 10" OF "CONNECT1"
     
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
