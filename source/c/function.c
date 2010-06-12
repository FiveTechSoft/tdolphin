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
     if( mysql_real_connect( mysql, szHost, szUser, szPass, 0, port, NULL, flags ) )
     {
        hb_retnl( ( long ) mysql );
     }
     else
     {
       mysql_close( mysql );
       hb_retnl( 0 );
     }
   }
   else
   {

     hb_retnl( 0 );
   }
}  