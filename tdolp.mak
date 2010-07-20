OBJPRG  = .\$(OBJS)
OBJC    = .\objc 
INCLUDE = .\include
LIBNAME = $(LIBNAME)
DOLPHINDEF = 

USE_INTERNAL = NO
USE_DEBUG = NO

!if $(USE_INTERNAL) == YES 
   DOLPHINDEF = -DNOINTERNAL
!endif
!if $(USE_DEBUG) == NO
   DOLPHINDEF = $(DOLPHINDEF)-DDEBUG
!endif

.path.PRG = .\source\prg
.path.OBJ = $(OBJPRG)
.path.CH  = $(INCLUDE)
.path.C   = .\source\c
.path.LIB = .\lib
 

PRG =        \
TDOLPSRV.PRG \
TDOLPQRY.PRG

C =                   \
FUNCTION.C               

PROJECT    : $(LIBNAME).lib 

$(LIBNAME).lib   : $(PRG:.PRG=.OBJ) $(C:.C=.OBJ)

.PRG.OBJ:
   $(HPATH)\bin\harbour $<  -D$(HARBOUR) $(DOLPHINDEF) /N /W /w /es2 /O$(OBJPRG)\ /I$(INCLUDE);$(HPATH)\include;$(USERINC) > comp.log
   $(BCCPATH)\bin\bcc32 -c -tWM -I$(HPATH)\include -o$(OBJPRG)\$& $(OBJPRG)\$&.c
   $(BCCPATH)\bin\TLib .\lib\$(LIBNAME).lib -+$(OBJPRG)\$&.obj /0 /P32,,

.C.OBJ:
  echo -c -tWM -D$(HARBOUR) > tmp
  echo -I$(HPATH)\include;$(INCLUDE);$(USERINC) >> tmp
   $(BCCPATH)\bin\bcc32 -o$(OBJC)\$& @tmp $<
   $(BCCPATH)\bin\TLib .\lib\$(LIBNAME).lib -+$(OBJC)\$&.obj /0 /P32,,
