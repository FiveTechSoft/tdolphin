/*
 * TDOLPHIN PROJECT source code:
 * Messages Language Support
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

#define STARTCODE 9000

static G_LANG * pLangActive;

static G_LANG LangInstalled[] = {
  { "EN", &LoadMsgsEN, 0 },
  { "ES", &LoadMsgsES, 0 }
};

G_ERRMSG g[] = { 
  { ERR_EMPTYDBNAME                 , "No se ha asignado Base de Datos" },
  { ERR_INVALID_STRUCT_ROW_SIZE     , "Tamaño inválido de la estructura"},
  { ERR_INVALID_STRUCT_NOTNULL_VALUE, "Asignaci¢n a valor NOTNUL inválido" },
  { ERR_INVALID_STRUCT_PRIKEY       , "Llave Primaria inválida" },
  { ERR_INVALID_STRUCT_UNIQUE       , "LLave Unica inválida" },
  { ERR_INVALID_STRUCT_AUTO         , "Autoincremtable inválido" },
  { ERR_NOQUERY                     , "No se envio sentencia" },
  { ERR_EMPTYVALUES                 , "No se enviaron valores a la sentencia" },
  { ERR_EMPTYTABLE                  , "No se envio nombre de la tabla" },
  { ERR_NOMATCHCOLUMNSVALUES        , "No concuerda Campos con Valores" },
  { ERR_INVALIDCOLUMN               , "Campo Inválido" },
  { ERR_INVALIDFIELDNUM             , "Numero de campo Inválido" } ,
  { ERR_INVALIDFIELDNAME            , "Nombre del campo Inválido" } ,
  { ERR_INVALIDFIELDGET             , "Nombre del campo Inválido en FIELDGET" } ,
  { ERR_FAILEDGETROW                , "Manejador de la consulta Inválido" } ,
  { ERR_INVALIDGETBLANKROW          , "Imposible cargar Buffer vacio con multiples tablas" } ,
  { ERR_INVALIDSAVE                 , "Imposible actualizar con multiples tablas" } ,
  { ERR_NOTHINGTOSAVE               , "" },
  { ERR_NODATABASESELECTED          , "No se ha seleccionado Base de Datos para el respaldo" } ,
  { ERR_MISSINGQRYOBJECT            , "Erropr en objeto TDOLPHINQRY" } ,
  { ERR_INVALIDBACKUPFILE           , "Fichero de Respaldo Inválido" } ,
  { ERR_NOTABLESSELECTED            , "No hay tablas seleccionadas para el Respaldo" },
  { ERR_INVALIDDELETE               , "Iposible borrar con multiples tablas" },
  { ERR_DELETING                    , "" },
  { ERR_INVALIDQUERYARRAY           , "Array Multisentencia Inválido" },
  { ERR_MULTIQUERYFAULIRE           , "Fallo ejecutando Array de multiples sentencia" },
  { ERR_INVALIDFIELDTYPE            , "Tipo de campo Inválido" } ,
  { ERR_INVALIDFILENAME             , "Nombre de campo Inválido" },
  { ERR_NOEXCELINSTALED             , "Excel no instalado" },
  { ERR_EXPORTTOEXCEL               , "Error exportando a Excel" },
  { ERR_INVALIDHTMLEXT              , "Invalida extenci¢n HTML" },
  { ERR_NOWORDINSTALED              , "Word no Instalado" },
  { ERR_EXPORTTOWORD                , "Error exportando a Word" } ,
  { ERR_INVALIDTABLES_EXPORTTOSQL   , "No hay tablas seleccionadas para exportar" },
  { ERR_INVALIDFILE_EXPORTTOSQL     , "Error usando en el archivo de exportanci¢n" },
  { ERR_NODEFINDEDHOST              , "No se ha definido HOST" } ,
  { ERR_INVALIDHOSTSELECTION        , "HOST Inválido" }, 
  { ERR_CANNOTCREATEBKFILE          , "No se pudo crear archivo de respaldo" },
  { ERR_OPENBACKUPFILE              , "No se puedo abrir archivo de respaldo" },
  { ERR_INSUFFICIENT_MEMORY         , "Memoria insuficiente" },
  { ERR_TABLENOEXIST                , "Tabla no existe" } ,
  { ERR_EMPTYALIAS                  , "No se icluyó Alias" },
  { ERR_NOMATCHCOLUMNSALIAS         , "No concuerda las columnas con la DBF"} }; 
 
static G_ERRMSG * pErrMessage = NULL;
  
static const char * sIDLang = NULL;


//--------------------------------------------------------------//

static void LoadMsgs( void )
{
  const char * sID = hb_langID();
  
  if( ! sIDLang || hb_stricmp( sIDLang, sID ) != 0 ){    
    int iLen = sizeof( LangInstalled ) / sizeof( G_LANG );
    int i;
    sIDLang = sID;    

    for( i=0; i < iLen; i++ )
    {
      if( hb_stricmp( LangInstalled[ i ].sLang, sID ) == 0 ){
         int (*fp)();
         pLangActive = &LangInstalled[ i ];
         fp = pLangActive->pFuncLang;
         pLangActive->lTotalMsgs = (*fp)();
      }
    }
  }
}

//--------------------------------------------------------------//  
  
static char * GetGErrorMsg( HB_ERRCODE iCode, const char * sAux )
{
  int iPos = ( int ) iCode - STARTCODE;
  char * cMsg = hb_xgrab( 128 );

  LoadMsgs();

  if( iPos >= 0 && iPos < pLangActive->lTotalMsgs )
  {
    if( sAux != NULL )
    {
       sprintf( cMsg,  pErrMessage[ iPos ].sDescription, sAux );
       return ( char * )cMsg;
    }else
    {
      memcpy( cMsg, pErrMessage[ iPos ].sDescription, strlen( pErrMessage[ iPos ].sDescription ) );     
      return cMsg;
    }
  }
}

//--------------------------------------------------------------//  

static char * GetGErrorMsg1( HB_ERRCODE iCode )
{
  return GetGErrorMsg( iCode, NULL );
}


//--------------------------------------------------------------//

void BuildErrMsg( G_ERRMSG *ErrMsg, int iSize )
{
  
  if( pErrMessage )
    hb_xfree( pErrMessage );
  
  pErrMessage = ( G_ERRMSG * ) hb_xgrab( iSize );
  
  memcpy( pErrMessage, ErrMsg, iSize );

  return;
}

HB_FUNC( DOL_GETERROTEXT )
{
   hb_retc( GetGErrorMsg1( hb_parnl( 1 ) ) );
}