#include <Fivewin.ch>
#include <hbcompat.ch>
#include <tdolphin.ch>
#include <XBrowse.ch>

#DEFINE C_SIMPLE CHR( 39 )
#DEFINE c_simple CHR( 39 )

* ---------------------------------------------------------*
* testfw3.prg                                              *
* uso de methods Seek(), Locate(), Find(), Save()          *
* con tDolphin y  xbrowse                                  *
*                                                          *
* by, Cesar Cortes Cruz                                    *
* sin +- fivewin es mejor
* ---------------------------------------------------------*

Function Main()
   
   WITH OBJECT SysCtrl()      
      :New()
   END OBJECT         
   
return nil

CLASS SysCtrl
   DATA oBox, oGrid, oMain, oCon, oQry AS OBJECT
   DATA cUser INIT ":: Usuario ::"
   METHOD New()
   METHOD Conecta()
   METHOD CreaPrueba()
   METHOD MakeDialogo()
   METHOD AddReg()
   method MakeBottoms()
   method Dlg1()
   METHOD ChkFolio( oGet, cNo_folio, oDlg )
   METHOD Guardar()
   method Dlg2()
   METHOD ChkFolio2( oGet, cNo_folio, oDlg )
   method Dlg3()
   METHOD ChkFolio3( oGet, cNo_folio, oDlg )      
ENDCLASS

METHOD New() CLASS SysCtrl
   
   SET( _SET_DATEFORMAT,"dd/mm/yyyy" )
   
   //Activated Case sensitive
   D_SetCaseSensitive( .t. )
   
   Set_MyLang( "esp" ) && seleccionamos el lenguaje
   
   * ----------------------------------- *
   * conectamos con el servidor          *
   * ----------------------------------- *
   IF ( ::oCon := ::Conecta() ) == NIL
      msgstop('No se pudo realizar una conecxion con el servidor', ::cUser )
      RETURN NIL
   ENDIF      
   
   * -------------------------------------------- *
   * si tuvimos exito con la conexion             *
   * creamos la tabla PRUEBA para nuestro ejemplo *
   * -------------------------------------------- *   
   ::CreaPrueba()
   
   * -------------------------------------------- *
   * creamos el dialogo para nuestros controles   *
   * -------------------------------------------- *      
   ::MakeDialogo()
   
   * -------------------------------------------- *
   * cerramos la conexion                         *
   * -------------------------------------------- *
   
   ::oCon:End()
   
return Self

METHOD Conecta() CLASS SysCtrl
   LOCAL hIni      := HB_ReadIni( ".\connect.ini" )
   LOCAL oServer   := NIL
   LOCAL cServer   := hIni["mysql"]["host"],;
         cUser     := hIni["mysql"]["user"],;
         cPassword := hIni["mysql"]["psw"],;
         nPort     := val(hIni["mysql"]["port"]), ;
         cDBName   := hIni["mysql"]["dbname"], ;
         nFlags    := val(hIni["mysql"]["flags"])
   LOCAL oErr
   
   TRY
   
      oServer = TDolphinSrv():New( cServer, ;
                                cUser, ;
                                cPassword, ;
                                nPort,;
                                nFlags,;
                                cDbName)
   CATCH oErr 
     RETURN NIL
   END
   
RETURN oServer

METHOD CreaPrueba() CLASS SysCtrl
   local cQry
   
   * -------------------------------------------- *
   * creamos la tabla PRUEBA                      *
   * -------------------------------------------- *

   cQry := "CREATE TABLE IF NOT EXISTS prueba ( "
   cQry += "cliente_id INT UNSIGNED NOT NULL AUTO_INCREMENT,"   
   cQry += "no_folio             varchar(10) default ' ', "  
   cQry += "no_suscriptor        varchar(10) default ' ', " 
   cQry += "fecha        date NOT NULL, "
   cQry += "nombre     varchar(60) default ' ', "
   
   cQry += "PRIMARY KEY (cliente_id)"
   cQry += ") ENGINE = InnoDB"
   
   ::oCon:Execute( cQry )   
   
Return nil

METHOD MakeDialogo() CLASS SysCtrl
   local oSelf := Self
   local nBottom, nRight
   * --------------------------------------- *
   * creamos nuestro query                   *
   * ordenado por el campo NO_FOLIO          *
   * --------------------------------------- *
   
   ::oQry = ::oCon:Query( "SELECT * FROM prueba ORDER BY no_folio" )
   
   ::oQry:zap() && limpiamos la tabla.
   
   * --------------------------------------- *
   * agregamos unos registros                *
   * a la tabla PRUEBA                       *
   * --------------------------------------- *
   ::AddReg()
   
   
   DEFINE DIALOG ::oBox SIZE 700,300 
   ::oBox:cTitle := 'BUSQUEDAS CON TDOLPHIN'
   
   ::MakeBottoms()
   
   // nBottom := (::oBox:nBottom / 2) - 100
   nRight  := (::oBox:nRight / 2 )   

   @ 0, 0 XBROWSE ::oGrid 
   
   ::oGrid:nTop    := 00
   ::oGrid:nLeft   := 100+2
   ::oGrid:nBottom := 150
   ::oGrid:nRight  := nRight   
   
   SetDolphin( ::oGrid, ::oQry )
      
   ::oGrid:CreateFromCode()
  
   ::oBox:oClient = ::oGrid 
   
   ACTIVATE DIALOG ::oBox CENTERED
   
   
   * ---------------------------------------- *
   * cerramos el query                        *
   * -----------------------------------------*
   ::oQry:End()   
RETURN NIL

METHOD AddReg() CLASS SysCtrl
   
   * ----------------------------------------- *
   * damos de alta 5 registros                 *
   * ----------------------------------------- *
   ::oQry:GetBlankRow( .F. )   
   ::oQry:no_folio      := '303030'
   ::oQry:no_suscriptor := "200"
   ::oQry:fecha         := date()
   ::oQry:nombre        := "NOMBRE 1"
   ::oQry:save()
   
   ::oQry:GetBlankRow( .F. )   
   ::oQry:no_folio      := '404040'
   ::oQry:no_suscriptor := "300"
   ::oQry:fecha         := date()
   ::oQry:nombre        := "NOMBRE 2"
   ::oQry:save()   
   
   ::oQry:GetBlankRow( .F. )   
   ::oQry:no_folio      := '505050'
   ::oQry:no_suscriptor := "400"
   ::oQry:fecha         := date()
   ::oQry:nombre        := "NOMBRE 4"
   ::oQry:save()   
   
   ::oQry:GetBlankRow( .F. )   
   ::oQry:no_folio      := '2000S'
   ::oQry:no_suscriptor := "500"
   ::oQry:fecha         := date()
   ::oQry:nombre        := "NOMBRE 5"
   ::oQry:save()      
   
   ::oQry:GetBlankRow( .F. )   
   ::oQry:no_folio      := '606060'
   ::oQry:no_suscriptor := "600"
   ::oQry:fecha         := date()
   ::oQry:nombre        := "CESAR CORTES CRUZ"
   ::oQry:save()            
   
   
return nil

method MakeBottoms() CLASS SysCtrl
   local oBtn := array(5)
   
   @ 10, 10 BUTTON oBtn[1] PROMPT "METHOD Seek() "  SIZE 70, 12 OF ::oBox ;
       ACTION (  ::Dlg1()     ) PIXEL
       
   @ 30, 10 BUTTON oBtn[2] PROMPT "METHOD Locate() "  SIZE 70, 12 OF ::oBox ;
       ACTION (  ::Dlg2()     ) PIXEL
       
   @ 50, 10 BUTTON oBtn[3] PROMPT "METHOD Find() "  SIZE 70, 12 OF ::oBox ;
       ACTION (  ::Dlg3()     ) PIXEL
       
   @ 70, 10 BUTTON oBtn[4] PROMPT "&Exit" SIZE 70, 12 OF ::oBox  ACTION ( ::oBox:end() ) CANCEL PIXEL
   
return nil

method Dlg1() CLASS SysCtrl
   local oDlg
   local oGet := array(10)
   local cNo_folio := space(10)
   local oBtn
   
   
   && creamos un registro en blanco
   ::oQry:GetBlankRow( .F. )
   
   DEFINE DIALOG oDlg SIZE 450,200  title 'BUSCAR POR EL CAMPO ( NO_FOLIO ) METHOD SEEK()'
   
   @ 10, 10 SAY "No. Folio : " OF oDlg pixel
   @ 10, 70 GET oGet[ 1 ] VAR cNo_folio of oDlg SIZE 60, 10  PICTURE "@!k" PIXEL UPDATE ;
   valid ::ChkFolio( @oGet, @cNo_folio, oDlg )
   
   @ 20, 10 SAY "No. Suscriptor : " OF oDlg pixel
   @ 20, 70 GET oGet[ 2 ] VAR ::oQry:no_suscriptor of oDlg SIZE 60, 10  PICTURE "@!k" PIXEL UPDATE 
   
   @ 30, 10 SAY "Fecha : " OF oDlg pixel
   @ 30, 70 GET oGet[ 3 ] VAR ::oQry:fecha of oDlg SIZE 40, 10  PICTURE "d" PIXEL UPDATE 
   
   @ 40, 10 SAY "Nombre : " OF oDlg pixel
   @ 40, 70 GET oGet[ 4 ] VAR ::oQry:nombre of oDlg SIZE 150, 10  PICTURE "@!k" PIXEL UPDATE 
   
   @ 70, 60 BUTTON oBtn PROMPT "Aceptar"  SIZE 60, 12 OF oDlg ;
       ACTION ( ::Guardar() ,oDlg:end()     ) PIXEL   
   
   ACTIVATE DIALOG oDlg CENTERED
   
return nil


* --------------------------------------------------- *
* dependiendo de la busqueda si no existe             *
* lo damos de alta en caso contrario                  *
* solo lo editamos                                    *
* --------------------------------------------------- *


METHOD Guardar() CLASS SysCtrl
   local oWait
   WaitOn(space(40), @oWait)
   oWait:say(1,1, 'Guardando datos')
   oWait:say(3,1, 'espere un momento ...')
   oWait:say(5,1, 'Gracias ...')
   
   ::oQry:save()
   
   WaitOff(@oWait)
   
   ::oGrid:Refresh()
   ::oGrid:Setfocus()
   ::oBox:Update()
   
   
return nil


METHOD ChkFolio( oGet, cNo_folio, oDlg ) CLASS SysCtrl
   LOCAL nSeek
   
   nSeek = ::oQry:Seek( cNo_folio, 2, , , .T.) // lSoft := .T.
   
   if nSeek == 0 
      msginfo('SI NO EXISTE' + chr(13) +;
      'entonces lo AGREGAMOS', 'Usuario ...'      )
      ::oQry:GetBlankRow( .F. )
      ::oQry:no_folio := cNo_folio
      ::oQry:fecha := date()
      ::oQry:lAppend := .t.
   else
      msginfo('El registro YA EXISTE' + chr(13) +;
      'se lo presentamos al usuario' + chr(13) +;
      'Para una posible EDICION', 'Usuario ...'      )   
      ::oQry:lAppend := .f.
   endif
   
   oDlg:update()
   
RETURN .T.



* ---------------------------------------------------- *
* buscando con el method LOCATE()                      *
* ---------------------------------------------------- *

method Dlg2() CLASS SysCtrl
   local oDlg
   local oGet := array(10)
   local cNo_folio := space(10)
   local oBtn
   
   
   && creamos un registro en blanco
   ::oQry:GetBlankRow( .F. )
   
   DEFINE DIALOG oDlg SIZE 450,200  title 'BUSCAR POR EL CAMPO ( NO_FOLIO ) METHOD LOCATE()'
   
   @ 10, 10 SAY "No. Folio : " OF oDlg pixel
   @ 10, 70 GET oGet[ 1 ] VAR cNo_folio of oDlg SIZE 60, 10  PICTURE "@!k" PIXEL UPDATE ;
   valid ::ChkFolio2( @oGet, @cNo_folio, oDlg )
   
   @ 20, 10 SAY "No. Suscriptor : " OF oDlg pixel
   @ 20, 70 GET oGet[ 2 ] VAR ::oQry:no_suscriptor of oDlg SIZE 60, 10  PICTURE "@!k" PIXEL UPDATE 
   
   @ 30, 10 SAY "Fecha : " OF oDlg pixel
   @ 30, 70 GET oGet[ 3 ] VAR ::oQry:fecha of oDlg SIZE 40, 10  PICTURE "d" PIXEL UPDATE 
   
   @ 40, 10 SAY "Nombre : " OF oDlg pixel
   @ 40, 70 GET oGet[ 4 ] VAR ::oQry:nombre of oDlg SIZE 150, 10  PICTURE "@!k" PIXEL UPDATE 
   
   @ 70, 60 BUTTON oBtn PROMPT "Aceptar"  SIZE 60, 12 OF oDlg ;
       ACTION ( ::Guardar() ,oDlg:end()     ) PIXEL   
   
   ACTIVATE DIALOG oDlg CENTERED
   
return nil

METHOD ChkFolio2( oGet, cNo_folio, oDlg ) CLASS SysCtrl
   LOCAL nSeek
   
   nSeek = ::oQry:Locate( { cNo_folio }, {"no_folio"} )
   
   if nSeek == 0 
      msginfo('SI NO EXISTE' + chr(13) +;
      'entonces lo AGREGAMOS', 'Usuario ...'      )
      ::oQry:GetBlankRow( .F. )
      ::oQry:no_folio := cNo_folio
      ::oQry:fecha := date()
      ::oQry:lAppend := .t.
   else
      msginfo('El registro YA EXISTE' + chr(13) +;
      'se lo presentamos al usuario' + chr(13) +;
      'Para una posible EDICION', 'Usuario ...'      )   
      ::oQry:lAppend := .f.
   endif
   
   oDlg:update()
   
RETURN .T.



* ---------------------------------------------------- *
* buscando con el method FIND()                        *
* ---------------------------------------------------- *

method Dlg3() CLASS SysCtrl
   local oDlg
   local oGet := array(10)
   local cNo_folio := space(10)
   local oBtn
   
   
   && creamos un registro en blanco
   ::oQry:GetBlankRow( .F. )
   
   DEFINE DIALOG oDlg SIZE 450,200  title 'BUSCAR POR EL CAMPO ( NO_FOLIO ) METHOD FIND()'
   
   @ 10, 10 SAY "No. Folio : " OF oDlg pixel
   @ 10, 70 GET oGet[ 1 ] VAR cNo_folio of oDlg SIZE 60, 10  PICTURE "@!k" PIXEL UPDATE ;
   valid ::ChkFolio3( @oGet, @cNo_folio, oDlg )
   
   @ 20, 10 SAY "No. Suscriptor : " OF oDlg pixel
   @ 20, 70 GET oGet[ 2 ] VAR ::oQry:no_suscriptor of oDlg SIZE 60, 10  PICTURE "@!k" PIXEL UPDATE 
   
   @ 30, 10 SAY "Fecha : " OF oDlg pixel
   @ 30, 70 GET oGet[ 3 ] VAR ::oQry:fecha of oDlg SIZE 40, 10  PICTURE "d" PIXEL UPDATE 
   
   @ 40, 10 SAY "Nombre : " OF oDlg pixel
   @ 40, 70 GET oGet[ 4 ] VAR ::oQry:nombre of oDlg SIZE 150, 10  PICTURE "@!k" PIXEL UPDATE 
   
   @ 70, 60 BUTTON oBtn PROMPT "Aceptar"  SIZE 60, 12 OF oDlg ;
       ACTION ( ::Guardar() ,oDlg:end()     ) PIXEL   
   
   ACTIVATE DIALOG oDlg CENTERED
   
return nil

METHOD ChkFolio3( oGet, cNo_folio, oDlg ) CLASS SysCtrl
   LOCAL nSeek
   
   nSeek = ::oQry:Find( { cNo_folio }, {"no_folio"} )
   
   if nSeek == 0 
      msginfo('SI NO EXISTE' + chr(13) +;
      'entonces lo AGREGAMOS', 'Usuario ...'      )
      ::oQry:GetBlankRow( .F. )
      ::oQry:no_folio := cNo_folio
      ::oQry:fecha := date()
      ::oQry:lAppend := .t.
   else
      msginfo('El registro YA EXISTE' + chr(13) +;
      'se lo presentamos al usuario' + chr(13) +;
      'Para una posible EDICION', 'Usuario ...'      )   
      ::oQry:lAppend := .f.
   endif
   
   oDlg:update()
   
RETURN .T.




* -------------------------------------------------- *
* FUNCIONES ADICIONALES                              *
* -------------------------------------------------- *

function waitOn( cCaption, oWait, cTitle )  //simula un waiton de grump
   LOCAL nWidth
   local lVal := .t.
   local oBrush

   LOCAL   bAction  := { || .t. }
   default cTitle := "Usuario, un momento por favor"
   DEFINE BRUSH oBrush COLOR RGB( 192, 216, 255 )   //rosa


   IF cCaption == NIL
      DEFINE DIALOG oWait ;
         FROM 0,0 TO 12, Len( cTitle ) + 4 ;
         STYLE nOr( DS_MODALFRAME, WS_POPUP ) BRUSH oBrush TRANSPARENT
   ELSE
      DEFINE DIALOG oWait ;
         FROM 0,0 TO 12, Max( Len( cCaption ), Len( cTitle ) ) + 4 ;
         TITLE cTitle ;
         STYLE DS_MODALFRAME BRUSH oBrush TRANSPARENT
   ENDIF

   oWait:cMsg   := cCaption

   nWidth := oWait:nRight - oWait:nLeft

   //@ 01, 1 BUTTON " &Cancelar " OF oWait SIZE 60, 12 ;
   //ACTION ( lVal := .f., oWait:End() )

   ACTIVATE DIALOG oWait CENTER ;
      ON PAINT oWait:Say( 1, 0, xPadC( oWait:cMsg, nWidth ) ) ;
      NOWAIT
   sysRefresh()
return (lVal)

function WaitOff( oWait )
   IF valtype(oWait) <> 'U'  /* waiton has to be called first! */
      oWait:end()
      oWait := NIL
   ENDIF
   sysRefresh()
RETURN NIL






#include "setbrw.prg"