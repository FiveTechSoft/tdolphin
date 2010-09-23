@ECHO OFF
CLS

if A%1 == A GOTO :SINTAX
if NOT EXIST %1.prg GOTO :NOEXIST

if "%HBDIR%" == "" set HBDIR=c:\harbour
rem if "%2" == "/b" set GT=gtwin
rem if not "%2" == "/b" set GT=gtgui
rem set GT=gtgui
set GT=gtwin

ECHO Compiling...

set hdir=c:\harbour
set hdirl=%hdir%\lib
set fwh=c:\fivewin\svn\repo
set bcdir=c:\bcc582

%hdir%\bin\harbour %1 /n /i%fwh%\include;%hdir%\include;..\include /w /p %2 %3 > comp.log
IF ERRORLEVEL 1 GOTO COMPILEERRORS
@type comp.log

echo -O2 -e%1.exe -I%hdir%\include -I%bcdir%\include;..\include %1.c > b32.bc
%bcdir%\bin\bcc32 -M -c @b32.bc
:ENDCOMPILE

IF EXIST %1.rc %bcdir%\bin\brc32 -r %1
rem IF EXIST %1.rc %vcdir%\bin\rc -r -d__FLAT__ %1

echo %bcdir%\lib\c0w32.obj + > b32.bc
echo %1.obj, + >> b32.bc
echo %1.exe, + >> b32.bc
echo %1.map, + >> b32.bc
echo ..\lib\dolphinh.lib + >> b32.bc
echo ..\lib\libmysqld.lib + >> b32.bc
echo %hdirl%\hbrtl.lib + >> b32.bc
echo %hdirl%\hbvm.lib + >> b32.bc
echo %hdirl%\%GT%.lib + >> b32.bc
echo %hdirl%\hblang.lib + >> b32.bc
echo %hdirl%\hbmacro.lib + >> b32.bc
echo %hdirl%\hbrdd.lib + >> b32.bc
echo %hdirl%\rddntx.lib + >> b32.bc
echo %hdirl%\rddcdx.lib + >> b32.bc
echo %hdirl%\rddfpt.lib + >> b32.bc
echo %hdirl%\hbsix.lib + >> b32.bc
echo %hdirl%\hbdebug.lib + >> b32.bc
echo %hdirl%\hbcommon.lib + >> b32.bc
echo %hdirl%\hbpp.lib + >> b32.bc
echo %hdirl%\hbcpage.lib + >> b32.bc
echo %hdirl%\hbwin.lib + >> b32.bc
echo %hdirl%\hbcplr.lib + >> b32.bc
echo %hdirl%\hbct.lib + >> b32.bc
echo %hdirl%\hbpcre.lib + >> b32.bc
echo %hdirl%\xhb.lib + >> b32.bc
rem echo %hdirl%\hbzlib.lib + >> b32.bc

rem Uncomment these two lines to use Advantage RDD
rem echo %hdirl%\rddads.lib + >> b32.bc
rem echo %hdirl%\Ace32.lib + >> b32.bc

echo %bcdir%\lib\cw32.lib + >> b32.bc
rem echo %bcdir%\lib\uuid.lib + >> b32.bc
echo %bcdir%\lib\import32.lib + >> b32.bc
rem echo %bcdir%\lib\psdk\odbc32.lib + >> b32.bc
rem echo %bcdir%\lib\psdk\nddeapi.lib + >> b32.bc
rem echo %bcdir%\lib\psdk\iphlpapi.lib + >> b32.bc
rem echo %bcdir%\lib\psdk\msimg32.lib + >> b32.bc
rem echo %bcdir%\lib\psdk\rasapi32.lib, >> b32.bc

IF EXIST %1.res echo %1.res >> b32.bc
if %GT% == gtwin %bcdir%\bin\ilink32 -Tpe -s @b32.bc
IF ERRORLEVEL 1 GOTO LINKERROR
if %GT% == gtgui %bcdir%\bin\ilink32 -Gn -aa -Tpe -s @b32.bc
IF ERRORLEVEL 1 GOTO LINKERROR
ECHO * Application successfully built *
%1
GOTO EXIT
ECHO


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
rem delete temporary files
@del %1.c
@del %1.ilc 
@del %1.ild 
@del %1.ils 
@del %1.tds
@del %1.ilf

