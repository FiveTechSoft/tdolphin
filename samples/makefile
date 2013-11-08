ifeq ($(BLD_TYPE),gtgui)
	PRG_FILES=\
		sa_vs_up \
		testfile \
		testfw1 \
		testfw2 \
		testfw3 \
		testpag \
		testsk2 \
		testvar \
		sped \
		testdbi
   _OUT = Graphic
endif

ifeq ($(BLD_TYPE),gtwin)
	ifeq ($(EMBEDDED),no)
		PRG_FILES=\
			bldtbls \
			filltbls \
			listdbs \
			testai \
			testback \
			testbck2 \
			testcon \
			testcon2 \
			testcrea \
			testdb \
			testexp \
			testexp2 \
			testexp3 \
			testexp4 \
			testexp5 \
			testexp6 \
			testfill \
			testfind \
			testfind2 \
			testloc \
			testmado \
			testman \
			testping \
			testqry \
			testqry1 \
			testqry2 \
			testqry3 \
			testqry4 \
			testrest \
			testrst2 \
			testseek \
			testset \
			teststru \
			testupd \
			testproc \
			testms   \
			testcon3 \
			testdbi \
			testupd2 \
			teststm \
			testuse
		else
			PRG_FILES= testemb1
		endif
		_OUT = Console
endif
ROOT=..

ifneq ($(findstring $(SAMPLE),$(PRG_FILES)),)
ifneq ($(ARCHITECTURE),linux)
	SEPARATOR=$(subst /,\,/)
endif
	include ..$(SEPARATOR)rules.mak
else

ifneq ($(ARCHITECTURE),linux)
	SEPARATOR=$(subst /,\,/)
	PATH_RM=..$(SEPARATOR)
else
	SEPARATOR=/
endif

.PHONY: sample cleanall

sample : nosample

nosample:

ifeq ($(EMBEDDED),no)
	@echo Invalid file $(SAMPLE) to build in mode $(_OUT)
else
	@echo Invalid file $(SAMPLE) to build in mode $(_OUT) embedded server
endif

cleanall:
ifneq ($(ARCHITECTURE),linux)
	@$(foreach file,$(foreach file,./,$(wildcard $(file)*.prg)), $(PATH_RM)rm -f $(subst /,$(SEPARATOR),$(subst .prg,.exe,$(file))))
	@$(foreach exefile, $(foreach file,./samples64/, $(wildcard $(file)*.exe)), $(PATH_RM)rm -f $(subst /,$(SEPARATOR),$(exefile)))
else
	@$(foreach file,$(foreach file,./,$(wildcard $(file)*.prg)), $(PATH_RM)rm -f $(subst .prg,,$(file)))
endif
	@$(PATH_RM)rm -f *.o
	@$(PATH_RM)rm -f *.obj
	@$(PATH_RM)rm -f *.map
	@$(PATH_RM)rm -f *.tds
	@$(PATH_RM)rm -f *.c
	@$(PATH_RM)rm -f *.bak
	@$(PATH_RM)rm -f *.log
	@$(PATH_RM)rm -f *.ppo
	@$(PATH_RM)rm -f *.tmp
	@$(PATH_RM)rm -f *.lib
	@$(PATH_RM)rm -f *.exp
	@$(PATH_RM)rm -f *.bc
	@$(PATH_RM)rm -f *.res
endif

