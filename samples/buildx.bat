@ECHO OFF
CLS
if A%1 == A GOTO :SINTAX
if NOT EXIST %1.prg GOTO :NOEXIST

ECHO Compiling...

set GT=gtgui

set hdir=c:\xharbour
set hdirl=%hdir%\lib
set bcdir=c:\bcc582
set fwh=c:\fivewin\svn\repo

%hdir%\bin\harbour %1 /n /i%fwh%\include;%hdir%\include;..\include /w /p %2 %3 > comp.log
IF ERRORLEVEL 1 GOTO COMPILEERRORS
@type comp.log

echo -O2 -e%1.exe -I%hdir%\include -I%bcdir%\include;..\include %1.c > b32.bc
%bcdir%\bin\bcc32 -M -c -v @b32.bc
:ENDCOMPILE

IF EXIST %1.rc %bcdir%\bin\brc32 -r -I%bcdir%\include %1

echo %bcdir%\lib\c0w32.obj + > b32.bc
echo %1.obj, + >> b32.bc
echo %1.exe, + >> b32.bc
echo %1.map, + >> b32.bc
echo %fwh%\lib\Fivehx.lib %fwh%\lib\FiveHC.lib + >> b32.bc
echo %hdirl%\rtlmt.lib + >> b32.bc
echo %hdirl%\vmmt.lib + >> b32.bc
echo %hdirl%\%GT%.lib + >> b32.bc
echo %hdirl%\lang.lib + >> b32.bc
echo %hdirl%\macro.lib + >> b32.bc
echo %hdirl%\rdd.lib + >> b32.bc
echo %hdirl%\dbfntx.lib + >> b32.bc
echo %hdirl%\dbfcdx.lib + >> b32.bc
echo %hdirl%\dbffpt.lib + >> b32.bc
echo %hdirl%\hbsix.lib + >> b32.bc
echo %hdirl%\debug.lib + >> b32.bc
echo %hdirl%\common.lib + >> b32.bc
echo %hdirl%\pp.lib + >> b32.bc
echo %hdirl%\pcrepos.lib + >> b32.bc
echo %hdirl%\ct.lib + >> b32.bc
echo ..\lib\dolphinx.lib + >> b32.bc
echo ..\lib\libmysql.lib + >> b32.bc


rem Uncomment these two lines to use Advantage RDD
rem echo %hdir%\lib\rddads.lib + >> b32.bc
rem echo %hdir%\lib\Ace32.lib + >> b32.bc

echo %bcdir%\lib\cw32mt.lib + >> b32.bc
echo %bcdir%\lib\import32.lib + >> b32.bc
echo %bcdir%\lib\uuid.lib + >> b32.bc
echo %bcdir%\lib\psdk\odbc32.lib + >> b32.bc
echo %bcdir%\lib\psdk\rasapi32.lib + >> b32.bc
echo %bcdir%\lib\psdk\nddeapi.lib + >> b32.bc
echo %bcdir%\lib\psdk\msimg32.lib + >> b32.bc
echo %bcdir%\lib\psdk\iphlpapi.lib, >> b32.bc

IF EXIST %1.res echo %1.res >> b32.bc

rem uncomment this line to use the debugger and comment the following one
if %GT% == gtwin %bcdir%\bin\ilink32 -Gn -Tpe -s -v @b32.bc
IF ERRORLEVEL 1 GOTO LINKERROR
if %GT% == gtgui %bcdir%\bin\ilink32 -Gn -aa -Tpe -s -v @b32.bc
IF ERRORLEVEL 1 GOTO LINKERROR
ECHO * Application successfully built *
%1
GOTO EXIT
ECHO

rem delete temporary files
@del %1.c

:COMPILEERRORS
@type comp.log
ECHO * Compile errors *
GOTO EXIT

:LINKERROR
ECHO * Linking errors *
GOTO EXIT

:SINTAX
ECHO    SYNTAX: Build [Program]     {-- No especifiques la extensi¢n PRG
ECHO                                {-- Don't specify .PRG extension
GOTO EXIT

:NOEXIST
ECHO The specified PRG %1 does not exist

:EXIT
