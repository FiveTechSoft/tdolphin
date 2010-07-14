#include "hbcompat.ch"
#include "tdolphin.ch"
#include "xbrowse.ch"
#include "fivewin.ch"

FUNCTION Main() 

   LOCAL oWnd 
   LOCAL oMenu
   LOCAL oServer
   MENU oMenu 2007
      MENUITEM "testing" ACTION DataBrowse( oServer, oWnd )
   ENDMENU
   
   SET CENTURY ON
   SET DATE FORMAT "dd/mm/yyyy"   
      
   //Activated Case sensitive
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN NIL
   ENDIF
   
   DEFINE WINDOW oWnd TITLE "Testing Dolphin - Fivewin" MENU oMenu
   
   ACTIVATE WINDOW oWnd 
   
   oServer:End()
   
RETURN NIL

PROCEDURE DataBrowse( oServer, oWnd )

   LOCAL oQry 
   LOCAL oDlg
   LOCAL oBrw
   LOCAL oData, oCol
   
   
   oQry = oServer:Query( "SELECT * FROM president ORDER BY last_name ASC" )
   
   DEFINE DIALOG oDlg SIZE 700,300 OF oWnd

   @ 0, 0 XBROWSE oBrw 
   
   SetDolphin( oBrw, oQry )
      
   oBrw:CreateFromCode()
  
   oDlg:oClient = oBrw 
   
   ACTIVATE DIALOG oDlg CENTERED ON INIT oDlg:Resize()
   
   oQry:End()

RETURN 

//--------------------------------------//

FUNCTION ConnectTo()
   LOCAL hIni      := HB_ReadIni( ".\connect.ini" )
   LOCAL oServer   := NIL
   LOCAL cServer   := hIni["mysql"]["host"],;
         cUser     := hIni["mysql"]["user"],;
         cPassword := hIni["mysql"]["psw"],;
         nPort     := val(hIni["mysql"]["port"]), ;
         cDBName   := hIni["mysql"]["dbname"], ;
         nFlags    := val(hIni["mysql"]["flags"])
   LOCAL oErr
   
   
   
   TRY
   
      oServer = TDolphinSrv():New( cServer, ;
                                cUser, ;
                                cPassword, ;
                                nPort, nFlags, cDBName )
                                
   CATCH oErr 
     RETURN NIL
   END
   
RETURN oServer

//--------------------------------------//

PROCEDURE SetDolphin( oBrw, oQry, lAddCols )

   LOCAL xField    := NIL
   LOCAL cHeader   := ""
   LOCAL cCol      := ""
   LOCAL aFldNames, oCol
   
   DEFAULT lAddCols := .T.

   WITH OBJECT oBrw
      :bGoTop    := {|| If( oQry:LastRec() > 0, oQry:GoTop(), NIL ) }
      :bGoBottom := {|| If( oQry:LastRec() > 0, oQry:GoBottom(), nil )  }
      :bSkip     := {| n | oQry:Skip( n ) }
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

   oBrw:nDataType         := DATATYPE_USER
   oQry:Cargo = oQry:aStructure[ 1 ][ MYSQL_FS_NAME ]
   


   IF lAddCols

      aFldNames := oQry:aStructure

      FOR EACH xField IN aFldNames
         cCol    := xField[ MYSQL_FS_NAME ]
         cHeader := xField[ MYSQL_FS_NAME ]
         oCol = SetColFromMySQL( cCol, cHeader, oQry, oBrw )
         //set order
         oCol:bLClickHeader = Build_CodeBlock_Order( oQry )
      NEXT

      oBrw:bSeek  := { | c | DolphinSeek( c, oQry ) }

   ENDIF

RETURN 

//--------------------------------------//

FUNCTION Build_CodeBlock_Order( oQry )
RETURN {| nMRow, nMCol, nFlags, oCol | SetOrderDolphin( oCol, oQry ) }

//--------------------------------------//

FUNCTION DolphinSeek( c, oQry )

   LOCAL nStart
   LOCAL uData, nNum
   LOCAL aToken
     
   STATIC aLastRec := {}

   aToken := HB_ATokens( oQry:cOrder, " " )
   
   IF Len( aLastRec ) < Len( c )
      IF Len( aLastRec ) == 0 
         nStart = 1
      ELSE 
         nStart = oQry:RecNo()
      ENDIF
      AAdd( aLastRec, nStart )
   ELSE 
      ADel( aLastRec, Len( aLastRec ) )
      ASize( aLastRec, Len( aLastRec ) - 1 )
      IF Len( aLastRec ) == 0
         nStart = 1 
      ELSE 
         nStart = ATail( aLastRec )
      ENDIF
   ENDIF
   
   oQry:Seek( c, aToken[ 1 ], nStart, oQry:LastRec(), .T., .T. )
   
RETURN .T.


//--------------------------------------//

FUNCTION SetColFromMySQL( cnCol, cHeader, oQry , oBrw ) 

   LOCAL nType, cType, nLen, nDec, cName
   LOCAL oCol, nCol
   
   IF ValType( cnCol ) == "C"
      nCol               := oQry:FieldPos( cnCol )
   ENDIF

   cName                 := oQry:FieldName( nCol )
   DEFAULT ;
   nCol                  := cnCol
   oCol                  := oBrw:AddCol()
   oCol:cHeader          := cHeader
   cType                 := oQry:FieldType( nCol )
   nLen                  := 0
   nDec                  := 0

   DO CASE
   CASE cType       == 'N'
      nLen               := oQry:FieldLen( nCol )
      nDec               := oQry:FieldDec( nCol )
      oCol:cEditPicture  := NumPict( nLen, nDec, .F., .f. )

   CASE cType       == 'C'
      nLen               := MIN( 100, oQry:FieldLen( nCol ) )

   CASE cType       == 'M'
      nLen               := MIN( 100, Len(AllTrim(oQry:FieldGet( nCol ))) )
      nLen               := IF(nLen < 30, 30, nLen )

   CASE cType       == 'D'
      oCol:nHeadStrAlign := 2
      oCol:nDataStrAlign := 0

   CASE cType       == NIL
      oCol:bEditValue    := { || "..." }

   OTHERWISE
      // just in case.  this will not be executed
      oCol:bEditValue    := { || "..." } 

   ENDCASE

   oCol:bEditValue       := { || oQry:FieldGet( nCol ) }
   oCol:cDataType        := If( cType == nil, 'C', cType )
   oCol:bOnPostEdit      := { |o,x,n| If( n == VK_RETURN, oBrw:onedit( o, x, n, cType, nCol ), NIL ) }

RETURN oCol


//--------------------------------------//

PROCEDURE SetOrderDolphin( oCol, oQry )

   LOCAL aToken 
   LOCAL cType, cOrder
      
   aToken := HB_ATokens( oQry:cOrder, " " )

   IF Len( aToken ) == 1 
      AAdd( aToken, "ASC" )
   ENDIF

   cOrder = AllTrim( Lower( aToken[ 1 ] ) )
   cType = aToken[ 2 ]
   
   AEval( oCol:oBrw:aCols, {| o | o:cOrder := " " } )
   IF oQry:aStructure[ oCol:nCreationOrder ][ MYSQL_FS_NAME ] == cOrder
      IF Upper( cType ) == "ASC"
         cType = "DESC"
         oCol:cOrder = "D"
      ELSE 
         cType = "ASC"
         oCol:cOrder = "A"
      ENDIF
   ELSE 
      cOrder = oQry:aStructure[ oCol:nCreationOrder ][ MYSQL_FS_NAME ]
      cType = "ASC"
      oCol:cOrder = "A"
   ENDIF 
   oQry:SetOrder( cOrder + " " + cType )
   oCol:oBrw:Refresh()

RETURN 