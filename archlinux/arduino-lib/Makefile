OBJ     := obj/
LIB     := lib/
BIN     := bin/

TARGET  ?= uno
SUBTYPE ?=


V                  ?= 2
VERBOSE            ?= $(V)
COMMAND-VERBOSITY  := $(VERBOSE)
ifeq ($(VERBOSE),4)
  GENERATE-VERBOSITY := 1
else
  GENERATE-VERBOSITY := 0
endif

MAKEFLAGS += --no-print-directory


# Arduino specific configuration ==============================================

BOARDS ?= boards.txt

define AVR-CONFIG
  $(shell ./avr-config -B $(BOARDS) $(1))
endef

# 1- Check of TARGET and SUBTYPE configuration --------------------------------

SUBTYPES := $(strip $(call AVR-CONFIG, -s $(TARGET)))

ifeq ($(SUBTYPE),)
  ifeq ($(SUBTYPES),)
    FULLTARGET := $(TARGET)
  else
    $(error Unspecified subtype for $(TARGET) (valid subtypes: $(SUBTYPES)))
  endif
else
  ifeq ($(filter $(SUBTYPES), $(SUBTYPE)),)
    $(error Invalid subtype for $(TARGET) (valid subtypes: $(SUBTYPES)))
  else
   FULLTARGET := $(TARGET).$(SUBTYPE)
  endif
endif

# 2- Generation of compilation flags ------------------------------------------

CFLAGS   := $(call AVR-CONFIG, -c   $(TARGET) $(SUBTYPE))
CXXFLAGS := $(call AVR-CONFIG, -cxx $(TARGET) $(SUBTYPE))
ASFLAGS  := $(call AVR-CONFIG, -as  $(TARGET) $(SUBTYPE))
VARIANT  := $(call AVR-CONFIG, -v   $(TARGET) $(SUBTYPE))
INCLUDES := include include/variants/$(strip $(VARIANT))

# 3- Generation of compilation commands ---------------------------------------

define cmd-cc
  $(call cmd-print,  CC      $(call cmd-path, $(1)))
  $(Q)avr-gcc $(CFLAGS) $(addprefix -I, $(INCLUDES)) -c $(2) -o $(1)
endef

define cmd-ccxx
  $(call cmd-print,  CCXX    $(call cmd-path, $(1)))
  $(Q)avr-g++ $(CXXFLAGS) $(addprefix -I, $(INCLUDES)) -c $(2) -o $(1)
endef

define cmd-as
  $(call cmd-print,  AS      $(call cmd-path, $(1)))
  $(Q)avr-gcc $(ASFLAGS) $(addprefix -I, $(INCLUDES)) -c $(2) -o $(1)
endef

define cmd-ar
  $(call cmd-print,  AR      $(call cmd-path, $(1)))
  $(Q)avr-ar rcs $(1) $(2)
endef

# =============================================================================


include Command.mk
include Function.mk


OBJECTS := $(patsubst src/%, $(OBJ)$(strip $(FULLTARGET))/%.o, \
             $(wildcard src/*))


default: all

all: $(LIB)libarduino-$(FULLTARGET).a

clean:
	$(call cmd-clean, $(OBJ) $(BIN))


$(LIB)libarduino-$(FULLTARGET).a: $(OBJECTS)
	$(call cmd-ar, $@, $^)

$(OBJ)$(strip $(FULLTARGET))/%.c.o: src/%.c
	$(call cmd-cc, $@, $<)

$(OBJ)$(strip $(FULLTARGET))/%.cpp.o: src/%.cpp
	$(call cmd-ccxx, $@, $<)

$(OBJ)$(strip $(FULLTARGET))/%.S.o: src/%.S
	$(call cmd-as, $@, $<)


$(call REQUIRE-DIR, $(OBJECTS), cmd-mkdir)
$(call REQUIRE-DIR, $(LIB)libarduino-$(FULLTARGET).a, cmd-mkdir)
