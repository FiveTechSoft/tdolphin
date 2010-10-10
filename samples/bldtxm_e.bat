@ECHO OFF
CLS

if A%1 == A GOTO :SINTAX
if NOT EXIST %1.prg GOTO :NOEXIST

rem if "%2" == "/b" set GT=gtwin
rem if not "%2" == "/b" set GT=gtgui
rem set GT=gtgui
set GT=gtwin

ECHO Compiling...

set hdir=c:\xharbourm
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

echo %hdir%\lib\rtl.lib  >> msvc.tmp
echo %hdir%\lib\vm.lib  >> msvc.tmp
echo %hdir%\lib\gtwin.lib  >> msvc.tmp
echo %hdir%\lib\lang.lib  >> msvc.tmp
echo %hdir%\lib\macro.lib  >> msvc.tmp
echo %hdir%\lib\rdd.lib  >> msvc.tmp
echo %hdir%\lib\dbfntx.lib  >> msvc.tmp
echo %hdir%\lib\dbfcdx.lib  >> msvc.tmp
echo %hdir%\lib\dbffpt.lib  >> msvc.tmp
echo %hdir%\lib\hbsix.lib  >> msvc.tmp
echo %hdir%\lib\debug.lib  >> msvc.tmp
echo %hdir%\lib\common.lib  >> msvc.tmp
echo %hdir%\lib\pp.lib  >> msvc.tmp
echo %hdir%\lib\pcrepos.lib  >> msvc.tmp
echo %hdir%\lib\ct.lib  >> msvc.tmp
echo ..\lib\dolpxm.lib  >> msvc.tmp
echo ..\lib\libmysqldm.lib  >> msvc.tmp


echo %vcdir%\lib\kernel32.lib  >> msvc.tmp
echo %vcdir%\lib\user32.lib    >> msvc.tmp
echo %vcdir%\lib\gdi32.lib     >> msvc.tmp
echo %vcdir%\lib\libcmt.lib     >> msvc.tmp
echo %vcdir%\lib\oldnames.lib     >> msvc.tmp
echo %vcdir%\lib\uuid.lib      >> msvc.tmp
echo %vcdir%\lib\ole32.lib     >> msvc.tmp
echo %vcdir%\lib\oleaut32.lib  >> msvc.tmp
echo %vcdir%\lib\psapi.lib  >> msvc.tmp
echo %vcdir%\lib\iphlpapi.lib  >> msvc.tmp
echo %vcdir%\lib\version.lib  >> msvc.tmp
echo %vcdir%\lib\shell32.lib  >> msvc.tmp
echo %vcdir%\lib\advapi32.lib  >> msvc.tmp
echo %vcdir%\lib\winspool.lib  >> msvc.tmp
echo %vcdir%\lib\ws2_32.lib  >> msvc.tmp
echo %vcdir%\lib\mpr.lib  >> msvc.tmp
echo %vcdir%\lib\winmm.lib  >> msvc.tmp
echo %vcdir%\lib\comctl32.lib  >> msvc.tmp
echo %vcdir%\lib\comdlg32.lib  >> msvc.tmp

IF EXIST %1.res echo %1.res >> msvc.tmp

%vcdir%\bin\link @msvc.tmp /nologo /subsystem:console /force:multiple /NODEFAULTLIB:libcmt /INCLUDE:__matherr

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
