#include "tdolphin.ch"


FUNCTION Main() 

   LOCAL oServer, oQry

   D_SetCaseSensitive( .T. )
   Set_MyLang( "esp" )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   
   oQry = oServer:Query( "select * from president; select * from student" )

   DolphinBrw( oQry, "President" )
   
   oQry:LoadNextQuery( )
   
   DolphinBrw( oQry, "Student" )
         
   oQry = NIL
   
   oServer:End()
   
RETURN NIL


#include "connto.prg"
#include "brw.prg"