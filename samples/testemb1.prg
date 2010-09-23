#include "hbcompat.ch"
#include "tdolphin.ch"

#define CONNECT1 1

PROCEDURE Main()
   LOCAL oServer , oQuery
   
   CONNECT EMBEDDED oServer ;
          DATABASE "tdolphin" ;
          OPTIONS "Dolphin_server_embedded",;
                  "--datadir=./dbdir/",;
                  "--language=./sysdir/spanish/",;
                  "--skip-innodb",;
                  "--key-buffer-size=64MB",;
                  "--console";
          GROUPS "Dolphin_server_embedded", 
   
   DEFINE QUERY oQuery "SELECT * FROM test"
   
   DolphinBrw( oQuery, "Test" )
   
   CLOSEMYSQL ALL
   
RETURN

#include "brw.prg"