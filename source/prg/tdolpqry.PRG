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
   
   METHOD FCount()   INLINE    ::nFCount
                               /*returns the number of fields in the query, compatibility with dbf*/
                               
   METHOD GetRow( nRow )   
   METHOD GoTo( nRow ) INLINE   ::GetRow( nRow )
                               
   METHOD LastRec()  INLINE     ::nRecCount
                               /*returns the number of rows in the current query, compatibility with dbf*/
                               
   METHOD RecNo()    INLINE    ::nRecNo
                               /*returns the identity found at the position of the row pointer.*/

   
   ERROR HANDLER ONERROR()   
   
ENDCLASS


//----------------------------------------------------//


METHOD New( cQuery, oServer ) CLASS TDolphinQry

   LOCAL aField, nIdx, cCol

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
      //Disable case sensitive
      hSetCaseMatch( ::hRow    ,.F. )
      hSetCaseMatch( ::hOldRow ,.F. )
      FOR each aField in ::aStructure
         cCol := Lower( aField[ MYSQL_FS_NAME ] )
         HSet( ::hRow, "_" + cCol, NIL )
         HSet( ::hOldRow, "_" + cCol, NIL )
      NEXT
      ::GetRow()
   
   ELSE
      IF MySqlFieldCount( oServer:hMysql ) == 0
         oServer:CheckError()
      ENDIF    
   ENDIF   

RETURN Self

//----------------------------------------------------//

METHOD GetRow( nRow ) CLASS TDolphinQry

   LOCAL cType, xField
   LOCAL bBlock
   LOCAL cCol
   LOCAL nIdx

   DEFAULT nRow  TO ::nRecNo

   
   if ::hResult <> NIL
   
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
            cType := ::aStructure[ nIdx ][ MYSQL_FS_TYPE ]

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
            cCol := "_" + Lower( ::aStructure[ nIdx ][ MYSQL_FS_NAME ] )
            HSet( ::hRow, cCol, xField )
            HSet( ::hOldRow, cCol, xField )
         NEXT

      ENDIF

   ENDIF

RETURN ::nRecNo


//-------------------------------------------------------------------------------------------
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
      cCol := "_" + Lower( cCol )
   ELSE 
      cCol = Lower( cCol )
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



