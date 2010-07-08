/*
 * $Id: newtop.js 7/7/2010 9:44:50 PMZ dgarciagil $
 */
// Get the num of open documents.
var num_of_docs = UltraEdit.document.length;

var com1 = "/*\r\n";
var com2 = " */\r\n";


// Enumerate through all open documents and add the header.
var index;
for (index = 0; index < num_of_docs; index++) {
  UltraEdit.document[index].top();	
	UltraEdit.document[index].deleteLine(); 
	UltraEdit.document[index].deleteLine();
	UltraEdit.document[index].deleteLine();	
  UltraEdit.document[index].write(com1);
  UltraEdit.document[index].write(" * $Id: ");
  UltraEdit.document[index].write( GetFileName( index ) + " " );
  UltraEdit.document[index].write( UltraEdit.document[index].timeDate() );
  UltraEdit.document[index].write( "Z dgarciagil $" );
  UltraEdit.document[index].write( "\r\n");
  UltraEdit.document[index].write(com2);
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
