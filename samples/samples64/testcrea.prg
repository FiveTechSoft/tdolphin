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

   LOCAL aStruc 
   
   
   aStruc = { { "ID", "N", 10, 0, .T., NIL },;
              { "NAME", "C", 15, 0, .F., "First" },;
              { "LAST", "C", 15, 0, .F., "Last" },;
              { "BIRTH", "D", , , , },;
              { "ACTIVE", "L", , , ,.F. } }
   
   oServer = TDolphinSrv():New( cServer, ;
                                cUser, ;
                                cPassword, ;
                                nPort, nFlags, ;
                                {| oServer, nError, lInternal | GetError( oServer, nError, lInternal  ) } )
   
   IF ! oServer:lError 
      IF oServer:DBCreate( cDBName )
         ? "Database created correctly " + cDBName
         ?
      ENDIF

      IF oServer:DBCreate( "test03" )
         ? "Database created correctly test03"
         ?
      ENDIF
      
      oServer:SelectDB( cDBName )
      IF oServer:CreateTable( "test", aStruc, "id", "id", "id" )
         ? "Table created correctly test"
         ?
         IF oServer:CreateIndex( "index01", "test", { { "LAST", IDX_ASC }, "BIRTH" } )
            ? "Create Index succefull"
            ? 
         ENDIF
         IF oServer:DeleteIndex( "index01", "test" )
            ? "Delete Index succefull"
            ?
         ENDIF
      ENDIF
            
      IF oServer:CreateTable( "test2", aStruc, "id", "id", "id" )
         ? "Table created correctly test2"
         ?
         oServer:CreateIndex( "index02", "test2", { "NAME" }, IDX_UNIQUE )
         ? "Create Index succefull"
         ? 
      ENDIF
            
      IF oServer:CreateTable( "test3", , , , , "LIKE TEST2" )
         ? "Table created correctly test3"
         ?
      ENDIF      
      IF oServer:CreateTable( "test4", , , , , "SELECT TEST2.NAME AS FIRST, TEST3.LAST AS LASTNAME FROM TEST2, TEST3" )
         ? "Table created correctly test4"
         ?
      ENDIF      
      
      IF oServer:DeleteTables( "test4" )
         ? "Delete successful: test4"
         ?
      ENDIF

      IF oServer:DeleteTables( {"test2", "test3"} )
         ? "Delete successful: test2, test3"
         ?
      ENDIF
/*
      IF oServer:DeleteDB( "test02" )
         ? "Delete database successful: test02"
         ?
      ENDIF
  */    
      IF oServer:DeleteDB( "test03" )
         ? "Delete database successful: test03"
         ?
      ENDIF
      
   ENDIF

   oServer:End()
   inkey(5)

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
