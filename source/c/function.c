/*
 * $Id: 10-Jul-10 9:40:28 AM function.c Z dgarciagil $
 */

/*
 * TDOLPHIN PROJECT source code:
 * wrapper function to libmysql.lib
 *
 * Copyright 2010 Daniel Garcia-Gil<danielgarciagil@gmail.com>
 * www - http://tdolphin.blogspot.com/
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception, the tdolphin Project gives permission for
 * additional uses of the text contained in its release of tdolphin.
 *
 * The exception is that, if you link the tdolphin libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the tdolphin library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the tdolphin
 * Project under the name tdolphin.  If you copy code from other
 * tdolphin Project or Free Software Foundation releases into a copy of
 * tdolphin, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for tdolphin, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

#include <windows.h>   
#include <hbapi.h>
#include <hbapiitm.h>
#include <hbapifs.h>
#include <mysql.h>

#ifdef __HARBOUR__
#define hb_retclenAdopt( szText, ulLen )     hb_retclen_buffer( (szText), (ulLen) )
#endif //__HARBOUR__

char * SQL2ClipType( long lType, BOOL bLogical );

LPSTR LToStr( long w )
{
   static char dbl[ HB_MAX_DOUBLE_LENGTH ];
   sprintf( dbl, "%f", ( double ) w );
   * strchr( dbl, '.' ) = 0;
   
   return ( char * ) dbl;
}  

LPSTR DToStr( double w )
{
   static char dbl[ HB_MAX_DOUBLE_LENGTH ];
   sprintf( dbl, "%f", w );
 //  * strchr( dbl, '.' ) = 0;
   
   return ( char * ) dbl;
} 

//------------------------------------------------//
//
HB_FUNC( VAL2ESCAPE )
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
       iSize = mysql_escape_string( ToBuffer, FromBuffer, iSize );
       hb_retclenAdopt( ( char * ) ToBuffer, iSize ) ;
       bResult = TRUE ;
     }
   }
   if ( !bResult )
   {
     hb_retclen( ( char * ) FromBuffer, iSize ) ;
   }
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
     hb_retclen( ( char * ) FromBuffer, iSize ) ;
   }
}



//------------------------------------------------//
// mysql_result, field pos, cSearch, nStart, nEnd
HB_FUNC( MYSEEK ) 
{
   MYSQL_RES * result = ( MYSQL_RES * ) hb_parnl( 1 );
   MYSQL_ROW row;
   unsigned int uii;
   int uiStart = ISNUM( 4 ) ? ( unsigned int ) hb_parni( 4 ) - 1 : 0 ;
   int uiEnd, uiOk = -1;
   unsigned int uiField = hb_parni( 2 ) - 1;
   char * cSearch = ( char *) hb_parc( 3 );
   unsigned long * pulFieldLengths;
   BOOL bSoft = hb_parl( 6 );
   
   
   if (result > 0)
   {
      if( ! ISNUM( 5 ) )
         uiEnd = mysql_num_rows( result );
      else 
      	 uiEnd = hb_parni( 5 ); 

      while( uiStart < uiEnd )
      {
      	mysql_data_seek(result, uiStart);
      	row = mysql_fetch_row( result );
      	pulFieldLengths = mysql_fetch_lengths( result ) ;
        
        if( pulFieldLengths[ uiField ] != 0 )
        {
         	if( bSoft )
         	   pulFieldLengths[ uiField ] = strlen( cSearch );
       	  
         	if( row )
         		 uii = hb_strnicmp( ( const char * ) row[ uiField ], ( const char * ) cSearch, ( long ) pulFieldLengths[ uiField ] );
   
           if( uii == 0 )
           { 
           	 uiOk = uiStart;
           	 break;
           }     
        }
        uiStart++;
      }      	 

   }
   uiOk = uiOk >=0 ? uiOk + 1 : 0;
   hb_retnl( ( long ) uiOk  );
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
	unsigned long ulLen;
	BOOL bCase = hb_parl( 2 );
	BOOL bNoLogical = hb_param( 3, HB_IT_LOGICAL ) ? hb_parl( 3 ) : FALSE;
	
	
	if( mresult )
  {
  	 unsigned int i;
     num_fields = mysql_num_fields( mresult );
     for( i = 0; i < num_fields; i++)
     {
     	  mfield = mysql_fetch_field( mresult ) ;
        hb_arrayNew( itemField, 9 );

        // The fieldname are convert to lower case
     	  hb_arraySetC( itemField, 1, hb_strLower( mfield->name, strlen( mfield->name ) ) ) ;  

        // only table name are affect by case sensitive      
        if( bCase )
           hb_arraySetC( itemField, 2, mfield->table );  
        else
        	 hb_arraySetC( itemField, 2, hb_strLower( mfield->table, strlen( mfield->table ) ) ) ;  
       
//        MessageBox( 0, mfield->name, "ok", 0 );	         	   
        hb_arraySetC( itemField, 3, mfield->def );
        hb_arraySetNL( itemField, 4, mfield->type );
        hb_arraySetNL( itemField, 5, mfield->length );
        hb_arraySetNL( itemField, 6, mfield->max_length );
        hb_arraySetNL( itemField, 7, mfield->flags );
        hb_arraySetNL( itemField, 8, mfield->decimals );   
        hb_arraySetC( itemField, 9, SQL2ClipType( ( long ) mfield->type, bNoLogical ) );
     	  hb_arrayAddForward( itemReturn, itemField );
      }
  } else
     itemReturn = hb_itemArrayNew( 0 );

   hb_itemRelease( itemField );
   hb_itemReturnRelease( itemReturn );
}

//------------------------------------------------//
// Build a Array with table structure 
HB_FUNC( DOLPHINFILLARRAY ) //-> Query result Structure
{
	MYSQL_RES * mresult = ( MYSQL_RES * ) hb_parnl( 1 );
	PHB_ITEM pBlock = HB_ISBLOCK( 2 ) ? hb_param( 2, HB_IT_BLOCK ) : NULL;
	unsigned int num_fields, ui;
	PHB_ITEM itemReturn = hb_itemArrayNew( 0 );
	PHB_ITEM itemRow = hb_itemNew( NULL );
	MYSQL_ROW mrow;
	ULONG *pulFieldLengths ;
	int i = 0;
	
	
	if( mresult )
  {
     num_fields = mysql_num_fields( mresult );
     pulFieldLengths = mysql_fetch_lengths( mresult ) ;
   	 mysql_data_seek( mresult, 0 );

     while( mrow = mysql_fetch_row( mresult ) )
     {
        if ( mrow )
        {
          hb_arrayNew( itemRow, num_fields );
          for ( ui = 0; ui < num_fields; ui++ )
          {
            if ( mrow[ ui ] == NULL )
            {
              hb_arraySetC( itemRow, ui + 1, NULL );
            }
            else  
            {
              hb_arraySetCL( itemRow, ui + 1, mrow[ ui ], pulFieldLengths[ ui ] );
            }
          }
          if( pBlock)
            {
               PHB_ITEM pParam = hb_itemPutNI( NULL, ++i );
               hb_evalBlock( pBlock, itemRow, pParam, 0 );
            }
          hb_arrayAddForward( itemReturn, itemRow );
        }
      }
   }

   hb_itemRelease( itemRow );
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
char * SQL2ClipType( long lType, BOOL bNoLogical ) //-> Clipper field type 
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
         sType = bNoLogical ? "L" : "N";
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

      case MYSQL_TYPE_VAR_STRING  :
         sType = "C";
         break;
         
      case FIELD_TYPE_BIT         :      	
         sType = bNoLogical ? "L" : "N";
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
// convert MySql field type to char
char * SQLType2Char( long lType ) //-> Clipper field type 
{
	 char * sType;
	 
   switch ( lType ){

      case FIELD_TYPE_DECIMAL     :
      case FIELD_TYPE_NEWDECIMAL  :
         sType = "DECIMAL";
         break;

      case FIELD_TYPE_TINY        :
         sType = "TINY";
         break;

      case FIELD_TYPE_SHORT       :
         sType = "SHORT";
         break;
         
      case FIELD_TYPE_LONG        :
         sType = "LONG";
         break;
         
      case FIELD_TYPE_FLOAT       :
         sType = "FLOAT";
         break;
         
      case FIELD_TYPE_DOUBLE      :
         sType = "DOUBLE";
         break;
         
      case FIELD_TYPE_NULL        :
         sType = "NULL";
         break;
         
      case FIELD_TYPE_TIMESTAMP   :
         sType = "TIME STAMP";
         break;
         
      case FIELD_TYPE_LONGLONG    :
         sType = "LONGLONG";
         break;
         
      case FIELD_TYPE_INT24       :
         sType = "INT24";
         break;
         
      case FIELD_TYPE_DATE        :
         sType = "DATE";
         break;
         
      case FIELD_TYPE_TIME        :
         sType = "TIME";
         break;
         
      case FIELD_TYPE_DATETIME    :
         sType = "DATETIME";
         break;
         
      case FIELD_TYPE_YEAR        :
         sType = "YEAR";
         break;
         
      case FIELD_TYPE_MEDIUM_BLOB :
         sType = "MEDIUM BLOB";
         break;
      	
      case FIELD_TYPE_LONG_BLOB   :
         sType = "LONG BLOB";
         break;

      case FIELD_TYPE_BLOB        :
         sType = "BLOB";
         break;

      case FIELD_TYPE_STRING      :
         sType = "STRING";
         break;
      
      case MYSQL_TYPE_VAR_STRING  :
      	 sType = "BIGINT";
      	 break;
         
      case FIELD_TYPE_BIT         :      	
         sType = "TINYINT";
         break;
      case FIELD_TYPE_NEWDATE     :
         sType = "NEW DATE";
         break;

      case FIELD_TYPE_ENUM        :
         sType = "ENUM";
         break;

      case FIELD_TYPE_SET         :
         sType = "SET";
         break;

      case FIELD_TYPE_TINY_BLOB   :         
         sType = "TINY BLOB";
         break;
      	
      default:
      	sType = "U";

 }

   return sType;
}

//------------------------------------------------//

HB_FUNC( SQL2CLIPTYPE )
{
	hb_retc( SQL2ClipType( hb_parnl( 1 ), hb_parl( 2 ) ) );
}

//------------------------------------------------//

HB_FUNC( SQLTYPE2CHAR )
{
	hb_retc( SQLType2Char( hb_parnl( 1 ) ) );
}

//------------------------------------------------//
HB_FUNC( GETTICKCOUNT )
{
   hb_retnl( GetTickCount() );
}

//------------------------------------------------//
// Function taked from mysql.c (xHarbour)
HB_FUNC( FILETOSQLBINARY )
{
   BOOL bResult = FALSE ;
   char *szFile = ( char * )hb_parc( 1 );
   int fHandle;
   ULONG iSize;
   char *ToBuffer;
   char *FromBuffer;
   if ( szFile && hb_parclen( 1 ) )
   {
     fHandle    = hb_fsOpen( ( BYTE * ) szFile,2 );
     if ( fHandle > 0 )
     {
       iSize      = hb_fsFSize( szFile, FALSE );
       if ( iSize > 0 )
       {
         FromBuffer = ( char * ) hb_xgrab( iSize );
         if ( FromBuffer )
         {
           iSize      = hb_fsReadLarge( fHandle , ( BYTE * ) FromBuffer , iSize );
           if ( iSize > 0 )
           {
             ToBuffer   = ( char * ) hb_xgrab( ( iSize*2 ) + 1 );
             if ( ToBuffer )
             {
               if ISNUM( 2 )
               {
                 iSize = mysql_real_escape_string( ( MYSQL * ) hb_parnl( 2 ), ToBuffer, FromBuffer, iSize );
               }
               else
               {
                 iSize = mysql_escape_string( ToBuffer, FromBuffer, iSize );
               }
               hb_retclenAdopt( ( char * ) ToBuffer, iSize );
               bResult = TRUE ;
             }
           }
           hb_xfree( FromBuffer );
         }
       }
       hb_fsClose( fHandle );
     }
   }
   if ( !bResult )
   {
     hb_retc( "" ) ;
   }
}

//------------------------------------
HB_FUNC( D_READFILE )
{
   char *szFile = ( char * )hb_parc( 1 );
   int fHandle;
   ULONG iSize;
   char *ToBuffer;
   char *FromBuffer;
   BOOL bError = FALSE;
   
   if ( szFile && hb_parclen( 1 ) )
   {
     fHandle    = hb_fsOpen( ( BYTE * ) szFile, HB_FA_ALL );
     if ( fHandle > 0 )
     {
       iSize      = hb_fsFSize( szFile, FALSE );
       if ( iSize > 0 )
       {
         FromBuffer = ( char * ) hb_xgrab( iSize );
         if ( FromBuffer )
         {
           iSize      = hb_fsReadLarge( fHandle , ( BYTE * ) FromBuffer , iSize );
         }else
         	   bError = TRUE;
       }else
          bError = TRUE;
     }else 
        bError = TRUE;
   }else 
      bError = TRUE;
    
   hb_fsClose( fHandle );
   
   if( bError )
      hb_retc( "" ) ;
   else
      hb_retclenAdopt( ( char * ) FromBuffer, iSize );
  
}

//
HB_FUNC( MYSQLEMBEDDED )  
{
   MYSQL *mysql;
   const char *szDataBase = hb_parc( 1 );
	 PHB_ITEM pArrayOption  = hb_param( 2, HB_IT_ARRAY );
	 PHB_ITEM pArrayGroup   = hb_param( 3, HB_IT_ARRAY );
	 PHB_ITEM pItem;
	 INT j, argc, iGroups;
	 char *server_options, *server_groups;
	 INT iError = 0; 

   //build server options
	 argc           = hb_arrayLen( pArrayOption );
   if( argc > 0 ){
   	  server_options = ( char * )hb_xgrab( sizeof( char ) * argc );
      for( j = 0; j < argc; j++ )
      {
   	    pItem = hb_itemArrayGet( pArrayOption, j + 1 );
       	server_options[ j ] = *hb_itemGetC( pItem );
      }
      hb_itemRelease( pItem );
   }
   
   //build groups
   iGroups       = hb_arrayLen( pArrayGroup );
   if( iGroups > 0 ) {
      server_groups = ( char * )hb_xgrab( sizeof( char * )* iGroups  );
      for( j = 0; j < iGroups; j++ )
      {
   	    pItem = hb_itemArrayGet( pArrayOption, j + 1 );
       	server_groups[ j ] = *hb_itemGetC( pItem );
      }
      hb_itemRelease( pItem );
   }
   

   //Initialize MySQL Embedded libmysqld.
   if( mysql_library_init(argc, &server_options, &server_groups ) == 0 )
   { 
      //Initialize MySQL Library. */
      if( ( mysql = mysql_init( NULL ) ) != NULL )
      {
         //Force use of embedded libmysqld. */
         mysql_options(mysql, MYSQL_OPT_USE_EMBEDDED_CONNECTION, NULL);
         
         //Connect to MySQL.
        if(mysql_real_connect(mysql, NULL, NULL, NULL, szDataBase, 0, NULL, 0) == NULL)
        {
            mysql_close(mysql);
            mysql_library_end();
            iError = 1;
        }
      }
    }

    if( iError == 1 )
    {
    	 if( server_options )
          hb_xfree( ( void * ) server_options );
       if( server_groups )
          hb_xfree( ( void * ) server_groups );
       hb_retnl( ( long ) 0 );
    }

   hb_retnl((long) mysql );
}
