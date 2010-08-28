
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