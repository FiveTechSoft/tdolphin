/*
 * $Id: 01-Aug-10 12:39:20 PM tdolpexp.PRG Z dgarciagil $
 */
   
/*
 * TDOLPHIN PROJECT source code:
 * Export table or query information
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
 * along with this software.  If not, write to
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

#include "hbclass.ch"
#include "common.ch"
#include "dbstruct.ch"
#include "tdolphin.ch"
#include "dolerr.ch"
#include "fileio.ch"
#ifndef __XHARBOUR__
#include "hbcompat.ch"
#endif

 
 CLASS TDolphinExport 
 
    DATA oQuery
    DATA aColumns
    DATA aPictures
 
    DATA cFileName
    
    DATA nType
    DATA bOnRow
    DATA oExport
    DATA oMain
    

    METHOD New( nType, oQuery, aColumns, aPictures  )
    
    METHOD Start() INLINE ::oExport:Export()
 
 
ENDCLASS

//----------------------------------------//

METHOD New( nType, oQuery, cFileName, aColumns, aPictures  ) CLASS TDolphinExport 

   DEFAULT nType TO EXP_TEXT

   ::oQuery     = oQuery
   ::aColumns   = aColumns
   ::aPictures  = aPictures
   
   IF Empty( cFileName )
      oQuery:oServer:nInternalError = ERR_INVALIDFILENAME
      oQuery:oServer:CheckError()
   ENDIF
   
   ::cFileName  = cFileName
      

   SWITCH nType
      CASE EXP_TEXT
         ::oExport = TDolphinToText():New( Self )
         EXIT
      CASE EXP_EXCEL
         ::oExport = TDolphinToExcel():New( Self )
         EXIT 
          
   ENDSWITCH 

RETURN Self

//----------------------------------------// 
// Start export to text
//----------------------------------------// 
 
CLASS TDolphinToText FROM TDolphinExport
 
    DATA cRowDelimiter
    DATA cTextQualifer
    DATA cFieldDelimiter
    DATA lAppend
    DATA lAddHeader
    
    METHOD New( oMain )
    METHOD Export()
   
ENDCLASS 

//----------------------------------------// 

METHOD New( oMain ) CLASS TDolphinToText

   ::oMain = oMain
   ::cRowDelimiter = Chr( 13 ) + Chr( 10 )
   ::cTextQualifer = ''
   ::cFieldDelimiter = ";"
   ::lAppend = .F.
   ::lAddHeader = .F.
   
RETURN Self

//----------------------------------------// 

METHOD Export() CLASS TDolphinToText

   LOCAL oQuery   := ::oMain:oQuery 
   LOCAL aColumns  := ::oMain:aColumns
   LOCAL aPictures := aPictures
   LOCAL cLine := "", cField, uField
   LOCAL bOnRow   := ::oMain:bOnRow
   LOCAL n := 1
   LOCAL nId
   LOCAL hFile, cTitle, cHeader := ""
   
   IF hb_IsObject( oQuery )
      IF Empty( aColumns )
         aColumns = {}
         AEval( oQuery:aStructure, {| aRow | AAdd( aColumns, aRow[ MYSQL_FS_NAME ] ) } )
      ENDIF
      IF hb_IsArray( aPictures )
         IF Len( aPictures ) != Len( aColumns )
            aPictures = ASize( aPictures, Len( aColumns ) )
         ENDIF
      ELSE 
         aPictures = Array( Len( aColumns ) )
      ENDIF

      IF ! File( ::oMain:cFileName )
        FClose( FCreate( ::oMain:cFileName ) )
      ENDIF

     IF( ( hFile := FOpen( ::oMain:cFileName, FO_WRITE ) ) != -1 )
        IF ::lAppend
           FSeek( hFile, 0, FS_END )
        ENDIF
     ENDIF      
     
     IF ::lAddHeader
        FOR EACH cTitle IN aColumns
#ifdef __XHARBOUR__
            nId = HB_EnumINdex()
#else 
            nId = cTitle:__EnumIndex()
#endif          
           cHeader += ( ::cTextQualifer + ;
                       PadR( cTitle,  oQuery:aStructure[ nId ][ MYSQL_FS_LENGTH ] ) + ;
                       ::cTextQualifer + ;
                       ::cFieldDelimiter )        
        NEXT 
         //Remove Last Delimiter
         cHeader = SubStr( cHeader, 1, Len( cHeader ) - 1 ) + ::cRowDelimiter
         FWrite( hFile, cHeader, Len( cHeader ) )
     ENDIF
           

     DO WHILE ! oQuery:Eof()
        FOR EACH cField IN aColumns
#ifdef __XHARBOUR__
            nId = HB_EnumINdex()
#else 
            nId = cField:__EnumIndex()
#endif      
            uField = Clip2Str( oQuery:FieldGet( cField ), aPictures[ nId ] )
            
            cLine += ( ::cTextQualifer + ;
                       uField + ;
                       ::cTextQualifer + ;
                       ::cFieldDelimiter )
         NEXT 
         //Remove Last Delimiter
         cLine = SubStr( cLine, 1, Len( cLine ) - 1 ) + ::cRowDelimiter
         IF bOnRow != NIL
            Eval( bOnRow, n, cLine )
         ENDIF
         FWrite( hFile, cLine, Len( cLine ) )
         cLine := ""
         n++
         oQuery:Skip()
      ENDDO
      FClose( hFile )
      
   ENDIF
         

RETURN NIL

//----------------------------------------// 
// end export to text
//----------------------------------------// 

//----------------------------------------// 
// Start export to excel
//----------------------------------------// 

CLASS TDolphinToExcel FROM TDolphinExport

   DATA lAddHeader
   DATA lOpened
   DATA cxlTrue
   DATA cxlFalse
   DATA cxlSum
   
   DATA oExcel
   METHOD New( oMain )
   
   METHOD Export()
   METHOD SetExcelLanguage()

ENDCLASS

//----------------------------------------// 

METHOD New( oMain ) CLASS TDolphinToExcel

   LOCAL oError

   ::oMain = oMain
   ::lAddHeader = .F.
   ::lOpened = .F.

   TRY
      ::oExcel   = GetActiveObject( "Excel.Application" )
      ::lOpened  = .T.
   CATCH oError
      TRY 
         ::oExcel   := CreateObject( "Excel.Application" )
      CATCH oError
         ::oMain:oQuery:oServer:lInternalError = ERR_NOEXCELINSTALED
         ::oMain:oQuery:oServer:CheckError()
      END
   END   
   ::SetExcelLanguage()
   
RETURN Self

//----------------------------------------// 

METHOD Export() CLASS TDolphinToExcel
   
   LOCAL oSheet, oBook
   LOCAL cField, aRow, nID
   LOCAL nRow     := 1
   LOCAL nCol     := 0
   LOCAL oQuery   := ::oMain:oQuery
   LOCAL aColumns  := ::oMain:aColumns
   LOCAL aPictures := aPictures   
   LOCAL bOnRow   := ::oMain:bOnRow   

   ::oExcel:ScreenUpdating := .T.
   oBook   = ::oExcel:WorkBooks:Add()
   oSheet  = ::oExcel:ActiveSheet()
   
   IF Empty( aColumns )
      aColumns = {}
      AEval( oQuery:aStructure, {| aRow | AAdd( aColumns, aRow[ MYSQL_FS_NAME ] ) } )
   ENDIF   

   FOR EACH cField IN aColumns
      oSheet:Cells( nRow, ++nCol ):Value   := cField
   NEXT
   oSheet:Rows( 1 ):Font:Bold   := .T.
   oSheet:Range( oSheet:Cells( 1, 1 ), oSheet:Cells( 1, nCol ) ):Select()
   ::oExcel:Selection:Borders( 9 ):LineStyle := 1   // xlContinuous = 1
   ::oExcel:Selection:Borders( 9 ):Weight    := -4138   // xlThin = 2, xlHairLine = 1, xlThick = 4, xlMedium = -4138   
   nRow++  
   nCol = 0
    
     DO WHILE ! oQuery:Eof()
        FOR EACH cField IN aColumns
#ifdef __XHARBOUR__
            nId = HB_EnumINdex()
#else 
            nId = cField:__EnumIndex()
#endif      
            oSheet:Cells( nRow, ++nCol ):Value   := oQuery:FieldGet( cField )
            
         NEXT 
         IF bOnRow != NIL
            Eval( bOnRow, nRow )
         ENDIF
         nRow++
         nCol = 0
         oQuery:Skip()
      ENDDO
      
   ::oExcel:ScreenUpdating   := .T.
   ::oExcel:visible          := .T.
   
   IF ! ::lOpened   
      ::oExcel:Quit()
   ENDIF
   
RETURN NIL

//----------------------------------------// 

METHOD SetExcelLanguage() CLASS TDolphinToExcel

   local aEng     := { 1033, 2057, 10249, 4105, 9225, 14345, 6153, 8201, 5129, 13321, 7177, 11273, 12297 }
   local aSpanish := {3082,1034,11274,16394,13322,9226,5130,7178,12298,17418,4106,18442,;
                     58378,2058,19466,6154,15370,10250,20490,21514,14346,8202}
   local aGerman  := {1031,3079,5127,4103,2055}
   local aFrench  := {1036,2060,11276,3084,9228,12300,15372,5132,13324,6156,14348,58380,8204,10252,4108,7180}

   local nxlLangID  := .f.

   nxlLangID := ::oExcel:LanguageSettings:LanguageID( 2 )
   do case
      case AScan( aEng, nxlLangID ) > 0 // English
         ::cxlTrue     := "TRUE"
         ::cxlFalse    := "FALSE"
         ::cxlSum      := "SUBTOTAL(9,"

      case AScan( aSpanish, nxlLangID ) > 0 // Spanish
         ::cxlTrue     := "VERDADERO"
         ::cxlFalse    := "FALSO"
         ::cxlSum      := "SUBTOTALES(9;"

      case nxlLangID == 1040 .or. nxlLangID == 2064 // Italian
         ::cxlTrue     := "VERO"
         ::cxlFalse    := "FALSO"
         ::cxlSum      := "SOMMA("

      case AScan( aGerman, nxlLangID ) > 0 // German
         ::cxlTrue     := "WAHR"
         ::cxlFalse    := "FALSCH"
         ::cxlSum      := "SUMME("

      case AScan( aFrench, nxlLangID ) > 0 // French
         ::cxlTrue     := "VRAI"
         ::cxlFalse    := "FAUX"
         ::cxlSum      := "SOMME("

      case nxlLangID == 2070 .or. nxlLangID == 1046 // Portugese
         ::cxlTrue     := "VERDADEIRO"
         ::cxlFalse    := "FALSO"
         ::cxlSum      := "SOMA("
         
      otherwise
         ::cxlTrue     := "=(1=1)"
         ::cxlFalse    := "=(1=0)"
         
   endcase

return nil   