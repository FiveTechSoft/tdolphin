// CLASS TDolphinSrv
// Manager MySql server connection


#include "hbclass.ch"
#include "common.ch"
#include "dbstruct.ch"
#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

#ifdef __HARBOUR__
#include "hbcompat.ch"
#ifndef RGB
#define RGB( nR,nG,nB )  ( nR + ( nG * 256 ) + ( nB * 256 * 256 ) )
#endif /*RGB*/
#endif/*__HARBOUR__*/


#define ERR_EMPTYDBNAME                  9000
#define ERR_INVALID_STRUCT_ROW_SIZE      9001
#define ERR_INVALID_STRUCT_NOTNULL_VALUE 9002
#define ERR_INVALID_STRUCT_PRIKEY        9003
#define ERR_INVALID_STRUCT_UNIQUE        9004
#define ERR_INVALID_STRUCT_AUTO          9005
#define ERR_NOQUERY                      9006
#define ERR_EMPTYVALUES                  9007
#define ERR_EMPTYTABLE                   9008
#define ERR_NOMATCHCOLUMNSVALUES         9009
#define ERR_INVALIDCOLUMN                9010


CLASS TDolphinSrv

   DATA bOnError       /*Custom manager error message
                         ( Self, nError, lInternal ) */
                       
   DATA cDBName        /*Data base selected*/
   DATA cPassword      /*Data contains the password for user*/
   DATA cServer        /*Host name, may be either a host name or an IP address */
   DATA cUser          /*DAta contains the user's MySQL login ID*/
                       
   DATA hMysql         /*MySQL connection handle*/
                       
   DATA lError         /*Error detection switch*/
                  
   DATA nFlags         /*Client flags*/
   DATA nInternalError /*error manager, no come from MySQL*/
   DATA nPort          /*value is used as the port number for the TCP/IP connection*/
   
   METHOD New( cServer, cUser, cPassword, nPort, nFlags, bOnError, cDBName )
   
   
   METHOD BeginTransaction()          INLINE ::Execute( "BEGIN" )      
   
   METHOD CheckError( nError )

   METHOD Connect( cServer, cUser, cPassword, nPort, nFlags, cDBName )	
                              /*to establish a connection to a MySQL database engine running on server*/

   METHOD CommitTransaction()         INLINE MySqlCommit( ::hMySql )
                              /*Commits the current transaction.*/

   METHOD CreateIndex( cName, cTable, aFNames, nCons, nType )                              

   METHOD DBCreate( cName, lIfNotExist, cCharSet, cCollate )
                              /* Create Database in current active connection*/
                              
   METHOD CreateTable( cTable, aStruct, cPrimaryKey, cUniqueKey, cAuto, cExtra )
                              /*creates a table with the cTable name*/

                                
   METHOD DBExist( cDB )      INLINE If( ! Empty( cDB ), Len( ::ListDBs( Lower( cDB ) ) ) > 0, .F. )
                              /* verify is Data Base exist, return logical value*/

   METHOD DeleteDB( cDB, lExists )
                              /*Delete Tables*/
                              
   METHOD DeleteIndex( cName, cTable )         
                              /*Delete Index*/                     
   
   METHOD DeleteTables( acTable, lExists )
                              /*Delete Tables*/
   
   METHOD End()               INLINE  If( ::hMysql > 0, ( MySqlClose( ::hMysql ), ::hMysql := 0 ), )
   
   METHOD ErrorTxt()          INLINE  If( ::hMysql != 0, MySqlError( ::hMysql ), "" )
                              /* Returns a string containing the error message for 
                                 the most recently invoked API function that failed.*/
   
   METHOD ErrorNo()           INLINE ::lError := .F., MySqlGetErrNo( ::hMysql )
                              /* Returns the error code for the most recently invoked 
                                API function that can succeed or fail. 
                                A return value of zero means that no error occurred.*/
                                
   METHOD Execute( cQuery )   INLINE ::SqlQuery( cQuery )  
   
   METHOD Insert( cTable, aColumns, aValues, lTransaction )  
                             /*inserts new rows into an existing table.*/

   METHOD IsAutoIncrement( cField, cTable )
   
   METHOD ListDBs( cWild )    /* Returns a array set consisting of database names on the server 
                                 that match the simple regular expression specified by the wild parameter. 
                                 wild may contain the wildcard characters “%” or “_”, 
                                 or may be a "" to match all databases.*/
   
   METHOD ListTables( cWild ) /* Returns a array set consisting of tables names in current satabase 
                                 that match the simple regular expression specified by the wild parameter. 
                                 wild may contain the wildcard characters “%” or “_”, 
                                 or may be a "" to match all tables.*/
   
   METHOD Ping()                  INLINE If( MySqlPing( ::hMysql ) > 0, ( ::CheckError(), .F.), .T. )
                              /* Checks whether the connection to the server is working. 
                                 If the connection has gone down and auto-reconnect is enabled an attempt 
                                 to reconnect is made. If the connection is down and auto-reconnect is disabled,
                                 ::ping() returns an error.*/

   METHOD RollBack()                  INLINE MySqlRollBack( ::hMysql )
                             /* Rolls back the current transaction.*/
   
   METHOD SelectDB( cDBName ) 
                             /*Select data base in current active connection*/
   
   METHOD SqlQuery( cQuery ) /*Executes the SQL statement pointed to by cQuery, 
                              Normally, the string must consist of a single SQL statement and 
                              you should not add a terminating semicolon (“;”) or \g to the statement. 
                              If multiple-statement execution has been enabled, 
                              the string can contain several statements separated by semicolons.*/
 
   METHOD TableExist( cTable )      INLINE If( ! Empty( cTable ), Len( ::ListTables( Lower( cTable ) ) ) > 0, .F. )
                              /* verify is table exist, return logical value*/ 
   
   METHOD TableStructure( cTable )  
   
   METHOD Update( cTable, aColumns, aValues, cWhere, lAddSelf, lTransaction )
                             /*inserts new rows into an existing table.*/
                                 
ENDCLASS

//----------------------------------------------------//

METHOD New( cServer, cUser, cPassword, nPort, nFlags, cDBName, bOnError ) CLASS TDolphinSrv

   ::cServer        = cServer
   ::cUser          = cUser
   ::cPassword      = cPassword
   ::nPort          = nPort
   ::nFlags         = nFlags
   ::lError         = .F.
   ::bOnError       = bOnError
   ::nInternalError = 0
   ::cDBName        = cDBName

   ::hMysql         = ::Connect() 
   
   ::CheckError()
   IF ::lError
      ::End()
   ENDIF

RETURN Self

//----------------------------------------------------//

METHOD CheckError( nError ) CLASS TDolphinSrv

   LOCAL lInternal := .F.

   DEFAULT nError TO ::ErrorNo()

   IF nError == 0 
      IF ::nInternalError > 0 
         nError = ::nInternalError
         lInternal = .T.
         ::lError    = .T.
      ENDIF
   ELSE 
      ::lError := .T.   
   ENDIF
   
   IF ::lError
      IF ::bOnError != nil
         Eval( ::bOnError, Self, nError, lInternal )
      ENDIF
   ENDIF

RETURN NIL

//----------------------------------------------------//


METHOD Connect( cServer, cUser, cPassword, nPort, nFlags, cDBName ) CLASS TDolphinSrv

   
   DEFAULT cServer   TO ::cServer
   DEFAULT cUser     TO ::cUser
   DEFAULT cPassword TO ::cPassword
   DEFAULT nPort     TO ::nPort
   DEFAULT nFlags    TO ::nFlags
   DEFAULT cDBName   TO ::cDBName
   

RETURN MySqlConnect( cServer, cUser, cPassword, nPort, nFlags, cDBName )

//-----------------------------------------------------------

METHOD CreateIndex( cName, cTable, aFNames, nCons, nType ) CLASS TDolphinSrv

   LOCAL cQuery := "ALTER TABLE "
   LOCAL cField
   LOCAL cConst, cType, cOrden
   LOCAL aIDX_CONST  := { "UNIQUE", "FULLTEXT", "SPATIAL", "PRIMARY KEY" }
   LOCAL aIDX_ORDEN  := { "ASC", "DESC" }
   LOCAL aIDX_TYPE   := { "BTREE", "HASH", "RTREE" }   

   // NOTE: aFNames each item can be array 2 position (1) column name (2) orden type 
   // like numeric, (1) ASC, (2) DESC ie. { "FIELD_NAME", 1 }
   DEFAULT nCons TO 0
   DEFAULT nType TO 0
   

   cQuery += Lower( AllTrim( cTable ) ) + " ADD " 
   cQuery += If( nCons == 0, "INDEX ", aIDX_CONST[ nCons ] + " " ) 
   cQuery += Lower( AllTrim( cName ) ) + " ("

   FOR EACH cField IN aFNames
      IF ValType( cField ) == "A"
         cQuery += cField[ 1 ] + " " + aIDX_ORDEN[ cField[ 2 ] ] + ","
      ELSE 
         cQuery += cField + ","
      ENDIF 
   NEXT
   
   //remove last coma(,)
   cQuery = Left( cQuery, Len( cQuery ) - 1 ) + ") "
   cQuery += If( nType == 0, "", aIDX_TYPE[ nType ] ) 

RETURN ::SqlQuery( cQuery )


//----------------------------------------------------//
//Table Structure
//Name, Type, Length, Decimal, Not Null (logical), Defaul value
METHOD CreateTable( cTable, aStruct, cPrimaryKey, cUniqueKey, cAuto, cExtra, lIfNotExist, lVer ) CLASS TDolphinSrv

   LOCAL aField
   LOCAL cQuery   
   LOCAL bDefault := { | aRow | " DEFAULT " + If( ! ValType( aRow[ DBS_DEFAULT ] ) == "U", ClipValue2SQL( aRow[ DBS_DEFAULT ] ), " NULL" ) }
     
   LOCAL lAutoIncrement
   LOCAL lRet := .T.
   LOCAL nLenStruct := If( ! Empty( aStruct ), Len( aStruct ), 0 ) 

   DEFAULT lVer TO .T.
   DEFAULT lIfNotExist TO .T.
   DEFAULT cPrimaryKey TO ""
   DEFAULT cUniqueKey TO ""
   DEFAULT cExtra TO ""
   

   cPrimaryKey = If( ! Empty( cPrimaryKey ), Lower( AllTrim( cPrimaryKey ) ), "" )
   cAuto       = If( ! Empty( cAuto ), Lower( AllTrim( cAuto ) ), "" )
   cUniqueKey  = If( ! Empty( cUniqueKey ), Lower( AllTrim( cUniqueKey ) ), "" )
   cExtra      = If( ! Empty( cExtra ), Lower( AllTrim( cExtra ) ), "" )

   IF lVer .AND. nLenStruct > 0
      ::CheckError( VerifyStructure( aStruct ) )

      IF ! ::lError .AND. cPrimarykey != NIL
         IF AScan( aStruct, {| aRow | AllTrim( Lower( aRow[ DBS_NAME ] ) ) == cPrimarykey } ) == 0
            ::nInternalError = ERR_INVALID_STRUCT_PRIKEY
            ::CheckError()
         ENDIF
      ENDIF
   
      IF ! ::lError .AND. cUniquekey != NIL 
         IF AScan( aStruct, {| aRow | AllTrim( Lower( aRow[ DBS_NAME ] ) ) == cUniquekey } ) == 0
            ::nInternalError = ERR_INVALID_STRUCT_UNIQUE
            ::CheckError()
         ENDIF
      ENDIF
      
      IF ! ::lError .AND. cAuto != NIL 
         IF AScan( aStruct, {| aRow | AllTrim( Lower( aRow[ DBS_NAME ] ) ) == cAuto } ) == 0
            ::nInternalError = ERR_INVALID_STRUCT_AUTO
            ::CheckError()
         ENDIF
      ENDIF      

      IF ::lError
         RETURN ::lError 
      ENDIF
   ENDIF
   
   cQuery := "CREATE TABLE " + If( lIfNotExist, " IF NOT EXISTS ", "" ) + Lower( cTable ) + If( nLenStruct > 0, " (", " " )

   IF nLenStruct > 0
   
      FOR EACH aField IN aStruct
         SWITCH aField[ DBS_TYPE ]
         CASE "C"
            cQuery += aField[ DBS_NAME ] + " char(" + AllTrim( Str( aField[ DBS_LEN ] ) ) + ")" + ;
                      fNotNull( aField, cPrimaryKey, cAuto ) + Eval( bDefault, aField ) + ","
            EXIT
   
         CASE "M"
            cQuery += aField[ DBS_NAME ] + " text" + fNotNull( aField, cPrimaryKey, cAuto ) + ","
            EXIT
   
         CASE "N"
            lAutoIncrement = Lower( AllTrim( aField[ DBS_NAME ] ) ) == cAuto
            
            IF aField[ DBS_DEC ] == 0 .AND. aField[ DBS_LEN ] <= 18 
               IF lAutoIncrement
                  cQuery += aField[ DBS_NAME ] + " int("       + AllTrim( Str( aField[ DBS_LEN ] ) ) + ")"
               ELSE
                  DO CASE
                     CASE aField[ DBS_LEN ] <= 4
                        cQuery += aField[ DBS_NAME ] + " smallint("  + AllTrim( Str( aField[ DBS_LEN ] ) ) + ")"
      
                     CASE aField[ DBS_LEN ] <= 6
                        cQuery += aField[ DBS_NAME ] + " mediumint(" + AllTrim( Str( aField[ DBS_LEN ] ) ) + ")"
      
                     CASE aField[ DBS_LEN ] <= 9
                        cQuery += aField[ DBS_NAME ] + " int("       + AllTrim( Str( aField[ DBS_LEN ] ) ) + ")"
      
                     OTHERWISE
                        cQuery += aField[ DBS_NAME ] + " long("    + AllTrim( Str( aField[ DBS_LEN ] ) ) + ")"
      
                  ENDCASE
               ENDIF
   
               cQuery += fNotNull( aField, cPrimaryKey, cAuto ) + ;
                         If( lAutoIncrement, " auto_increment", ;
                             Eval( bDefault, aField ) ) + ","
   
            ELSE
               cQuery += aField[ DBS_NAME ] + " decimal(" + AllTrim( Str( aField[ DBS_LEN ] ) ) + "," + ;
                         AllTrim( Str( aField[ DBS_DEC ] ) ) + ")" + fNotNull( aField, cPrimaryKey, cAuto ) + Eval( bDefault, aField ) + ","
   
            ENDIF
            EXIT
   
         CASE "D"
            cQuery += aField[ DBS_NAME ] + " date " + fNotNull( aField, cPrimaryKey, cAuto ) + Eval( bDefault, aField ) + ","
            EXIT
   
         CASE "L"
            cQuery += aField[ DBS_NAME ] + " tinyint (1)" + fNotNull( aField, cPrimaryKey, cAuto ) + Eval( bDefault, aField ) + ","
            EXIT
   
         CASE "B"
            cQuery += aField[ DBS_NAME ] + " mediumblob " + fNotNull( aField, cPrimaryKey, cAuto ) + Eval( bDefault, aField ) + ","
            EXIT
   
         CASE "I"
            cQuery += aField[ DBS_NAME ] + " mediumint " + fNotNull( aField, cPrimaryKey, cAuto ) + Eval( bDefault, aField ) + ","
            EXIT
   
         CASE "T"
            cQuery += aField[ DBS_NAME ] + " timestamp(" + AllTrim( Str( aField[ DBS_LEN ] ) ) + ")" + fNotNull( aField, cPrimaryKey, cAuto ) + Eval( bDefault, aField ) + ","
            EXIT
   
   #ifdef __XHARBOUR__
         DEFAULT
   #else
         OTHERWISE
   #endif            
            cQuery += aField[ DBS_NAME ] + " char(" + AllTrim(Str(aField[DBS_LEN])) + ")" + fNotNull( aField, cPrimaryKey, cAuto ) + Eval( bDefault, aField ) + ","
   
         END
   
      NEXT
   
      IF cPrimarykey != NIL
         cQuery += ' PRIMARY KEY (' + cPrimaryKey + '),'
      ENDIF
   
      IF ::nInternalError == 0 .AND. cUniquekey != NIL 
         cQuery += ' UNIQUE ' + cUniquekey + ' (' + cUniqueKey + '),'
      ENDIF     
   ENDIF

   // remove last comma from list
   IF nLenStruct > 0
      cQuery := Left( cQuery, Len( cQuery ) - 1 ) + ")" + cExtra + ";"
   ELSE 
      cQuery += cExtra + ";"
   ENDIF
   
RETURN ::SqlQuery( cQuery ) 


//----------------------------------------------------//

METHOD DBCreate( cName, lIfNotExist, cCharSet, cCollate ) CLASS TDolphinSrv

   LOCAL cQuery := "CREATE DATABASE" 
   
   DEFAULT lIfNotExist TO .T.
   
   IF lIfNotExist
      cQuery += " IF NOT EXISTS"
   ENDIF
   
   cQuery += " " + Lower( Alltrim(  cName ) )
   
   IF ! Empty( cCharSet )
      cQuery += " CHARACTER SET " + cCharSet
   ENDIF 
   
   IF ! Empty( cCollate )
      cQuery += " COLLATE  " + cCollate
   ENDIF 

RETURN ::SqlQuery( cQuery )

//----------------------------------------------------//

METHOD DeleteDB( cDB, lExists ) CLASS TDolphinSrv

   LOCAL cQuery := "DROP DATABASE "
   
   DEFAULT lExists TO .F.

   cDB = Lower( cDB )

   IF lExists
      cQuery += " IF EXISTS "
   ENDIF 
   
   cQuery += cDB

RETURN ::SqlQuery( cQuery ) 
   
//----------------------------------------------------//   

METHOD DeleteIndex( cName, cTable, lPrimary ) CLASS TDolphinSrv

   LOCAL cQuery 
   DEFAULT lPrimary TO .F.
   
   cQuery = "DROP INDEX" + If( lPrimary, " PRIMARY ", " " ) + cName + " ON " + Lower( cTable )

RETURN ::SqlQuery( cQuery )


//----------------------------------------------------//

METHOD DeleteTables( acTables, lExists ) CLASS TDolphinSrv
   
   LOCAL cTables 
   LOCAL cQuery := "DROP TABLE "
   
   DEFAULT lExists TO .F.

   IF ValType( acTables ) == "A"
       cTables = SqlStringFromArray( acTables )
   ELSE 
       cTables = Lower( acTables )
   ENDIF 

   IF lExists
      cQuery += " IF EXISTS "
   ENDIF 
   
   cQuery += cTables

RETURN ::SqlQuery( cQuery ) 

//----------------------------------------------------//

METHOD Insert( cTable, aColumns, aValues, lTransaction ) CLASS TDolphinSrv

   LOCAL cExecute
   LOCAL lRet, n
   
   DEFAULT lTransaction TO .F.
   
   IF Empty( aColumns ) .AND. Empty( aValues ) 
      ::nInternalError = ERR_EMPTYVALUES
      ::CheckError()
      RETURN .F. 
   ENDIF    
   
   IF Empty( cTable ) 
      ::nInternalError = ERR_EMPTYTABLE
      ::CheckError()
      RETURN .F. 
   ENDIF 
   
   IF Len( aColumns ) # Len( aValues )
      ::nInternalError = ERR_NOMATCHCOLUMNSVALUES
      ::CheckError()
      RETURN .F. 
   ENDIF 
   
   cExecute := "INSERT INTO " + Lower( cTable ) + " SET "
   
   FOR n = 1 TO Len( aColumns )
      cExecute += aColumns[ n ] + " = " + ClipValue2SQL( aValues[ n ] ) + ","
   NEXT 
   IF lTransaction
      ::BeginTransaction()
   ENDIF   
   //Delete last coma 
   cExecute = SubStr( cExecute, 1, Len( cExecute ) - 1 )

   lRet = ::Execute( cExecute )  
   
   IF lTransaction
      IF lRet
         ::CommitTransaction()
      ELSE 
         ::RollBack()
      ENDIF
   ENDIF   
   
  
RETURN lRet

//----------------------------------------------------//

METHOD IsAutoIncrement( cField, cTable ) CLASS TDolphinSrv

   LOCAL lAuto := .F.
   LOCAL aStruct
   
   cField = Lower( Alltrim( cField ) )
   cTable = Lower( Alltrim( cTable ) )
 
   aStruct = MyTableStructure( ::hMysql, cTable, cField )
     
   lAuto = MyAnd( aStruct[ 1, MYSQL_FS_FLAGS ], AUTO_INCREMENT_FLAG ) == AUTO_INCREMENT_FLAG

return( lAuto )


//----------------------------------------------------//

METHOD ListDBs( cWild ) CLASS TDolphinSrv
   LOCAL aList
      
   aList = MySqlListDBs( ::hMysql, cWild ) 
   ::CheckError()
   
RETURN aList


//----------------------------------------------------//

   
METHOD ListTables( cWild ) CLASS TDolphinSrv
   LOCAL aList

   aList = MysqlListTbls( ::hMysql, cWild )
   ::CheckError()

RETURN aList


//----------------------------------------------------//

METHOD SelectDB( cDBName ) CLASS TDolphinSrv

   LOCAL nError 
   
   ::lError := .F.

   IF Empty( cDBName )
      ::nInternalError = ERR_EMPTYDBNAME
      ::CheckError()
      RETURN .F.
   ENDIF

   IF ( nError := MysqlSelectDB( ::hMysql, cDBName ) ) != 0   // table not exist
      ::cDBName :=""
      ::lError  := .T.
      ::CheckError( nError )
   ELSE                                       // table exist
      ::cDBName := cDBName
      ::lError  := .F.
      RETURN .T.
   ENDIF

RETURN .F.

//----------------------------------------------------//

METHOD SQLQuery( cQuery ) CLASS TDolphinSrv

   LOCAL nLen := If( ! Empty( cQuery ), Len( cQuery ), 0 )
   LOCAL nRet
      
   IF nLen > 0
      IF ( nRet := MySqlQuery( ::hMysql, cQuery, nLen ) ) > 0
         ::CheckError()
      ENDIF
   ELSE 
      ::nInternalError = ERR_NOQUERY
      ::CheckError()
      nRet = ::nInternalError
   ENDIF

RETURN nRet == 0

//----------------------------------------------------//

METHOD TableStructure( cTable )  CLASS TDolphinSrv

   LOCAL aStruct := {}
   LOCAL n

   aStruct = MyTableStructure( ::hMysql, cTable )
   
   IF Len( aStruct ) == 0
      ::CheckError()
   ENDIF

RETURN aStruct
   
//----------------------------------------------------//   
   
METHOD Update( cTable, aColumns, aValues, cWhere, lAddSelf, lTransaction ) CLASS TDolphinSrv

   LOCAL cExecute
   LOCAL lRet, n
   LOCAL aStruc, nPos
   
   DEFAULT lTransaction TO .F.   
   DEFAULT lAddSelf     TO .F.   
   DEFAULT cWhere       TO ""
   
   IF Empty( aColumns ) .OR. Empty( aValues )
      ::nInternalError = ERR_EMPTYVALUES
      ::CheckError()
      RETURN .F. 
   ENDIF 
   
   
   IF Empty( cTable ) 
      ::nInternalError = ERR_EMPTYTABLE
      ::CheckError()
      RETURN .F. 
   ENDIF 
   
   IF Len( aColumns ) # Len( aValues )
      ::nInternalError = ERR_NOMATCHCOLUMNSVALUES
      ::CheckError()
      RETURN .F. 
   ENDIF 
   
   cExecute := "UPDATE " + Lower( cTable ) + " SET "
   aStruc = ::TableStructure( cTable )
   FOR n = 1 TO Len( aColumns )
      IF lAddSelf
         nPos := AScan( aStruc, {| uItem | Upper( AllTrim( uItem[ 1 ] ) ) == Upper( AllTrim( aColumns[ n ] ) ) } )
         IF nPos > 0 .AND. aStruc[ nPos ][ 2 ] == "M"
            cExecute += aColumns[ n ] + " = CONCAT(" + aColumns[ n ] + ", " + ClipValue2SQL( aValues[ n ] ) + "),"
         ELSEIF nPos > 0
            cExecute += aColumns[ n ] + " = " + aColumns[ n ] + " + " + ClipValue2SQL( aValues[ n ] ) + ","
         ELSE 
            ::lError := .T.
            ::nInternalError = ERR_INVALIDCOLUMN
            EXIT
         ENDIF
      ELSE
         cExecute += aColumns[ n ] + " = " + ClipValue2SQL( aValues[ n ] ) + ","
      ENDIF
   NEXT 
   IF ! ::lError
      //Delete last comma 
      cExecute = SubStr( cExecute, 1, Len( cExecute ) - 1 )
      IF !Empty( cWhere )
         cExecute += " WHERE " + cWhere
      ENDIF
      lRet = ::Execute( cExecute )   
   ELSE 
      lRet = .F.
      ::CheckError()
   ENDIF
   
   IF lTransaction
      IF lRet
         ::CommitTransaction()
      ELSE 
         ::RollBack()
      ENDIF
   ENDIF   

RETURN lRet   
   
//----------------------------------------------------//
//----------------------------------------------------//
//----------------------------------------------------//
//----------------------------------------------------//

// Returns an SQL string with clipper value converted ie. Date() -> "'YYYY-MM-DD'"
FUNCTION ClipValue2SQL( Value, cType )

   LOCAL cValue := ""

   DEFAULT cType to ValType( Value )

   switch cType
      CASE "N"
         cValue := AllTrim( Str( Value ) )
         EXIT
      CASE "I"
         cValue := AllTrim( Str( Value ) )
         EXIT

      CASE "D"
         if ! Empty( Value )
            // MySQL dates are like YYYY-MM-DD or YYYYMMDD
            cValue := "'" + Transform( Dtos( Value ), "@R 9999-99-99" ) + "'"
         else
            cValue := "NULL"
         endif
         EXIT

      CASE "C"
         cValue := "'" + AllTrim( Value ) + "'"
         EXIT
      CASE "M"
         cValue := "'" + AllTrim( Value ) + "'"
         EXIT
      CASE "B"
         IF Empty( Value)
            cValue := "''"
         ELSE
            cValue := "'" + MySqlEscape( value ) + "'"
         ENDIF
         EXIT

      CASE "L"
         cValue := AllTrim( Str( iif(Value, 1, 0 ) ) )
         EXIT

      CASE "T"
         cValue := iif( Value < 0, "NULL", Alltrim( str( Value ) ) )
         EXIT

#ifdef __XHARBOUR__
      DEFAULT
#else 
      OTHERWISE
#endif
         cValue := "''"       // NOTE: Here we lose values we cannot convert

   END

RETURN cValue

//----------------------------------------------------//
// Return string from array separated with ","
STATIC FUNCTION SqlStringFromArray( aArray )
   
   LOCAL cItem, cString := ""
   

   FOR EACH cItem IN aArray
      cString += Lower( cItem ) + ", "
   NEXT
   
   cString = Left( cString, Len( cString ) - 2 )
   
RETURN Lower( cString )

//----------------------------------------------------//

STATIC FUNCTION VerifyStructure( aStruct )
   
   LOCAL aRow 
   LOCAL nError
   
   FOR EACH aRow IN aStruct
      IF Len( aRow ) < DBS_DEFAULT 
         nError = ERR_INVALID_STRUCT_ROW_SIZE
         EXIT 
      ENDIF
      IF ValType( aRow[ DBS_NOTNULL ] ) != "U" .AND. ValType( aRow[ DBS_NOTNULL ] ) != "L"  
         nError = ERR_INVALID_STRUCT_NOTNULL_VALUE
         EXIT 
      ENDIF
   NEXT 

RETURN nError
         
//----------------------------------------------------//         

STATIC FUNCTION fNotNull( aField, cPrimaryKey, cAuto )         
   LOCAL cRet := ""
   
   IF ValType( aField[ DBS_NOTNULL ] ) == "L" .AND. aField[ DBS_NOTNULL ]
      cRet = " NOT NULL "
   ELSE 
      IF Lower( AllTrim( aField[ DBS_NAME ] ) ) == cPrimaryKey .OR. Lower( AllTrim( aField[ DBS_NAME ] ) ) == cAuto
         cRet = " NOT NULL "
      ENDIF
   ENDIF

RETURN cRet