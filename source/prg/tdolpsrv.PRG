// CLASS TDolphinSrv
// Manager MySql server connection


#include "hbclass.ch"
#include "common.ch"
#include "tdolphin.ch"

#define CRLF Chr( 13 ) + Chr( 10 )

#ifdef __HARBOUR__
#include "hbcompat.ch"
#ifndef RGB
#define RGB( nR,nG,nB )  ( nR + ( nG * 256 ) + ( nB * 256 * 256 ) )
#endif /*RGB*/
#endif/*__HARBOUR__*/


#define ERR_EMPTYDBNAME 9000

CLASS TDolphinSrv

   DATA bOnError    /*Custom manager error message
                      ( Self, nError, lInternal ) */

   DATA cDBName     /*Data base selected*/
   DATA cPassword   /*Data contains the password for user*/
   DATA cServer     /*Host name, may be either a host name or an IP address */
   DATA cUser       /*DAta contains the user's MySQL login ID*/

   DATA hMysql      /*MySQL connection handle*/
                  
   DATA lError      /*Error detection switch*/
                  
   DATA nFlags      /*Client flags*/
   DATA nInternalError /*error manager, no come from MySQL*/
   DATA nPort       /*value is used as the port number for the TCP/IP connection*/
   
   METHOD New( cServer, cUser, cPassword, nPort, nFlags, bOnError )
   
   METHOD CheckError( nError )
   METHOD Connect( cServer, cUser, cPassword, nPort, nFlags )	
   
   METHOD End()        INLINE MySqlClose( ::hMysql )
   
   METHOD ErrorTxt()   INLINE  If( ::hMysql != 0, MySqlError( ::hMysql ), "" )
   METHOD ErrorNo()    INLINE ::lError := .F., MySqlGetErrNo( ::hMysql )
   
   METHOD SelectDB( cDBName ) /*Select data base in current active connection*/

   
ENDCLASS

//----------------------------------------------------//

METHOD New( cServer, cUser, cPassword, nPort, nFlags, bOnError ) CLASS TDolphinSrv

   ::cServer        = cServer
   ::cUser          = cUser
   ::cPassword      = cPassword
   ::nPort          = nPort
   ::nFlags         = nFlags
   ::lError         = .F.
   ::bOnError       = bOnError
   ::nInternalError = 0

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


METHOD Connect( cServer, cUser, cPassword, nPort, nFlags ) CLASS TDolphinSrv

   
   DEFAULT cServer   TO ::cServer
   DEFAULT cUser     TO ::cUser
   DEFAULT cPassword TO ::cPassword
   DEFAULT nPort     TO ::nPort
   DEFAULT nFlags    TO ::nFlags
   

RETURN MySqlConnect( cServer, cUser, cPassword, nPort, nFlags )

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