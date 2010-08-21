@ECHO OFF
CLS

if A%1 == A GOTO :SINTAX
if NOT EXIST %1.prg GOTO :NOEXIST

rem if "%2" == "/b" set GT=gtwin
rem if not "%2" == "/b" set GT=gtgui
rem set GT=gtgui
set GT=gtwin

ECHO Compiling...

set hdir=c:\harbourm
set hdirl=%hdir%\lib
set fwh=c:\fivewin\svn\repo
set vcdir=c:\vc2008

%hdir%\bin\harbour %1 /n /i%fwh%\include;%hdir%\include;..\include /w /p %2 %3 > comp.log
IF ERRORLEVEL 1 GOTO COMPILEERRORS
@type comp.log

%vcdir%\bin\cl -TP -W3 -c -I%hdir%\include -I%vcdir%\include /GA %1.c
:ENDCOMPILE

IF EXIST %1.rc %vcdir%\bin\rc -r -d__FLAT__ %1

echo %1.obj  > msvc.tmp

echo %hdirl%\hbrtl.lib  >> msvc.tmp
echo %hdirl%\hbvm.lib  >> msvc.tmp
echo %hdirl%\gtwin.lib  >> msvc.tmp
echo %hdirl%\hblang.lib  >> msvc.tmp
echo %hdirl%\hbmacro.lib  >> msvc.tmp
echo %hdirl%\hbrdd.lib  >> msvc.tmp
echo %hdirl%\rddntx.lib  >> msvc.tmp
echo %hdirl%\rddcdx.lib  >> msvc.tmp
echo %hdirl%\rddfpt.lib  >> msvc.tmp
echo %hdirl%\hbsix.lib  >> msvc.tmp
echo %hdirl%\hbdebug.lib  >> msvc.tmp
echo %hdirl%\hbcommon.lib  >> msvc.tmp
echo %hdirl%\hbpp.lib  >> msvc.tmp
echo %hdirl%\hbcpage.lib  >> msvc.tmp
echo %hdirl%\hbwin.lib  >> msvc.tmp
echo %hdirl%\hbct.lib  >> msvc.tmp
echo %hdirl%\xhb.lib  >> msvc.tmp
echo %hdirl%\hbpcre.lib  >> msvc.tmp
echo ..\lib\dolphm.lib  >> msvc.tmp
echo ..\lib\libmysqlm.lib  >> msvc.tmp


echo %vcdir%\lib\kernel32.lib  >> msvc.tmp
echo %vcdir%\lib\user32.lib    >> msvc.tmp
echo %vcdir%\lib\gdi32.lib     >> msvc.tmp
echo %vcdir%\lib\libcmt.lib     >> msvc.tmp
echo %vcdir%\lib\oldnames.lib     >> msvc.tmp
echo %vcdir%\lib\uuid.lib      >> msvc.tmp
echo %vcdir%\lib\ole32.lib     >> msvc.tmp
echo %vcdir%\lib\oleaut32.lib  >> msvc.tmp

IF EXIST %1.res echo %1.res >> msvc.tmp

%vcdir%\bin\link @msvc.tmp /nologo /subsystem:console /force:multiple /NODEFAULTLIB:libcmt

IF ERRORLEVEL 1 GOTO LINKERROR
ECHO * Application successfully built *
%1
GOTO EXIT
ECHO

rem delete temporary files
@del %1.c
@del msvc.tmp

:COMPILEERROR
@type comp.log
ECHO * Compiling errors *
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
