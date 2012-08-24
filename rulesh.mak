#rules.mak
##################################################################
#PRG_COMPILER
#   HARBOUR
#      PRG_COMP_PATH -> \harbour
#   XHARBOUR
#      PRG_COMP_PATH -> \xharbour
##################################################################
#      PRG_COMP_BIN_PATH -> $(PRG_COMP_PATH)\bin
#      PRG_COMP_LIB_PATH -> $(PRG_COMP_PATH)\lib\win\bcc
#      PRG_COMP_INC_PATH -> $(PRG_COMP_PATH)\include
##################################################################
#C_COMPILER
#   BCC    -> BORLAND
#      C_COMP_PATH -> \bcc582
#      C_COMP_BIN_PATH=$(C_COMP_PATH)\bin
#      C_COMP_LIB_PATH=$(C_COMP_PATH)\lib;$(C_COMP_PATH)\lib\psdk
#      C_COMP_INC_PATH=$(C_COMP_PATH)\include
#   MINGW  -> MINGW32
#      C_COMP_PATH -> \mingw
#      C_COMP_BIN_PATH=$(C_COMP_PATH)\bin
#      C_COMP_LIB_PATH=$(C_COMP_PATH)\lib
#      C_COMP_INC_PATH=$(C_COMP_PATH)\include
#   MSVC32 -> MICROSOFT 32 BITS
#      C_COMP_PATH -> %ProgramFiles%\Microsoft Visual Studio 9.0\vc
#   MSVC64 -> MICROSOFT 64 BITS
#      C_COMP_PATH -> "%ProgramFiles(x86)%\Microsoft Visual Studio 9.0\vc"
##################################################################
# for microsoft compiler call $(C_COMP_PATH)\vcvarsall.bat
# otherwise
##################################################################
# output 
# HARBOUR
#    LIBNAME=dolphinh
# XHARBOUR
#    LIBNAME=dolphinx
#
# DOLPHIN_INC=.\include
# DOLPHIN_OBJ  = obj\$(PRG_COMPILER)\$(C_COMPILER)
# DOLPHIN_LIB  = lib\$(PRG_COMPILER)\$(C_COMPILER)
##################################################################
# user variables
# USER_DEFINE=
# USER_INCLUDE=
##################################################################

#default values

DEFX=__HARBOUR__
ifeq ($(DEBUG),)
	DEBUG=__NODEBUG__
endif
ifeq ($(PRG_COMPILER),XHARBOUR)
	DEFX=__XHARBOUR__
endif

OBJ_EXT=o
AR=ar
CC=gcc
LD=gcc
LIB_PREF=lib
LIB_EXT=a
DOLPHIN_LIBNAME=$(LIBNAME).$(LIB_EXT)
DOLPHIN_INC=$(ROOT)$(SEPARATOR)include
PRG_SOURCE_PATH=$(ROOT)$(SEPARATOR)source$(SEPARATOR)prg
C_SOURCE_PATH=$(ROOT)$(SEPARATOR)source$(SEPARATOR)c
LANG_SOURCE_PATH=$(ROOT)$(SEPARATOR)source$(SEPARATOR)lang
DOLPHIN_OBJ  = $(ROOT)$(SEPARATOR)obj$(SEPARATOR)$(PRG_COMPILER)$(SEPARATOR)$(C_COMPILER)
DOLPHIN_LIB  = $(ROOT)$(SEPARATOR)lib$(SEPARATOR)$(PRG_COMPILER)$(SEPARATOR)$(C_COMPILER)

ifeq ($(SAMPLE),)
PRG_FLAGS=-D$(USER_DEFINE) -q0 -N -W -w -es2 \
-o$(DOLPHIN_OBJ)$(SEPARATOR) \
-I$(DOLPHIN_INC) -I$(PRG_COMP_INC_PATH) \
-I$(USER_INCLUDE)
else
PRG_FLAGS=-D$(USER_DEFINE) -D$(DEBUG) -q0 -n -I$(DOLPHIN_INC) -I$(PRG_COMP_INC_PATH) -I$(USER_INCLUDE) -I$(GUI_INC)
endif

LIB_FLAGS= rc $(DOLPHIN_LIB)$(SEPARATOR)$(LIBNAME).$(LIB_EXT) $(filter %.o,$^)

C_FLAGS= -D$(DEFX) -DHB_LEGACY_TYPES_ON -I$(PRG_COMP_INC_PATH) -I$(DOLPHIN_INC) -I$(C_COMP_INC_PATH) -Wall -c -o $@ $<

ifneq ($(PRG_COMPILER),XHARBOUR)
	LD_LIB= $(GUI_LIB) $(GT_LIB) z crypt nsl pthread hbcommon hbcpage hbcplr hbct \
hbhsx hblang hbmacro hbmisc hbmzip hbnf hbpcre hbpp hbrdd hbrtl hbsix \
hbtip hbusrrdd hbvm gtstd gttrm rddcdx rddfpt rddntx xhb ncurses m
else
	LD_LIB= $(GUI_LIB) $(GT_LIB) z crypt m pthread common vm rtl rdd macro lang codepage pp dbfntx dbfcdx dbffpt hbsix hsx pcrepos usrrdd tip ct cgi gtstd gtcgi gtcrs debug ncurses
endif
LD_FLAGS= -o$@ $@.$(OBJ_EXT) $(mysql_config  --libs) -Wall -s -mwindows \
	-L$(DOLPHIN_LIB) \
	-L$(PRG_COMP_LIB_PATH) \
	-L/usr/lib/mysql \
  -mno-cygwin -Wl,--start-group -lsupc++

ifeq ($(LIBMYSQL),)
	ifeq ($(EMBEDDED),no)
		LIBMYSQL := -lmysqlclient
	else 
		LIBMYSQL := -lmysqld
	endif
endif

LIB=-ldolphin $(LIBMYSQL) $(addprefix -l,$(LD_LIB))

OBJ_FILES = $(addprefix $(DOLPHIN_OBJ)$(SEPARATOR),$(addsuffix .$(OBJ_EXT),$(PRG_FILES))) $(addprefix $(DOLPHIN_OBJ)$(SEPARATOR),$(addsuffix .$(OBJ_EXT),$(C_FILES))) $(addprefix $(DOLPHIN_OBJ)$(SEPARATOR),$(addsuffix .$(OBJ_EXT),$(LANG_FILES)))

#prg compiler commnad

ifeq ($(PRG_COMP_BIN_PATH),)
	PRG_COMP_CMD=harbour $< $(PRG_FLAGS)
else
	PRG_COMP_CMD=$(PRG_COMP_BIN_PATH)$(SEPARATOR)harbour $< $(PRG_FLAGS)
endif

LIB_CMD=$(AR) $(LIB_FLAGS)
C_COMP_CMD=$(CC) $(C_FLAGS)
LD_CMD= $(LD) $(LD_FLAGS) $(LIB) -Wl,--end-group

define HAR_CMD
	@echo Compiling $<
	@$(PRG_COMP_CMD)
endef

define C_CMD
	@echo Compiling $<
	@$(C_COMP_CMD)
endef

define LIB_CMD1
	@$(LIB_CMD)
endef

define BUILD_SAMPLE
	@echo Linking $<
	@$(LD_CMD)
endef

ifeq ($(SAMPLE),)

.PHONY: lib clean

else

.PHONY: sample cleansample

sample : samplelog cleansample $(SAMPLE)

endif

lib : logfile dir $(DOLPHIN_LIBNAME)

logfile:
	echo # ----------------------------------------------------------------------- 
	echo # Building $(DOLPHIN_LIBNAME)	
	echo # 	
	echo # C COMPILER    :$(C_COMPILER) 	
	echo # PRG COMPILER  :$(PRG_COMPILER) 	
	echo # -----------------------------------------------------------------------	
	
samplelog:
	echo # ----------------------------------------------------------------------- 
	echo # Building sample $(SAMPLE).prg EMBEDDED : $(EMBEDDED)
	echo #
	echo # C COMPILER    :$(C_COMPILER) 
	echo # PRG COMPILER  :$(PRG_COMPILER) 
	echo #  -----------------------------------------------------------------------	
	
	
$(DOLPHIN_LIBNAME) : $(OBJ_FILES)
	$(LIB_CMD1)

$(DOLPHIN_OBJ)%.c : $(PRG_SOURCE_PATH)%.prg
	$(HAR_CMD)
	
$(DOLPHIN_OBJ)%.$(OBJ_EXT): $(DOLPHIN_OBJ)%.c
	$(C_CMD)

$(DOLPHIN_OBJ)%.$(OBJ_EXT): $(C_SOURCE_PATH)%.c
	$(C_CMD)

$(DOLPHIN_OBJ)%.$(OBJ_EXT): $(LANG_SOURCE_PATH)%.c
	$(C_CMD)
# -----------------------------------------------------
# dir
# -----------------------------------------------------

dir: $(DOLPHIN_OBJ) $(DOLPHIN_LIB)

$(DOLPHIN_OBJ) :
	mkdir -p $@

$(DOLPHIN_LIB) :
	mkdir -p $@
	
clean:
	rm -r -f .$(SEPARATOR)$(DOLPHIN_OBJ)$(SEPARATOR) 
	rm -r -f .$(SEPARATOR)$(DOLPHIN_LIB)$(SEPARATOR) 
	rm -f *.bak 
	rm -f *.log
	rm -f *.o
	rm -r -f .$(SEPARATOR)lib$(SEPARATOR)$(DOLPHIN_LIB)$(SEPARATOR)
	rm -r -f .$(SEPARATOR)obj$(SEPARATOR)$(DOLPHIN_OBJ)$(SEPARATOR)

error:
	echo .$(ERROR_MSG) IS REQUIRED


# --------------------------------------------------------
# Build samples
# --------------------------------------------------------

$(SAMPLE) : $(SAMPLE).$(OBJ_EXT)
	@echo $(LD_CMD) 
	$(BUILD_SAMPLE)
	

$(SAMPLE).c: $(SAMPLE).prg
	@echo $(PRG_COMP_CMD) 
	$(HAR_CMD)

$(SAMPLE).$(OBJ_EXT): $(SAMPLE).c
	@echo $(C_COMP_CMD) 
	$(C_CMD)
		
cleansample :	
	rm -f $(SAMPLE).o 
	rm -f $(SAMPLE).c 
	rm -f $(SAMPLE)
	
