#rules.mak
#default values
ERROR_MSG=
_MSVC=no
OBJ_EXT=obj
SEPARATOR=/
ifeq ($(ROOT),)
	ROOT=.
endif
ifeq ($(ARCHITECTURE),)
	ARCHITECTURE=win
endif
ifeq ($(ARCHITECTURE),win)
	include $(ROOT)\rulewin.mak
endif
ifeq ($(ARCHITECTURE),linux)
	include $(ROOT)/rulesh.mak
endif
