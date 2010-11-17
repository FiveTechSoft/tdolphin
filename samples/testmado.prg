//#include "hbcompat.ch"
#include "adordd.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL cTime :=  time()
   LOCAL oServer
   LOCAL oRs

   IF ( oServer := ConnectTo() ) != NIL   
      DoInsert( oServer )
   ENDIF


   ? "Test with ADO is finished!!!"
   ? "Process Time: " + ElapTime( cTime, time() )
   ? 
   Inkey(5)

RETURN 


PROCEDURE DoInsert( oServer )

   LOCAL aFields
   LOCAL aValues
   LOCAL m, n, lSwitch := .T.
   LOCAL aRow
   LOCAL cQry
   
   ?
   oServer:Execute( "DELETE FROM testman" )
   FOR n = 1 TO 500
       
       cQry = "INSERT INTO testman SET " + ;
              " NAME='NAME" + StrZero( n, 4 ) + "'" +;
              ",LAST='LAST" + StrZero( n, 4 ) + "'" +;
              ",BIRTH='" + StrZero( Year( Date() ), 4 ) + "-" + StrZero( Month( Date() ), 2 )  + "-" + StrZero( Day( Date() ), 2 ) +"'" +;
              ",ACTIVE=1" 
       ? cQry       
       oServer:Execute( cQry )
          
   NEXT

   ? "Finished Insert 500 items"
   ?

RETURN

//-----------------------------------------//

PROCEDURE GetError( oServer, nError, lInternal )
   LOCAL cText := ""
   
   cText += "Error from Custom Error Message" + CRLF
   cText += "================================" + CRLF
   cText += oServer:ErrorTxt() + CRLF
   cText += "ERROR No: " + Str( nError ) + CRLF
   cText += "Internal: " + If( lInternal, "Yes", "No" ) + CRLF
   
   ? cText + CRLF
   
   
RETURN

//-----------------------------------------//

FUNCTION ConnectTo()
   LOCAL hIni      := HB_ReadIni( ".\connect.ini" )
   LOCAL oServer   := NIL
   LOCAL cServer   := hIni["mysql"]["host"],;
         cUser     := hIni["mysql"]["user"],;
         cPassword := hIni["mysql"]["psw"],;
         nPort     := hIni["mysql"]["port"], ;
         cDBName   := hIni["mysql"]["dbname"], ;
         nFlags    := val(hIni["mysql"]["flags"])
   LOCAL oErr
   LOCAL cConString
   LOCAL lRet      := .T.

   cConString := "Driver={MySQL ODBC 5.1 Driver}"    + ;
                 ";Server=" + cServer                + ;
                 ";DefaultDatabase=" + cDBName       + ;
                 ";Database=" + cDBName              + ;
                 ";Port=" + nPort                    + ;
                 ";User=" + cUser                    + ;
                 ";Password=" + cPassword            + ;
                 ";Option=3;"   
   

   TRY
     oServer := TOleAuto():New( "ADODB.Connection" )     
   CATCH oErr
      ? "Init Server Failed!!!"
      ShowError( oErr )      
      RETURN NIL
   END   
   
   oServer:ConnecTionString := cConString
   
   TRY
     oServer:Open()
   CATCH oErr
     ? "Conection erver Failed!!!"
     ShowError( oErr )
     RETURN NIL
   END   
   
RETURN oServer

//-----------------------------------------//

FUNCTION ShowError( oError )

   ? " Descripción  : " + oError:Description
   ? " SubSystem    : " + oError:SubSystem
   ? " Error Number : " + Str( oError:SubCode )
   ? " Severity     : " + Str( oError:Severity )
   
RETURN NIL
