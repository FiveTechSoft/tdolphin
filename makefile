PRG_FILES = \
	tdolpexp \
	tdolpqry \
	tdolpsrv 
  	
C_FILES = \
	function \
	gerrapi
	
LANG_FILES = \
	msges\
	msgen
	
#No mover esta linea
ifneq ($(PRG_COMPILER),)
include rules.mak
else

SEPARATOR=/
ifneq ($(ARCHITECTURE),linux)
	SEPARATOR=$(subst /,\,/)
endif
DOLPHIN_OBJ=.$(SEPARATOR)obj$(SEPARATOR)
DOLPHIN_LIB=.$(SEPARATOR)lib$(SEPARATOR)
clean:
	@rm -r -f $(DOLPHIN_OBJ)HARBOUR
	@rm -r -f $(DOLPHIN_OBJ)XHARBOUR
	@rm -r -f $(DOLPHIN_LIB)HARBOUR
	@rm -r -f $(DOLPHIN_LIB)XHARBOUR
	@rm -f *.bak 
	@rm -f *.log
	@rm -f *.o
	@rm -f *.obj
endif