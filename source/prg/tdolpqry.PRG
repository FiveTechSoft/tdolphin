// CLASS TDolphinQry
// Manager MySql Queries


#include "hbclass.ch"
#include "common.ch"
#include "dbstruct.ch"
#include "tdolphin.ch"
#include "dolerr.ch"

#ifdef __HARBOUR__
   #include "hbcompat.ch"
#endif

CLASS TDolphinQry

   DATA aRow
   DATA aStructure
   
   DATA aColumns      
   DATA aTables       
   DATA cWhere        
   DATA cGroup        
   DATA cHaving       
   DATA cOrder        
   DATA cLimit      
   DATA cExt        
   
   DATA cQuery
   
   DATA hOldRow                // Hash Last row selected
   DATA hResult                 
   DATA hRow                   // Hash current row selected

   DATA lBof                   // Begin of query, compatibility with dbf*/
   DATA lEof                   // End of Query, compatibility with dbf*/
   

   DATA nFCount                // number of fields in the query
   DATA nRecCount              // number of rows in the current query
   DATA nRecNo                 // Current query row position
   
   DATA oServer
   
   
   METHOD New( cQuery, oServer )
   METHOD End()      INLINE MySqlFreeResult( ::hResult ), ::hResult := NIL 

   METHOD Bof()        INLINE ::lBof  
   
   METHOD BuildDatas( cQuery )
   METHOD BuildQuery( aColumns, aTables, cWhere, cGroup, cHaving, ;
                      cOrder, cLimit, cExt, lWithRoll )   
                      
   METHOD CheckError( nError )  INLINE ::oServer:CheckError( nError )
                               /*Compatibility with CheckError from TDolphinSrv*/

   METHOD Eof()        INLINE ::lEof  
                      
   METHOD FCount()   INLINE    ::nFCount
                                /*returns the number of fields in the query, compatibility with dbf*/

   METHOD FieldName( nNum )     /*returns the name of the specified field as a character string.*/
   METHOD FieldPos( cFieldName )
                                /*returns the position of the specified field*/
   METHOD FieldGet( cnField )   /*returns the value of the specified field*/
   METHOD FieldType( cnField )  /*returns the field type of the specified field*/
   METHOD FieldMySqlType( cnField ) 
                                /*returns the MySql field type of the specified field*/
                               
   METHOD GetRow( nRow )        /*Fill aRow and Hash with current data row selected*/
   METHOD GoTo( nRow ) INLINE   ::GetRow( nRow )
                                /*Goto specific Row (RecNo) and fill aRow/Hash*/
                                
   METHOD GoBottom()   INLINE   ::GetRow( ::nNumRows ) 
                                /*Goto BOTTOM of Query and fill aRow/Hash*/
                                
   METHOD GoTop()      INLINE   ::GetRow( 1 )
                                /*Goto TOP of Query and fill aRow/Hash*/

                               
   METHOD LastRec()  INLINE     ::nRecCount
                               /*returns the number of rows in the current query, compatibility with dbf*/
                               
   METHOD RecNo()    INLINE    ::nRecNo
                               /*returns the identity found at the position of the row pointer.*/

   
   ERROR HANDLER ONERROR()   
   
ENDCLASS


//----------------------------------------------------//


METHOD New( cQuery, oServer ) CLASS TDolphinQry

   LOCAL aField, nIdx, cCol
   LOCAL lCaseSen := D_SetCaseSensitive()

   IF oServer == NIL
      RETURN NIL 
   ENDIF   

   ::oServer = oServer
   ::cQuery  = cQuery

   ::nRecCount = 0
   ::nRecNo    = 0
   ::nFCount   = 0

   ::aColumns      := {}
   ::aTables       := {}
   ::cWhere        := ""
   ::cGroup        := ""
   ::cHaving       := ""
   ::cOrder        := ""
   ::cLimit        := ""   
   
   
   ::hRow      = Hash()
   ::hOldRow   = Hash()

   ::lEof      := .T.
   ::lBof      := .T.   

   IF cQuery == NIL .OR. ! oServer:SQLQuery( cQuery )
      RETURN Self 
   ENDIF 
   
   
   ::hResult := MySqlStoreResult( oServer:hMysql )
   
   IF ! ( ::hResult == 0 )

      ::aStructure = MySqlResultStructure( ::hResult ) 
      
      ::nRecCount = MySqlNumRows( ::hResult )
      ::nRecNo    = 1
      ::nFCount   = Len( ::aStructure )
   
      IF ::nRecCount > 0
         ::lEof      := .F.
         ::lBof      := .T.
      ELSE
         ::lEof      := .T.
         ::lBof      := .T.
      ENDIF   
   
      //Build Hash
      //Enable case sensitive
      hSetCaseMatch( ::hRow    , lCaseSen )
      hSetCaseMatch( ::hOldRow , lCaseSen )
      //set hash
      FOR each aField in ::aStructure
         aField[ MYSQL_FS_NAME ] = D_LowerCase( aField[ MYSQL_FS_NAME ] ) 
         cCol = aField[ MYSQL_FS_NAME ]
         HSet( ::hRow, "_" + cCol, NIL )
         HSet( ::hOldRow, "_" + cCol, NIL )
      NEXT
      ::GetRow()
      ::BuildDatas()
      
   ELSE
      IF MySqlFieldCount( oServer:hMysql ) == 0
         oServer:CheckError()
      ENDIF    
   ENDIF   

RETURN Self

//----------------------------------------------------//

METHOD BuildDatas( cQuery ) CLASS TDolphinQry

   LOCAL aToken, cItem, cSelect, cTables, cFind
   LOCAL aCommands := { "SELECT", ;
                        "WHERE",;
                        "GROUP",;
                        "HAVING",;
                        "LIMIT",;
                        "ORDER",;
                        "FROM",;
                        "DESC",;
                        "ASC" }
   LOCAL nFind
   
   DEFAULT cQuery TO ::cQuery

   ::cExt = ""

   aToken := HB_ATokens( cQuery, " " )
   
   FOR EACH cItem IN aToken
      IF AScan( aCommands, {| cCommand | cCommand == Upper( cItem ) } ) > 0
         cItem := "|" + cItem
      ENDIF
   NEXT

   cQuery := ""
   FOR EACH cItem IN aToken
      cQuery += cItem + " "
   NEXT
   cQuery := AllTrim( cQuery )

   aToken := HB_ATokens( cQuery, "|" )
   
   FOR EACH cItem IN aToken
   
      cFind = Upper( SubStr( cItem, 1, At( " ", cItem ) - 1 ) )
      
      // for comapibility with xharbour
      // xharbour no accept string like switch constant
      nFind = AScan( aCommands, cFind )
      
      SWITCH nFind
         CASE 1 //"SELECT"
            cSelect := AllTrim( SubStr( cItem, 8 ) )
            ::aColumns = ArrayFromSQLString( cSelect )
            EXIT

            
         CASE 2 //"WHERE"
            IF Empty( ::cWhere )
               ::cWhere  := AllTrim( SubStr( cItem, 7 ) )
            ENDIF
            EXIT

         CASE 3 //"GROUP" 
            IF Empty( ::cGroup )
               ::cGroup  := AllTrim( SubStr( cItem, 10 ) )
            ENDIF
            EXIT

         CASE 4 //"HAVING" 
            IF Empty( ::cHaving )
               ::cHaving := AllTrim( SubStr( cItem, 8 ) )
            ENDIF
            EXIT

         CASE 5 //"LIMIT"
            IF Empty( ::cLimit )
               ::cLimit  := AllTrim( SubStr( cItem, 7 ) )
            ENDIF
            IF Val(::cLimit) <= 1
               ::cLimit := ""
            ENDIF     

         CASE 6 //"ORDER"
            IF Empty( ::cOrder )
               ::cOrder  := AllTrim(SubStr( cItem, 10 ))
            ENDIF
            EXIT
            
         CASE 7 //"FROM"
            IF Empty( ::aTables )
               cTables := AllTrim( SubStr( cItem, 6 ) )
               ::aTables := ArrayFromSQLString( cTables )
            ENDIF
            EXIT
            
            
         CASE 8//"DESC" 
            IF ! Empty( ::cOrder )
              ::cOrder  += " DESC"
            ENDIF 
            EXIT
            
         CASE 9 //"ASC" 
            IF ! Empty( ::cOrder )
              ::cOrder  += " ASC"
            ENDIF
            EXIT
            

            EXIT
#ifdef __XHARBOUR__
         DEFAULT 
#else
         OTHERWISE 
#endif                           
           ::cExt += cItem
      ENDSWITCH
   NEXT

RETURN NIL

//----------------------------------------------------//

METHOD BuildQuery( aColumns, aTables, cWhere, cGroup, cHaving, ;
                   cOrder, cLimit, cExt, lWithRoll ) CLASS TDolphinQry

   LOCAL cQuery := ""
   
   ::aColumns = aColumns
   ::aTables  = aTables
   ::cWhere   = cWhere
   ::cGroup   = cGroup
   ::cHaving  = cHaving
   ::cOrder   = cOrder
   ::cLimit   = cLimit 
   ::cExt     = cExt

   cQuery = BuildQuery( aColumns, aTables, cWhere, cGroup, cHaving, cOrder, cLimit, cExt, lWithRoll )
   

RETURN cQuery

//----------------------------------------------------//

METHOD FieldGet( cnField ) CLASS TDolphinQry
   
   LOCAL cFieldName
   
   IF ValType( cnField ) == "N"
      cFieldName = "_" + ::FieldName( cnField )
   ELSE 
      cFieldName = "_" + D_LowerCase( cnField )
   ENDIF

   IF hGetPos( ::hRow, cFieldName ) > 0
      RETURN ::hRow[ cFieldName ]
   ELSE 
      ::oServer:nInternalError = ERR_INVALIDFIELDGET
      ::oServer:CheckError()
   ENDIF   

RETURN nil

//----------------------------------------------------//

METHOD FieldName( nNum ) CLASS TDolphinQry
   LOCAL cName := ""
   
   IF nNum > 0 .AND. nNum <= ::nFCount
      cName = ::aStructure[ nNum ][ MYSQL_FS_NAME ]
   ELSE 
      ::oServer:nInternalError = ERR_INVALIDFIELDNUM
      ::oServer:CheckError()
   ENDIF
    
RETURN cName

//----------------------------------------------------//

METHOD FieldPos( cFieldName ) CLASS TDolphinQry
   LOCAL nPos := 0

   IF ! Empty( cFieldName )
      nPos = AScan( ::aStructure, {| aField | aField[ MYSQL_FS_NAME ] == D_LowerCase( cFieldName ) } )
   ENDIF

   IF nPos == 0 
      ::oServer:nInternalError = ERR_INVALIDFIELDNAME
      ::oServer:CheckError()
   ENDIF

RETURN nPos

//----------------------------------------------------//


METHOD FieldType( cnField ) CLASS TDolphinQry
   local cType := "U"
   LOCAL nNum

   if ValType( cnField ) == "C"
      nNum := ::FieldPos( cnField )
   else
      nNum := cnField
   endif

   if nNum >= 0 .AND. nNum <= ::nFCount

      cType := ::aStructure[ nNum ][ MYSQL_FS_CLIP_TYPE ]

   endif

return cType

//----------------------------------------------------//


METHOD FieldMySqlType( cnField ) CLASS TDolphinQry
   local cType := "U"
   LOCAL nNum

   if ValType( cnField ) == "C"
      nNum := ::FieldPos( cnField )
   else
      nNum := cnField
   endif

   if nNum >= 0 .AND. nNum <= ::nFCount

      cType := ::aStructure[ nNum ][ MYSQL_FS_TYPE ]

   endif

return cType


//----------------------------------------------------//

METHOD GetRow( nRow ) CLASS TDolphinQry

   LOCAL cType, xField
   LOCAL bBlock
   LOCAL cCol
   LOCAL nIdx

   DEFAULT nRow  TO ::nRecNo

   
   IF ::hResult <> NIL
   
      DO CASE
         CASE ::nRecCount <= 1
            ::lBof    = .T.
            ::lEof    = .T.
            ::nRecNo  = 1
         CASE nRow > 0 .and. nRow <= ::nRecCount
            ::lBof    = .F.
            ::lEof    = .F.
            ::nRecNo  = nRow
         CASE nRow > ::nRecCount
            ::lBof    = .F.
            ::lEof    = .T.
            ::nRecNo  = ::nRecCount
      ENDCASE

      nRow := ::nRecNo
      MySqlDataSeek( ::hResult, nRow - 1 )
      ::aRow := MySqlFetchRow( ::hResult )

      //fill ::aRow Info
      IF ::aRow <> NIL
         // Convert answer from text field to correct clipper types
         FOR EACH xField IN ::aRow
          
#ifdef __XHARBOUR__
            nIdx = HB_EnumIndex()
#else
            nIdx = xField:__EnumIndex()
#endif
            cType := ::aStructure[ nIdx ][ MYSQL_FS_CLIP_TYPE ]

            SWITCH cType
               CASE "L"
                  xField := !( Val( xField ) == 0 )
                  EXIT

               CASE "N"
                  xField := Val( xField )
                  EXIT

               CASE "D"
                  IF Empty( xField )
                     xField := CToD( "" )
                  ELSE
                     xField := SToD( Left( xField, 4 ) + substr( xField, 6, 2 ) + right( xField, 2 ) )
                  ENDIF
                  EXIT

               CASE "T"
               CASE "C"
                  xField := PadR( xField, ::aStructure[ nIdx ][ MYSQL_FS_LENGTH ] ) 
                  EXIT
            ENDSWITCH
            cCol := "_" + D_LowerCase( ::aStructure[ nIdx ][ MYSQL_FS_NAME ] )
            HSet( ::hRow, cCol, xField )
            HSet( ::hOldRow, cCol, xField )
         NEXT

      ENDIF

   ENDIF

RETURN ::nRecNo


//----------------------------------------------------//

#ifdef __HARBOUR__
   METHOD ONERROR( uParam1, uParam2 ) CLASS TDolphinQry
      LOCAL cCol   := __GetMessage()
#else
   METHOD ONERROR( cCol, nError ) CLASS TDolphinQry
      LOCAL uParam1
      IF Len( HB_AParams() ) > 0
         uParam1 = HB_AParams()[ 1 ]
      ENDIF
#else

   IF Substr( cCol, 1, 1 ) != "_"
      cCol := "_" + D_LowerCase( cCol )
   ELSE 
      cCol = D_LowerCase( cCol )
   ENDIF
   
   IF ! ( uParam1 == NIL )
      ? cCol, uParam1
      HSet( ::hRow, cCol, uParam1 )
   ELSE
      IF hGetPos( ::hRow, cCol ) > 0
         RETURN ::hRow[ cCol ]
      ENDIF
   ENDIF

RETURN NIL


