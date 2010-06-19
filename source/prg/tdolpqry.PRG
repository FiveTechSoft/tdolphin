// CLASS TDolphinQry
// Manager MySql Queries


#include "hbclass.ch"
#include "common.ch"
#include "dbstruct.ch"
#include "tdolphin.ch"
#include "dolerr.ch"


CLASS TDolphinQry

   
   DATA aStructure
   
   DATA cQuery

   DATA hResult

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
                               
   METHOD LastRec() INLINE     ::nRecCount
                               /*returns the number of rows in the current query, compatibility with dbf*/
                               
   METHOD RecNo()    INLINE    ::nRecNo
                               /*returns the identity found at the position of the row pointer.*/

   
ENDCLASS


//----------------------------------------------------//


METHOD New( cQuery, oServer ) CLASS TDolphinQry

   IF oServer == NIL
      RETURN NIL 
   ENDIF   

   ::oServer = oServer
   ::cQuery  = cQuery

   ::nRecCount = 0
   ::nRecNo    = 0
   ::nFCount   = 0

   ::lEof      := .T.
   ::lBof      := .T.   

   IF cQuery == NIL .OR. ! oServer:SQLQuery( cQuery )
      RETURN Self 
   ENDIF 
   
   
   ::hResult := MySqlStoreResult( oServer:hMysql )
   
   IF ::hResult == 0 
      IF MySqlFieldCount( oServer:hMysql ) == 0
         oServer:CheckError()
         RETURN Self
      ENDIF 
   ENDIF   

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
   

RETURN Self





