@CALL CLEANENV.BAT
@ECHO OFF
SET PRG_COMPILER=XHARBOUR
SET PRG_COMP_PATH=\xharbourm
SET PRG_COMP_BIN_PATH=%PRG_COMP_PATH%\bin
SET PRG_COMP_LIB_PATH=%PRG_COMP_PATH%\lib\win\bcc
SET PRG_COMP_INC_PATH=%PRG_COMP_PATH%\include
SET C_COMPILER=MSVC32
SET DOLPHIN_INC=.\include

:FIND_VC
   IF EXIST "%ProgramFiles%\Microsoft Visual Studio 10.0\vc"      GOTO SET_VC2010
   IF EXIST "%ProgramFiles%\Microsoft Visual Studio 9.0\vc"       GOTO SET_VC2008
   IF EXIST "%ProgramFiles%\Microsoft Visual Studio 8\vc"         GOTO SET_VC2005
   IF EXIST "%ProgramFiles%\Microsoft Visual Studio 2003\vc"      GOTO SET_VC2003
   IF EXIST "%ProgramFiles%\Microsoft Visual Studio\vc8"          GOTO SET_VC6
   GOTO END
:SET_VC2010
   SET C_COMP_PATH=%ProgramFiles%\Microsoft Visual Studio 10.0\vc
   IF "%VS100COMNTOOLS%"=="" SET VS100COMNTOOLS=%ProgramFiles%\Microsoft Visual Studio 10.0\Common7\Tools\
   GOTO READY

:SET_VC2008
   SET C_COMP_PATH=%ProgramFiles%\Microsoft Visual Studio 9.0\vc
   IF "%VS90COMNTOOLS%"=="" SET VS90COMNTOOLS=%ProgramFiles%\Microsoft Visual Studio 9.0\Common7\Tools\
   GOTO READY

:SET_VC2005
   SET C_COMP_PATH=%ProgramFiles%\Microsoft Visual Studio 8\vc
   GOTO READY

:SET_VC2003
   SET C_COMP_PATH=%ProgramFiles%\Microsoft Visual Studio .NET 2003\VC7
   GOTO READY

:SET_VC6
   SET C_COMP_PATH=%ProgramFiles%\Microsoft Visual Studio\VC98
   GOTO READY

:READY
IF EXIST "%C_COMP_PATH%"\vcvarsall.bat (CALL "%C_COMP_PATH%"\vcvarsall.bat) ELSE GOTO ERROR
SET PATH="%C_COMP_PATH%\bin";%VS100COMNTOOLS%;%VS90COMNTOOLS%;%PATH%
GOTO END

:ERROR
SET NO_VC_BAT=1

:END
@CALL win-make
@ECHO ON