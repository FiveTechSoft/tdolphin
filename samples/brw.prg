#include "InKey.ch"
#include "tdolphin.ch"

#define B_BOX ( CHR( 218 ) + CHR( 196 ) + CHR( 191 ) + CHR( 179 ) + ;
                CHR( 217 ) + CHR( 196 ) + CHR( 192 ) + CHR( 179 ) + " " )
#define MAXROW 24

//----------------------------------------------------------------------------//

static procedure DolphinBrw( oQry, cName )

    local oBrowse, oCol
    local lEnd := .f.
    local nKey, n, nFld
    local cFlechas := chr( 27 ) + chr( 24 ) + chr( 25 ) + chr( 26 )
    static lPad := .f.

    if oQry:RecCount() < 1 // Comprobamos que hay registros
        Alert( "No hay registros" )
        return
    endif

    if ! HB_isString( cName )
        cName := " la consulta"
    else
        cName := " la tabla " + Upper( cName )
    endif

    oBrowse := TBrowseNew( 1, 0, MaxRow() - 1, MaxCol() )

    oBrowse:colorSpec  := "W+/B, N/BG"
    oBrowse:ColSep  := "|"
    oBrowse:HeadSep := "="
    oBrowse:FootSep := "="
    SetBrowse( oBrowse, oQry )

    nFld := oQry:FCount()

    FOR n := 1 TO nFld
        oCol = TBColumnNew( oQry:FieldName( n ), DataCol( oQry, n ) )
        SetPicture( oCol, oQry, n )
        oBrowse:AddColumn( oCol )        
    NEXT

    cls

    @ 0, 0 SAY PadC( "Consulta: " + cName, MaxCol() + 1, " " ) COLOR "W+/G+"

    @ MaxRow(),         0 SAY space( 100 )  COLOR "W+/G+"
    @ MaxRow(),         0 SAY cFlechas      COLOR "GR+/R+"
    @ MaxRow(), Col() + 1 SAY "Moverse"     COLOR "W+/R+"
    @ MaxRow(), Col() + 1 SAY "ESC"         COLOR "GR+/R+"
    @ MaxRow(), Col() + 1 SAY "Salir"       COLOR "W+/R+"

    while !lEnd

      oBrowse:ForceStable()

      nKey = InKey( 0 )

      switch nKey
         case K_ESC
              SetPos( MaxRow(), 0 )
              lEnd = .t.
              exit

         case K_DOWN
              oBrowse:Down()
              exit

         case K_UP
              oBrowse:Up()
              exit

         case K_LEFT
              oBrowse:Left()
              exit

         case K_RIGHT
              oBrowse:Right()
              exit

         case K_PGDN
              oBrowse:pageDown()
              exit

         case K_PGUP
              oBrowse:pageUp()
              exit

         case K_CTRL_PGUP
              oBrowse:goTop()
              exit

         case K_CTRL_PGDN
              oBrowse:goBottom()
              exit

         case K_HOME
              oBrowse:home()
              exit

         case K_END
              oBrowse:end()
              exit

         case K_CTRL_LEFT
              oBrowse:panLeft()
              exit

         case K_CTRL_RIGHT
              oBrowse:panRight()
              exit

         case K_CTRL_HOME
              oBrowse:panHome()
              exit

         case K_CTRL_END
              oBrowse:panEnd()
              exit

      endswitch

   end

return

static function DataCol( oQry, n )
return( { || oQry:FieldGet( n ) } )


//--------------------------------------//
//browse console mode

PROCEDURE SetBrowse( oBrw, oQry )

   WITH OBJECT oBrw
      :GoTopBlock    := {|| If( oQry:LastRec() > 0, oQry:GoTop(), NIL ) }
      :GoBottomBlock := {|| If( oQry:LastRec() > 0, oQry:GoBottom(), nil )  }
      :SkipBlock     := {| n | oQry:Skip( n ) }
   END
         
return nil      

//--------------------------------------//

PROCEDURE SetPicture( oCol, oQry, nField )
   local nType
   
   nType = oQry:aStructure[ nField ][ MYSQL_FS_CLIP_TYPE ]
   WITH OBJECT oCol
      if nType == "N"
         :picture = Replicate( "9", oQry:aStructure[ nField ][ MYSQL_FS_LENGTH ] )
         if oQry:aStructure[ nField ][ MYSQL_FS_DECIMALS ] > 0 
            :picture += "." + Replicate( "9", oQry:aStructure[ nField ][ MYSQL_FS_DECIMALS ] )
         endif
      endif 
   END            
   
static FUNCTION MaxRow()
RETURN MAXROW
   
      
      
