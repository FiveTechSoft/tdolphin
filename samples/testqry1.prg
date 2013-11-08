/*
 * este ejemplo mueastra como obtener informacion ed un query
 * ---
 * This sample show ho get query datas
 */

//#include "hbcompat.ch" // is necesary form compatibility with xharbour
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
   /*
   cQuery  = "select student.name, grade_event.date, score.score, grade_event.category"
   cQuery += "from grade_event, score, student where grade_event.date = " + ClipValue2SQL( CToD( '09-23-2008' ) ) + " and "
   cQuery += "grade_event.event_id = score.event_id and score.student_id = student.student_id"
   */
   
   // define query tables
   aTables  = { "grade_event", "score", "student" }
   
   //define query columns (from)
   aColumns = { "student.student_id", "student.name", "grade_event.date", "score.score", "grade_event.category"}
   
   //define where
   cWhere   = "grade_event.date = " + ClipValue2SQL( CToD( '09-23-2008' ) ) + " and "
   cWhere  += "grade_event.event_id = score.event_id and score.student_id = student.student_id"
   
   //let Dolphin build query by us, remmenber can build the query your self
   cQuery = BuildQuery( aColumns, aTables, cWhere )
   ? cQuery
   
   //build query object
   oQry = TDolphinQry():New( cQuery, oServer )
   
   ? "NAME      TABLE     DEFAULT   TYPE      LENGTH    MAXLENGTH FLAGS     DECIMAL CLIP TYPE"
   ? "======================================================================================="
   ?
   FOR EACH aRow IN oQry:aStructure
     FOR EACH uItem IN aRow
        ?? If( ValType( uItem ) == "N", PadR( AllTrim( Str( uItem ) ), 10 ), PadR( uItem, 11 ) )
     NEXT 
     ? 
   NEXT  
   ? "======================================================================================="
      
   ?

   //Retrieve cWhere
   ? "WHERE" 
   ? oQry:cWhere 
   
   //Retrieve Info, we can use fieldget( cnField )
   ? 
   ? oQry:student_id, oQry:name, oQry:date, oQry:score, oQry:category
   ? oQry:FieldGet( 1 ), oQry:FieldGet( 2 ), oQry:FieldGet( "date" ), oQry:FieldGet( 4 ), oQry:FieldGet( "category" )
   ?
   // moving recond pointer
   ? oQry:Goto( 5 ), "GoTo 5"
   ? oQry:GoTop(), "GoTop()"
   ? oQry:GoBottom(), "GoBottom()"
   ? oQry:Skip( - 3 ), "Skip -3"
   ? 
   
   
   //browsing
   oQry:GoTop()
   ? "student_id  name        date    score    category"
   ? "==================================================="
   do while !oQry:Eof()
      ? oQry:student_id, oQry:name, oQry:date, oQry:score, oQry:category
      oQry:Skip()
   end
   ? "==================================================="
   ?
   inkey(180)

   oServer:End()   


RETURN   	           

#include "connto.prg"
  	
  
