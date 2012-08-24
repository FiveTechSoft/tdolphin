/*
 * $Id: 20-Jul-10 3:30:59 PM testupd.PRG Z dgarciagil $
 */

//#include "hbcompat.ch"
#include "tdolphin.ch"


FUNCTION Main() 

   LOCAL oServer
   LOCAL oQry
   LOCAL aFields
   LOCAL c
   
   SET CENTURY ON
   SET DATE FORMAT "dd/mm/yyyy"   
      
   //Activated Case sensitive
   D_SetCaseSensitive( .T. )

   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   
   oQry = oServer:Query( "SELECT * FROM clientes LIMIT 100" )
   
   oQry:notes = time()
   
   if ! oQry:IsEqual( "notes" )
      ? "Not Equal, will save"
      oQry:Save()
   endif
   
   oQry:notes = time()
   oQry:married = ! oQry:married
   oQry:Salary = 10
   
   aFields = oQry:GetFieldsModified()
   
   FOR EACH c IN aFields
      ? "Modfied " + c
   NEXT 
   
   if Len( aFields ) > 0 
      ? "some fields was modified, will save"
      oQry:Save()
   endif
   
   oServer:End()
   
RETURN NIL

PROCEDURE Updates( oServer, nOpc, nRecords, aOpc )

   LOCAL oQry 
   LOCAL aColumns
   LOCAL aValues
   LOCAL cWhere
   LOCAL cTime := Time()
   LOCAL cQry, cField, n, cValue
   
   oQry = oServer:Query( "SELECT * FROM clientes LIMIT " + Str( nRecords ) )

   aColumns = { "married", "age", "salary", "notes" }
   
   DO WHILE ! oQry:Eof()
      aValues = { .f., 40, 10, oQry:Notes }
      
      cWhere = "notes='" + oQry:Notes + "'"
      
      @ 2,1 SAY cWhere
      @ 3,1 SAY  "Process Time: " + ElapTime( cTime, time() )
      
      SWITCH nOpc
         CASE 1
           oServer:Update( "clientes", aColumns, aValues, cWhere )      
           EXIT 
         CASE 2 
            cQry = "UPDATE clientes SET "
            FOR EACH cField IN aColumns
#ifdef __XHARBOUR__
               n = HB_EnumIndex()
#else                      
               n = cField:__EnumIndex() 
#endif 
               cValue   = ClipValue2SQL( aValues[ n ] )
               cQry += cField + " = " + cValue + ","
            NEXT             
            //Delete last comma 
            cQry = SubStr( cQry, 1, Len( cQry ) - 1 ) 
            cQry += " WHERE " + cWhere
            oServer:SqlQuery( cQry )       
            EXIT 
         CASE 3
            oQry:married = .T.
            oQry:age = 30 
            oQry:salary = 20
            oQry:Save()
            EXIT
         CASE 4
            cQry = "update clientes set "
            cQry += "married = 0,"
            cQry += "age = 40,"
            cQry += "salary = 10"
            cQry += " where " + cWhere
            oServer:SqlQuery( cQry )
      ENDSWITCH
      oQry:Skip() 
   END
   @ 4,1 SAY  "Opcion: " + aOpc[ nOpc ]
   ? 
   
   
RETURN 
   
//--------------------------------------//

#include "connto.prg"