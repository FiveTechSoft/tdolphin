
FUNCTION ConnectTo()
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
      CONNECT oServer HOST cServer ;
                      USER cUser ;
                      PASSWORD cPassword ;
                      PORT nPort ;
                      FLAGS nFlags;
                      DATABASE cDBName
                                
   CATCH oErr 
     RETURN NIL
   END
   
RETURN oServer

FUNCTION ConnectTo2()

   LOCAL hIni      := HB_ReadIni( ".\connect.ini" )
   LOCAL aServer   := {NIL, NIL}
   LOCAL aHost     := { hIni["mysql"]["host"], hIni["mysql2"]["host"] } ,;
         aUser     := { hIni["mysql"]["user"], hIni["mysql2"]["user"] },;
         aPassword := { hIni["mysql"]["psw"],  hIni["mysql2"]["psw"] },;
         aPort     := { val(hIni["mysql"]["port"]), val(hIni["mysql2"]["port"])}, ;
         aDBName   := { hIni["mysql"]["dbname"], hIni["mysql2"]["dbname"] },;
         aFlags    := { val(hIni["mysql"]["flags"]), val(hIni["mysql2"]["flags"])}
   LOCAL oError

   TRY 

      CONNECT aServer[ 1 ] HOST aHost[ 1] ;
                      USER aUser[ 1 ] ;
                      PASSWORD aPassword[ 1 ] ;
                      PORT aPort[ 1 ] ;
                      FLAGS aFlags[ 1 ];
                      NAME "CONNECT1"
   
      CONNECT aServer[ 2 ] HOST aHost[ 2 ] ;
                      USER aUser[ 2 ] ;
                      PASSWORD aPassword[ 2 ] ;
                      PORT aPort[ 2 ] ;
                      FLAGS aFlags[ 2 ];
                      NAME "CONNECT2"
                          
    CATCH oError
       IF aServer[ CONNECT1 ] != NIL 
         aServer[ CONNECT1 ]:End()
       ENDIF
       return
    END  
    
RETURN aServer    