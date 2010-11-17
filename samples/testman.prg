//#include "hbcompat.ch"
#include "tdolphin.ch"

FUNCTION Main() 

   LOCAL cTime :=  time()
   LOCAL oServer   
   
   SET CENTURY ON
   SET DATE FORMAT "dd/mm/yyyy"   
      
   //Activated Case sensitive
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   
   DoInsert( oServer )

   ? "Test with DOLPHIN is finished!!!"
   ? "Process Time: " + ElapTime( cTime, time() )
   ? 
   Inkey(5)
   
   oServer:End()
   
RETURN NIL


PROCEDURE DoInsert( oServer )

   LOCAL n := 1
   LOCAL cQry
   ?
    oServer:SQLQuery( "DELETE FROM testman" )
   FOR n = 1 TO 500
       cQry = "INSERT INTO testman SET " + ;
              " NAME='NAME" + StrZero( n, 4 ) + "'" +;
              ",LAST='LAST" + StrZero( n, 4 ) + "'" +;
              ",BIRTH='" + StrZero( Year( Date() ), 4 ) + "-" + StrZero( Month( Date() ), 2 )  + "-" + StrZero( Day( Date() ), 2 ) +"'" +;
              ",ACTIVE=1" 
       ? cQry    
       
       oServer:SQLQuery( cQry )
          
   NEXT
   ? "Finished Insert 500 items"
   ?
   
RETURN

#include "connto.prg"
