/*
 * $Id: 10-Jul-10 9:40:27 AM tdolphin.ch Z dgarciagil $
 */


// MySQL field types

#define  MYSQL_DECIMAL_TYPE      0
#define  MYSQL_TINY_TYPE         1
#define  MYSQL_SHORT_TYPE        2
#define  MYSQL_LONG_TYPE         3
#define  MYSQL_FLOAT_TYPE        4
#define  MYSQL_DOUBLE_TYPE       5
#define  MYSQL_NULL_TYPE         6
#define  MYSQL_TIMESTAMP_TYPE    7
#define  MYSQL_LONGLONG_TYPE     8
#define  MYSQL_INT24_TYPE        9
#define  MYSQL_DATE_TYPE         10
#define  MYSQL_TIME_TYPE         11
#define  MYSQL_DATETIME_TYPE     12
#define  MYSQL_YEAR_TYPE         13
#define  MYSQL_NEWDATE_TYPE      14
#define  MYSQL_NUMERIC_TYPE      15
#define  MYSQL_ENUMTYPE          247
#define  MYSQL_SET_TYPE          248
#define  MYSQL_TINY_BLOB_TYPE    249
#define  MYSQL_MEDIUM_BLOB_TYPE  250
#define  MYSQL_LONG_BLOB_TYPE    251
#define  MYSQL_BLOB_TYPE         252
#define  MYSQL_VAR_STRING_TYPE   253
#define  MYSQL_STRING_TYPE       254

#ifndef MAX_BLOCKSIZE
#define MAX_BLOCKSIZE            65535
#endif


// MySQL field structure 
#define  MYSQL_FS_NAME           1     /* Name of column */
#define  MYSQL_FS_TABLE          2     /* Table of column if column was a field */
#define  MYSQL_FS_DEF            3     /* Default value (set by mysql_list_fields) */
#define  MYSQL_FS_TYPE           4     /* Type of field. Se mysql_com.h for types */
#define  MYSQL_FS_LENGTH         5     /* Width of column */
#define  MYSQL_FS_MAXLEN         6     /* Max width of selected set */
#define  MYSQL_FS_FLAGS          7     /* Div flags */
#define  MYSQL_FS_DECIMALS       8     /* Number of decimals in field */
#define  MYSQL_FS_CLIP_TYPE      9     /* Type of field. clipper field type */

// MySQL field flags
#define  NOT_NULL_FLAG           1        /* Field can't be NULL */
#define  PRI_KEY_FLAG            2        /* Field is part of a primary key */
#define  UNIQUE_KEY_FLAG         4		    /* Field is part of a unique key */
#define  MULTIPLE_KEY_FLAG       8		    /* Field is part of a key */
#define  BLOB_FLAG               16		    /* Field is a blob */
#define  UNSIGNED_FLAG           32		    /* Field is unsigned */
#define  ZEROFILL_FLAG           64		    /* Field is zerofill */
#define  BINARY_FLAG             128      /* Field is binary */
#define  ENUM_FLAG               256		  /* field is an enum */
#define  AUTO_INCREMENT_FLAG     512		  /* field is a autoincrement field */
#define  TIMESTAMP_FLAG          1024		  /* Field is a timestamp */
#define  PART_KEY_FLAG           16384		/* Intern; Part of some key */
#define  GROUP_FLAG              32768		/* Intern group field */


#define  DBS_NOTNULL             5        /* True if field has to be NOT NULL */
#define  DBS_DEFAULT             6        /* Field Value by default  */


//Create index
#define IDX_UNIQUE      1
#define IDX_FULLTEXT    2
#define IDX_SPATIAL     3
#define IDX_PRIMARY     4
                        
#define IDX_ASC         1
#define IDX_DES         2
                        
#define IDX_BTREE       1
#define IDX_HASH        2
#define IDX_RTREE       3

// 
#define IS_PRIMARY_KEY( uValue )  MyAND( uValue, PRI_KEY_FLAG ) == PRI_KEY_FLAG 
#define IS_MULTIPLE_KEY( uValue ) MyAND( uValue, MULTIPLE_KEY_FLAG ) == MULTIPLE_KEY_FLAG
#define IS_AUTO_INCREMENT( uValue ) MyAND( uValue, AUTO_INCREMENT_FLAG ) == AUTO_INCREMENT_FLAG
#define IS_NOT_NULL( uValue ) MyAND( uValue, NOT_NULL_FLAG ) == NOT_NULL_FLAG

// SET NEW FILTER
#define SET_WHERE    1
#define SET_GROUP    2
#define SET_HAVING   3
#define SET_ORDER    4
#define SET_LIMIT    5

//Privileges type
#define PRIV_ADMIN      1
#define PRIV_DATA       2
#define PRIV_TABLE      3
#define PRIV_ALL        4

//Backup Status process
#define ST_STARTBACKUP   1
#define ST_LOADINGTABLE  2
#define ST_ENDBACKUP     3
#define ST_BACKUPCANCEL  0

//Restore Process 
#define ST_STARTRESTORE  1
#define ST_LOADING       2
#define ST_RESTORING     3
#define ST_ENDRESTORE    4
#define ST_RSTCANCEL     0

//export
#define EXP_TEXT     1 
#define EXP_EXCEL    2
#define EXP_DBF      3