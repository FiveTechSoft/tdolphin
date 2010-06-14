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
/*
//------------------------------------------------//
// MYSQL *, char * cTable, char * cwild
HB_FUNC( MYGETFIELDINFO ) //-> Array with field info
{
	 MYSQL_RES * mresult;
	 PHB_ITEM itemReturn = hb_itemArrayNew( 0 );
	 PHB_ITEM itemField = hb_itemNew( NULL );
	 MYSQL_FIELD *mfield;
	
   mresult = mysql_list_fields( ( MYSQL * )hb_parnl( 1 ), hb_parc( 2 ), hb_parc( 3 ) );

   PHB_ITEM itField = hb_itemArrayNew( 8 );
   
   mfield = mysql_fetch_field( ( MYSQL_RES * ) hb_parnl( 1 ) );

   if ( !( mfield == NULL ) )
   {
      hb_arraySetC( itField, 1, mfield->name );
      hb_arraySetC( itField, 2, mfield->table );
      hb_arraySetC( itField, 3, mfield->def );
      hb_arraySetNL( itField, 4, ( long ) mfield->type );
      hb_arraySetNL( itField, 5, mfield->length );
      hb_arraySetNL( itField, 6, mfield->max_length );
      hb_arraySetNL( itField, 7, mfield->flags );
      hb_arraySetNL( itField, 8, mfield->decimals );
   }

   hb_itemReturnRelease( itField );

}
*/

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
//int mysql_real_query(MYSQL *mysql, const char *stmt_str, unsigned long length)
HB_FUNC( MYSQLQUERY ) //
{
   hb_retnl( ( long ) mysql_real_query( ( MYSQL * )hb_parnl( 1 ),
              ( const char * ) hb_parc( 2 ),
              ( unsigned long ) hb_parnl( 3 ) ) ) ;
}

//------------------------------------------------//
//int mysql_select_db(MYSQL *mysql, const char *db)
HB_FUNC( MYSQLSELECTDB ) //-> Zero for success. Nonzero if an error occurred.
{
   const   char * db = ( const char* ) hb_parc( 2 );
   hb_retnl( ( long ) mysql_select_db( ( MYSQL * ) hb_parnl( 1 ), db ) );
}

//------------------------------------------------//
// Build a Array with table structure 
HB_FUNC( MYTABLESTRUCTURE ) //-> Table Structure
{
	MYSQL_RES * mresult;
	unsigned int num_fields;
	PHB_ITEM itemReturn = hb_itemArrayNew( 0 );
	PHB_ITEM itemField = hb_itemNew( NULL );
	MYSQL_FIELD *mfield;
	
	mresult = mysql_list_fields( ( MYSQL * )hb_parnl( 1 ), hb_parc( 2 ), hb_parc( 3 ) );
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
  	  mysql_free_result( mresult );
  } else
     itemReturn = hb_itemArrayNew( 0 );

   hb_itemRelease( itemField );
   hb_itemReturnRelease( itemReturn );
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
         sType = "B";
         break;
      	
      case FIELD_TYPE_LONG_BLOB   :
         sType = "B";
         break;

      case FIELD_TYPE_BLOB        :
         sType = "B";
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