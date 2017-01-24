# This Makefile contains the definition of several commands (as executed in the
# recipe part of a rule). This should be included at the top of the main
# Makefile (it is guaranteed to not contain any rule).
# The command define here can be redefined by a local configuration file.

# Verbosity of commands =======================================================

COMMAND-VERBOSITY ?= 1

# Level 0: print nothing
ifeq ($(COMMAND-VERBOSITY),0)
  Q := @
endif

# Level 1: pretty print important commands with short paths
ifeq ($(COMMAND-VERBOSITY),1)
  define cmd-print
    @echo '$(1)'
  endef
  define cmd-path
$(strip $(notdir $(1)))
  endef
  Q := @
endif

# Level 2: pretty print all commands with long paths
ifeq ($(COMMAND-VERBOSITY),2)
  define cmd-print
    @echo '$(1)'
  endef
  define cmd-info
    @echo '$(1)'
  endef
  define cmd-path
$(strip $(1))
  endef
  Q := @
endif

# Level 3: raw print all commands
ifeq ($(COMMAND-VERBOSITY),3)
endif


# File system commands ========================================================

define cmd-mkdir ?=
  $(call cmd-info,  MKDIR   $(call cmd-path, $(1)))
  $(Q)mkdir $(1)
endef

define cmd-make ?=
  $(call cmd-info,  MAKE    $(call cmd-path, $(1)))
  $(Q)+$(MAKE) $(1) $(2)
endef

define cmd-clean
  $(call cmd-print,  CLEAN)
  $(Q)rm -rf $(1) 2> /dev/null || true
endef


# Compilation commands ========================================================

define cmd-cc ?=
  $(call cmd-print,  CC      $(call cmd-path, $(1)))
  $(Q)gcc -Wall -Wextra -O2 -g -c $(2) -o $(1)
endef

define cmd-ccxx ?=
  $(call cmd-print,  CCXX    $(call cmd-path, $(1)))
  $(Q)g++ -Wall -Wextra -O2 -g -c $(2) -o $(1)
endef

define cmd-as ?=
  $(call cmd-print,  AS      $(call cmd-path, $(1)))
  $(Q)gcc -c $(2) -o $(1)
endef


define cmd-ar ?=
  $(call cmd-print,  AR      $(call cmd-path, $(1)))
  $(Q)avr-ar rcs $@ $^
endef
