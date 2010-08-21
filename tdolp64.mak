OBJPRG  = .\$(OBJS)
OBJC    = .\objc64
INCLUDE = .\include;c:\fivewin\svn\repo\include
LIBNAME = $(LIBNAME)
DOLPHINDEF = 

USE_INTERNAL = YES
USE_DEBUG = YES

!if $(USE_INTERNAL) == NO 
   DOLPHINDEF = -DNOINTERNAL
!endif
!if $(USE_DEBUG) == YES
   DOLPHINDEF = $(DOLPHINDEF)-DDEBUG
!endif

.path.PRG = .\source\prg
.path.OBJ = $(OBJPRG)
.path.CH  = $(INCLUDE)
.path.C   = .\source\c
.path.LIB = .\lib\lib64
 

PRG =        \
TDOLPSRV.PRG \
TDOLPQRY.PRG \
TDOLPEXP.PRG

C =                   \
FUNCTION.C               

PROJECT    : $(LIBNAME).lib 

$(LIBNAME).lib   : $(PRG:.PRG=.OBJ) $(C:.C=.OBJ)

.PRG.OBJ:
   if not exist .\lib\lib64\$(LIBNAME).lib $(VCDIR)\bin\lib /DEF:.\lib\lib64\$(LIBNAME).DEF  /OUT:.\lib\lib64\$(LIBNAME).lib
   $(HPATH)\bin\harbour $<  -D$(HARBOUR) $(DOLPHINDEF) /N /W /w /es2 /O$(OBJPRG)\ /I$(INCLUDE);$(HPATH)\include;$(USERINC) > comp.log
   echo -c -TP -D$(HARBOUR) -I$(HPATH)\include -I.\INCLUDE > tmp
   echo -I$(VCDIR)\include -I$(INCLUDE) >> tmp   
   $(VCDIR)\bin\cl -c -TP -I$(VCDIR)\include -I$(HPATH)\include -Fo$(OBJPRG)\$& $(OBJPRG)\$&.c
   $(VCDIR)\bin\Lib .\lib\lib64\$(LIBNAME).lib /MACHINE:X64 /OUT:.\lib\lib64\$(LIBNAME).lib $(OBJPRG)\$&.obj

.C.OBJ:
   echo -c -TP -D$(HARBOUR) -I$(HPATH)\include -I.\INCLUDE > tmp
   echo -I$(VCDIR)\include -I$(INCLUDE) >> tmp
   $(VCDIR)\bin\cl -c -TC -I$(VCDIR)\include -I$(HPATH)\include -I.\INCLUDE -Fo$(OBJC)\$& $<
   $(VCDIR)\bin\Lib .\lib\lib64\$(LIBNAME).lib /MACHINE:X64 /OUT:.\lib\lib64\$(LIBNAME).lib $(OBJC)\$&.obj