TARGET  := uno
SUBTYPE :=
OBJ     := obj/
BIN     := bin/

PROJECT := my_project
SOURCES := source.c
IPATH   := /usr/include/arduino/

mcu      := $(shell avr-config -m $(TARGET) $(SUBTYPE))
cflags   := $(shell avr-config -c $(TARGET) $(SUBTYPE))
cxxflags := $(shell avr-config -cxx $(TARGET) $(SUBTYPE))
asflags  := $(shell avr-config -as $(TARGET) $(SUBTYPE))
variant  := $(strip $(shell avr-config -v $(TARGET) $(SUBTYPE)))
includes := -I$(IPATH) -I$(IPATH)variants/$(variant)
terminal := /dev/serial/by-id/*Arduino*
objects  := $(patsubst %, $(OBJ)%.o, $(SOURCES))


subtypes := $(strip $(shell avr-config -s $(TARGET)))

ifeq ($(SUBTYPE),)
  ifneq ($(subtypes),)
    $(error Unspecified subtype for $(TARGET) (valid subtypes: $(subtypes)))
  endif
else
  ifeq ($(filter $(SUBTYPES), $(SUBTYPE)),)
    $(error Invalid subtype for $(TARGET) (valid subtypes: $(subtypes)))
  endif
endif


default: all

all: $(BIN)$(PROJECT).hex

upload: $(BIN)$(PROJECT).hex
	stty -F $(terminal) -hupcl; sleep 0.1
	stty -F $(terminal)  hupcl; sleep 0.1
	stty -F $(terminal) -hupcl
	avrdude -D -q -p $(mcu) -c arduino -b 115200 -P $(terminal) \
                -C /etc/avrdude.conf -U flash:w:$<:i

clean:
	-rm -rf $(OBJ) $(BIN)


$(BIN)$(PROJECT).hex: $(BIN)$(PROJECT).elf | $(BIN)
	avr-objcopy -O ihex -R .eeprom $< $@

$(BIN)$(PROJECT).elf: $(objects) | $(BIN)
	avr-gcc $(cflags) $^ -o $@ -larduino-$(strip $(TARGET)) -lm


$(OBJ)%.c.o: %.c | $(OBJ)
	avr-gcc -Wall -Wextra $(cflags) -c $< -o $@ $(includes)

$(OBJ)%.cpp.o: %.cpp | $(OBJ)
	avr-g++ -Wall -Wextra $(cxxflags) -c $< -o $@ $(includes)

$(OBJ)%.S.o: %.S | $(OBJ)
	avr-gcc -Wall -Wextra $(asflags) -c $< -o $@ $(includes)


$(OBJ) $(BIN):
	mkdir $@
