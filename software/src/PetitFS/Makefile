#########################################################################################################
##
## Name:            Makefile
## Created:         January 2019
## Author(s):       Philip Smart
## Description:     PetitFS makefile
##                  This makefile builds the Petit FatFS for use in the RFS with banked ROMS.
##
## Credits:         
## Copyright:       (c) 2020 Philip Smart <philip.smart@net2net.org>
##
## History:         March 2020   - Initial script written.
##
## Notes:           Optional component enables:
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
CC              = $(BASE)zcc
LD              = $(BASE)zcc
AS              = $(BASE)zcc
#CP              = $(BASE)
#DUMP            = $(BASE)

BASEDIR         = ../..
#BASEDIR        = ../../..
SWDIR           = $(BASEDIR)/software

# we use printf from here
COMMON_DIR      = $(SWDIR)/common
PFS_DIR         = $(SWDIR)/common/PetitFS
INCLUDE_DIR     = $(SWDIR)/include

# Working directory to build object files.
BUILD_DIR       = pff_obj

COMMON_SRC      = #$(COMMON_DIR)/sdmmc.c
PFS_SRC         = $(PFS_DIR)/sdmmc.c $(PFS_DIR)/pff_func.c $(PFS_DIR)/pff_dir.c $(PFS_DIR)/pff_read.c $(PFS_DIR)/pff_write.c  $(PFS_DIR)/pff_open.c $(PFS_DIR)/pff_mount.c

COMMON_OBJ      = $(patsubst $(COMMON_DIR)/%.c,$(BUILD_DIR)/%.o,$(COMMON_SRC))
PFS_OBJ         = $(patsubst $(PFS_DIR)/%.c,$(BUILD_DIR)/%.o,$(PFS_SRC))
COMMON_ASM      = $(patsubst $(COMMON_DIR)/%.c,$(BUILD_DIR)/%.asm,$(COMMON_SRC))
PFS_ASM         = $(patsubst $(PFS_DIR)/%.c,$(BUILD_DIR)/%.asm,$(PFS_SRC))

MAIN_PRJ        = sdtest
MAIN_ASM        = $(COMMON_ASM) $(PFS_ASM) $(patsubst %.c,$(BUILD_DIR)/%.asm,$(MAIN_SRC))
MAIN_SRC        = sdtest.c
MAIN_OBJ        = $(COMMON_OBJ) $(PFS_OBJ) $(patsubst %.c,$(BUILD_DIR)/%.o,$(MAIN_SRC))
MAIN_PRAGMA     = rfs.inc

ROM_PRJ         = rom
ROM_SRC         = 
ROM_OBJ         = $(COMMON_OBJ) $(PFS_OBJ) $(patsubst %.c,$(BUILD_DIR)/%.o,$(ROM_SRC))

# Commandline options for each tool.
# To disable use of a given instruction, prefix it with no-
TARGET          = +mz
VERBOSITY       = -vn
OPTIMISATION    = -O3
CFLAGS          = $(TARGET) -pragma-define:REGISTER_SP=0xd000 -pragma-include:$(MAIN_PRAGMA) $(OPTIMISATION) -I. -I$(COMMON_DIR) -I$(PFS_DIR) -I$(INCLUDE_DIR) -lm  $(VERBOSITY)
#
# Enable debug output.
OFLAGS         += -DDEBUG
LFLAGS          = $(TARGET) $(VERBOSITY) -pragma-define:REGISTER_SP=0xd000 -pragma-include:$(MAIN_PRAGMA) -lm -create-app -m
#
# Assembler flags.
ASFLAGS         = $(TARGET) $(VERBOSITY) -c -I. -I$(COMMON_DIR) -I$(INCLUDE_DIR) -I$(STARTUP_DIR)
#

# Our target.
all: $(BUILD_DIR) $(MAIN_PRJ) #$(MAIN_ASM) #$(ROM_PRJ)
#
$(MAIN_PRJ): $(BUILD_DIR) $(MAIN_OBJ) #$(MAIN_PRJ).asm


$(MAIN_ASM): $(BUILD_DIR) 

clean:
	rm -f $(BUILD_DIR)/*.o *.hex *.lss *.elf *.map *.lst *.srec $(MAIN_PRJ) *~ */*.o *.bin *.srec *.dmp *.rpt *.ihx *.sym *.rel *.noi *.lk *.err *.mzt *.o


# Convert ELF binary to bin file.
%.bin: %.elf
	@$(CP) -O binary $< $@

# Convert ELF to srec format for serial upload.
%.srec: %.elf
	@$(CP) -O srec $< $@


# Link - this produces an ELF binary.
$(MAIN_PRJ): $(MAIN_OBJ)
	$(CC) $(LFLAGS) $(MAIN_OBJ) -o $@ $(LIBS) 

$(ROM_PRJ): $(ROM_OBJ)
	$(CC)  +z80 $(VERBOSITY) -pragma-define:REGISTER_SP=0xd000 -pragma-include:$(MAIN_PRAGMA) -lm -m $(ROM_OBJ) -o $@ $(LIBS) 

$(BUILD_DIR)/%.o: %.c Makefile
	$(CC) $(CFLAGS) $(OFLAGS) -o $@ -c $<

$(BUILD_DIR)/%.asm: %.c Makefile
	$(CC) $(CFLAGS) $(OFLAGS) -a -o $@ -c $<

$(BUILD_DIR)/%.o: %.cpp Makefile
	$(CC) $(CFLAGS) $(OFLAGS) -o $@ -c $<

$(BUILD_DIR)/%.o: %.asm Makefile
	$(AS) $(ASFLAGS) -o $@ -c $<

$(BUILD_DIR)/%.o: $(COMMON_DIR)/%.c Makefile
	$(CC) $(CFLAGS) $(OFLAGS) -o $@ -c $<

$(BUILD_DIR)/%.o: $(PFS_DIR)/%.c Makefile
	$(CC) $(CFLAGS) $(OFLAGS)  -o $@ -c $<

$(BUILD_DIR)/%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: $(STARTUP_DIR)/%.s
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

