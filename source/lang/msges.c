/*
 * TDOLPHIN PROJECT source code:
 * Language Support Module (ES)
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
 
int LoadMsgsES() {
  
  G_ERRMSG ErrMsg[] = { 
  { ERR_EMPTYDBNAME                 , "No se ha asignado Base de Datos" },
  { ERR_INVALID_STRUCT_ROW_SIZE     , "Tamano invalido de la estructura"},
  { ERR_INVALID_STRUCT_NOTNULL_VALUE, "Asignacion a valor NOTNUL invalido" },
  { ERR_INVALID_STRUCT_PRIKEY       , "Llave Primaria invalida" },
  { ERR_INVALID_STRUCT_UNIQUE       , "LLave Unica invalida" },
  { ERR_INVALID_STRUCT_AUTO         , "Autoincremtable invalido" },
  { ERR_NOQUERY                     , "No se envio sentencia" },
  { ERR_EMPTYVALUES                 , "No se enviaron valores a la sentencia" },
  { ERR_EMPTYTABLE                  , "No se envio nombre de la tabla" },
  { ERR_NOMATCHCOLUMNSVALUES        , "No concuerda Campos con Valores" },
  { ERR_INVALIDCOLUMN               , "Campo Invalido" },
  { ERR_INVALIDFIELDNUM             , "Numero de campo Invalido" } ,
  { ERR_INVALIDFIELDNAME            , "Nombre del campo Invalido" } ,
  { ERR_INVALIDFIELDGET             , "Nombre del campo Invalido en FIELDGET" } ,
  { ERR_FAILEDGETROW                , "Manejador de la consulta Invalido" } ,
  { ERR_INVALIDGETBLANKROW          , "Imposible cargar Buffer vacio con multiples tablas" } ,
  { ERR_INVALIDSAVE                 , "Imposible actualizar con multiples tablas" } ,
  { ERR_NOTHINGTOSAVE               , "" },
  { ERR_NODATABASESELECTED          , "No se ha seleccionado Base de Datos para el respaldo" } ,
  { ERR_MISSINGQRYOBJECT            , "Erropr en objeto TDOLPHINQRY" } ,
  { ERR_INVALIDBACKUPFILE           , "Fichero de Respaldo Invalido" } ,
  { ERR_NOTABLESSELECTED            , "No hay tablas seleccionadas para el Respaldo" },
  { ERR_INVALIDDELETE               , "Iposible borrar con multiples tablas" },
  { ERR_DELETING                    , "" },
  { ERR_INVALIDQUERYARRAY           , "Array Multisentencia Invalido" },
  { ERR_MULTIQUERYFAULIRE           , "Fallo ejecutando Array de multiples sentencia" },
  { ERR_INVALIDFIELDTYPE            , "Tipo de campo Invalido" } ,
  { ERR_INVALIDFILENAME             , "Nombre de campo Invalido" },
  { ERR_NOEXCELINSTALED             , "Excel no instalado" },
  { ERR_EXPORTTOEXCEL               , "Error exportando a Excel" },
  { ERR_INVALIDHTMLEXT              , "Invalida extencion HTML" },
  { ERR_NOWORDINSTALED              , "Word no Instalado" },
  { ERR_EXPORTTOWORD                , "Error exportando a Word" } ,
  { ERR_INVALIDTABLES_EXPORTTOSQL   , "No hay tablas seleccionadas para exportar" },
  { ERR_INVALIDFILE_EXPORTTOSQL     , "Error usando en el archivo de exportancion" },
  { ERR_NODEFINDEDHOST              , "No se ha definido HOST" } ,
  { ERR_INVALIDHOSTSELECTION        , "HOST Invalido" }, 
  { ERR_CANNOTCREATEBKFILE          , "No se pudo crear archivo de respaldo" },
  { ERR_OPENBACKUPFILE              , "No se puedo abrir archivo de respaldo" },
  { ERR_INSUFFICIENT_MEMORY         , "Memoria insuficiente" },
  { ERR_TABLENOEXIST                , "Tabla no existe" } ,
  { ERR_EMPTYALIAS                  , "No se icluyo Alias" },
  { ERR_NOMATCHCOLUMNSALIAS         , "No concuerda las columnas con la DBF"} };
  
  BuildErrMsg( ErrMsg, sizeof( ErrMsg ) );
  
  return sizeof( ErrMsg ) / sizeof( G_ERRMSG );
} 