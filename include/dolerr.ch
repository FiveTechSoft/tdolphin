/*
 * $Id: 10-Jul-10 9:40:26 AM dolerr.ch Z dgarciagil $
 */



// dolerr.ch
// internal error


//from server
#define ERR_EMPTYDBNAME                  9000
#define ERR_INVALID_STRUCT_ROW_SIZE      9001
#define ERR_INVALID_STRUCT_NOTNULL_VALUE 9002
#define ERR_INVALID_STRUCT_PRIKEY        9003
#define ERR_INVALID_STRUCT_UNIQUE        9004
#define ERR_INVALID_STRUCT_AUTO          9005
#define ERR_NOQUERY                      9006
#define ERR_EMPTYVALUES                  9007
#define ERR_EMPTYTABLE                   9008
#define ERR_NOMATCHCOLUMNSVALUES         9009
#define ERR_INVALIDCOLUMN                9010
#define ERR_INVALIDFIELDNUM              9011
#define ERR_INVALIDFIELDNAME             9012
#define ERR_INVALIDFIELDGET              9013
#define ERR_FAILEDGETROW                 9014
#define ERR_INVALIDGETBLANKROW           9015
#define ERR_INVALIDSAVE                  9016
#define ERR_NOTHINGTOSAVE                9017
#define ERR_NODATABASESELECTED           9018
#define ERR_MISSINGQRYOBJECT             9019
#define ERR_INVALIDBACKUPFILE            9020
#define ERR_NOTABLESSELECTED             9021
#define ERR_INVALIDDELETE                9022 
#define ERR_DELETING                     9023
#define ERR_INVALIDQUERYARRAY            9024
#define ERR_MULTIQUERYFAULIRE            9025
#define ERR_INVALIDFIELDTYPE             9026
#define ERR_INVALIDFILENAME              9027
#define ERR_NOEXCELINSTALED              9028
#define ERR_EXPORTTOEXCEL                9029

//MySql Errort


#define CR_UNKNOWN_ERROR	2000
#define CR_SOCKET_CREATE_ERROR	2001
#define CR_CONNECTION_ERROR	2002
#define CR_CONN_HOST_ERROR	2003
#define CR_IPSOCK_ERROR		2004
#define CR_UNKNOWN_HOST		2005
#define CR_SERVER_GONE_ERROR	2006
#define CR_VERSION_ERROR	2007
#define CR_OUT_OF_MEMORY	2008
#define CR_WRONG_HOST_INFO	2009
#define CR_LOCALHOST_CONNECTION 2010
#define CR_TCP_CONNECTION	2011
#define CR_SERVER_HANDSHAKE_ERR 2012
#define CR_SERVER_LOST		2013
#define CR_COMMANDS_OUT_OF_SYNC 2014
#define CR_NAMEDPIPE_CONNECTION 2015
#define CR_NAMEDPIPEWAIT_ERROR  2016
#define CR_NAMEDPIPEOPEN_ERROR  2017
#define CR_NAMEDPIPESETSTATE_ERROR 2018
#define CR_CANT_READ_CHARSET	2019
#define CR_NET_PACKET_TOO_LARGE 2020
#define CR_EMBEDDED_CONNECTION	2021
#define CR_PROBE_SLAVE_STATUS   2022
#define CR_PROBE_SLAVE_HOSTS    2023
#define CR_PROBE_SLAVE_CONNECT  2024
#define CR_PROBE_MASTER_CONNECT 2025
#define CR_SSL_CONNECTION_ERROR 2026
#define CR_MALFORMED_PACKET     2027
#define CR_WRONG_LICENSE	2028

/* new 4.1 error codes */
#define CR_NULL_POINTER		2029
#define CR_NO_PREPARE_STMT	2030
#define CR_PARAMS_NOT_BOUND	2031
#define CR_DATA_TRUNCATED	2032
#define CR_NO_PARAMETERS_EXISTS 2033
#define CR_INVALID_PARAMETER_NO 2034
#define CR_INVALID_BUFFER_USE	2035
#define CR_UNSUPPORTED_PARAM_TYPE 2036

#define CR_SHARED_MEMORY_CONNECTION             2037
#define CR_SHARED_MEMORY_CONNECT_REQUEST_ERROR  2038
#define CR_SHARED_MEMORY_CONNECT_ANSWER_ERROR   2039
#define CR_SHARED_MEMORY_CONNECT_FILE_MAP_ERROR 2040
#define CR_SHARED_MEMORY_CONNECT_MAP_ERROR      2041
#define CR_SHARED_MEMORY_FILE_MAP_ERROR         2042
#define CR_SHARED_MEMORY_MAP_ERROR              2043
#define CR_SHARED_MEMORY_EVENT_ERROR     	2044
#define CR_SHARED_MEMORY_CONNECT_ABANDONED_ERROR 2045
#define CR_SHARED_MEMORY_CONNECT_SET_ERROR      2046
#define CR_CONN_UNKNOW_PROTOCOL 		2047
#define CR_INVALID_CONN_HANDLE			2048
#define CR_SECURE_AUTH                          2049
#define CR_FETCH_CANCELED                       2050
#define CR_NO_DATA                              2051
#define CR_NO_STMT_METADATA                     2052
#define CR_NO_RESULT_SET                        2053
#define CR_NOT_IMPLEMENTED                      2054
#define CR_SERVER_LOST_EXTENDED			2055
#define CR_STMT_CLOSED				2056
#define CR_NEW_STMT_METADATA                    2057
#define CR_ALREADY_CONNECTED                    2058