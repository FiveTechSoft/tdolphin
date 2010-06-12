#include <windows.h>   
#include <hbapi.h>
#include <hbapiitm.h>
#include <hbapifs.h>
#include <mysql.h>

// MYSQL *mysql_real_connect( MYSQL*, char * host, char * user, char * password, char * db, uint port, char *, uint flags )
HB_FUNC( MYSQLCONNECT ) // -> MYSQL*
{
   MYSQL * mysql;
   const char *szHost = ( LPSTR ) hb_parc( 1 );
   const char *szUser = ( LPSTR ) hb_parc( 2 );
   const char *szPass = ( LPSTR ) hb_parc( 3 );
   unsigned int port  = ISNUM( 4 ) ? ( unsigned int ) hb_parni( 4 ) :  MYSQL_PORT;
   unsigned int flags = ISNUM( 5 ) ? ( unsigned int ) hb_parni( 5 ) :  0;
   mysql = mysql_init( NULL );
   if ( ( mysql != NULL ) )
   {
   	  mysql_real_connect( mysql, szHost, szUser, szPass, 0, port, NULL, flags );
      hb_retnl( ( long ) mysql );
   }
   else
   {
     hb_retnl( 0 );
   }
}  

//------------------------------------------------//
//void mysql_close(MYSQL *mysql)
HB_FUNC( MYSQLCLOSE )//->none
{
   mysql_close( ( MYSQL * ) hb_parnl( 1 ) );
}

//------------------------------------------------//
// char *mysql_error(MYSQL *mysql)
HB_FUNC( MYSQLERROR ) //-> A null-terminated character string that describes the error. 
                      //   An empty string if no error occurred.
{
   hb_retc( ( char * ) mysql_error( ( MYSQL * ) hb_parnl( 1 ) ) );
}

//------------------------------------------------//
//unsigned int mysql_errno(MYSQL *mysql)
HB_FUNC( MYSQLGETERRNO )//->An error code value for the last mysql_xxx()
{
   hb_retnl( mysql_errno( ( MYSQL * ) hb_parnl( 1 ) ) );
}

//------------------------------------------------//
//int mysql_select_db(MYSQL *mysql, const char *db)
HB_FUNC( MYSQLSELECTDB ) //-> Zero for success. Nonzero if an error occurred.
{
   const   char * db = ( const char* ) hb_parc( 2 );
   hb_retnl( ( long ) mysql_select_db( ( MYSQL * ) hb_parnl( 1 ), db ) );
}