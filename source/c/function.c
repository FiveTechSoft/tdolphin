#include <windows.h>   
#include <hbapi.h>
#include <hbapiitm.h>
#include <hbapifs.h>
#include <mysql.h>

#ifdef __HARBOUR__
#define hb_retclenAdopt( szText, ulLen )     hb_retclen_buffer( (szText), (ulLen) )
#endif //__HARBOUR__

char * SQL2ClipType( long lType );

LPSTR LToStr( long w )
{
   static char dbl[ HB_MAX_DOUBLE_LENGTH ];
   sprintf( dbl, "%f", ( double ) w );
   * strchr( dbl, '.' ) = 0;
   
   return ( char * ) dbl;
}  

//------------------------------------------------//
// returns parameter bitwise 
HB_FUNC( MYAND )
{
   hb_retnl( hb_parnl( 1 ) & hb_parnl( 2 ) );
}

//------------------------------------------------//
//unsigned long mysql_real_escape_string(MYSQL *mysql, char *to, const char *from, unsigned long length)
HB_FUNC( MYSQLESCAPE )
{
   char *FromBuffer ;
   ULONG iSize, iFromSize ;
   char *ToBuffer;
   BOOL bResult = FALSE ;
   iSize= hb_parclen( 1 ) ;

   FromBuffer = ( CHAR * )hb_parc( 1 ) ;
   if ( iSize )
   {
     ToBuffer = ( char * ) hb_xgrab( ( iSize*2 ) + 1 );
     if ( ToBuffer )
     {
       iSize = mysql_real_escape_string( ( MYSQL * ) hb_parnl( 2 ), ToBuffer, FromBuffer, iSize );
       hb_retclenAdopt( ( char * ) ToBuffer, iSize ) ;
       bResult = TRUE ;
     }
   }
   if ( !bResult )
   {
     // Should we raise a runtime error here????? or just return the original string
     hb_retclen( ( char * ) FromBuffer, iSize ) ;
   }
}

//------------------------------------------------//
// my_bool mysql_commit(MYSQL *mysql)
HB_FUNC( MYSQLCOMMIT )
{
	 int iret = 1;
   MYSQL * hMysql =  ( MYSQL * )hb_parnl( 1 );

   if( hMysql )
      iret = ( int )mysql_commit( hMysql );
   
   hb_retni( iret );
}	


//------------------------------------------------//
// MYSQL *mysql_real_connect( MYSQL*, char * host, char * user, char * password, char * db, uint port, char *, uint flags )
HB_FUNC( MYSQLCONNECT ) // -> MYSQL*
{
   MYSQL * mysql;
   const char *szHost = ( LPSTR ) hb_parc( 1 );
   const char *szUser = ( LPSTR ) hb_parc( 2 );
   const char *szPass = ( LPSTR ) hb_parc( 3 );
   unsigned int port  = ISNUM( 4 ) ? ( unsigned int ) hb_parni( 4 ) :  MYSQL_PORT;
   unsigned int flags = ISNUM( 5 ) ? ( unsigned int ) hb_parni( 5 ) :  0;
   const char *szdb = ISCHAR( 6 ) ? ( LPSTR ) hb_parc( 6 ): 0;
   mysql = mysql_init( NULL );
   if ( ( mysql != NULL ) )
   {
   	  mysql_real_connect( mysql, szHost, szUser, szPass, szdb, port, NULL, flags );
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
//void mysql_data_seek(MYSQL_RES *result, my_ulonglong offset)
HB_FUNC( MYSQLDATASEEK ) // ->void
{
   mysql_data_seek( ( MYSQL_RES * )hb_parnl( 1 ), ( unsigned int )hb_parni( 2 ) );
   hb_ret();
}



//------------------------------------------------//
// char *mysql_error(MYSQL *mysql)
HB_FUNC( MYSQLERROR ) //-> A null-terminated character string that describes the error. 
                      //   An empty string if no error occurred.
{
   hb_retc( ( char * ) mysql_error( ( MYSQL * ) hb_parnl( 1 ) ) );
}


//------------------------------------------------//
// unsigned int mysql_num_fields( MYSQL_RES * )
HB_FUNC( MYSQLFIELDCOUNT ) //-> num fields
{
   hb_retnl( mysql_field_count( ( ( MYSQL * )hb_parnl( 1 ) ) ) );
}


//------------------------------------------------//
// void mysql_free_result( MYSQL_RES * )
HB_FUNC( MYSQLFREERESULT ) // VOID
{
   mysql_free_result( ( MYSQL_RES * )hb_parnl( 1 ) );
}


//------------------------------------------------//
//unsigned int mysql_errno(MYSQL *mysql) 
// MYSQL_RES, [ num_fields ]
HB_FUNC( MYSQLFETCHROW ) // -> array current row data
{
   MYSQL_RES *mresult = ( MYSQL_RES * )hb_parnl( 1 );
   UINT ui, uiNumFields;
   ULONG *pulFieldLengths ;
   MYSQL_ROW mrow;
   PHB_ITEM itRow;

   if( hb_pcount() > 1 )
      uiNumFields = hb_parnl( 2 );
   else
   	  uiNumFields = mysql_num_fields( mresult );

   itRow           = hb_itemArrayNew( uiNumFields );
   mrow            = mysql_fetch_row( mresult );
   pulFieldLengths = mysql_fetch_lengths( mresult ) ;
   
   if ( mrow )
   {
     for ( ui = 0; ui < uiNumFields; ui++ )
     {
       if ( mrow[ ui ] == NULL )
       {
         hb_arraySetC( itRow, ui + 1, NULL );
       }
       else  
       {
         hb_arraySetCL( itRow, ui + 1, mrow[ ui ], pulFieldLengths[ ui ] );
       }
     }
   }
   hb_itemReturnRelease( itRow );

}


//------------------------------------------------//
//unsigned int mysql_errno(MYSQL *mysql)
HB_FUNC( MYSQLGETERRNO )//->An error code value for the last mysql_xxx()
{
   hb_retnl( mysql_errno( ( MYSQL * ) hb_parnl( 1 ) ) );
}

//------------------------------------------------//
//MYSQL_RES *mysql_list_tables(MYSQL *mysql, const char *wild)
HB_FUNC( MYSQLLISTTBLS ) //->Array List Table
{
   MYSQL * mysql = ( MYSQL * ) hb_parnl( 1 );
   const char *szwild = ( const char* ) hb_parc( 2 );
   MYSQL_RES * mresult = NULL;
   MYSQL_ROW mrow;
   long nr, i;
   PHB_ITEM itemReturn;

   if( mysql )
      mresult = mysql_list_tables( mysql, szwild );

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
HB_FUNC( MYSQLLISTDBS ) //->Array List Databases
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
//my_ulonglong mysql_num_rows(MYSQL_RES *result)
HB_FUNC( MYSQLNUMROWS ) // -> The number of rows in the result set.
{
   hb_retnll( ( LONGLONG )mysql_num_rows( ( ( MYSQL_RES * )hb_parnl( 1 ) ) ) );
}


//------------------------------------------------//
//int mysql_options(MYSQL *mysql, enum mysql_option option, const void *arg)
HB_FUNC( MYSQLOPTION )
{
	const void *arg = ( const void * ) hb_param( 1, HB_IT_ANY );
	MYSQL *mysql = ( MYSQL * ) hb_parnl( 1 );
  int iret = 1;
	if( mysql )
	   iret = mysql_options( mysql, hb_parnl( 2 ), arg );
	   
	hb_retni( iret );
}

//------------------------------------------------//
//int mysql_ping(MYSQL *mysql)
HB_FUNC( MYSQLPING )//Zero if the connection to the server is alive. Nonzero if an error occurred
{
   int nping = 1;
   MYSQL * hMysql =  ( MYSQL * )hb_parnl( 1 );
   
   if( hMysql )
      nping = mysql_ping( hMysql );
   
   hb_retni( nping );
}

//------------------------------------------------//
//int mysql_real_query(MYSQL *mysql, const char *stmt_str, unsigned long length)
HB_FUNC( MYSQLQUERY ) //
{
   hb_retnl( ( long ) mysql_real_query( ( MYSQL * )hb_parnl( 1 ),
              ( const char * ) hb_parc( 2 ),
              ( unsigned long ) hb_parnl( 3 ) ) ) ;
}

//------------------------------------------------//
// my_bool mysql_rollback(MYSQL *mysql)
HB_FUNC( MYSQLROLLBACK )
{
	 int iret = 1;
   MYSQL * hMysql =  ( MYSQL * )hb_parnl( 1 );

   if( hMysql )
      iret = ( int )mysql_rollback( hMysql );
   
   hb_retni( iret );
}	


//------------------------------------------------//
//int mysql_select_db(MYSQL *mysql, const char *db)
HB_FUNC( MYSQLSELECTDB ) //-> Zero for success. Nonzero if an error occurred.
{
   const   char * db = ( const char* ) hb_parc( 2 );
   hb_retnl( ( long ) mysql_select_db( ( MYSQL * ) hb_parnl( 1 ), db ) );
}

//------------------------------------------------//
//MYSQL_RES *mysql_list_fields(MYSQL *mysql, const char *table, const char *wild)
HB_FUNC( MYSQLLISTFIELDS ) // -> MYSQL_RES *
{
   hb_retnl( ( LONG ) mysql_list_fields( ( MYSQL * )hb_parnl( 1 ), hb_parc( 2 ), hb_parc( 3 ) ) );
}


//------------------------------------------------//
// Build a Array with table structure 
HB_FUNC( MYSQLRESULTSTRUCTURE ) //-> Query result Structure
{
	MYSQL_RES * mresult = ( MYSQL_RES * ) hb_parnl( 1 );
	unsigned int num_fields;
	PHB_ITEM itemReturn = hb_itemArrayNew( 0 );
	PHB_ITEM itemField = hb_itemNew( NULL );
	MYSQL_FIELD *mfield;
	
	
	if( mresult )
  {
  	 unsigned int i;
     num_fields = mysql_num_fields( mresult );
     for( i = 0; i < num_fields; i++)
     {
     	  mfield = mysql_fetch_field( mresult ) ;
        hb_arrayNew( itemField, 8 );
        hb_arraySetC( itemField, 1, mfield->name );     
        hb_arraySetC( itemField, 2, mfield->table );
        hb_arraySetC( itemField, 3, mfield->def );
        hb_arraySetC( itemField, 4, SQL2ClipType( ( long ) mfield->type ) );
        hb_arraySetNL( itemField, 5, mfield->length );
        hb_arraySetNL( itemField, 6, mfield->max_length );
        hb_arraySetNL( itemField, 7, mfield->flags );
        hb_arraySetNL( itemField, 8, mfield->decimals );        	
     	  hb_arrayAddForward( itemReturn, itemField );
      }
  } else
     itemReturn = hb_itemArrayNew( 0 );

   hb_itemRelease( itemField );
   hb_itemReturnRelease( itemReturn );
}


//------------------------------------------------//
// MYSQL_RES *mysql_store_result(MYSQL *mysql)
HB_FUNC( MYSQLSTORERESULT ) // -> MYSQL_RES 
{
   hb_retnl( ( long ) mysql_store_result( ( MYSQL * )hb_parnl( 1 ) ) );
}

//------------------------------------------------//
// convert MySql field type to clipper field type
char * SQL2ClipType( long lType ) //-> Clipper field type 
{
	 char * sType;
	 
   switch ( lType ){

      case FIELD_TYPE_DECIMAL     :
         sType = "N";
         break;

      case FIELD_TYPE_NEWDECIMAL  :
         sType = "N";
         break;

      case FIELD_TYPE_TINY        :
         sType = "L";
         break;

      case FIELD_TYPE_SHORT       :
         sType = "N";
         break;
         
      case FIELD_TYPE_LONG        :
         sType = "N";
         break;
         
      case FIELD_TYPE_FLOAT       :
         sType = "N";
         break;
         
      case FIELD_TYPE_DOUBLE      :
         sType = "N";
         break;
         
      case FIELD_TYPE_NULL        :
         sType = "U";
         break;
         
      case FIELD_TYPE_TIMESTAMP   :
         sType = "T";
         break;
         
      case FIELD_TYPE_LONGLONG    :
         sType = "N";
         break;
         
      case FIELD_TYPE_INT24       :
         sType = "N";
         break;
         
      case FIELD_TYPE_DATE        :
         sType = "D";
         break;
         
      case FIELD_TYPE_TIME        :
         sType = "C";
         break;
         
      case FIELD_TYPE_DATETIME    :
         sType = "C";
         break;
         
      case FIELD_TYPE_YEAR        :
         sType = "N";
         break;
         
      case FIELD_TYPE_MEDIUM_BLOB :
         sType = "M";
         break;
      	
      case FIELD_TYPE_LONG_BLOB   :
         sType = "M";
         break;

      case FIELD_TYPE_BLOB        :
         sType = "M";
         break;

      case FIELD_TYPE_STRING      :
         sType = "C";
         break;
         
      case FIELD_TYPE_BIT         :      	
         sType = "L";
         break;
      case FIELD_TYPE_NEWDATE     :
      case FIELD_TYPE_ENUM        :
      case FIELD_TYPE_SET         :
      case FIELD_TYPE_TINY_BLOB   :         
      case FIELD_TYPE_GEOMETRY    :
      default:
      	sType = "U";

 }

   return sType;
}

//------------------------------------------------//

HB_FUNC( SQL2CLIPTYPE )
{
	hb_retc( SQL2ClipType( hb_parnl( 1 ) ) );
}

//------------------------------------------------//
HB_FUNC( GETTICKCOUNT )
{
   hb_retnl( GetTickCount() );
}

//------------------------------------------------//

