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
 
 #include "tdolphin.ch"
 #include "hbclass.ch"
 #include "common.ch"
 #include "fileio.ch"
 #include "dolerr.ch" 
 
 CLASS TDolphinExport 
 
    DATA oQuery
    DATA aColumns
    DATA aPictures
 
    DATA cFileName
    
    DATA nType
    DATA bOnRow
    DATA oExport

    METHOD New( nType, oQuery, aColumns, aPictures  )
    
    METHOD Start() INLINE ::oExport:Export()
 
 
ENDCLASS

//----------------------------------------//

METHOD New( nType, oQuery, cFileName, aColumns, aPictures  ) CLASS TDolphinExport 

   DEFAULT nType TO EXP_TEXT

   ::oQuery     = oQuery
   ::aColumns   = aColumns
   ::aPictures  = aPictures
   ::cFileName  = cFileName
      

   SWITCH nType
      CASE EXP_TEXT
         ::oExport = TDolphinToText():New( Self )
         EXIT 
   ENDSWITCH 

RETURN Self

//----------------------------------------// 
 
CLASS TDolphinToText FROM TDolphinExport
 
    DATA cRowDelimiter
    DATA cTextQualifer
    DATA cFieldDelimiter
    DATA lAppend
    DATA lAddHeader
    DATA oMain
    
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