#!/bin/bash
#########################################################################################################
##
## Name:            make_roms.sh
## Created:         August 2018
## Author(s):       Philip Smart
## Description:     Sharp MZ series Flash ROM Packaging tool
##                  This is a very basic script to package programs into ROM images suitable for
##                  programming into the Flash ROMS. It needs a rewrite but for now please
##                  manually edit the list below to select the programs you want, run the script
##                  and flash the images created into the Flast ROMS.
##
## Credits:         
## Copyright:       (c) 2020-21 Philip Smart <philip.smart@net2net.org>
##
## History:         January 2020   - Initial script written.
##                  March 2021     - Updates for the RFS v2.1 board.
##                  April 2021     - Removed the CPM ROM Drive functionality as it provided no benefit
##                                   over SD card and SD cards are larger.
##
#########################################################################################################
## This source file is free software: you can redistribute it and#or modify
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

ROOTDIR=../../MZ80A_RFS
MZB_PATH=${ROOTDIR}/software/MZB
ROM_PATH=${ROOTDIR}/software/roms/
ROM_LIST_FILE=/tmp/ROMLIST
SECTORSIZE=256
#CPMDISKMODE=SPLIT
MZFTOOL=${ROOTDIR}/software/tools/mzftool.pl
MONITOR_ROM=/tmp/mrom.rom
USER_ROM_I=/tmp/user.rom
USER_ROM_II=/tmp/user2.rom
USER_ROM_III=/tmp/user3.rom

# Monitor/User ROM 1/2/3 = empty.
> ${MONITOR_ROM}
> ${USER_ROM_I}
> ${USER_ROM_II}
> ${USER_ROM_III}

# Create a file with a list of programs placed into the ROM. This list can then be used by the SD
# card script to ensure no duplication occurs when building the SD RFS program directory.
rm -f ${ROM_LIST_FILE}

# Place the monitor roms into the MROM at the beginning for banked page usage.
echo "cat ${ROM_PATH}/monitor_sa1510.rom ${ROM_PATH}/monitor_80c_sa1510.rom  ${ROM_PATH}/cbios.rom ${ROM_PATH}/rfs_mrom.rom ${ROM_PATH}/monitor_1z-013a.rom ${ROM_PATH}/monitor_80c_1z-013a.rom ${ROM_PATH}/ipl.rom ${ROM_PATH}/blank_mrom.rom > /tmp/mrom.rom"
cat ${ROM_PATH}/monitor_sa1510.rom ${ROM_PATH}/monitor_80c_sa1510.rom \
    ${ROM_PATH}/cbios.rom ${ROM_PATH}/rfs_mrom.rom \
    ${ROM_PATH}/monitor_1z-013a.rom ${ROM_PATH}/monitor_80c_1z-013a.rom \
    ${ROM_PATH}/ipl.rom ${ROM_PATH}/blank_mrom.rom \
    >> ${MONITOR_ROM}

# Place the RFS rom into the User ROM at the beginning as it contains all the banked pages.
echo "cat ${ROM_PATH}/rfs.rom ${ROM_PATH}/cbios_bank1.rom ${ROM_PATH}/cbios_bank2.rom ${ROM_PATH}/cbios_bank3.rom ${ROM_PATH}/cbios_bank4.rom > ${USER_ROM_I}"
cat ${ROM_PATH}/rfs.rom ${ROM_PATH}/cbios_bank1.rom ${ROM_PATH}/cbios_bank2.rom \
    ${ROM_PATH}/cbios_bank3.rom ${ROM_PATH}/cbios_bank4.rom \
    >> ${USER_ROM_I}

# For CPM, to be safe, we manually copy the required files rather than use the list below. The CP/M boot image must be in User ROM 1.
echo "cat ${MZB_PATH}/Common/cpm22.${SECTORSIZE}.bin >> ${USER_ROM_I}"
cat ${MZB_PATH}/Common/cpm22.${SECTORSIZE}.bin >> ${USER_ROM_I}

# According to flag set above, either put the CPM Disks in the first ROM, or place one in each ROM allowing for better write spread and larger disks.
#
#if [ "${CPMDISKMODE}" != "SPLIT" ]; then
#    # CPM RFS Disks currently only in User ROM.
#    for f in 1 2
#    do
#        if [ -f ${MZB_PATH}/Common/CPM_RFS_${f}.${SECTORSIZE}.bin ]; then
#            echo "cat ${MZB_PATH}/Common/CPM_RFS_${f}.${SECTORSIZE}.bin >> ${USER_ROM_I}"
#            cat ${MZB_PATH}/Common/CPM_RFS_${f}.${SECTORSIZE}.bin >> ${USER_ROM_I}
#            basename "${f}" .${SECTORSIZE}.bin >> ${ROM_LIST_FILE}
#        fi
#    done
#else
#    if [ -f ${MZB_PATH}/Common/CPM_RFS_1.${SECTORSIZE}.bin ]; then
#        echo "cat ${MZB_PATH}/Common/CPM_RFS_1.${SECTORSIZE}.bin >> ${USER_ROM_I}"
#        cat ${MZB_PATH}/Common/CPM_RFS_1.${SECTORSIZE}.bin >> ${USER_ROM_I}
#        basename "${f}" .${SECTORSIZE}.bin >> ${ROM_LIST_FILE}
#    fi
#
#    if [ -f ${MZB_PATH}/Common/CPM_RFS_2.${SECTORSIZE}.bin ]; then
#        echo "cat ${MZB_PATH}/Common/CPM_RFS_2.${SECTORSIZE}.bin >> ${USER_ROM_II}"
#        cat ${MZB_PATH}/Common/CPM_RFS_2.${SECTORSIZE}.bin >> ${USER_ROM_II}
#        basename "${f}" .${SECTORSIZE}.bin >> ${ROM_LIST_FILE}
#    fi
#fi

# Manually choose the programs you want installed into the ROMS. The files will be first placed into the USER ROM and when full into the 
# Monitor ROM. Thus order is important if you want a particular program in a particular ROM.
#
# NB: A Double Hash (##) indicates a program found not to work on the Sharp MZ-80A.
#
ROM_INCLUDE=""
#
# Common
#
ROM_INCLUDE+="${MZB_PATH}/Common/sa-5510_rfs.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/basic_sa5510.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/basic_sa6510.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/msbasic_mz80a.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/msbasic_rfs40.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/msbasic_rfs80.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/sa-5510_compiler.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/bas_mod_v374.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/xpatch_5510_v2.2.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/basic_sp5025.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/basic_sp5030.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/basic_sp-5035mc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/solo_basic.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/basic_om-500.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/basic_om-1000.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/basic_om-1001.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/hu-basic_v1.3_k.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/hucompilmc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/compiler_a2.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/express_compiler.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/k_a_converter.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/hisoft_pascal4.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/z80assembler2mc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/editor-assembler_sp2202mc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/zen.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/8048_cpu_disas.mc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/6502betrmc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/6502demo2mc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/6502demomc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/fortransosz80.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/mz700_forth1.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/kniforth.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/tinylispmc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/apollo_word_1.9mmc_.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/hucalc_80a_m.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/send-1.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Common/apollo_chess_v2a.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/Common/5z009-1b.mzf:"
#ROM_INCLUDE+="${MZB_PATH}/Common/basic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/Common/cpm22.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/Common/cpm223.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/Common/sharpmz-test.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/Common/testtz.${SECTORSIZE}.bin:"
#
# MZ-80A
#
#ROM_INCLUDE+="${MZB_PATH}/MZ-80A/sa-6510.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/3-d_maze.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/80a_pencil.a2_c2.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/80a_pencil.a2_s.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80A/a-basic_sa-5510.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/adventuregame.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/air_lander.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/alien_attack.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/alien_attack_machinecode.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/alien_eagle.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/alligator.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80A/apollo_chess_v2a.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80A/basic80a.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80A/basic_sa-5510.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80A/basic.sa-5510.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/blocking.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/bouncing_ball.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/breakout.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/breakout_mc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/brickstop.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80A/bytesaver_sa5510.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/cells_and_serps.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/colony.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/cosmiad-a.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/cosmiad-k.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/cursedchamber.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/dcs_mz80a_append.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/dcs_mz80a_renum.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/defender(2).${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/defender.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/defender_bizzarri.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/diamond.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/digger.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/dog_and_flea.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/dog_star_2.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/duck_shoot.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/epidemic.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/escape.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/escape_force.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/flying_mission.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/forest_of_doom.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/fruit_machine.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/galaxy_invaders.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/greedy_gremlins.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/hangman2.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/horse_race2.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80A/hucalc_80a_c2.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80A/hucalc_80a_m.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80A/hucalc_80a_s.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/land_escape.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/laser_defence.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/le_mans.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/ludo.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/lunarlander.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/mad_max_2.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/man-hunt.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/m_c_breakout_2.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/m_c_race_chase.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/minotaur.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/missile_attack.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/munchers_2.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/MZ-80A_galactic.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/navvy.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/new_invaders.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/noughts_crosses.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/numbercrunch.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/obstacles.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/pinball.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/puckman.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/qbert.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/quest.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/race_chase.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/ribbit_v2.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80A/sa-5510_compiler.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80A/sa-5510_kn.comm.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/sargon_2.71.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/scramble_a.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80A/send-1.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/serendipity.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/ski_run.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/space_combat.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/space_fighter.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/space_invaders.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/spooks.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/starship_mk2.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/star_wars.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/super_tilt.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/the_lily_pond.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/the_meanies.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/tunnel_run.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/ufo.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/wiggly_worm.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A/witches.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80A/xpatch_5510_v2.2.${SECTORSIZE}.bin:"
#
# MZ-80K
#
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/3dspacecbasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/3-d_way_out_bbg_software.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/6502betrmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/6502demo2mc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/6502demomc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/8048_cpu_disas.mc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/a-basic_sa-5510.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/abenteuebasic.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/advance-guardmc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/advance_guard_wics_1983.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/aimemc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/alienmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/andromedamc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/apollo_word_1.9mmc_.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/ascii_gamebasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/atcf_datamc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/attackerscramblemc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/barcode_reader_1basic.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/barcode_reader_2basic.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/barcode_reader_3basic.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/barcode_reader_4basic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/base_ballbasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/baseballbasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/basic_sp-5035mc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/block_kuzushimc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/bomberbasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/bomberman_hudson_soft_1983.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/boueisakusenbasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/boxing_mzmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/breakout_sharp_corporation.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/bugfire_1.1_wics.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/bugfire-newmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/bugfire-oldmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/bugfire_wics.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/cannon_ball_hudson_soft_1983.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/car-racemc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/clever_cribber.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/code_hu_convertmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/cosmic_cruiser1mc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/cosmic_cruiser2mc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/cosmic_cruiser3pr1mc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/cowboy_duelmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/crazy-climber_pt1mc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/crazy-climber_pt2mc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/crystallmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/daikaisenbasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/d-day_sharp_corporation.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/defendermc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/defend_the_citybasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/don_chackbasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/donkey_derby.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/editor-assembler_sp2202mc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/elektronic_musicmc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/empire_climbermc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/empire_climber_wics.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/executivebasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/f-1_racemc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/fdcontromc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/filecardmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/form_map-listmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/formmc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/forth_simulatorbasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/fortressmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/galacticabasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/galaxianbasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/gens3_1mc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/gokiburibasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/goldminebasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/gomokumc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/hat_the_boxbasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/home_budget_mk2basic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/hucompilermc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/hucompilmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/identi-kit.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/jampacmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/jintorimc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/jumping_bunnymc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/ladybugmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/laser_commandmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/loaderckmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/lunar_lander.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/lunar_landingmc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/machine_language_sp2001mc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/machin_lang.monmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/mannenbasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/master_mindbasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/mazemanmc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/micropedemc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/minotaur's_cavemc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/miz-mazebasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/mogurabasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/monaco-gpmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/monitormc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/monitorrmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/munchiesmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/nautic_crisisbasic.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/neptunmc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/notutoribasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/nsc-rallymc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/one_key_organmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/othellomc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/otori_attackmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/pacmanmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/pascal_sp-6610mc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/phoenixmc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/printmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/puckmanmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/racemc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/ralleymc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/ranger_specialpacmanmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/sargonchessmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/scashbasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/schlogesmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/scramble.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/scramblemc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/shooting-ufobasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/shougibasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/space_defendermc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/space_drivescramblemc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/space_fighter_sharp_corporation_1979.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/space_invader1mc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/space_invader.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/space_invader2intro-jpnmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/space_invader2no_intromc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/space_invader3mc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/space_invader4mc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/space-invadermc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/space_mouse2mc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/space_mousemc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/space_mouse_wics.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/space_panicmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/space_ruinerdeffendermc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/space_ruiner_wics_1982.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/spider_maze.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/startrekbasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/star_trek_jpnbasic.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/star_trek_sharp_corporation.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/star_warsmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/star-warsmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/stoneworldbasic.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/sub-monitor_48kmc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/superdefendermc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/super-monitormc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/supertargmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/superwurmmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/survivemc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/tankwarmc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/tapecopymc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/ten-pin_bowling.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/test_match.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/the_munchies_c_smith.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/time_bombbasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/tinylispmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/tomahawk_hiroshi_masuko.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/tomahawkmc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/toweringmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/trapmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/turtlegdemo1mc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/turtlegdemo2mc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/turtle-grafikmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/tycoonbasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/ubootjagmc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/ufo_cavesmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/ufo_huntermc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/undameshibasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/videoflippermc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/view-findermc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/view_finder_wics_1983.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/vikingmc.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80K/voicemc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/war_of_conbasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/westernmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/western_wics_1983.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/wilhelm-tellmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/willhelm_tellmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/yakyukenbasic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/z80assembler2mc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/zardosmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/zardos_mz_soft_group.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/zeichengmc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-80K/zeroidmc.${SECTORSIZE}.bin:"
#
# MZ-700
#
ROM_INCLUDE+="${MZB_PATH}/MZ-700/1z-013b.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/2z009e.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/3-d_car_race.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/3-d_graphikpaket.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/3dmuehle.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/3d-way_out.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/6502_betriebssys.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/700_poker.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/ace_racer.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/advancedchess.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/airbus_a_310.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/aliens.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/amityville.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/antares.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/anthill_raider.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/apollo.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/apollo2_8-200785.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/apprentissage_nombres.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/asteroid_belt.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/astro-blaster.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/attack-a-tank.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/auto_run.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/backgammon.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/bas700tutorial.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/basezero.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/basic_1z-013b.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/basic_700-vers.4.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/basic_mz-5z008_2.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/basic_mz-5z008.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/battle_game.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/bio-700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/blastoff.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/bloktekeningen.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/bomberman_mz700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/boulder_dash.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/breuken_1.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/cadre_diabolique.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/calendrier.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/cannon_ball.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/catacombes.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/caterpillar.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/centro-anl.disk.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/centro-anleitung.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/circus_star.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/club_golf.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/c-master.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/codewoord.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/commando_plain.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/competitie.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/comput-a-slot.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/computertekenen.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/connect_four.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/converter_a_700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/conveyor.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/copy-cf.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/cosmo_blaster_mz700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/cribbage.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/croaker.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/cyfax.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/database_filer.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/datei_universal.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/dbp-701.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/delete.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/demasaso.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/demo-lissajou.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/demo_sin-berg.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/descente_aux_enfers.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/destructeurs.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/domination.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/donkey_gorilla.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/exploding_atoms.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/express_bas_700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/f1200.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/fantastic_grove.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/fdcopy.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/fd_editor_mz700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/fighter_command.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/fire!!!.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/fisherman_fred.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/flugsim_mz700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/flugsimulator.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/fortransosz80.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/full_speed.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/gate-crasher.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/gdp9-ba.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/geboortedatum.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/global_war_3.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/globule.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/gobbler.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/greedy_gremlins.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/grid.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/guerre_spatiale.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/hdc_orgel.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/hp4tmz7.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/hp4tmz7l.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/hunchy.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/impossible_mission.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/isola.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/jeux_intergalactiques.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/jumping_runner.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/jungle-jinks.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/kalender.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/kamertje.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/kasboek.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/k-basic_v.5.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/kentucky_derby.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/kniforth.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/knight's_castle.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/knights_ufo.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/kp_dbasic.800b.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/k.s.m._pt._1.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/k.s.m._pt._2.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/k.s.m._pt._3.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-700/kuma_interpr..${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/kup80z354.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/kup80z355.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/lady-bug.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/land_escape.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/le_mans.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/lightning_patrol.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/lijnenspel.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/logo_v30.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/mac_pac.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/mad_maze.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/man-hunt.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/manza.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/mastermind.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/math_pendu.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/maze_escape.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/messing.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/mission_a.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/mission_alpha.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/mission_delta.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/ml-sp_8002_bbg.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/moleatta.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/monitor.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/monitor3.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/monitor6.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/morpion.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/morpius.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/moty.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/moving_searcher.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/mucmac700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/munroe_manor.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/music.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/musique_suisse.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/mz-1p01.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/mz-2z009.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/mz700bas.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/MZ-700_demo.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/mz700_forth1.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/MZ-700_forth.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/MZ-700_klavier.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/MZ-700_plot.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/nakamoto.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/nakamoto_mz700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/nibbler_part1.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/nibbler_part2.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/nightmare_park2.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/nightmare_park.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/nightm_prk.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/nite_flite.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/octopussy.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/pac-man.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/painful_man.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/panique.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/para_shoot.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/pascal_sp-4015.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/pascal_sp-4015_c.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/patrol_alpha.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/pcgaid.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/pcgaid_europe.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/pcg_basic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/pcg_basic_mz700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/pendu.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/printerfiguren1.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/puissance_4.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/puzzle.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/qd_bas_5z008_mz700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/qdcopy.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/qd-pascal_c.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/quixi.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/realfort.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/rebond.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/rescue_plane.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/reverse.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/rollsroyce1906.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/round_shoot.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/safe-cracker.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/s-basic-cent-2.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/s-basic-comp-cnt.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/s-basic-compiler.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/s-basic-compiler-original.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/s-basicode_2.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/schach2_mz700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/schach700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/send-1.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/send-1_mz700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/sh7ced1.3g.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/shogun.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/sky_chaos.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/s-master.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/snake-and-snake.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/snake_snake_exp1.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/soudard.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/south_pacific.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/space_fighter.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/space_guerilla.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/space_invaders.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/spa_data.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/squash_700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/star_fighter.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/startrek.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/stkeeper2bas700a.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/strip_poker.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/submarine_shooter.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/sub-monitor-700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/suicide_run.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/super-bandit.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/super_biorhythm.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/super_helicopter.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/super_puck-man.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/super_spy_obj.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/supertypen.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/super_vrac.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/sutam1f.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/sutamc9.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/sutapeba.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/sutapemo.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/systeme_expert.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/tapeworm.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/tbasic_bm_pk.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/t-basic_(uitleg).${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/telefontarieven.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/three_card_brag.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/tomahawk.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/tracker.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/trans.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/trucker.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/typen.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/ufo.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/uni700basic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/urania_ii.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/uras-700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/vicious_viper.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/vol_676.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/vragendmaken.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/wizard_castle.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/wonderhouse.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/wookya.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/wookyb.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/xanagrams.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/xbc.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/xbc_f_1_02.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/yams.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-700/z80_desassembleur.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MZ-700/zen.${SECTORSIZE}.bin:"

# Set the pointer which indicates the next ROM to be filled with applications.
GENROM=0

IFS=":"; for f in ${ROM_INCLUDE}
do
    if [ -f ${f} ]; then

        # Identify type of file.
        ${MZFTOOL} --command=IDENT --mzffile=${f} >/dev/null
        FILETYPE=$?

        if [ ${FILETYPE} == 1 ]; then

            # Fill the User ROM as these get listed first.
            if (( ${GENROM} == 0 )); then
                cat ${USER_ROM_I} "${f}" > /tmp/tmp.size
                FILESIZE=$(stat -c%s "/tmp/tmp.size")
                if (( ${FILESIZE} < 524288 )); then
                    echo "Adding $f to User I Rom"
                    cat "${f}" >> ${USER_ROM_I}
                    basename "${f}" .${SECTORSIZE}.bin >> ${ROM_LIST_FILE}
                else
                    GENROM=1
                fi
            fi

            if (( ${GENROM} == 1 )); then
                cat ${MONITOR_ROM} "${f}" > /tmp/tmp.size
                FILESIZE=$(stat -c%s "/tmp/tmp.size")
                if (( ${FILESIZE} < 524288 )); then
                    echo "Adding $f to Monitor Rom"
                    cat "${f}" >> ${MONITOR_ROM}
                    basename "${f}" .${SECTORSIZE}.bin >> ${ROM_LIST_FILE}
                else
                    GENROM=2
                fi
            fi

            # User ROM II and III are optional.
            if (( ${GENROM} == 2 )); then
                cat ${USER_ROM_II} "${f}" > /tmp/tmp.size
                FILESIZE=$(stat -c%s "/tmp/tmp.size")
                if (( ${FILESIZE} < 524288 )); then
                    echo "Adding $f to User II Rom"
                    cat "${f}" >> ${USER_ROM_II}
                    basename "${f}" .${SECTORSIZE}.bin >> ${ROM_LIST_FILE}
                else
                    GENROM=3
                fi
            fi

            if (( ${GENROM} == 3 )); then
                cat ${USER_ROM_III} "${f}" > /tmp/tmp.size
                FILESIZE=$(stat -c%s "/tmp/tmp.size")
                if (( ${FILESIZE} < 524288 )); then
                    echo "Adding $f to User III Rom"
                    cat "${f}" >> ${USER_ROM_III}
                    basename "${f}" .${SECTORSIZE}.bin >> ${ROM_LIST_FILE}
                else
                    GENROM=4
                fi
            fi

            if (( ${GENROM} == 4 )); then
                echo "Limit reached ROMS full, skipping from ${f}..."
                break
            fi
        else
            echo "File:${f},Type:${FILETYPE} is not machine code, skipping.."
        fi
    else
        echo "ALERT! File:${f} not found."
    fi
done
if [ -f ${USER_ROM_I} ]; then
    mv ${USER_ROM_I} ${ROM_PATH}/USER_ROM_${SECTORSIZE}.bin
    FILESIZE=$(stat -c%s "${ROM_PATH}USER_ROM_${SECTORSIZE}.bin")
    echo "USER ROM I SIZE (${ROM_PATH}USER_ROM_${SECTORSIZE}.bin) = ${FILESIZE} Bytes"
fi
if [ -f ${USER_ROM_II} ]; then
    mv ${USER_ROM_II} ${ROM_PATH}/USER_ROM_II_${SECTORSIZE}.bin
    FILESIZE=$(stat -c%s "${ROM_PATH}USER_ROM_II_${SECTORSIZE}.bin")
    echo "USER ROM II SIZE (${ROM_PATH}USER_ROM_II_${SECTORSIZE}.bin) = ${FILESIZE} Bytes"
fi
if [ -f ${USER_ROM_III} ]; then
    mv ${USER_ROM_III} ${ROM_PATH}/USER_ROM_III_${SECTORSIZE}.bin
    FILESIZE=$(stat -c%s "${ROM_PATH}USER_ROM_III_${SECTORSIZE}.bin")
    echo "USER ROM III SIZE (${ROM_PATH}USER_ROM_III_${SECTORSIZE}.bin) = ${FILESIZE} Bytes"
fi
if [ -f ${MONITOR_ROM} ]; then
    mv ${MONITOR_ROM} ${ROM_PATH}/MROM_${SECTORSIZE}.bin
    FILESIZE=$(stat -c%s "${ROM_PATH}/MROM_${SECTORSIZE}.bin")
    echo "MROM SIZE (${ROM_PATH}/MROM_${SECTORSIZE}.bin) = ${FILESIZE} Bytes"
fi
exit 0
