/*
 * TDOLPHIN PROJECT source code:
 * Language Support Module (EN)
 *
 * Copyright 2011 Daniel Garcia-Gil<danielgarciagil@gmail.com>
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

#include "hbapi.h"
#include "hbapilng.h"
#include "gerrapi.h"
#include "hbapierr.h"
#include "dolerr.ch"
 
int LoadMsgsEN() {
  
  G_ERRMSG ErrMsg[] = { 
  { ERR_EMPTYDBNAME                 , "Empty Data Base name" },
  { ERR_INVALID_STRUCT_ROW_SIZE     , "Invalid structure size"},
  { ERR_INVALID_STRUCT_NOTNULL_VALUE, "Invalid NOTNULL value" },
  { ERR_INVALID_STRUCT_PRIKEY       , "Invalid Primary Key" },
  { ERR_INVALID_STRUCT_UNIQUE       , "Invalid UNIQUE Key" },
  { ERR_INVALID_STRUCT_AUTO         , "Invalid Autoincrement" },
  { ERR_NOQUERY                     , "Empty Statement" },
  { ERR_EMPTYVALUES                 , "Empty values" },
  { ERR_EMPTYTABLE                  , "Empty Table" },
  { ERR_NOMATCHCOLUMNSVALUES        , "No Match Columns-Values" },
  { ERR_INVALIDCOLUMN               , "Invalid Field" },
  { ERR_INVALIDFIELDNUM             , "Invalid Field Number" } ,
  { ERR_INVALIDFIELDNAME            , "Invalid Field name" } ,
  { ERR_INVALIDFIELDGET             , "Invalid FIELDGET" } ,
  { ERR_FAILEDGETROW                , "Invalid Result handle" } ,
  { ERR_INVALIDGETBLANKROW          , "Fail loading buffer with Multilple tables" } ,
  { ERR_INVALIDSAVE                 , "Fail saving with Multilple tables" } ,
  { ERR_NOTHINGTOSAVE               , "" },
  { ERR_NODATABASESELECTED          , "No Data Base seleccted in Backup" } ,
  { ERR_MISSINGQRYOBJECT            , "Missing TDOLPHINQRY object" } ,
  { ERR_INVALIDBACKUPFILE           , "Invalid backup File" } ,
  { ERR_NOTABLESSELECTED            , "No tables selected in backup" },
  { ERR_INVALIDDELETE               , "Fail deleting with Multilple tables" },
  { ERR_DELETING                    , "" },
  { ERR_INVALIDQUERYARRAY           , "Inavlis Array MultiQuery" },
  { ERR_MULTIQUERYFAULIRE           , "MultiQuery Faulire" },
  { ERR_INVALIDFIELDTYPE            , "Invalid Field Type" } ,
  { ERR_INVALIDFILENAME             , "Invalid Field Name" },
  { ERR_NOEXCELINSTALED             , "Excel not instaled" },
  { ERR_EXPORTTOEXCEL               , "Fail exporting to excel" },
  { ERR_INVALIDHTMLEXT              , "Invalid extention file HTML" },
  { ERR_NOWORDINSTALED              , "Word not instaled" },
  { ERR_EXPORTTOWORD                , "Fail exporting to Word" } ,
  { ERR_INVALIDTABLES_EXPORTTOSQL   , "No tables selected to export" },
  { ERR_INVALIDFILE_EXPORTTOSQL     , "Invalid Export File" },
  { ERR_NODEFINDEDHOST              , "Host not defined" } ,
  { ERR_INVALIDHOSTSELECTION        , "Invalid Host" }, 
  { ERR_CANNOTCREATEBKFILE          , "can not create Backup File" },
  { ERR_OPENBACKUPFILE              , "Can Not open Backup File" },
  { ERR_INSUFFICIENT_MEMORY         , "Insufficient Memory" },
  { ERR_TABLENOEXIST                , "Table no exist" } ,
  { ERR_EMPTYALIAS                  , "Empty Alias" },
  { ERR_NOMATCHCOLUMNSALIAS         , "No Match DBF fields with table Fields"},
  { ERR_INVALID_PARAMETER_CALL      , "Invalid parametres in Call Method"} };
  
  BuildErrMsg( ErrMsg, sizeof( ErrMsg ) );
  
  return sizeof( ErrMsg ) / sizeof( G_ERRMSG );
} 