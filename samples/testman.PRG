#include "hbcompat.ch"
#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL hIni      := HB_ReadIni( ".\connect.ini" )
   LOCAL oServer   := NIL
   LOCAL cServer   := hIni["mysql"]["host"],;
         cUser     := hIni["mysql"]["user"],;
         cPassword := hIni["mysql"]["psw"],;
         nPort     := val(hIni["mysql"]["port"]), ;
         cDBName   := hIni["mysql"]["dbname"], ;
         nFlags    := val(hIni["mysql"]["flags"])
   LOCAL cText := ""

   LOCAL aStruc, aRow, uItem
   
   oServer = TDolphinSrv():New( cServer, ;
                                cUser, ;
                                cPassword, ;
                                nPort, nFlags, ,;
                                {| oServer, nError, lInternal | GetError( oServer, nError, lInternal  ) } )
   oServer:DBCreate( "test03" )
   oServer:SelectDB( "test03" )
   
   IF ! oServer:lError 
      IF CreateTable( oServer )
         DoInsert( oServer )
         DoUpdate( oServer )
      ENDIF

   ENDIF 

   oServer:end()
   inkey(5)

RETURN 

FUNCTION CreateTable( oServer )
   LOCAL aStruc := { { "ID",     "N", 10, 0, .T., NIL     },;
                     { "NAME",   "C", 15, 0, .F., "First" },;
                     { "LAST",   "C", 15, 0, .F., "Last"  },;
                     { "BIRTH",  "D",   ,  ,    ,         },;
                     { "ACTIVE", "L",   ,  ,    ,.F.      } }

RETURN oServer:CreateTable( "testman", aStruc, "id", "id", "id" )


PROCEDURE DoInsert( oServer )

   LOCAL aFields
   LOCAL aValues
   LOCAL n, lSwitch := .T.
   LOCAL nTimes := GetTickCount()
   
   aFields = { "NAME", "LAST", "BIRTH", "ACTIVE" }
   ?
   FOR n = 1 TO 500
       aValues = { "NAME" + StrZero( n, 4 ),;
                   "LAST" + StrZero( n, 4 ),;
                   Date(),;
                   .T. }
       oServer:Insert( "testman", aFields, aValues )
       
       IF n%50 == 0
          lSwitch = ! lSwitch 
       ENDIF
       
       IF lSwitch
         ?? "="
       ELSE
         ?? chr( 8 )
       ENDIF
          
   NEXT

   ? "Finished Insert 500 items"
   ? "Time " + Str( (  GetTickCount() - nTimes ) / 1000, 8, 2 ) + " Sec"
   ?
RETURN


PROCEDURE DoUpdate( oServer )

   LOCAL aFields
   LOCAL aValues
   LOCAL n, lSwitch := .T.
   
   
   aFields = { "BIRTH" }
   aValues = { Date() - 5 }
   
   oServer:Update( "testman", aFields, aValues, "ID<=200" )
   
   ? "Finished Update 200 items"
   ?

RETURN

PROCEDURE GetError( oServer, nError, lInternal )
   LOCAL cText := ""
   
   cText += "Error from Custom Error Message" + CRLF
   cText += "================================" + CRLF
   cText += oServer:ErrorTxt() + CRLF
   cText += "ERROR No: " + Str( nError ) + CRLF
   cText += "Internal: " + If( lInternal, "Yes", "No" ) + CRLF
   
   ? cText + CRLF
   
   
RETURN