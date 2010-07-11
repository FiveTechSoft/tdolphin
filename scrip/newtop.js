/*
 * $Id: 11-Jul-10 9:42:23 AM newtop.js Z dgarciagil $
 */


// Get the num of open documents.
var num_of_docs = UltraEdit.document.length;

var com1 = "/*\r\n";
var com2 = " */\r\n";
var time;
var sfile;
var doc

// Enumerate through all open documents and add the header.
var index;
for (index = 0; index < num_of_docs; index++) {
  UltraEdit.document[index].top();	
	UltraEdit.document[index].deleteLine(); 
	UltraEdit.document[index].deleteLine();
	UltraEdit.document[index].deleteLine();	
  UltraEdit.document[index].write(com1);
  UltraEdit.document[index].write(" * $Id: ");
  sfile = GetFileName( index );
  time = UltraEdit.document[index].timeDate();
  UltraEdit.document[index].write( " " + sfile + " " );
  UltraEdit.document[index].write( time );
  UltraEdit.document[index].write( "Z dgarciagil $" );
  UltraEdit.document[index].write( "\r\n");
  UltraEdit.document[index].write(com2);
  GetBuild( sfile, index, time );
  UltraEdit.saveAll();

}


function GetFileName ( nIndex ) {
	var sFullName = UltraEdit.document[nIndex].path;
	var sFileName;
	var nLastDirDelim = 0;
	nLastDirDelim = sFullName.lastIndexOf("\\");
	sFileName = sFullName.substring(nLastDirDelim + 1);	
	return sFileName;
}

function GetBuild ( sfile, index, time ) {
	if( sfile == "tdolpsrv.PRG" ){
		UltraEdit.document[index].findReplace.find( "DATA cBuild" );
    UltraEdit.document[index].deleteLine(); 
    UltraEdit.document[index].write( "   DATA cBuild     INIT '" );
    UltraEdit.document[index].write( UltraEdit.document[index].timeDate() );
    UltraEdit.document[index].write( "'" );
    UltraEdit.document[index].write( "\r\n");    
	}
}