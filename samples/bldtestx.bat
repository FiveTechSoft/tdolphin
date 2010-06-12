@echo off
ECHO Compiling...

set wfile=testcon
set hdir=y:\xharbcvs
set bcdir=y:\borland\bcc55\bin

%hdir%\bin\harbour %wfile% /n /i..\include;%hdir%\include /p %2 %3 > clip.log
@type clip.log
IF ERRORLEVEL 1 PAUSE
IF ERRORLEVEL 1 GOTO EXIT

echo -O2 -e%wfile%.exe -I%hdir%\include %wfile%.c > b32.bc
%bcdir%\bcc32 -M -c @b32.bc
:ENDCOMPILE

echo c0x32.obj + > b32.bc
echo %wfile%.obj, + >> b32.bc
echo %wfile%.exe, + >> b32.bc
echo %wfile%.map, + >> b32.bc
echo dolphinx.lib + >> b32.bc
echo ..\lib\libmysql.lib + >> b32.bc
echo %hdir%\lib\rtl.lib + >> b32.bc
echo %hdir%\lib\hsx.lib + >> b32.bc
echo %hdir%\lib\hbsix.lib + >> b32.bc
echo %hdir%\lib\rtl.lib + >> b32.bc
echo %hdir%\lib\vm.lib + >> b32.bc
echo %hdir%\lib\rtl.lib + >> b32.bc
echo %hdir%\lib\gtwin.lib + >> b32.bc
echo %hdir%\lib\Lang.lib + >> b32.bc
echo %hdir%\lib\macro.lib + >> b32.bc
echo %hdir%\lib\rdd.lib + >> b32.bc
echo %hdir%\lib\dbfntx.lib + >> b32.bc
echo %hdir%\lib\dbfcdx.lib + >> b32.bc
echo %hdir%\lib\common.lib + >> b32.bc
echo %hdir%\lib\libmisc.lib + >> b32.bc
echo %hdir%\lib\CodePage.lib + >> b32.bc
echo %hdir%\lib\DbfFpt.lib + >> b32.bc
echo %hdir%\lib\pcrepos.lib + >> b32.bc

rem Uncomment these two lines to use Advantage RDD
rem echo %hdir%\lib\rddads.lib + >> b32.bc 
rem echo %hdir%\lib\ace32.lib + >> b32.bc

echo %bcdir%\lib\cw32.lib + >> b32.bc
echo %bcdir%\lib\import32.lib, >> b32.bc

ECHO * 
ECHO Linking...
%bcdir%\ilink32 -Gn -Tpe -s @b32.bc

rem delete temporary files
rem @del %wfile%.c

IF ERRORLEVEL 1 GOTO LINKERROR
ECHO * Application successfully built
GOTO EXIT
ECHO

:LINKERROR
rem PAUSE * Linking errors *
GOTO EXIT

:EXIT
pause 
