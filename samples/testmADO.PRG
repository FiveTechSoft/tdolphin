#include "hbcompat.ch"
#include "adordd.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

STATIC oRs
STATIC oServer
static cTabla := "testman"
PROCEDURE Main()
   
   LOCAL cText :=  ""
   LOCAL cTime :=  time()

   LOCAL aStruc, aRow, uItem

   IF conectaserver()
      IF abretabla()
         doinsert()
         DoUpdate()
      ENDIF
   ENDIF

   ? "Tiempo de proceso: " + ElapTime( cTime, time() )
   inkey(5)

RETURN 

PROCEDURE DoInsert()

   LOCAL aFields
   LOCAL aValues
   LOCAL m, n, lSwitch := .T.
   LOCAL aRow
   
   aFields = { "NAME", "LAST", "BIRTH", "ACTIVE" }
   ?
   FOR n = 1 TO 500
       aValues = { "NAME" + StrZero( n, 4 ),;
                   "LAST" + StrZero( n, 4 ),;
                   Date(),;
                   1 }
       oRs:addnew()
       FOR m = 1 TO LEN( aFields )
          oRs:Fields(aFields[m]):Value := aValues[m]
       NEXT
       oRs:update()
       oRs:movenext()
       
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
   ?

RETURN


PROCEDURE DoUpdate()

   oServer:Execute( "UPDATE " + cTabla + " SET BIRTH = " + dtoc( date()-5 ) + ;
                    " WHERE ID <= 200" )

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


/****************************************************************************/
FUNCTION CONECTASERVER()
*--
LOCAL lRet := .T.
LOCAL cSqlCmd, cQuery, cConString, oError
LOCAL cHost := "localhost"
LOCAL cUser := "dolphin"
LOCAL cPasw := "dolphin"
LOCAL cDb   := "dolphin"
LOCAL nPort := "3307"
*--
oError  := NIL
*--
TRY
  oServer := TOleAuto():New( "ADODB.Connection" )
CATCH oError
   ? "No se pudo crear la conexion"
   ShowError(oError)   
   RETURN( ! lRet )
END
*--
cConString := "Driver={MySQL ODBC 5.1 Driver}" + ;
              ";Server="+cHost                  + ;
              ";DefaultDatabase="+cDb           + ;
              ";Database="+cDb                  + ;
              ";Port="+nPort                    + ;
              ";User="+cUser                    + ;
              ";Password="+cPasw                + ;
              ";Option=3;"
*--                                         
oServer:ConnecTionString := cConString
*--
TRY
  oServer:oPen()
CATCH oError
  ? "No se pudo crear la conexion"
  ShowError(oError)
  RETURN( !lRet )
END

RETURN( lRet )
*--
*
*--
FUNCTION ShowError(oError)
*--
FOR EACH oError IN oServer:Errors
    ? " Descripción: "+oError:Description+CRLF+;
      " Error Nativo: "+STR(oError:NativeError)+CRLF+;
      "Número Error: "+STR(oError:Number)+CRLF+;
      " Origen: "+oError:Source+CRLF+;
      " Estado SQL: "+oError:SQLState
NEXT
RETURN(NIL)
*--
*
*--
FUNCTION AbreTabla()
*--
LOCAL lRet   := .F.
LOCAL oError
*--
oRs := NIL
*--
TRY
  oRs := TOleAuto():New("ADODB.RecordSet")
  CATCH oError
  ? "NO HAY CONECCION CON EL SERVIDOR !" + CRLF + FWVERSION
  ShowError(oError)
  RETURN( lRet )
END
*--
oRs:CursorLocation := adUseClient
oRs:LockType       := adLockOptimistic
oRs:CursorType     := adOpenDynamic
*--
oRs:Source := "SELECT * FROM " + cTabla + " LIMIT 0"
oRs:ActiveConnection( oServer )
*--
TRY
  oRs:Open()
CATCH oError
  ? "No se ha podido abrir el Archivo ! " + cTabla + CRLF + FWVERSION
  ShowError(oError)
  RETURN( lRet )
END
*--
RETURN( !lRet )
*--
*
*--
