/*
 * $Id: 20-Jul-10 3:30:59 PM testupd.PRG Z dgarciagil $
 */

//#include "hbcompat.ch"
#include "tdolphin.ch"


FUNCTION Main() 

   LOCAL oServer
   LOCAL aOpc := { "Method Update", "Build Sentence", "Method Save", "Sentence UPDATE" }, nOpc, nRecords := 100
   LOCAL GetList := {}
   
   SET CENTURY ON
   SET DATE FORMAT "dd/mm/yyyy"   
      
   //Activated Case sensitive
   D_SetCaseSensitive( .T. )
   
   CLS 
   DispBox( 1, 1, Len( aOpc ) + 2, 31 )
   nOpc = AChoice( 2, 2, Len( aOpc ) + 1, 30, aOpc )
   CLS
   
   IF LastKey() == 27
      CLS
      RETURN NIL
   ENDIF
   @ 1,1 SAY "How many records?" GET nRecords PICTURE "999"
   READ
    
   IF LastKey() == 27
      CLS
      RETURN NIL
   ENDIF
       
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   
   Updates( oServer, nOpc, nRecords, aOpc )

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