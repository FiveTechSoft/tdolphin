#include "fivewin.ch"
#include "hbcompat.ch"
#include "tdolphin.ch"
#include "xbrowse.ch"

//#define CRLF Chr( 13 ) + Chr( 10 )

PROCEDURE Main()
   
   LOCAL oServer   := NIL
   
   LOCAL cServer   := "dolphintest.sitasoft.net",;
         cUser     := "test_dolphin",;
         cPassword := "123456",;
         nPort     := 3306, ;
         cDBName   := "dolphin_man", ;
         nFlags    := 0
   LOCAL oQry
   
   LOCAL oWnd, oBrw
   
   LOCAL cTime 

   
   SET CENTURY ON
   SET DATE FORMAT "dd/mm/yyyy"
 
   oServer = TDolphinSrv():New( cServer, ;
                                cUser, ;
                                cPassword, ;
                                nPort, nFlags, cDBName,;
                                {| oServer, nError, lInternal | GetError( oServer, nError, lInternal  ) } )
   
   IF ! oServer:lError 
      cTime := time()
      oQry = TDolphinQry():New( "SELECT * FROM testman LIMIT 100", oServer )
//      ? "load finished, Time " + elaptime( cTime, time() )
      oQry:SetPages( 100 )
      oQry:bOnChangePage = {| lPrev | oBrw:Refresh(), If( lPrev, oBrw:GoBottom(), ) }

      DEFINE WINDOW oWnd TITLE "Testing TDOLPHIN"
      
      @ 0, 0 XBROWSE oBrw OF oWnd
      
      SetDolphin( oBrw, oQry )
      
      oBrw:CreateFromCode() 
      
      oWnd:oClient = oBrw
      
      
      ACTIVATE WINDOW oWnd      
      
            
   ELSE 
      RETURN 
   ENDIF

   oServer:End()


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

PROCEDURE SetDolphin( oBrw, oQry)

   LOCAL xField    := NIL
   LOCAL cHeader   := ""
   LOCAL cCol      := ""
   LOCAL aFldNames
   LOCAL nP

   WITH OBJECT oBrw
      :bGoTop    := {|| If( oQry:LastRec() > 0, oQry:GoTop(), NIL ) }
      :bGoBottom := {|| If( oQry:LastRec() > 0, oQry:GoBottom(), nil )  }
      IF oQry:lPagination
         :bSkip     := {| n | If ( n != NIL, If( n + oQry:nRecNo < 1 .AND. oQry:nCurrentPage > 1,;
                                                 ( oQry:PrevPage(, .T. ), 0 ), ;
                                                 If( n + oQry:nRecNo > oQry:nRecCount .AND. oQry:nCurrentPage < oQry:nTotalRows,;
                                                     ( oQry:NextPage( , .T. ), 0 ), oQry:Skip( n ) ) ), oQry:Skip( n ) )  }
      ELSE 
         :bSkip     := {| n | oQry:Skip( n ) }
      ENDIF
      
      :bBof      := {|| oQry:Bof() }
      :bEof      := {|| oQry:Eof() }
      :bBookMark := {| n | If( n == nil,;
                           If( oQry:LastRec() > 0, oQry:RecNo(), 0 ), ;
                           If( oQry:LastRec() > 0, oQry:goto( n ), 0 ) ) }
      :bKeyNo    := {| n | If( n == nil, ;
                           If( oQry:LastRec() > 0, oQry:RecNo(), 0 ), ;
                           If( oQry:LastRec() > 0, oQry:Goto( n ), 0 ) ) }
      :bKeyCount := {|| oQry:LastRec() }
   END

   oBrw:nDataType         := DATATYPE_MYSQL
   oBrw:oMySql = oQry
   

//   IF lAddCols

      aFldNames := oQry:aStructure

      FOR EACH xField IN aFldNames
         IF Valtype( xField ) == "A" .AND. Len(xField) == 2
            cCol    := xField[1]
            cHeader := xField[2]
         ELSEIF Valtype( xField ) == "A" .AND. Len(xField) # 2
            cCol    := xField[1]
            cHeader := xField[1]
         ELSE
            cCol    := xField
            cHeader := xField
         ENDIF

         oBrw:SetColFromMySQL( cCol, cHeader, .F., oQry )
      NEXT

//      oBrw:bSeek  := { | c | DolphinSeek( c, oQry ) }

//   ENDIF

RETURN 


  
   
