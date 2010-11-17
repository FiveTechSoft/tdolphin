/*
 * este ejemplo contruye las tablas en la base de datos ejemplo que utilizaremos 
 * para mostar las propiedades de Dolphin
 * la base de datos debe estar previamente creada
 * Muestra como usar METHOD CreateTable, Execute y MultiQuery
 * ---
 * This sample build tables in database sample we will use to show Dolphin features
 * Database should be exist
 * this aample show how use METHOD CreateTable, Execute and MultiQuery
 */

//#include "hbcompat.ch" // is necesary form compatibility with xharbour
#include "tdolphin.ch"


PROCEDURE Main()

   LOCAL aQuery    := Array( 9 )
   LOCAL aMemberSt, aPresidentSt
   LOCAL oServer
   LOCAL cQuery
   
   //Activated Case sensitive
   D_SetCaseSensitive( .T. )
   
   IF ( oServer := ConnectTo() ) == NIL
      RETURN
   ENDIF
   
   //Create tables
   //Student
   aQuery[ 1 ] = "DROP TABLE IF EXISTS absence"
   aQuery[ 2 ] = "DROP TABLE IF EXISTS score"
   aQuery[ 3 ] = "DROP TABLE IF EXISTS grade_event"
   aQuery[ 4 ] = "DROP TABLE IF EXISTS student"
   aQuery[ 5 ] = "DROP TABLE IF EXISTS member"
   aQuery[ 6 ] = "DROP TABLE IF EXISTS president"

   aQuery[ 7 ] =  "CREATE TABLE student ( name VARCHAR(20) NOT NULL,"
   aQuery[ 7 ] += "sex        ENUM('F','M') NOT NULL," 
   aQuery[ 7 ] += "student_id INT UNSIGNED NOT NULL AUTO_INCREMENT,"
   aQuery[ 7 ] += "PRIMARY KEY (student_id)) ENGINE = InnoDB"
   
   //grade_event
   aQuery[ 8 ] = "CREATE TABLE grade_event( date DATE NOT NULL, "
   aQuery[ 8 ] += "category ENUM('T','Q') NOT NULL,"
   aQuery[ 8 ] += "event_id INT UNSIGNED NOT NULL AUTO_INCREMENT,"
   aQuery[ 8 ] += "PRIMARY KEY (event_id)"
   aQuery[ 8 ] += ") ENGINE = InnoDB"
  
   //score
   aQuery[ 9 ] = "CREATE TABLE score( student_id INT UNSIGNED NOT NULL, "
   aQuery[ 9 ] += "event_id   INT UNSIGNED NOT NULL,"
   aQuery[ 9 ] += "score      INT NOT NULL,"
   aQuery[ 9 ] += "PRIMARY KEY (event_id, student_id), INDEX (student_id),"
   aQuery[ 9 ] += "FOREIGN KEY (event_id) REFERENCES grade_event (event_id),"
   aQuery[ 9 ] += "FOREIGN KEY (student_id) REFERENCES student (student_id)"
   aQuery[ 9 ] += ") ENGINE = InnoDB"
    
   //absence
   cQuery = "CREATE TABLE absence( student_id INT UNSIGNED NOT NULL, "
   cQuery += "date       DATE NOT NULL,"
   cQuery += "PRIMARY KEY (student_id, date), "
   cQuery += "FOREIGN KEY (student_id) REFERENCES student (student_id)"
   cQuery += ") ENGINE = InnoDB"   
   
   
    //we dont need transaction here
   oServer:MultiQuery( aQuery, .F., {| nIdx | Qout( "Query " + StrZero( nIdx, 2 ) + " OK" ) } )
   
   oServer:Execute( cQuery )
   
   //CreateTable( cTable, aStruct, cPrimaryKey, cUniqueKey, cAuto, cExtra, lIfNotExist, lVer )
   //Table Structure (like dbf)
   //Name, Type, Length, Decimal, Not Null (logical), Defaul value
   //member structure 
   aMemberSt = { { "member_id" , "N", 10, 0, .T., 0 },;
   	             { "last_name" , "C", 20, 0, .T., } ,;
   	             { "first_name", "C", 20, 0, .T., } ,;
   	             { "suffix"    , "C",  5, 0, .F., } ,;
   	             { "expiration", "D", 10, 0, .F., } ,;
   	             { "email"     , "C",100, 0, .F., } ,;
   	             { "street"    , "C", 50, 0, .F., } ,;
   	             { "city"      , "C", 50, 0, .F., } ,;
   	             { "state"     , "C",  2, 0, .F., } ,;
   	             { "zip"       , "C", 10, 0, .F., } ,;
   	             { "phone"     , "C", 20, 0, .F., } ,;
   	             { "interests" , "C",255, 0, .F., } }
  oServer:CreateTable( "member", aMemberSt, "member_id", , "member_id", "ENGINE = InnoDB" )
  
  //
  //president structure 
  aPresidentSt = { { "last_name" , "C", 15, 0, .T., } ,;
   	               { "first_name", "C", 15, 0, .T., } ,;
   	               { "suffix"    , "C",  5, 0, .F., } ,;
   	               { "city"      , "C", 20, 0, .F., } ,;
   	               { "state"     , "C",  2, 0, .F., } ,;
   	               { "birth"     , "D", 10, 0, .T., } ,;
   	               { "death"     , "D", 10, 0, .F., } }

  oServer:CreateTable( "president", aPresidentSt, , , ,"ENGINE = InnoDB" )

  ? "all tables was created successful"
  ?

RETURN   	           

#include "connto.prg"  	
  