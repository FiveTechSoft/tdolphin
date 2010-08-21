OBJPRG  = .\$(OBJS)
OBJC    = .\objcm
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
.path.LIB = .\lib
 

PRG =        \
TDOLPSRV.PRG \
TDOLPQRY.PRG \
TDOLPEXP.PRG

C =                   \
FUNCTION.C               

PROJECT    : $(LIBNAME).lib 

$(LIBNAME).lib   : $(PRG:.PRG=.OBJ) $(C:.C=.OBJ)

.PRG.OBJ:
   if not exist .\lib\$(LIBNAME).lib $(VCDIR)\bin\lib /DEF:.\lib\$(LIBNAME).DEF  /OUT:.\lib\$(LIBNAME).lib
   $(HPATH)\bin\harbour $<  -D$(HARBOUR) $(DOLPHINDEF) /N /W /w /es2 /O$(OBJPRG)\ /I$(INCLUDE);$(HPATH)\include;$(USERINC) > comp.log
   $(VCDIR)\bin\cl -c -I$(VCDIR)\include -I$(HPATH)\include -Fo$(OBJPRG)\$& $(OBJPRG)\$&.c
   $(VCDIR)\bin\Lib .\lib\$(LIBNAME).lib  /OUT:.\lib\$(LIBNAME).lib $(OBJPRG)\$&.obj

.C.OBJ:
  echo -c -D$(HARBOUR) -D__FLAT__ -I$(HPATH)\include -I.\INCLUDE > tmp
  echo -I$(VCDIR)\include -I$(INCLUDE) >> tmp
   $(VCDIR)\bin\cl @tmp -Fo$(OBJC)\$& $<
   $(VCDIR)\bin\Lib lib\$(LIBNAME).lib /OUT:lib\$(LIBNAME).lib $(OBJC)\$&.obj
