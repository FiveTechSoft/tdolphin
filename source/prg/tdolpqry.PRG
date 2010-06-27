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


#define USE_HASH /* use hash of fields for faster FieldPos
                    If hash code breaks in any build of (x)Harbour ( can happen )
                    uncomment and recompile to use standard array scan*/


CLASS TDolphinQry

   DATA aColumns,;    // query active columns (select) 
        aTables,;     // query active tables
        aRow,;        // info currect record selected
        aStructure    // type of each field, a copy is here a copy inside each row
   DATA aOldRow        PROTECTED// Value copy
        
   DATA bBof,;        //codeblock to evaluate if the value is the first row
        bEof,;        //codeblock to evaluate if the value is the last row
        bOnFillArray  //codeblock to evaluate while is filling array
   
   DATA cBuild,;        // Current server version
        cQuery,;        // copy of query that generated this object
        cWhere,;        // copy of WHERE command
        cGroup,;        // copy of GROUP BY command
        cHaving,;       // copy of HAVING command
        cOrder,;        // copy of OREDER BY command
        cLimit,;        // copy of LIMIT command
        cExt            // Data for control other MySql commands

   
   DATA hOldRow                // Hash Last row selected
   DATA hResult                 
   DATA hRow                   // Hash current row selected

   DATA lBof                   // Begin of query, compatibility with dbf*/
   DATA lEof                   // End of Query, compatibility with dbf*/
   DATA lAppend

   DATA nFCount                // number of fields in the query
   DATA nRecCount              // number of rows in the current query
   DATA nRecNo                 // Current query row position
   DATA nQryId
   
   DATA oServer
   
   
   METHOD New( cQuery, oServer )
   METHOD End()        INLINE ::oServer:CloseQuery( ::nQryId )

   METHOD Bof()        INLINE ::lBof  
   
   METHOD BuildDatas( cQuery )
   METHOD BuildQuery( aColumns, aTables, cWhere, cGroup, cHaving, ;
                      cOrder, cLimit, cExt, lWithRoll )   
                      
   METHOD CheckError( nError )  INLINE ::oServer:CheckError( nError )
                               /*Compatibility with CheckError from TDolphinSrv*/

   METHOD Eof()        INLINE ::lEof  
                      
   METHOD FCount()     INLINE    ::nFCount
                                /*returns the number of fields in the query, compatibility with dbf*/

   METHOD FieldName( nNum )     /*returns the name of the specified field as a character string.*/
   METHOD FieldPos( cFieldName )
                                /*returns the position of the specified field*/
   METHOD FieldGet( cnField )   /*returns the value of the specified field*/
   METHOD FieldType( cnField )  /*returns the field type of the specified field*/
   METHOD FieldMySqlType( cnField ) 
                                /*returns the MySql field type of the specified field*/
                                
   METHOD FieldPut( cnField, uValue )
                                /*Set the value of a field variable using the ordinal position of the field.
                                  returns the value assigned to the designated field.*/                            
   
   METHOD FillArray()           /*Fill and return a array with all query information*/
   
   METHOD GetBlankRow()                       
   METHOD GetRow( nRow )        /*Fill aRow and Hash with current data row selected*/
   METHOD GoTo( nRow ) INLINE   ::GetRow( nRow )
                                /*Goto specific Row (RecNo) and fill aRow/Hash*/
                                
   METHOD GoBottom()   INLINE   ::GetRow( ::nRecCount ) 
                                /*Goto BOTTOM of Query and fill aRow/Hash*/
                                
   METHOD GoTop()      INLINE   ::GetRow( 1 )
                                /*Goto TOP of Query and fill aRow/Hash*/
                                
   METHOD IsEqual( nIdx )                                

   METHOD IsSingleTable() INLINE Len( ::aTables ) == 1  
   METHOD IsCommand()     INLINE ( ::IsSingleTable() .AND. Len( ::aColumns ) == 0 ) .OR. ;
                                 ( Len( ::aTables ) < 1 .AND. Len( ::aColumns ) >= 1 )

                                  
   METHOD LastRec()    INLINE     ::nRecCount
                               /*returns the number of rows in the current query, compatibility with dbf*/

   METHOD LoadQuery() 
                               
   METHOD MakePrimaryKeyWhere() 
                               
   METHOD RecNo()      INLINE    ::nRecNo
                               /*returns the identity found at the position of the row pointer.*/

   METHOD Save()
                               
   METHOD SetData( nNum, uValue ) HIDDEN
   
   METHOD SetNewFilter( nType, cFilter, lRefresh )
   METHOD SetWhere( cWhere, lRefresh )   INLINE ::SetNewFilter( SET_WHERE, cWhere, lRefresh )
   METHOD SetGroup( cGroup, lRefresh )   INLINE ::SetNewFilter( SET_GROUP, cGroup, lRefresh )
   METHOD SetHaving( cHaving, lRefresh ) INLINE ::SetNewFilter( SET_HAVING, cHaving, lRefresh )
   METHOD SetOrder( cOrder, lRefresh )   INLINE ::SetNewFilter( SET_ORDER, cOrder, lRefresh )
   METHOD SetLimit( cLimit, lRefresh )   INLINE ::SetNewFilter( SET_LIMIT, cLimit, lRefresh )
  
   METHOD Skip( nRecords )
   
   ERROR HANDLER ONERROR()   
   
ENDCLASS


//----------------------------------------------------//


METHOD New( cQuery, oServer ) CLASS TDolphinQry


   IF oServer == NIL
      RETURN NIL 
   ENDIF   

   ::oServer = oServer
   ::cQuery  = cQuery
   ::nQryId  = oServer:GetQueryId()
   oServer:AddQuery( Self )

   ::nRecCount = 0
   ::nRecNo    = 0
   ::nFCount   = 0

   ::aColumns      = {}
   ::aTables       = {}
   ::cWhere        = ""
   ::cGroup        = ""
   ::cHaving       = ""
   ::cOrder        = ""
   ::cLimit        = ""   
   
   ::aRow          = {}
   ::aOldRow       = {}
   
#ifdef USE_HASH     
   ::hRow      = Hash()
   ::hOldRow   = Hash()
#endif /*USE_HASH*/
   ::lEof      := .T.
   ::lBof      := .T.   

   IF cQuery == NIL 
      RETURN Self 
   ENDIF 

   ::LoadQuery()
   


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
   LOCAL nNum
   LOCAL lError := .F.

#ifdef USE_HASH
   IF ValType( cnField ) == "N"
      cFieldName = "_" + ::FieldName( cnField )
   ELSE 
      cFieldName = "_" + D_LowerCase( cnField )
   ENDIF
   IF hGetPos( ::hRow, cFieldName ) > 0
      RETURN ::hRow[ cFieldName ]
   ELSE
      lError = .T.
   ENDIF
#else      
   IF ValType( cnField ) == "N"
      nNum = cnField 
   ELSE 
      nNum = ::FieldPos( cnField )
   ENDIF
   IF nNum > 0
      RETURN ::aRow[ nNum ]
   ENDIF

#endif /*USE_HASH*/
   
   IF lError
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

METHOD FieldPut( cnField, uValue ) CLASS TDolphinQry

   LOCAL nNum

   IF ValType( cnField ) == "C"
      nNum := ::FieldPos( cnField )
   ELSE
      nNum := cnField
   ENDIF

   IF nNum > 0 .AND. nNum <= ::nFCount
      IF Valtype( uValue ) == Valtype( ::aRow[ nNum ] ) .OR. ::aRow[ nNum ] == NIL

         IF ValType( uValue ) == "C"
            uValue := MySqlEscape( AllTrim( uValue ) )
         ENDIF
         ::SetData( nNum, uValue )
         RETURN uValue
      ENDIF
   ENDIF

RETURN NIL

//---------------------------------------

METHOD FillArray( bOnFillArray ) CLASS TDolphinQry

   LOCAL aTable := {}, aRow
   LOCAL n, aGet

   DEFAULT bOnFillArray TO ::bOnFillArray

   IF ::nRecCount > 0
         
      WHILE ! ::lEof
         aRow = {}
         FOR n = 1 to ::nFCount
            AAdd( aRow, ::FieldGet( n ) )
         NEXT 
         IF bOnFillArray != NIL 
            Eval( bOnFillArray, aRow )
         ENDIF
         AAdd( aTable, aRow )
         ::Skip()
      END 
   ENDIF
   
RETURN aTable 


//----------------------------------------------------//

METHOD GetBlankRow() CLASS TDolphinQry
   LOCAL cType
   LOCAL uValue, uItem
   LOCAL nIdx
   LOCAL cCol


   IF ! ::IsSingleTable()
      ::oServer:nInternalError = ERR_INVALIDGETBLANKROW
      ::oServer:CheckError()
      RETURN NIL 
   ENDIF
   
   ::lAppend := .T.

   IF ::aRow == NIL
      ::aRow    = Array( Len( ::aStructure ) )
   ENDIF

   ::aOldRow = AClone( ::aRow )
   
   FOR EACH uItem IN ::aRow
     
#ifdef __XHARBOUR__
      nIdx = HB_EnumIndex()
#else 
      nIdx = uItem:__EnumIndex()
#endif

      cType := ::aStructure[ nIdx ][ MYSQL_FS_CLIP_TYPE ]

      SWITCH cType
      
      CASE "C"
         IF ::aStructure[ nIdx ][ MYSQL_FS_DEF ] != NIL
            uValue = PadR( ::aStructure[ nIdx ][ MYSQL_FS_DEF ], ::aStructure[ nIdx ][ MYSQL_FS_LENGTH ] )
         ELSE 
            uValue = Space(::aStructure[ nIdx ][ MYSQL_FS_LENGTH ])
         ENDIF 
         EXIT
      CASE "M"
      CASE "B"
         uValue := ""
         EXIT

      CASE "N"
      CASE "I"
         IF ::aStructure[ nIdx ][ MYSQL_FS_DEF ] != NIL
            uValue = Val( ::aStructure[ nIdx ][ MYSQL_FS_DEF ] )
         ELSE 
            uValue = 0
         ENDIF 
         EXIT

      CASE "L"
         IF ::aStructure[ nIdx ][ MYSQL_FS_DEF ] != NIL
            uValue = ::aStructure[ nIdx ][ MYSQL_FS_DEF ] == "1"
         ELSE 
            uValue = .F.
         ENDIF 
         
         EXIT

      CASE "D"
         IF ::aStructure[ nIdx ][ MYSQL_FS_DEF ] != NIL
            uValue = SqlDate2Clip( ::aStructure[ nIdx ][ MYSQL_FS_DEF ] )
         ELSE 
            uValue = CToD("")
         ENDIF 
      
         EXIT

#ifdef __XHARBOUR__
      DEFAULT
#else 
      OTHERWISE
#endif
         uValue := nil
      END
      ::SetData( nIdx, uValue )
   NEXT



return Self

//----------------------------------------------------//

METHOD GetRow( nRow ) CLASS TDolphinQry

   LOCAL cType, uValue, cField
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

      nRow  = ::nRecNo
      MySqlDataSeek( ::hResult, nRow - 1 )
      ::aRow    = MySqlFetchRow( ::hResult )
      ::aOldRow = Array( Len( ::aRow ) )

      //fill ::aRow Info
      IF ::aRow != NIL .AND. ::nRecCount > 0
         // Convert answer from text field to correct clipper types
         FOR EACH cField IN ::aRow

#ifdef __XHARBOUR__
            nIdx = HB_EnumIndex()
#else
            nIdx = cField:__EnumIndex()
#endif
            cType := ::aStructure[ nIdx ][ MYSQL_FS_CLIP_TYPE ] //, ::aStructure[ nIdx ][ MYSQL_FS_TYPE ]

            SWITCH cType
               CASE "L"
                  uValue := !( Val( cField ) == 0 )
                  EXIT

               CASE "N"
                  uValue = Val( cField )
                  EXIT

               CASE "D"
                  IF Empty( cField )
                     uValue := CToD( "" )
                  ELSE
                     uValue := SqlDate2Clip( cField )
                  ENDIF
                  EXIT

               CASE "T"
               CASE "C"
                  uValue := PadR( cField, ::aStructure[ nIdx ][ MYSQL_FS_LENGTH ] ) 
                  EXIT
#ifdef __XHARBOUR__
               DEFAULT
#else
               OTHERWISE 
#endif
               uValue = cField
            ENDSWITCH
            ::SetData( nIdx, uValue )
         NEXT

      ENDIF
   ELSE 
      ::oServer:nInternalError = ERR_FAILEDGETROW
      ::nRecNo = 0
      ::CheckError()
   ENDIF

RETURN ::nRecNo

//----------------------------------------------------//

METHOD IsEqual( cnField ) CLASS TDolphinQry
#ifdef USE_HASH
RETURN ::hRow( "_" + cnField ) == ::hOldRow( "_" + cnField ) 
#else 
RETURN ::aRow( cnField ) == ::aOldRow( cnField ) 
#endif /*USE_HASH*/


//----------------------------------------------------//


METHOD LoadQuery( lBuildData ) CLASS TDolphinQry

   LOCAL oServer := ::oServer
   LOCAL cQuery  := ::cQuery
   LOCAL aField, nIdx, cCol
   LOCAL lCaseSen := D_SetCaseSensitive()

   DEFAULT lBuildData TO .T.

   IF ! oServer:SQLQuery( cQuery )
      RETURN NIL 
   ENDIF
   
   IF lBuildData
      ::BuildDatas()
   ENDIF
   
   IF ::hResult != 0
      MySqlFreeResult( ::hResult )
      ::hResult = 0
   ENDIF
   
   ::hResult := MySqlStoreResult( oServer:hMysql )
   
   IF ! ( ::hResult == 0 )
      IF ::IsSingleTable() .AND. ! ::IsCommand()
         ::aStructure = ::oServer:TableStructure( ::aTables[ 1 ] )
      ELSE
         ::aStructure = MySqlResultStructure( ::hResult, D_SetCaseSensitive() ) 
      ENDIF
      
      ::nRecCount := MySqlNumRows( ::hResult )
      ::nRecNo    = 1
      ::nFCount   = Len( ::aStructure )
   
      IF ::nRecCount > 0
         ::lEof      := .F.
         ::lBof      := .T.
      ELSE
         ::lEof      := .T.
         ::lBof      := .T.
      ENDIF   

#ifdef USE_HASH
      //Build Hash
      //Enable case sensitive
      hSetCaseMatch( ::hRow    , lCaseSen )
      hSetCaseMatch( ::hOldRow , lCaseSen )
      //set hash
      FOR each aField in ::aStructure
         cCol = aField[ MYSQL_FS_NAME ]
         ::SetData( cCol, NIL )
      NEXT
#endif /*USE_HASH*/
      ::GetRow()
      
   ELSE
      IF MySqlFieldCount( oServer:hMysql ) == 0
         oServer:CheckError()
      ENDIF    
   ENDIF  
   
RETURN NIL 

//----------------------------------------------------//

METHOD MakePrimaryKeyWhere() CLASS TDolphinQry

   LOCAL cWhere := " WHERE ", aField
   LOCAL nIdx

   FOR EACH aField IN ::aStructure

      // search for fields part of a primary key
      IF IS_PRIMARY_KEY( aField[ MYSQL_FS_FLAGS ] ) .OR.;
         IS_MULTIPLE_KEY( aField[ MYSQL_FS_FLAGS ] )

         cWhere += aField[ MYSQL_FS_NAME ] + "="

         // if a part of a primary key has been changed, use original value
#ifdef __XHARBOUR__         
         nIdx = HB_EnumIndex()
#else 
         nIdx = aField:__EnumIndex()
#endif /*__XHARBOUR__*/   

#ifdef USE_HASH
         IF ! ::IsEqual( aField[ MYSQL_FS_NAME ] )
            cWhere += ClipValue2SQL( ::hOldRow[ "_" + aField[ MYSQL_FS_NAME ] ], aField[ MYSQL_FS_CLIP_TYPE ] ) 
         ELSE
            cWhere += ClipValue2SQL( ::hRow[ "_" + aField[ MYSQL_FS_NAME ] ], aField[ MYSQL_FS_CLIP_TYPE ] ) 
         ENDIF
#else          
         IF ! ::IsEqual( nIdx )
            cWhere += ClipValue2SQL( ::aOldRow[ nIdx ], aField[ MYSQL_FS_CLIP_TYPE ] ) 
         ELSE
            cWhere += ClipValue2SQL( ::aRow[ nIdx ], aField[ MYSQL_FS_CLIP_TYPE ] )
         ENDIF         
#endif /*USE_HASH*/
         cWhere += " AND "
      ENDIF

   NEXT

   // remove last " AND "
   cWhere := Left( cWhere, Len( cWhere ) - 5 )

RETURN cWhere

//----------------------------------------------------//

/* Creates an update query for changed fields and submits it to server */
METHOD Save() CLASS TDolphinQry

   LOCAL cTable
   LOCAL aField
   LOCAL cQry := ""
   LOCAL uValue  
   LOCAL uOldValue
   LOCAL nIdx
   LOCAL lSaveOk := .F.
   
   
   IF ! ::IsSingleTable()
      ::oServer:nInternalError = ERR_INVALIDSAVE
      ::oServer:CheckError()
      RETURN NIL 
   ENDIF
   
   cTable = ::aTables[ 1 ]

   IF ! ::lAppend
      cQry += "UPDATE " + Lower( cTable ) + " SET "
   ELSE
      cQry += "INSERT INTO " + Lower( cTable ) + " SET "
   ENDIF

   FOR EACH aField IN ::aStructure
      
      IF ::lAppend
         lSaveOk = .T.
         uValue = ::FieldGet( aField[ MYSQL_FS_NAME ] )
      ELSE
#ifdef USE_HASH
         uValue = ::FieldGet( aField[ MYSQL_FS_NAME ] )
         uOldValue = ::hOldRow[ "_" + aField[ MYSQL_FS_NAME ] ]
#else 
#ifdef __XHARBOUR__
         nIdx = HB_EnumIndex()
#else
         nIdx = aField:__EnumIndex()
#endif /*__XHARBOUR__*/ 
         uValue = ::FieldGet( aField[ MYSQL_FS_NAME ] )
         uOldValue = ::aOldRow[ nIdx ]
#endif /*USE_HASH*/
         IF uValue != uOldValue
            lSaveOk = .T.
         ENDIF
      ENDIF
      IF lSaveOk
         cQry += aField[ MYSQL_FS_NAME ] + "=" + ClipValue2SQL( uValue ) + ","
      ENDIF
   NEXT

   IF lSaveOk
   // remove last comma
      
      cQry = Left( cQry, Len( cQry ) - 1 )
      
      IF !::lAppend
         cQry   += ::MakePrimaryKeyWhere()
      ENDIF

      IF ::oServer:SqlQuery( cQry )
         ::LoadQuery()
      ENDIF         
      ::lAppend = .F.
   ELSE 
      ::oServer:nInternalError = ERR_NOTHINGTOSAVE
      ::CheckError()
   ENDIF


RETURN nil

//----------------------------------------------------//


METHOD SetData( cnField, uValue )	CLASS TDolphinQry

   LOCAL cCol
   LOCAL nNum

   IF ValType( cnField ) == "C"
      nNum := ::FieldPos( cnField )
   ELSE
      nNum := cnField
   ENDIF
#ifdef USE_HASH
   cCol := "_" + D_LowerCase( ::aStructure[ nNum ][ MYSQL_FS_NAME ] )
   HSet( ::hRow, cCol, uValue )
   HSet( ::hOldRow, cCol, uValue )

#else 
   ::aRow[ nNum ]    = uValue
   ::aOldRow[ nNum ] = uValue
#endif /*USE_HASH*/    

RETURN NIL


//----------------------------------------------------//


METHOD SetNewFilter( nType, cFilter, lRefresh ) CLASS TDolphinQry 
   LOCAL cOldFilter

   DEFAULT lRefresh TO .T.
   
   
   SWITCH nType
      CASE SET_WHERE
         cOldFilter = ::cWhere
         ::cWhere = cFilter
         EXIT
      CASE SET_GROUP
         cOldFilter = ::cGroup
         ::cGroup = cFilter 
         EXIT
      CASE SET_HAVING
         cOldFilter = ::cHaving      
         ::cHaving = cFilter
         EXIT
      CASE SET_ORDER
         cOldFilter = ::cOrder      
         ::cOrder = cFilter 
         EXIT
      CASE SET_LIMIT
         cOldFilter = ::cLimit  
         IF ValType( cFilter ) == "C"
            ::cLimit = cFilter
         ELSEIF ValType( cFilter ) == "N"
            ::cLimit = AllTrim( Str( cFilter ) )
         ENDIF
         EXIT
   ENDSWITCH
 
   IF lRefresh 
      ::cQuery := ::BuildQuery( ::aColumns, ::aTables, ::cWhere, ::cGroup, ::cHaving, ::cOrder, ::cLimit )
      ::LoadQuery( .F. )
   ENDIF

RETURN cOldFilter

//----------------------------------------------------//


METHOD Skip( nRecords ) CLASS TDolphinQry

   LOCAL n := ::nRecNo

   DEFAULT nRecords TO 1

   IF nRecords == 0
      // No move

   ELSEIF nRecords <= 1
      // Negative movement
      if ( ::nRecNo += nRecords ) <= 1
         ::nRecNo = 1
         ::lBof   = .T.
         ::lEof   = ::nRecNo >= ::nRecCount
      endif

   ELSE
      // positive movement
      IF ( ::nRecNo += nRecords ) >= ::nRecCount
         ::nRecNo = ::nRecCount
         ::lEof   = .T.
         ::lBof   = ::nRecNo <= 1
      ENDIF

   ENDIF

   IF ::GetRow( ::nRecNo ) > 0

      IF ::Eof()
         IF ::bEoF != nil
            Eval( ::bEoF, Self )
         ENDIF
      ENDIF
   
      IF ::BoF()
         IF ::bBoF != nil
            Eval( ::bBoF, Self )
         ENDIF
      ENDIF
   ENDIF
   
RETURN ::nRecNo - n

//----------------------------------------------------//

#ifdef __HARBOUR__
   METHOD ONERROR( uParam1 ) CLASS TDolphinQry
      LOCAL cCol   := __GetMessage()
      LOCAL lAssign := .F., nCol
      LOCAL oError := ErrorNew()
      LOCAL nError := If( SubStr( cCol, 1, 1 ) == "_", 1005, 1004 )      
#else
   METHOD ONERROR( cCol, nError ) CLASS TDolphinQry
      LOCAL uParam1
      LOCAL lAssign
      LOCAL oError := ErrorNew()
      IF Len( HB_AParams() ) > 0
         uParam1 = HB_AParams()[ 1 ]
      ENDIF
#endif

   IF Substr( cCol, 1, 1 ) != "_"
      cCol := "_" + D_LowerCase( cCol )
      lAssign = .T.
   ELSE 
      cCol = D_LowerCase( cCol )
   ENDIF

#ifdef USE_HASH    

      IF ! ( uParam1 == NIL ) 
         IF hGetPos( ::hRow, cCol ) > 0        
            HSet( ::hRow, cCol, uParam1 )
            RETURN uParam1
         ENDIF
      ELSE
         IF hGetPos( ::hRow, cCol ) > 0
            RETURN ::hRow[ cCol ]
         ENDIF
      ENDIF
#else
      cCol  := If( lAssign := ( Left( cCol, 1 ) == '_' ), SubStr( cCol, 2 ), cCol )

      IF( nCol := ::FieldPos( cCol ) ) > 0
         RETURN If( lAssign, ::FieldPut( nCol, uParam1 ), ::FieldGet( cCol ) )
      ENDIF
     
#endif /*USE_HASH*/

   oError:SubSystem   = "BASE"
   oError:SubCode     = nError
   oError:Severity    = 2 // ES_ERROR
   oError:Description = "Message not found"
   oError:Operation   = "TDOLPHYNQRY: " + cCol   

   Eval( ErrorBlock(), oError )
      

RETURN NIL


