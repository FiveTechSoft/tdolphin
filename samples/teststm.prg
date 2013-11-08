#include "hbcompat.ch" // is necesary form compatibility with xharbour
#include "tdolphin.ch"


PROCEDURE Main()

   LOCAL oServer, aRow, uItem
   LOCAL cQuery, oQry, oErr
   LOCAL aTables, aColumns, cWhere, cOrder
   
   //Activated Case sensitive
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN
   ENDIF

   cQuery = "UPDATE customer SET first=&nombre WHERE id=&id"

   oServer:Execute( cQuery, {"nombre" => "'daniel'", "id" => "1"})
   inkey(180)

   oServer:End()   


RETURN   	           

#include "connto.prg"
