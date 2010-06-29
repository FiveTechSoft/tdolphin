// CLASS TDolphinSrv
// Manager MySql server connection


#include "hbclass.ch"
#include "common.ch"
#include "dbstruct.ch"
#include "tdolphin.ch"
#include "dolerr.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

#ifdef __HARBOUR__
#include "hbcompat.ch"
#ifndef RGB
#define RGB( nR,nG,nB )  ( nR + ( nG * 256 ) + ( nB * 256 * 256 ) )
#endif /*RGB*/
#endif/*__HARBOUR__*/



CLASS TDolphinSrv

   CLASSDATA nQueryId

   DATA bOnError       /*Custom manager error message
                         ( Self, nError, lInternal ) */
                       
   DATA cDBName        /*Data base selected*/
   DATA cPassword      /*Data contains the password for user*/
   DATA cHost          /*Host name, may be either a host name or an IP address */
   DATA cUser          /*DAta contains the user's MySQL login ID*/
                       
   DATA hMysql         /*MySQL connection handle*/
                       
   DATA lError         /*Error detection switch*/
                  
   DATA nFlags         /*Client flags*/
   DATA nInternalError /*error manager, no come from MySQL*/
   DATA nPort          /*value is used as the port number for the TCP/IP connection*/
   
   DATA aQueries       /*Array queries actives*/
   
   METHOD New( cHost, cUser, cPassword, nPort, nFlags, bOnError, cDBName )
   
   METHOD AddUser( cHost, cUser, cPassword, cDb, lCreateDB, acPrivilegs, cWithOption )
                              /*The AddUser() enables system administrators to grant privileges to MySQL user accounts. 
                                AddUser also serves to specify other account characteristics such as use of secure 
                                connections and limits on access to server resources. 
                                To use AddUser(), you must have the GRANT OPTION privilege, 
                                and you must have the privileges that you are granting.*/
                                
   METHOD AddQuery( oQuery )          INLINE AAdd( ::aQueries, oQuery )

   METHOD BeginTransaction()          INLINE ::Execute( "BEGIN" )      
   
   METHOD CheckError( nError )
   
   METHOD CloseQuery( nId )
   
   METHOD CloseAllQuery()             

   METHOD Connect( cHost, cUser, cPassword, nPort, nFlags, cDBName )	
                              /*to establish a connection to a MySQL database engine running on server*/

   METHOD CommitTransaction()         INLINE MySqlCommit( ::hMySql )
                              /*Commits the current transaction.*/

   METHOD CreateIndex( cName, cTable, aFNames, nCons, nType )                              
                              
   METHOD CreateTable( cTable, aStruct, cPrimaryKey, cUniqueKey, cAuto, cExtra )
                              /*creates a table with the cTable name*/

   METHOD DBCreate( cName, lIfNotExist, cCharSet, cCollate )
                              /* Create Database in current active connection*/

                                
   METHOD DBExist( cDB )      INLINE If( ! Empty( cDB ), Len( ::ListDBs( D_LowerCase( cDB ) ) ) > 0, .F. )
                              /* verify is Data Base exist, return logical value*/

   METHOD DeleteDB( cDB, lExists )
                              /*Delete Tables*/
                              
   METHOD DeleteIndex( cName, cTable )         
                              /*Delete Index*/                     
   
   METHOD DeleteTables( acTable, lExists )
                              /*Delete Tables*/
                              
   METHOD DropUser( cUser )             INLINE ::Execute( "DROP USER " + cUser )
                              /*Drop User*/
   
   METHOD End()               
   
   METHOD ErrorTxt()          INLINE  If( ::hMysql != 0, MySqlError( ::hMysql ), "" )
                              /* Returns a string containing the error message for 
                                 the most recently invoked API function that failed.*/
   
   METHOD ErrorNo()           INLINE ::lError := .F., MySqlGetErrNo( ::hMysql )
                              /* Returns the error code for the most recently invoked 
                                API function that can succeed or fail. 
                                A return value of zero means that no error occurred.*/
                                
   METHOD Execute( cQuery )   INLINE ::SqlQuery( cQuery )  

   METHOD GetAutoIncrement( cTable )
                                /*Retrieve next Auto increment value in specified table;
                                 in current database selected*/   
   
   METHOD GetQueryId()   
   
   METHOD GetTotalRows( cTable )
                               /*Retrieve total row avalaible in  specified table;
                                in current database selected*/    
   
   METHOD Insert( cTable, aColumns, aValues, lTransaction )  
                              /*inserts new rows into an existing table.*/

   METHOD IsAutoIncrement( cField, cTable )
                              /* Verify is a field is Auto Increment*/
   
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

   METHOD RenameUser( cUser, cRename )  INLINE ::Execute( "RENAME USER " + D_LowerCase( cUser )+ "@ TO " + cRename )  
                              /*Rename User*/

   METHOD RevokePrivileges( cHost, cUser, cDB, acPrivilegs )
                              /*The RevokePrivileges() enables system administrators to revoke privileges from MySQL accounts.*/
   

   METHOD RollBack()                  INLINE MySqlRollBack( ::hMysql )
                              /* Rolls back the current transaction.*/
                             
   METHOD SelectDB( cDBName ) 
                              /*Select data base in current active connection*/
   
   METHOD SqlQuery( cQuery )  /*Executes the SQL statement pointed to by cQuery, 
                              Normally, the string must consist of a single SQL statement and 
                              you should not add a terminating semicolon (“;”) or \g to the statement. 
                              If multiple-statement execution has been enabled, 
                              the string can contain several statements separated by semicolons.*/
 
   METHOD TableExist( cTable )      INLINE If( ! Empty( cTable ), Len( ::ListTables( D_LowerCase( cTable ) ) ) > 0, .F. )
                              /* verify is table exist, return logical value*/ 
   
   METHOD TableStructure( cTable )  
   
   METHOD Update( cTable, aColumns, aValues, cWhere, lAddSelf, lTransaction )
                             /*inserts new rows into an existing table.*/
                                 
ENDCLASS

//----------------------------------------------------//

METHOD New( cHost, cUser, cPassword, nPort, nFlags, cDBName, bOnError ) CLASS TDolphinSrv

   ::cHost        = cHost
   ::cUser          = cUser
   ::cPassword      = cPassword
   ::nPort          = nPort
   ::nFlags         = nFlags
   ::lError         = .F.
   ::bOnError       = bOnError
   ::nInternalError = 0
   ::cDBName        = cDBName
   ::aQueries       = {}

   ::hMysql         = ::Connect() 
   
   ::CheckError()
   IF ::lError
      ::End()
   ENDIF

RETURN Self


//----------------------------------------------------//

METHOD AddUser( cHost, cUser, cPassword, cDb, lCreateDB, acPrivilegs, cWithOption ) CLASS TDolphinSrv
   LOCAL lReturn := .f.
   LOCAL cQuery  := ""
   LOCAL cDbOld  := ""
   LOCAL cPriv

   DEFAULT cHost     TO ::cHost
   DEFAULT cUser     TO ""
   DEFAULT cPassword TO ""
   DEFAULT cDb       TO "*"
   DEFAULT lCreateDB TO .f.
   DEFAULT acPrivilegs TO "ALL PRIVILEGES"
   DEFAULT cWithOption     TO ""
   

   IF Empty( cHost ) .OR. Empty( cUser ) .OR. Empty( cDb )
      RETURN lReturn
   ENDIF

   cHost     := Alltrim( cHost )
   cUser     := Alltrim( cUser )
   cPassword := Alltrim( cPassword )
   cDb       := Alltrim( cDb )

   IF !::DBExist( cDb ) .AND. lCreateDB
      ::DBCreate( cDb )
   ENDIF
   
   IF ValType( acPrivilegs ) == "A"
      cPriv = SQLStringFromArray( acPrivilegs )
   ELSE 
      cPriv = acPrivilegs
   ENDIF
   

   cQuery  := "GRANT " + cPriv + " ON " + cDb + ".* TO "
   cQuery  += "'" + cUser + "'@'" + cHost + "'"
   IF !Empty( cPassword )
      cQuery  += " IDENTIFIED BY "
      cQuery  += "'" + cPassword + "'"
   ENDIF
   
   IF !Empty( cWithOption )
      cQuery += " WITH " + cWithOption
   ENDIF

   lReturn := ::Execute( cQuery )

RETURN lReturn


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

METHOD CloseQuery( nId ) CLASS TDolphinSrv

   LOCAL nPos := AScan( ::aQueries, {| o | o:nQryId == nId } )
   LOCAL oQry
   
   IF nPos > 0 
      oQry = ::aQueries[ nPos ]
      IF oQry:hResult != 0
         MySqlFreeResult( oQry:hResult )
         oQry:hResult = NIL 
      ENDIF 
      ADel( ::aQueries, nPos )
      ASize( ::aQueries, Len( ::aQueries ) - 1 )
   ENDIF

RETURN NIL 


//----------------------------------------------------//

METHOD CloseAllQuery() CLASS TDolphinSrv           

   LOCAL oQry 
   
   FOR EACH oQry IN ::aQueries
    
      ::CloseQuery( oQry:nQryId ) 
      
   NEXT
   
RETURN NIL

//----------------------------------------------------//

METHOD Connect( cHost, cUser, cPassword, nPort, nFlags, cDBName ) CLASS TDolphinSrv

   
   DEFAULT cHost   TO ::cHost
   DEFAULT cUser     TO ::cUser
   DEFAULT cPassword TO ::cPassword
   DEFAULT nPort     TO ::nPort
   DEFAULT nFlags    TO ::nFlags
   DEFAULT cDBName   TO ::cDBName
   

RETURN MySqlConnect( cHost, cUser, cPassword, nPort, nFlags, cDBName )

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
   

   cQuery += D_LowerCase( cTable ) + " ADD " 
   cQuery += If( nCons == 0, "INDEX ", aIDX_CONST[ nCons ] + " " ) 
   cQuery += D_LowerCase( cName ) + " ("

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
   

   cPrimaryKey = If( ! Empty( cPrimaryKey ), D_LowerCase( cPrimaryKey ), "" )
   cAuto       = If( ! Empty( cAuto ), D_LowerCase( cAuto ), "" )
   cUniqueKey  = If( ! Empty( cUniqueKey ), D_LowerCase( cUniqueKey ), "" )
   cExtra      = If( ! Empty( cExtra ), D_LowerCase( cExtra ), "" )

   IF lVer .AND. nLenStruct > 0
      ::CheckError( VerifyStructure( aStruct ) )

      IF ! ::lError .AND. cPrimarykey != NIL
         IF AScan( aStruct, {| aRow | AllTrim( D_LowerCase( aRow[ DBS_NAME ] ) ) == cPrimarykey } ) == 0
            ::nInternalError = ERR_INVALID_STRUCT_PRIKEY
            ::CheckError()
         ENDIF
      ENDIF
   
      IF ! ::lError .AND. cUniquekey != NIL 
         IF AScan( aStruct, {| aRow | AllTrim( D_LowerCase( aRow[ DBS_NAME ] ) ) == cUniquekey } ) == 0
            ::nInternalError = ERR_INVALID_STRUCT_UNIQUE
            ::CheckError()
         ENDIF
      ENDIF
      
      IF ! ::lError .AND. cAuto != NIL 
         IF AScan( aStruct, {| aRow | AllTrim( D_LowerCase( aRow[ DBS_NAME ] ) ) == cAuto } ) == 0
            ::nInternalError = ERR_INVALID_STRUCT_AUTO
            ::CheckError()
         ENDIF
      ENDIF      

      IF ::lError
         RETURN ::lError 
      ENDIF
   ENDIF
   
   cQuery := "CREATE TABLE " + If( lIfNotExist, " IF NOT EXISTS ", "" ) + D_LowerCase( cTable ) + If( nLenStruct > 0, " (", " " )

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
            lAutoIncrement = D_LowerCase( aField[ DBS_NAME ] ) == cAuto
            
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
                        cQuery += aField[ DBS_NAME ] + " bigint("    + AllTrim( Str( aField[ DBS_LEN ] ) ) + ")"
      
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
   
   cQuery += " " + D_LowerCase(  cName )
   
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

   cDB = D_LowerCase( cDB )

   IF lExists
      cQuery += " IF EXISTS "
   ENDIF 
   
   cQuery += cDB

RETURN ::SqlQuery( cQuery ) 
   
//----------------------------------------------------//   

METHOD DeleteIndex( cName, cTable, lPrimary ) CLASS TDolphinSrv

   LOCAL cQuery 
   DEFAULT lPrimary TO .F.
   
   cQuery = "DROP INDEX" + If( lPrimary, " PRIMARY ", " " ) + cName + " ON " + D_LowerCase( cTable )

RETURN ::SqlQuery( cQuery )


//----------------------------------------------------//

METHOD DeleteTables( acTables, lExists ) CLASS TDolphinSrv
   
   LOCAL cTables 
   LOCAL cQuery := "DROP TABLE "
   
   DEFAULT lExists TO .F.

   IF ValType( acTables ) == "A"
       cTables = SqlStringFromArray( acTables )
   ELSE 
       cTables = D_LowerCase( acTables )
   ENDIF 

   IF lExists
      cQuery += " IF EXISTS "
   ENDIF 
   
   cQuery += cTables

RETURN ::SqlQuery( cQuery ) 

//----------------------------------------------------//


METHOD End() CLASS TDolphinSrv

   IF ::hMysql > 0
      MySqlClose( ::hMysql )
      ::hMysql = 0
      AEval( ::aQueries, {| o | o:End() } )
   ENDIF
   
RETURN NIL


//----------------------------------------------------//

METHOD GetAutoIncrement( cTable ) CLASS TDolphinSrv
   LOCAL nId    := 0
   LOCAL oQuery := NIL
   LOCAL cQuery := ""
   LOCAL cOldDB := ""

   DEFAULT cTable TO ""

   IF Empty( cTable )
      RETURN( nId )
   ENDIF
   
   IF !Empty( ::cDBName )
      cOldDB = ::cDBName
   ELSE 
      ::nInternalError = ERR_NODATABASESELECTED
      ::CheckError()
      RETURN nId
   ENDIF
      
   ::SelectDB( "information_schema" )

   cQuery := "SELECT auto_increment "
   cQuery += "FROM tables "
   cQuery += "WHERE table_schema = '"
   cQuery += cOldDB + "'"
   cQuery += " AND table_name = '"
   cQuery += cTable + "'"

   oQuery := TDolphinQry():New( cQuery, Self )
   IF oQuery:LastRec() > 0
      nId := oQuery:FieldGet( 1 )
   ENDIF

   ::SelectDB( cOldDB )
   
   oQuery:End()
   oQuery := NIL

RETURN nId


//----------------------------------------------------//

METHOD GetQueryId() CLASS TDolphinSrv

   DEFAULT ::nQueryId TO 0
   
   ::nQueryId++

RETURN ::nQueryId

//----------------------------------------------------//


METHOD GetTotalRows( oQry ) CLASS TDolphinSrv

   LOCAL nTotal := 0
   LOCAL aOldColumns
   LOCAL cQuery
   LOCAL oQryAux
   
   IF ! oQry != NIL .AND. oQry:IsKindOf( "TDOLPHINQRY" )
      ::nInternalError = ERR_MISSINGQRYOBJECT
      ::CheckError()
      RETURN nTotal 
   ENDIF
   
   aOldColumns = AClone( oQry:aColumns )
   
   cQuery := oQry:BuildQuery( { "COUNT(*)" }, ;
                                oQry:aTables, ;
                                oQry:cWhere, ;
                                oQry:cGroup, ;
                                oQry:cHaving,;
                                oQry:cOrder, ;
                                NIL, ;
                                oQry:cExt )
   
   oQry:BuildQuery( aOldColumns, ;
                    oQry:aTables,;
                    oQry:cWhere, ;
                    oQry:cGroup, ;
                    oQry:cHaving,; 
                    oQry:cOrder, ;
                    oQry:cLimit, ;
                    oQry:cExt )
   
   oQryAux = TDolphinQry():New( cQuery, Self )
   
   nTotal  = oQryAux:FieldGet( 1 )
   
   oQryAux:End()   

RETURN nTotal

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
   
   cExecute := "INSERT INTO " + D_LowerCase( cTable ) + " SET "
   
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
   LOCAL hRes 

   cField = D_LowerCase( cField )
   cTable = D_LowerCase( cTable )


   hRes = MySqlListFields( ::hMysql, cTable, cField )
   
   IF hRes == 0 
      ::CheckError() 
   ELSE   
      aStruct = MySqlResultStructure( hRes, D_SetCaseSensitive() ) 
      MySqlFreeResult( hRes )
      lAuto = IS_AUTO_INCREMENT( aStruct[ 1, MYSQL_FS_FLAGS ] )
   ENDIF
   
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


//---------------------------------------------//

METHOD RevokePrivileges( cHost, cUser, cDB, acPrivilegs ) CLASS TDolphinSrv
   LOCAL lReturn := .f.
   LOCAL cQuery  := ""
   LOCAL cPriv

   DEFAULT cHost     TO ::cHost
   DEFAULT cUser     TO ""
   DEFAULT cDB       TO "*"
   DEFAULT acPrivilegs TO "ALL PRIVILEGES"

   IF Empty( cHost ) .OR. Empty( cUser )
      RETURN lReturn
   ENDIF

   cHost     := Alltrim( cHost )
   cUser     := Alltrim( cUser )
   
   IF ValType( acPrivilegs ) == "A"
      cPriv = SQLStringFromArray( acPrivilegs )
   ELSE 
      cPriv = acPrivilegs
   ENDIF

   cQuery  := "REVOKE " + cPriv + " ON " + cDb + ".* FROM "
   cQuery  += "'" + cUser + "'@'" + cHost + "'"

RETURN ::SqlQuery( cQuery )

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
   LOCAL hRes 


   hRes = MySqlListFields( ::hMysql, cTable )
   
   IF hRes == 0 
      ::CheckError() 
   ELSE
      aStruct = MySqlResultStructure( hRes, D_SetCaseSensitive() ) 
      
      MySqlFreeResult( hRes )
      
      IF Len( aStruct ) == 0
         ::CheckError()
      ENDIF
   ENDIF
   
RETURN aStruct
   
//----------------------------------------------------//   
   
METHOD Update( cTable, aColumns, aValues, cWhere, lTransaction ) CLASS TDolphinSrv

   LOCAL cExecute
   LOCAL lRet, n
   LOCAL aStruc, nPos
   LOCAL lAddSelf := .F.
   LOCAL cValue
   
   DEFAULT lTransaction TO .F.   
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
   
   cExecute := "UPDATE " + D_LowerCase( cTable ) + " SET "
   aStruc = ::TableStructure( cTable )
   FOR n = 1 TO Len( aColumns )
      IF ValType( aValues[ n ] ) == "A"
         lAddSelf = aValues[ n ][ 2 ]
         cValue   = ClipValue2SQL( aValues[ n ][ 1 ] )
      ELSE 
         cValue   = ClipValue2SQL( aValues[ n ] )
      ENDIF
         
      IF lAddSelf
         nPos := AScan( aStruc, {| uItem | Upper( AllTrim( uItem[ 1 ] ) ) == Upper( AllTrim( aColumns[ n ] ) ) } )
         IF nPos > 0 .AND. aStruc[ nPos ][ 2 ] == "M"
            cExecute += aColumns[ n ] + " = CONCAT(" + aColumns[ n ] + ", " + cValue + "),"
         ELSEIF nPos > 0
            cExecute += aColumns[ n ] + " = " + aColumns[ n ] + " + " + cValue + ","
         ELSE 
            ::lError := .T.
            ::nInternalError = ERR_INVALIDCOLUMN
            EXIT
         ENDIF
      ELSE
         cExecute += aColumns[ n ] + " = " + ClipValue2SQL( aValues[ n ] ) + ","
      ENDIF
      lAddSelf = .F.
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
FUNCTION ClipValue2SQL( Value, cType, lTxt )

   

   LOCAL cValue := ""
   LOCAL cTxt   
   
   DEFAULT lTxt TO .T.
   DEFAULT cType to ValType( Value )

   cTxt   := If( lTxt, "'", "" )

   SWITCH cType
      CASE "N"
         cValue := AllTrim( Str( Value ) )
         EXIT
      CASE "I"
         cValue := AllTrim( Str( Value ) )
         EXIT

      CASE "D"
         if ! Empty( Value )
            // MySQL dates are like YYYY-MM-DD or YYYYMMDD
            cValue := cTxt + Transform( Dtos( Value ), "@R 9999-99-99" ) + cTxt
         else
            cValue := "NULL"
         endif
         EXIT

      CASE "C"
         cValue := cTxt + AllTrim( Value ) + cTxt
         EXIT
      CASE "M"
         cValue := cTxt + AllTrim( Value ) + cTxt
         EXIT
      CASE "B"
         IF Empty( Value)
            cValue := "" + cTxt + cTxt + ""
         ELSE
            cValue := cTxt + MySqlEscape( value ) + cTxt
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
         cValue := "" + cTxt + cTxt + ""       // NOTE: Here we lose values we cannot convert

   END

RETURN cValue

//----------------------------------------------------//

FUNCTION SqlDate2Clip( cField )
RETURN  SToD( Left( cField, 4 ) + substr( cField, 6, 2 ) + right( cField, 2 ) )

//----------------------------------------------------//
// Return string from array separated with ","
FUNCTION SqlStringFromArray( aArray )
   
   LOCAL cItem, cString := ""
   

   FOR EACH cItem IN aArray
      cString += D_LowerCase( cItem ) + ", "
   NEXT
   
   cString = Left( cString, Len( cString ) - 2 )
   
RETURN cString

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
      IF D_LowerCase( aField[ DBS_NAME ] ) == cPrimaryKey .OR. D_LowerCase( aField[ DBS_NAME ] ) == cAuto
         cRet = " NOT NULL "
      ENDIF
   ENDIF

RETURN cRet

//----------------------------------------------------//         

FUNCTION ArrayFromSqlString( cString )
   
   LOCAL aArray
   
   aArray := HB_ATokens( cString, "," )
   
RETURN aArray

//----------------------------------------------------//         

FUNCTION BuildQuery( aColumns, aTables, cWhere, cGroup, cHaving, cOrder, cLimit, cExt, lWithRoll )
   LOCAL cQuery := ""
   LOCAL cColumns

   DEFAULT cWhere   TO ""
   DEFAULT cGroup   TO ""
   DEFAULT cHaving  TO ""
   DEFAULT cOrder   TO ""
   DEFAULT cLimit   TO ""
   DEFAULT aTables  TO {}
   DEFAULT aColumns TO {}
   DEFAULT cExt     TO ""
   DEFAULT lWithRoll TO .F.

   cColumns = SQLStringFromArray( aColumns )
   
   IF Empty( cColumns )
      cColumns = "*"
   ENDIF

   cQuery := "SELECT " + cColumns

   IF !Empty( aTables )
      cQuery += " FROM "
      cQuery += SQLStringFromArray( aTables )
   ENDIF
   IF !Empty( cWhere )
      cQuery += " WHERE "
      cQuery += cWhere
   ENDIF
   IF !Empty( cGroup )
      cQuery += " GROUP BY "
      cQuery += cGroup
      IF lWithRoll
         cQuery += " WITH ROLLUP"
      ENDIF
   ENDIF
   IF !Empty( cHaving )
      cQuery += " HAVING "
      cQuery += cHaving
   ENDIF
   IF !Empty( cOrder )
      cQuery += " ORDER BY "
      cQuery += cOrder
   ENDIF
   IF !Empty( cLimit )
      cQuery += " LIMIT "
      cQuery += cLimit
   ENDIF
   
   cQuery += cExt

RETURN cQuery

//----------------------------------------------------//  
// Turn On/Off case sensitive use
// return Last Status
FUNCTION D_SetCaseSensitive( lOnOff )

  LOCAL lOldStatus

  STATIC lStatus := .F.

  lOldStatus = lStatus

  IF PCount() == 1 .AND. ValType( lOnOff ) == "L"
     lStatus = lOnOff
  ENDIF

RETURN lOldStatus

//----------------------------------------------------//  
// Convert lower case if case sesitive is off
FUNCTION D_LowerCase( cText )

   IF ! D_SetCaseSensitive()
      cText = Lower( AllTrim( cText ) )
   ELSE 
      cText = AllTrim( cText )
   ENDIF
   
RETURN cText
   
//----------------------------------------------------//  
// Turn On/Off Hash
// return Last Status
FUNCTION D_SetHash( lOnOff )
   
  LOCAL lOldStatus

  STATIC lStatus := .F.

  lOldStatus = lStatus

  IF PCount() == 1 .AND. ValType( lOnOff ) == "L"
     lStatus = lOnOff
  ENDIF

RETURN lOldStatus

