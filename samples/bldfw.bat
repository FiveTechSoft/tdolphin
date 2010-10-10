@ECHO OFF
CLS

if A%1==A GOTO :SINTAX
if NOT EXIST %1.prg GOTO :NOEXIST
if "%2"=="yes" ( GOTO :OK ) else ( 
	if "%2"=="no" ( GOTO :OK ) else (
		if "%2"=="" ( GOTO :FORCE ) else ( GOTO :SINTAX ) ) )

:FORCE
SET EMBEDDED=no
GOTO :BUILD

:OK
SET EMBEDDED=%2
GOTO :BUILD

:BUILD
SET BLD_TYPE=gtgui
SET SAMPLE=%1
SET GUI_LIB=c:\fivewin\svn\repo\lib\fivehc c:\fivewin\svn\repo\lib\fiveh
SET GUI_INC=\fwh\include
if exist %1.rc SET FILE_RC=%1.rc

..\win-make sample
GOTO :EXIT

:SINTAX
ECHO %2
ECHO    SYNTAX: bldcon Program [yes/[no]] {-- No especifiques la extensi¢n PRG yes/no servidor incrustado
ECHO                                      {-- Don't specify .PRG extension PRG yes/no server embedded
GOTO EXIT

:NOEXIST
ECHO The specified PRG %1 does not exist

:EXIT
SET EMBEDDED=
SET SAMPLE=
SET FILE_RC=
SET GUI_LIB=
SET GUI_INC=