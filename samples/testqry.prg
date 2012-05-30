//#include "hbcompat.ch" // is necesary form compatibility with xharbour
#include "tdolphin.ch"


PROCEDURE Main()
   local oServer, oQry, aTables, aColumns, cQry, lError := .F.
   local aQuery
   local cScript, nLen 
   
   D_SetCaseSensitive( .T. )
 
   IF ( oServer := ConnectTo(4) ) == NIL
      RETURN NIL
   ENDIF
   
   oServer:Execute( "TRUNCATE TABLE script" )
   cScript := memoread( "base.sql" )
   aQuery = hb_ATokens( cScript, ";" )
   nLen = Len( aQuery )
   cls
   for each cQry in aQuery
      @ 1, 1 say AllTrim( Str( cQry:__enumIndex() ) ) + " / " + AllTrim( Str( nLen ) )
      if ! empty( cQry )
         oServer:insert( "script", {"tipo", "texto"}, { 1, AllTrim( cQry ) } )      
      endif
   next 

   cScript := memoread( "func.sql" )
   aQuery = hb_ATokens( cScript, ";;" )
   nLen = Len( aQuery )
   cls
   for each cQry in aQuery
      @ 1, 1 say AllTrim( Str( cQry:__enumIndex() ) ) + " / " + AllTrim( Str( nLen ) )
      if ! empty( cQry )
         oServer:insert( "script", {"tipo", "texto"}, { 2, AllTrim( cQry ) } )      
      endif
   next   
      
   cScript := memoread( "trig.sql" )
   aQuery = hb_ATokens( cScript, ";;" )
   nLen = Len( aQuery )
   cls
   for each cQry in aQuery
      @ 1, 1 say AllTrim( Str( cQry:__enumIndex() ) ) + " / " + AllTrim( Str( nLen ) )
      if ! empty( cQry )
         oServer:insert( "script", {"tipo", "texto"}, { 3, AllTrim( cQry ) } )      
      endif
   next  

   cScript := memoread( "records.sql" )
   aQuery = hb_ATokens( cScript, ";" )
   nLen = Len( aQuery )
   cls
   for each cQry in aQuery
      @ 1, 1 say AllTrim( Str( cQry:__enumIndex() ) ) + " / " + AllTrim( Str( nLen ) )
      if ! empty( cQry )
         oServer:insert( "script", {"tipo", "texto"}, { 4, AllTrim( cQry ) } )      
      endif
   next  
      
RETURN

#include "connto.prg"