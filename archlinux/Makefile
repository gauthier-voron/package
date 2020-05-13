# Name of the repository file to build
#
REPOSITORY := mnesic

# Name of the packages to build.
# These must be names of the directories containing a PKGBUILD file.
#
PACKAGES += config-audio
PACKAGES += config-desktop
PACKAGES += config-devel
PACKAGES += config-graphic
PACKAGES += config-multimedia
PACKAGES += ec2tools
PACKAGES += emacs-go-mode
PACKAGES += emacs-kotlin-mode
PACKAGES += homectl
PACKAGES += perl-synctl
PACKAGES += setup-bouleau
PACKAGES += setup-laurier
PACKAGES += setup-orme
PACKAGES += setup-qemu
PACKAGES += synctl-git
PACKAGES += xmde-git

# URL of the server to push the repository as well as the path inside the
# server.
SERVER     := www.mnesic.fr:/srv/www/mnesic.fr/files/archlinux/mnesic/x86_64


# Be sure that in case of reccursive call, we do not make anoying printings.
# Also, we do not use builtin variables or rules, so discard them for saftey.
#
MAKEFLAGS += --no-builtin-rules --no-builtin-variables --no-print-directory


# Verbosity level control:
#   0 - only print errors
#   1 - pretty print what is being done but keep it concise
#   2 - print everything that is happening
V ?= 1
ifeq ($(V),1)
  define cmd-print
    @echo '$(1)'
  endef
endif
ifneq ($(V),2)
  Q := @
endif


# Selection on the Makefile mode based on its goals.
# Only in build mode, we need to generate and include '.package-files.mk'. This
# file contains the paths of the actual package files to generate (the ones
# ending with a '.pkg.tar.xz') and their dependencies.
#

config-goals := .package-files.% clean

ifeq ($(filter $(config-goals), $(MAKECMDGOALS)),)
  mode := build
else
  ifeq ($(filter-out $(config-goals), $(MAKECMDGOALS)),)
    mode := config
  else
    mode := mixed
  endif
endif


# If we have both config and build goals, execute each goal one by one with
# a reccursive $(MAKE) call.
#

ifeq ($(mode),mixed)

  .PHONY: FORCE

  FORCE:

  %: FORCE
	$(Q)+$(MAKE) $@

else


# Puth this default rule in first position so it is the default rule.
# Other rules, like 'all' need to be put after the '.package-files.mk' because
# they rely on some variables defined inside.
# However, '.package-files.mk' also define rules and we do not want them to be
# the default ones.
#

default: all


# Only in build mode, include the package file dependencies.
# Including it triggers its generation if it is not up to date.
#

ifeq ($(mode),build)
  -include .package-files.mk
endif


all: $(REPOSITORY).db.tar.gz

push: $(REPOSITORY).db.tar.gz $(REPOSITORY).db $(REPOSITORY).files.tar.gz \
      $(REPOSITORY).files $(package-files)
	$(call cmd-print,  RSYNC   $(strip $(SERVER)))
	$(Q)dir="$$(mktemp -d --suffix='.d' 'push-tempdir.XXXXXXXXXX')" ; \
        for path in $^ ; do \
            ln "$$path" "$$dir" ; \
        done ; \
        chmod 711 "$$dir" ; \
        rsync -aAHX --delete "$$dir/" "$(SERVER)/" ; \
        rm -rf "$$dir"


# Repository related rules.
# The repo-add command actually generate several files.
#

$(REPOSITORY).db.tar.gz: $(package-files)
	$(call cmd-print,  MKREPO  $(strip $@))
	$(Q)rm $@ 2> /dev/null || true
	$(Q)repo-add -q $@ $^

$(REPOSITORY).db: $(REPOSITORY).db.tar.gz

$(REPOSITORY).files.tar.gz: $(REPOSITORY).db.tar.gz

$(REPOSITORY).files: $(REPOSITORY).db.tar.gz


# Generation of package files.
# The makepkg command does not have any quiet mode which forces us to intercept
# its stdout / stderr into a log file and only if the makepkg commad fails, to
# display the log.
#

ifeq ($(V),2)
  %.pkg.tar.xz:
	cd $(dir $@) && makepkg -f
else
  %.pkg.tar.xz:
	$(call cmd-print,  MAKEPKG $@)
	@cd $(dir $@) && \
         log="$$(mktemp --suffix='.log' 'makepkg.XXXXXXXXXX')" ; \
         if makepkg -f > "$$log" 2>&1 ; then \
           rm "$$log" ; \
         else \
           cat "$$log" ; \
           rm  "$$log" ; \
           false ; \
         fi
endif


# Generation of '.package-files.mk'
# Standard dependencies generation, thanks to makepkg --packagelist.
#

.package-files.mk:
	$(call cmd-print,  CAT     $@)
	$(Q)cat $^ > $@

.package-files.d:
	$(call cmd-print,  MKDIR   $@)
	$(Q)mkdir $@

define PACKAGE-SOURCES
  $(foreach p, $(1), \
    $(filter-out $(addprefix $(strip $(p))/, src pkg %.pkg.tar.xz), \
      $(wildcard $(strip $(p))/*)))
endef

define PACKAGE-FILES-MK-PATTERN
  .package-files.mk: .package-files.d/$(strip $(1)).mk

  .package-files.d/$(strip $(1)).mk: $(call PACKAGE-SOURCES, $(1)) \
                                   | .package-files.d
	$(call cmd-print,  DEP     $$@)
	$(Q)(cd $(1) && makepkg --packagelist) | while read path ; do \
            path="$$$${path#$(PWD)/}" ; \
            printf "%s: %s\n" "$$$$path" "$$^" ; \
            echo ; \
            printf "package-files += %s\n" "$$$$path" ; \
            echo ; \
        done > $$@
endef

$(foreach p, $(PACKAGES), \
  $(eval $(call PACKAGE-FILES-MK-PATTERN, $(p))))


# Clean rule
# Clean as much as we can whild staying pretty conservative.
#

clean:
	$(call cmd-print,  CLEAN)
	$(Q)rm -rf .package-files.mk .package-files.d \
           $(patsubst %, %/src, $(PACKAGES)) \
           $(patsubst %, %/pkg, $(PACKAGES)) \
           $(wildcard $(patsubst %, %/*.pkg.tar.xz, $(PACKAGES))) \
           $(REPOSITORY).db $(REPOSITORY).db.tar.gz \
           $(REPOSITORY).files $(REPOSITORY).files.tar.gz


.PHONY: default all push clean

endif
