DEP := .depends.d/
OBJ := .build.d/


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
PACKAGES += pacmerge
PACKAGES += perl-synctl
PACKAGES += setup-bouleau
PACKAGES += setup-laurier
PACKAGES += setup-orme
PACKAGES += setup-qemu
PACKAGES += synctl-git
PACKAGES += vpstools
PACKAGES += xmde-git

# URL of the server to push the repository as well as the path inside the
# server.
SERVERPATH := /srv/http/pkg.gauthiervoron.net/archlinux/x86_64
SERVER     := package@pkg.gauthiervoron.net:$(SERVERPATH)


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
ifeq ($(V),2)
  F := --verbose
else
  Q := @
endif


# Selection on the Makefile mode based on its goals.
# Only in build mode, we need to generate and include '.depends.mk'. This
# file contains the paths of the actual package files to generate (the ones
# ending with a '.pkg.tar.xz') and their dependencies.
#

config-goals := %.mk clean cleanall

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


# Put this default rule in first position so it is the default rule.
# Other rules, like 'all' need to be put after the '.depends.mk' because they
# rely on some variables defined inside.
# However, '.depends.mk' also define rules and we do not want them to be the
# default ones.
#

default: all


# Only in build mode, include the package file dependencies.
# Including it triggers its generation if it is not up to date.
#

ifeq ($(mode),build)
  -include .depends.mk
endif


# Build the complete package database.
# This database depends on the actual package files.
#

all: $(REPOSITORY).db.tar.gz


# Push the database and the package files to the remote server.
# Use hard links and rsync to make the push.
#

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



# Generage the actual package.
# This is where the build() and package() functions of a PKGBUILD are called.
# The dependencies are defined in .depends.mk
#

$(package-files): %.pkg.tar.xz:
	$(call cmd-print,  MAKEPKG $@)
	$(Q)./Makepkg $(F) $(dir $@) -frs --noextract


# Copy the package directory from the source to a $(OBJ) copy.
# The package generation can create several files in the PKGBUILD directory.
# There is no easy way to track which files are generated and which files are
# sources.
# The first step is then to copy the clean sources to a $(OBJ) copy and to
# call makepkg only on this copy.
#
# Call makepkg to get the sources at this step.
# The source may be necessary to know the package version (in case of VCS
# package).
#

$(OBJ)%.build/PKGBUILD:
	$(call cmd-print,  CP      $(strip $@))
	$(Q)rm -rf $(dir $@) 2> '/dev/null' || true
	$(Q)cp -R $(dir $<) $(dir $@)
	$(call cmd-print,  FETCH   $(strip $(dir $@)))
	$(Q)./Makepkg $(F) $(dir $@) -frs --nobuild


# Generate a dependency from the fetched source.
# The filename of this package depends on the package version, and thus, on the
# fetched sources.
# Also add the package name in the package-list variable.
#

$(DEP)%.mk: $(OBJ)%.build/PKGBUILD | $(DEP)
	$(call cmd-print,  DEP     $(strip $@))
	$(Q)(cd $(dir $<) && makepkg --packagelist) | grep '.pkg.tar.xz$$' | \
         while read path ; do \
             path="$${path#$(PWD)/}" ; \
             odir="$(patsubst $(OBJ)%.build/PKGBUILD, %, $<)" ; \
             echo "$$path: \$$(wildcard $${odir}/*)" ; \
             echo "package-files += $$path" ; \
         done > $@


# Aggregate all the $(DE)*.mk files into a single .mk file.
#

.depends.mk:
	$(call cmd-print,  CAT     $(strip $@))
	$(Q)cat $^ > $@


# Generate the dependency rules for $(OBJ) copy build directories.
# A build directory depends on all the source files located in the package
# directory.
#

define PACKAGE-TEMPLATE

  $$(OBJ)$(strip $(1)).build/PKGBUILD: $(strip $(1))/PKGBUILD \
                                       $$(wildcard $(strip $(1))/*) \
                                     | $$(OBJ)

  .depends.mk: $$(DEP)$(strip $(1)).mk

endef

$(foreach package, $(PACKAGES), \
  $(eval $(call PACKAGE-TEMPLATE, $(package))))



$(DEP) $(OBJ):
	$(call cmd-print,  MKDIR   $(strip $@))
	$(Q)mkdir $@


# Clean rule
# Clean as much as we can whild staying pretty conservative.
#

clean:
	$(call cmd-print,  CLEAN)
	$(Q)rm $(REPOSITORY).db $(REPOSITORY).db.tar.gz \
               $(REPOSITORY).files $(REPOSITORY).files.tar.gz \
               $(REPOSITORY).files.tar.gz.old \
            2> /dev/null || true

cleanall:
	$(call cmd-print,  CLEAN)
	$(Q)rm -rf .depends.mk $(OBJ) $(DEP) \
               $(REPOSITORY).db $(REPOSITORY).db.tar.gz \
               $(REPOSITORY).files $(REPOSITORY).files.tar.gz \
               $(REPOSITORY).files.tar.gz.old \
            2> /dev/null || true


.PHONY: default all push clean cleanall

endif
