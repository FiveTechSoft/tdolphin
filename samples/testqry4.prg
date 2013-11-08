/*
 * este ejemplo mueastra como obtener informacion ed un query
 * ---
 * This sample show ho get query datas
 */

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
   cQuery  = "select student.student_id, student.name, grade_event.date, score.score, grade_event.category "
   cQuery += "from grade_event, score, student where grade_event.date = &fecha and "
   cQuery += "grade_event.event_id = score.event_id and score.student_id = student.student_id"

   //build query object
   oQry = TDolphinQry():New( cQuery, oServer, {"fecha" => "'2008-09-23'" } )
      
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

   cQuery  = "select student.student_id, student.name, grade_event.date, score.score, grade_event.category "
   cQuery += "from grade_event, score, student where grade_event.date = &1 and "
   cQuery += "grade_event.event_id = score.event_id and score.student_id = student.student_id"

   //build query object
   oQry = TDolphinQry():New( cQuery, oServer, { "'2008-09-23'" } )
      
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
  	
  
