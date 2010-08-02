/*
 * $Id: 01-Aug-10 12:39:20 PM tdolpexp.PRG Z dgarciagil $
 */
   
/*
 * TDOLPHIN PROJECT source code:
 * Export Query information to specific format ( text, excel )
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



//Main class to manager exports 
CLASS TDolphinExport 
 
    DATA oQuery        /* Query object */
    DATA aColumns      /* Columns seelct to fill file */
    DATA aPictures     /* Columns's Picture */
 
    DATA cFileName     /* File name */
    
    DATA nType         /* Export type */
    DATA bOnRow        /* codeblock to evaluate row by row */
    DATA bOnStart      /* codeblock to evaluate at the begin process */
    DATA bOnEnd        /* codeblock to evaluate at the end process */ 
    DATA oExport       /* Export Objet, is direftent by type */
    DATA oMain         /* Self */
    

    METHOD New( nType, oQuery, aColumns, aPictures  )
    
    METHOD Start() INLINE ::oExport:Export()
    
    ERROR HANDLER ONERROR()
 
 
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

METHOD ONERROR( uParam ) CLASS TDolphinExport

   LOCAL cMsg   := __GetMessage()
   LOCAL a

#ifndef __XHARBOUR__
   IF uParam == nil
      a = __ObjSendMsg( ::oExport, cMsg )
   ELSE
      a = __ObjSendMsg( ::oExport, cMsg, uParam )
   ENDIF
#else   

   IF uParam == nil
      a = hb_execFromArray( @::oExport, cMsg )
   ELSE
      a = hb_execFromArray( @::oExport, cMsg, { uParam } )
   ENDIF
#endif

RETURN a


//----------------------------------------// 
// Start export to text
//----------------------------------------// 
 
CLASS TDolphinToText FROM TDolphinExport
 
    DATA cRowDelimiter
    DATA cTextQualifer
    DATA cFieldDelimiter
    DATA lAppend
    DATA lAddHeader
    DATA hFile
    
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

   LOCAL oQuery    := ::oMain:oQuery 
   LOCAL aColumns  := ::oMain:aColumns
   LOCAL aPictures := ::oMain:aPictures
   LOCAL cLine     := "", cField, uField
   LOCAL bOnRow    := ::oMain:bOnRow
   LOCAL bOnStart  := ::oMain:bOnStart
   LOCAL bOnEnd    := ::oMain:bOnEnd
   LOCAL n := 1
   LOCAL nId
   LOCAL cTitle, cHeader := ""
   
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

     IF( ( ::hFile := FOpen( ::oMain:cFileName, FO_WRITE ) ) != -1 )
        IF ::lAppend
           FSeek( ::hFile, 0, FS_END )
        ENDIF
     ENDIF      
     
      IF bOnStart != NIL 
         Eval( bOnStart, Self )
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
         FWrite( ::hFile, cHeader, Len( cHeader ) )
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
            Eval( bOnRow, Self, n, cLine )
         ENDIF
         FWrite( ::hFile, cLine, Len( cLine ) )
         cLine := ""
         n++
         oQuery:Skip()
      ENDDO

      IF bOnEnd != NIL 
         Eval( bOnEnd, Self )
      ENDIF      
      
      FClose( ::hFile )
      
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
   DATA cxlSum
   DATA lMakeTotals
   DATA oExcel
   DATA nRow, nCol
   
   
   METHOD New( oMain )
   
   METHOD Export()
   METHOD SetExcelLanguage()

ENDCLASS

//----------------------------------------// 

METHOD New( oMain ) CLASS TDolphinToExcel

   LOCAL oError

   ::oMain       = oMain
   ::lAddHeader  = .T.
   ::lOpened     = .F.
   ::lMakeTotals = .F.

   TRY
      ::oExcel   = GetActiveObject( "Excel.Application" )      
      ::lOpened  = .T.
   CATCH oError
      TRY 
         ::oExcel   := CreateObject( "Excel.Application" )
      CATCH oError
         ::oMain:oQuery:oServer:nInternalError = ERR_NOEXCELINSTALED
         ::oMain:oQuery:oServer:CheckError(, Ole2TxtError())
      END
   END   
   ::SetExcelLanguage()
   
RETURN Self

//----------------------------------------// 

METHOD Export() CLASS TDolphinToExcel
   
   LOCAL oSheet, oBook, oError
   LOCAL cField, aRow, nID
   LOCAL oQuery    := ::oMain:oQuery
   LOCAL aColumns  := ::oMain:aColumns
   LOCAL aPictures := ::oMain:aPictures   
   LOCAL bOnRow    := ::oMain:bOnRow   
   LOCAL lAddHeader:= ::lAddHeader
   LOCAL bOnStart  := ::oMain:bOnStart
   LOCAL bOnEnd    := ::oMain:bOnEnd
   
   ::nRow = 1
   ::nCol = 0

   TRY 
      ::oExcel:visible       = .F.
      ::oExcel:DisplayAlerts = .F.
      
      oBook   = ::oExcel:WorkBooks:Add()
      oSheet  = ::oExcel:ActiveSheet()
      
      IF bOnStart != NIL 
         Eval( bOnStart, Self )
      ENDIF
      
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
   
      //Make header and cell format
      FOR EACH cField IN aColumns
         ++::nCol
         IF lAddHeader
            oSheet:Cells( ::nRow, ::nCol ):Value  = cField       
         ENDIF
         oSheet:Columns( ::nCol ):ColumnWidth  = Max( Len( cField ), oQuery:aStructure[ ::nCol ][ MYSQL_FS_LENGTH ] + 2 )
         if oQuery:aStructure[ ::nCol ][ MYSQL_FS_CLIP_TYPE ] = "N"
            oSheet:Columns( ::nCol ):NumberFormat = clp2xlnumpic( aPictures[ ::nCol ] )
            oSheet:Columns( ::nCol ):HorizontalAlignment := -4152
         endif
      NEXT
      IF lAddHeader
         oSheet:Rows( 1 ):Font:Bold   := .T.
         oSheet:Range( oSheet:Cells( 1, 1 ), oSheet:Cells( 1, ::nCol ) ):Select()
         ::oExcel:Selection:Borders( 9 ):LineStyle := 1   // xlContinuous = 1
         ::oExcel:Selection:Borders( 9 ):Weight    := -4138   // xlThin = 2, xlHairLine = 1, xlThick = 4, xlMedium = -4138   
         ::nRow++  
      ENDIF
      ::nCol = 0
      
      //Fill Sheet 
      DO WHILE ! oQuery:Eof()
         FOR EACH cField IN aColumns
   #ifdef __XHARBOUR__
            nId = HB_EnumINdex()
   #else 
            nId = cField:__EnumIndex()
   #endif      
            oSheet:Cells( ::nRow, ++::nCol ):Value   := oQuery:FieldGet( cField )
               
         NEXT 
         IF bOnRow != NIL
            Eval( bOnRow, oQuery:RecNo )
         ENDIF
         ::nRow++
         ::nCol = 0
         oQuery:Skip()
      ENDDO
   
      //Make Totals
      IF ::lMakeTotals
         ::nCol = 0
         oSheet:Rows( ::nRow ):Font:Bold   := .T.
         ::nRow--
         oSheet:Range( oSheet:Cells( ::nRow, 1 ), oSheet:Cells( ::nRow, Len( aColumns ) ) ):Select()
         ::oExcel:Selection:Borders( 9 ):LineStyle := 1   
         ::oExcel:Selection:Borders( 9 ):Weight    := -4138
         ::nRow++
         FOR EACH cField IN aColumns
            IF oQuery:aStructure[ ++::nCol ][ MYSQL_FS_CLIP_TYPE ] = "N"
               oSheet:Cells( ::nRow, ::nCol ):Formula := "=" + ::cxlSum + ;
                                   oSheet:Range( oSheet:Cells( 2, ::nCol ), ;
                                   oSheet:Cells( ::nRow - 1, ::nCol ) ):Address( .f., .f. ) + ")"
            ENDIF
         NEXT   
      ENDIF
      oSheet:Cells( 1,1 ):Select()
      
      IF bOnEnd != NIL 
         Eval( bOnEnd, ::oExcel, ::nRow, ::nCol )
      ENDIF
      
      oBook:SaveAs( ::oMain:cFileName )
      
   CATCH oError
      oError:Description = Ole2TxtError()
      oBook:Close( .F. )
      IF ! ::lOpened   
         ::oExcel:Quit()
      ENDIF

      oQuery:oServer:nInternalError = ERR_EXPORTTOEXCEL
      oQuery:oServer:CheckError( , oError:Description )

   END         
   
   IF ! ::lOpened   
      ::oExcel:Quit()
   ELSE 
      oBook:Close()
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
         ::cxlSum      := "SUM("

      case AScan( aSpanish, nxlLangID ) > 0 // Spanish
         ::cxlSum      := "SUMA("

      case nxlLangID == 1040 .or. nxlLangID == 2064 // Italian
         ::cxlSum      := "SOMMA("

      case AScan( aGerman, nxlLangID ) > 0 // German
         ::cxlSum      := "SUMME("

      case AScan( aFrench, nxlLangID ) > 0 // French
         ::cxlSum      := "SOMME("

      case nxlLangID == 2070 .or. nxlLangID == 1046 // Portugese
         ::cxlSum      := "SOMA("
         
   endcase

return nil   

static function clp2xlnumpic( cPic )

   local cFormat, aPic, c
   local cDecimal  := GetDecimalSep()
   local cThousand := GetThousandSep()
   

   if cPic == nil
      cFormat  := "0"
   else
      if cThousand $ cPic
         cFormat = "#" + cThousand + "##"
      endif
      if cDecimal $ cPic
         cFormat += "0" + cDecimal + "00"
      endif         
   endif

return cFormat