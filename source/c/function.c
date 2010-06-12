#include <windows.h>   
#include <hbapi.h>
#include <hbapiitm.h>
#include <hbapifs.h>
#include <mysql.h>


LPSTR LToStr( long w )
{
   static char dbl[ HB_MAX_DOUBLE_LENGTH ];
   sprintf( dbl, "%f", ( double ) w );
   * strchr( dbl, '.' ) = 0;
   
   return ( char * ) dbl;
}  

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
//MYSQL_RES *mysql_list_tables(MYSQL *mysql, const char *wild)
HB_FUNC( MYSQLLISTTBLS ) //->A MYSQL_RES result set for success. NULL if an error occurred. 
{
   MYSQL * mysql = ( MYSQL * ) hb_parnl( 1 );
   const char *szwild = ( const char* ) hb_parc( 2 );
   MYSQL_RES * mresult = NULL;
   MYSQL_ROW mrow;
   long nr, i;
   PHB_ITEM itemReturn;

//   MessageBox( 0, "paso", "ok", 0 );

   if( mysql )
      mresult = mysql_list_tables( mysql, szwild );

//   MessageBox( 0, LToStr( ( long ) mresult ), "ok", 0 );

   if( mresult )
   {
      nr = ( LONG ) mysql_num_rows( mresult );

      itemReturn = hb_itemArrayNew( nr );
      
      for ( i = 0; i < nr; i++ )
      {
     	   PHB_ITEM pString;
         mrow = mysql_fetch_row( mresult );
         pString = hb_itemPutC( NULL, mrow[ 0 ] );
         hb_itemArrayPut( itemReturn, i+1, pString );
         hb_itemRelease( pString );
         mysql_free_result( mresult );
      }
   }else
   itemReturn = hb_itemArrayNew( 0 );

   hb_itemReturn( itemReturn );
   hb_itemRelease( itemReturn );         

}

//------------------------------------------------//
//MYSQL_RES *mysql_list_dbs(MYSQL *mysql, const char *wild)
HB_FUNC( MYSQLLISTDBS ) //->A MYSQL_RES result set for success. NULL if an error occurred. 
{
   MYSQL * mysql = ( MYSQL * ) hb_parnl( 1 );
   const char *szwild = ( const char* ) hb_parc( 2 );
   MYSQL_RES * mresult = NULL;
   MYSQL_ROW mrow;
   long nr, i;
   PHB_ITEM itemReturn;

   if( mysql )
      mresult = mysql_list_dbs( mysql, szwild );

   if( mresult )
   {
      nr = ( LONG ) mysql_num_rows( mresult );

      itemReturn = hb_itemArrayNew( nr );
      
      for ( i = 0; i < nr; i++ )
      {
     	   PHB_ITEM pString;
         mrow = mysql_fetch_row( mresult );
         pString = hb_itemPutC( NULL, mrow[ 0 ] );
         hb_itemArrayPut( itemReturn, i+1, pString );
         hb_itemRelease( pString );
         mysql_free_result( mresult );
      }
   }else
   itemReturn = hb_itemArrayNew( 0 );

   hb_itemReturn( itemReturn );
   hb_itemRelease( itemReturn );         

}

//------------------------------------------------//
//int mysql_select_db(MYSQL *mysql, const char *db)
HB_FUNC( MYSQLSELECTDB ) //-> Zero for success. Nonzero if an error occurred.
{
   const   char * db = ( const char* ) hb_parc( 2 );
   hb_retnl( ( long ) mysql_select_db( ( MYSQL * ) hb_parnl( 1 ), db ) );
}