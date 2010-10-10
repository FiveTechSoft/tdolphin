#include "hbcompat.ch"
#include "tdolphin.ch"

PROCEDURE Main()
   
   LOCAL oServer   := NIL
   LOCAL cText := ""

   LOCAL aStruc, aRow, uItem
   LOCAL oQry
   
   
   D_SetCaseSensitive( .T. )

   oServer = ConnectTo()
   
   IF ! oServer:lError 
      
      oQry = TDolphinQry():New( "select student.student_id, student.name, "+; 
                                "absence.date from absence right join  student on "+;
                                "student.student_id = absence.student_id "+;
                                "where absence.date is not null group by student.student_id"+;
                                " order by absence.date limit 10", oServer )

   
    ? "QUERY  => " , oQry:cQuery
    ?
    ? "WHERE  => " , oQry:cWhere     
    ? "GROUP  => " , oQry:cGroup     
    ? "HAVING => ", oQry:cHaving    
    ? "ORDER  => ", oQry:cOrder     
    ? "LIMIT  => ", oQry:cLimit
    ? "Changing sentences values"
    ?
    oQry:SetLimit( 3, .F. ) //no refresh
    oQry:SetWhere( "absence.date is null" )// by default the query is refresh
    ? "Limit changed"   
    ? "Where changed"
    ? "LIMIT  => ", oQry:cLimit
    ? "WHERE  => " , oQry:cWhere     
    ?
    ? "QUERY  => " , oQry:cQuery
    ?
   ENDIF

   oServer:End()
   inkey(5)

RETURN

#include "connto.prg"