GENERATE-VERBOSITY ?= 0

ifeq ($(GENERATE-VERBOSITY),1)
  define PRINT
    $(info $(1))
  endef
endif


define NOSLASH
$(strip                                       \
  $(if $(filter %/, $(1)),                    \
    $(call NOSLASH, $(patsubst %/, %, $(1))), \
    $(1)))
endef

define UPPER
$(strip $(call NOSLASH, $(dir $(call NOSLASH, $(1)))))
endef


__REQUIRE-DIR-DONE := .

define __GENERATE-DIR-TEMPLATE
  $(call PRINT, $(1): | $(call UPPER, $(1)))
  $(call PRINT,         $$(call $(2), $$@))

  $(1): | $(call UPPER, $(1))
	$$(call $(2), $$@)

  __REQUIRE-DIR-DONE += $(1)

  $(call __GENERATE-DIR, $(call UPPER, $(1)), $(2))
endef

define __GENERATE-DIR
  $(if $(filter-out $(__REQUIRE-DIR-DONE), $(1)), \
    $(eval $(call __GENERATE-DIR-TEMPLATE, $(1), $(2))))
endef

define GENERATE-DIR
  $(foreach elem, $(call NOSLASH, $(1)), \
    $(call __GENERATE-DIR, $(elem), $(2)))
endef

define __REQUIRE-DIR-TEMPLATE
  $(call PRINT, $(1): | $(call UPPER, $(1)))

  $(1): | $(call UPPER, $(1))

  __REQUIRE-DIR-DONE += $(1)

  $(call __GENERATE-DIR, $(call UPPER, $(1)), $(2))
endef

define __REQUIRE-DIR
  $(if $(filter-out $(__REQUIRE-DIR-DONE), $(1)), \
    $(eval $(call __REQUIRE-DIR-TEMPLATE, $(1), $(2))))
endef

define REQUIRE-DIR
  $(foreach elem, $(call NOSLASH, $(1)), \
    $(call __REQUIRE-DIR, $(elem), $(2)))
endef
