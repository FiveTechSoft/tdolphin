@echo off
ECHO Compiling...

set hdir=c:\xharbour
set bcdir=c:\bcc582\bin

%hdir%\bin\harbour %1 /n /i..\include;%hdir%\include /p %2 %3 > clip.log
@type clip.log
IF ERRORLEVEL 1 PAUSE
IF ERRORLEVEL 1 GOTO EXIT

echo -O2 -e%1.exe -I%hdir%\include %1.c > b32.bc
%bcdir%\bcc32 -M -c @b32.bc
:ENDCOMPILE

echo c0x32.obj + > b32.bc
echo %1.obj, + >> b32.bc
echo %1.exe, + >> b32.bc
echo %1.map, + >> b32.bc
echo ..\lib\dolphinx.lib + >> b32.bc
echo ..\lib\libmysqld.lib + >> b32.bc
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
echo %hdir%\lib\ct.lib + >> b32.bc

rem Uncomment these two lines to use Advantage RDD
rem echo %hdir%\lib\rddads.lib + >> b32.bc 
rem echo %hdir%\lib\ace32.lib + >> b32.bc

echo %bcdir%\lib\cw32.lib + >> b32.bc
echo %bcdir%\lib\import32.lib, >> b32.bc

ECHO * 
ECHO Linking...
%bcdir%\ilink32 -Gn -Tpe -s @b32.bc

rem delete temporary files
rem @del %1.c

IF ERRORLEVEL 1 GOTO LINKERROR
ECHO * Application successfully built
%1
GOTO EXIT
ECHO

:LINKERROR
rem PAUSE * Linking errors *
GOTO EXIT

:EXIT
