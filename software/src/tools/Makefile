#########################################################################################################
##
## Name:            Makefile
## Created:         March 2020
## Author(s):       Philip Smart
## Description:     Helper tools for the MZ80A RFS upgrade
##                  This makefile builds tools written in C which help with building/setting up the
##                  RFS images for use in the RFS adapter.
##
## Credits:         
## Copyright:       (c) 2020 Philip Smart <philip.smart@net2net.org>
##
## History:         March 2020   - Initial Makefile creation
##
## Notes:           
##
#########################################################################################################
## This source file is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published
## by the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This source file is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
#########################################################################################################
BASE	        = 
CC              = $(BASE)gcc
LD              = $(BASE)gcc
AS              = $(BASE)as
CP              = $(BASE)objcopy
DUMP            = $(BASE)objdump

BASEDIR         = ../../..
SWDIR           = $(BASEDIR)/software/src
INSTALLDIR      = $(BASEDIR)/software/tools

# we use printf from here
COMMON_DIR      = $(SWDIR)/common
INCLUDE_DIR     = $(SWDIR)/include

# Working directory to build object files.
BUILD_DIR       = tools_obj

COMMON_SRC      = #$(COMMON_DIR)/sdtool.c
COMMON_OBJ      = $(patsubst $(COMMON_DIR)/%.c,$(BUILD_DIR)/%.o,$(COMMON_SRC))

SDTOOL_PRJ      = sdtool
SDTOOL_SRC      = sdtool.c
SDTOOL_OBJ      = $(COMMON_OBJ) $(patsubst %.c,$(BUILD_DIR)/%.o,$(SDTOOL_SRC))

MZFDC2_PRJ      = mzfdc2
MZFDC2_SRC      = mz-fdc2.c
MZFDC2_OBJ      = $(COMMON_OBJ) $(patsubst %.c,$(BUILD_DIR)/%.o,$(MZFDC2_SRC))

MZFDC3_PRJ      = mzfdc3
MZFDC3_SRC      = mz-fdc3.c
MZFDC3_OBJ      = $(COMMON_OBJ) $(patsubst %.c,$(BUILD_DIR)/%.o,$(MZFDC3_SRC))

# Commandline options for each tool.
OPTS            = 

CFLAGS          = -I. -I$(COMMON_DIR) -I$(INCLUDE_DIR) -O3 
# Enable debug output.
OFLAGS         += -DDEBUG
LFLAGS          = -Wl,--gc-sections -Wl,--relax -Os
#
# Assembler flags.
ASFLAGS         = -I. -I$(COMMON_DIR) -I$(INCLUDE_DIR) -I$(STARTUP_DIR) 
#

# Our target.
all: clean $(BUILD_DIR) $(SDTOOL_PRJ)  $(MZFDC2_PRJ) $(MZFDC3_PRJ)

install: all
	cp $(SDTOOL_PRJ) $(MZFDC2_PRJ) $(INSTALLDIR)

clean:
	rm -f $(BUILD_DIR)/*.o *.hex *.lss *.elf *.map *.lst *.srec *~ */*.o *.bin *.srec *.dmp *.vhd *.rpt $(SDTOOL_PRJ)

$(SDTOOL_PRJ): $(SDTOOL_PRJ).elf $(SDTOOL_PRJ).dmp $(SDTOOL_PRJ).lss

$(MZFDC2_PRJ): $(MZFDC2_PRJ).elf $(MZFDC2_PRJ).dmp $(MZFDC2_PRJ).lss

$(MZFDC3_PRJ): $(MZFDC3_PRJ).elf $(MZFDC3_PRJ).dmp $(MZFDC3_PRJ).lss

# Convert ELF binary to bin file.
%.bin: %.elf
	@$(CP) -O binary $< $@

# Convert ELF to srec format for serial upload.
%.srec: %.elf
	@$(CP) -O srec $< $@

%.dmp: %.elf
	@$(DUMP) -x $< >>$@

# Create extended listing file from ELF output file.
# testing: option -C
%.lss: %.elf
	@echo
	@$(DUMP) -h -S -C $< > $@

$(SDTOOL_PRJ): $(SDTOOL_OBJ)
	$(CC) $(LFLAGS) $(SDTOOL_OBJ) -o $@ $(LIBS)
	chmod +x $@

$(MZFDC2_PRJ): $(MZFDC2L_OBJ)
	$(CC) $(LFLAGS) $(MZFDC2_OBJ) -o $@ $(LIBS)
	chmod +x $@

$(MZFDC3_PRJ): $(MZFDC3L_OBJ)
	$(CC) $(LFLAGS) $(MZFDC3_OBJ) -o $@ $(LIBS)
	chmod +x $@

# Link - this produces an ELF binary.
$(SDTOOL_PRJ).elf: $(SDTOOL_OBJ)
	$(LD) $(LFLAGS) -o $@ $+ $(LIBS)

$(MZFDC2_PRJ).elf: $(MZFDC2_OBJ)
	$(LD) $(LFLAGS) -o $@ $+ $(LIBS)

$(MZFDC3_PRJ).elf: $(MZFDC3_OBJ)
	$(LD) $(LFLAGS) -o $@ $+ $(LIBS)

$(BUILD_DIR)/%.o: %.c Makefile
	$(CC) $(CFLAGS) $(OFLAGS) -o $@ -c $<

$(BUILD_DIR)/%.o: %.cpp Makefile
	$(CC) $(CFLAGS) $(OFLAGS) -o $@ -c $<

$(BUILD_DIR)/%.o: $(COMMON_DIR)/%.c Makefile
	$(CC) $(CFLAGS) $(OFLAGS) -o $@ -c $<

$(BUILD_DIR)/%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: $(STARTUP_DIR)/%.s
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

