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
## Copyright:       (c) 2020 Philip Smart <philip.smart@net2net.org>
##
## History:         January 2020   - Initial script written.
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
SECTORSIZE=256
CPMDISKMODE=SPLIT

# Place the RFS rom into the User ROM at the beginning as it contains all the banked pages.
echo "cat ${ROM_PATH}/rfs.rom ${ROM_PATH}/cbios_bank1.rom ${ROM_PATH}/cbios_bank2.rom ${ROM_PATH}/cbios_bank3.rom ${ROM_PATH}/cbios_bank4.rom > /tmp/user.rom"
cat ${ROM_PATH}/rfs.rom ${ROM_PATH}/cbios_bank1.rom ${ROM_PATH}/cbios_bank2.rom \
    ${ROM_PATH}/cbios_bank3.rom ${ROM_PATH}/cbios_bank4.rom \
    > /tmp/user.rom

# User ROM 2 = empty.
> /tmp/user2.rom

# According to flag set above, either put the CPM Disks in the first ROM, or place one in each ROM allowing for better write spread and larger disks.
#
if [ "${CPMDISKMODE}" != "SPLIT" ]; then
    # CPM RFS Disks currently only in User ROM.
    for f in 1 2
    do
        if [ -f ${MZB_PATH}/CPM_RFS_${f}.${SECTORSIZE}.bin ]; then
            echo "cat ${MZB_PATH}/CPM_RFS_${f}.${SECTORSIZE}.bin >> /tmp/user.rom"
            cat ${MZB_PATH}/CPM_RFS_${f}.${SECTORSIZE}.bin >> /tmp/user.rom
        fi
    done
else
    if [ -f ${MZB_PATH}/CPM_RFS_1.${SECTORSIZE}.bin ]; then
        echo "cat ${MZB_PATH}/CPM_RFS_1.${SECTORSIZE}.bin >> /tmp/user.rom"
        cat ${MZB_PATH}/CPM_RFS_1.${SECTORSIZE}.bin >> /tmp/user.rom
    fi

    if [ -f ${MZB_PATH}/CPM_RFS_2.${SECTORSIZE}.bin ]; then
        echo "cat ${MZB_PATH}/CPM_RFS_2.${SECTORSIZE}.bin >> /tmp/user2.rom"
        cat ${MZB_PATH}/CPM_RFS_2.${SECTORSIZE}.bin >> /tmp/user2.rom
    fi
fi

# Place the monitor roms into the MROM at the beginning for banked page usage.
echo "cat ${ROM_PATH}/monitor_SA1510.rom ${ROM_PATH}/monitor_80c_SA1510.rom  ${ROM_PATH}/cbios.rom ${ROM_PATH}/rfs_mrom.rom ${ROM_PATH}/blank_mrom.rom ${ROM_PATH}/blank_mrom.rom ${ROM_PATH}/blank_mrom.rom ${ROM_PATH}/blank_mrom.rom > /tmp/mrom.rom"
cat ${ROM_PATH}/monitor_SA1510.rom ${ROM_PATH}/monitor_80c_SA1510.rom \
    ${ROM_PATH}/cbios.rom ${ROM_PATH}/rfs_mrom.rom \
    ${ROM_PATH}/blank_mrom.rom ${ROM_PATH}/blank_mrom.rom \
    ${ROM_PATH}/blank_mrom.rom ${ROM_PATH}/blank_mrom.rom \
    > /tmp/mrom.rom
GENROM=0

# Manually choose the programs you want installed into the ROMS. The files will be first placed into the USER ROM and when full into the 
# Monitor ROM. Thus order is important if you want a particular program in a particular ROM.
#
# NB: A Double Hash (##) indicates a program found not to work on the Sharp MZ-80A.
#
ROM_INCLUDE=
ROM_INCLUDE+="${MZB_PATH}/cpm22.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/sdtest.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/1Z-013B.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/2Z009E.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/2z-046a.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/5Z-009A.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/5Z-009B.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/6502_Betriebssys.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/80A PENCIL.A2_C2.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/80A_PENCIL.A2_C2.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/80A PENCIL.A2_S.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/80A_PENCIL.A2_S.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/80zbasic.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/A-BASIC_SA-5510.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/AIP_-_LOGO_xrr.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/APOLLO CHESS v2a.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/APOLLO_CHESS_v2a.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/B880.A3_P6.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/B880 MASTER.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/B880_MASTER.${SECTORSIZE}.bin:"
###ROM_INCLUDE+="${MZB_PATH}/BASIC_MZ-5Z008_2.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/BASIC_MZ-5Z008.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/BASIC_MZ-5Z009.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/BASIC_MZ-5Z009_modified.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/BASIC_OM-1000.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/BASIC_OM-1001.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/BASIC_OM-500.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/basic_sa-5510.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/BASIC.SA-5510.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/BASIC SA-5575_C.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/BASIC_SA-5575_C.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/BASIC SA-5575_S.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/BASIC_SA-5575_S.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/BASIC SA-5577_C.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/BASIC_SA-5577_C.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/BASIC SA-5577_S.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/BASIC_SA-5577_S.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/BASIC SA-5580.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/BASIC_SA-5580.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/BASIC_SP-5025.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/BAS MOD v3.74.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/BAS_MOD_v3.74.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/BATTLE_GAME.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/BINARY COUNT.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/BINARY_COUNT.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/BYTESAVER SA5510.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/BYTESAVER_SA5510.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/CIRCUS_STAR.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/clock1.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/CLUB COPY.U1.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/CLUB_COPY.U1.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/CLUB MON.A1_M.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/CLUB_MON.A1_M.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/CLUB MON.A1_S.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/CLUB_MON.A1_S.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/cmttofd.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/COLONY.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/COMPILER_A2.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/CONVERTER.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/CONVERTER A_700.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/CONVERTER_A_700.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/COPIER.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/COSMO_BLASTER_MZ700.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/DCS MZ80A APPEND.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/DCS_MZ80A_APPEND.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/DCS MZ80A RENUM.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/DCS_MZ80A_RENUM.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/DELETE.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/diamond.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/DISASM 8800.A15.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/DISASM_8800.A15.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/DISASM B800.A15.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/DISASM_B800.A15.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/DISKEDIT.A4B.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/DISKEDIT.A7_40T.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/diskutility.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/EXPRESS BAS_700.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/EXPRESS_BAS_700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/EXPRESS COMPILER.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/EXPRESS_COMPILER.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/EXPRESS PLUS.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/EXPRESS_PLUS.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/EXT.BASIC_OM-500.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/FDCOPY.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/FD_Editor_MZ700.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Filing(CMT).${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/FLAP.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/fortransosz80.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/FRONT_PANEL_v1.5.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/GALAXI_FORM.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/GALAXY_INVADERS.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/GDP9-BA.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Greedy_Gremlins.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/Hardcopy.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/HP4TMZ7.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/HP4TMZ7L.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/HU-BASIC.A1_M.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/HU-BASIC.A1_S.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/HU-BASIC.A2_80M.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/HU-BASIC.A2_80S.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/HU-BASIC_V1.3_K.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/HUCALC_80A+_C2.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/HUCALC_80A+_M.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/HUCALC_80A+_S.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/hudson_basic.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/HUNCHY.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/INSTRUCS_v1.1.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/JIGSAW.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/Joy.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/k-basic_v.5.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/KNIFORTH.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/KUMA_INTERPR..${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/KuPTest.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/LAND_ESCAPE.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Le_Mans.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/loader.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MAGIC_PAINTBOX.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MAN-HUNT.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/m_c_Breakout_2.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/m_c_Hissing_Sid.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/m_c_Race_Chase.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MEMORY_TEST.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MINI_DATACARD..${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/minotaur.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/ML-SP_8002_BBG.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/monitor3.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MONITOR6.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/MOVING_SEARCHER.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/Mz1571.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/MZ-2Z009.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/mz-5z009_modified2.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/MZ700BAS.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-700_FORTH.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/MZ-80A_GALACTIC.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/Mzprint.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/NEW_INVADERS.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/OPENING_DATA.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/OTHELLO.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/PAC-MAN.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/PAC-MAN3.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/PAINFUL_MAN.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/PAINTBOX.BAS.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/PCG_BASIC.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/PCG_BASIC_MZ700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/Pcgrally_MZ800.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/PROBE_A_1200.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/PROBE_A_8000.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/PROBE_A_B600.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/QD_BAS_5Z008_MZ700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/QDCOPY.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/RAM_CHECK_A.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/REALFORT.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/ROUND_SHOOT.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/sa-5510_Bas_MZ80K.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/SA-5510_Compiler.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/SA-5510+KN.COMM..${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/sa-6510.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/SARGON_2.71.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/S-Basic-Cent-2.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SCRAMBLE_A.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SECTOR_R_W.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SECTOR_R_W(NEC).${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SEND-1.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SHARPLAN01.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SHARP_PENCIL.A1.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SHARP_PENCIL.ALF.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SLAVE_v1.1A.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/S-MASTER.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SNAKE&SNAKE_EXP1.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SNOWFLAKES.${SECTORSIZE}.bin:"
##ROM_INCLUDE+="${MZB_PATH}/SOLO_BASIC.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SP-4015.A1_C.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SP-4015.A1_S.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SP-5060.A1_M.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SP-5060.A1_S.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/SPACE_INVADERS.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SP-CONVERT.A1.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/STKEEPER2BAS700A.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SUB-MONITOR-700.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SUCOPY_A000.A16.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SUPERFIRE.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SUPER_PUCK-MAN.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SUPERTAPE_2.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SUTAM1F.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SUTAMC9.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SUTAPEBA.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/SUTAPEMO.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/TETRIS.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/tetris-2_MZ800.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/TEXT_BASIC_I.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/TEXT~ED_v1.2.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/textsobs5.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/TRANS.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/ufo.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/UNI=BASIC800.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/UNIVERSAL_BASIC.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/URAS-700.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Utility_2.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/Utility_V_1.1.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/Utility_V_2.0.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/WDPRO_2.37AT.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/WDPRO_2.37AT_C2.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/Wooky.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/XPATCH_5510_v2.2.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/Z80_MACHINE.A1_M.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/Z80_MACHINE.A1_S.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/Z80_MACHINE.A2_M.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/Z80MACHINE.A3_C2.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/Z80_MACHINE.A3_S.${SECTORSIZE}.bin:"
ROM_INCLUDE+="${MZB_PATH}/ZEN7E.A2.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/Zexas_MZ800.${SECTORSIZE}.bin:"
#ROM_INCLUDE+="${MZB_PATH}/ZSP.${SECTORSIZE}.bin:"

IFS=":"; for f in ${ROM_INCLUDE}
do
    if [ -f ${f} ]; then
        if (( ${GENROM} == 0 )); then
            cat /tmp/user.rom "${f}" > /tmp/tmp.size
            FILESIZE=$(stat -c%s "/tmp/tmp.size")
            if (( ${FILESIZE} < 524288 )); then
                echo "Adding $f to User I Rom"
                cat "${f}" >> /tmp/user.rom
            else
                GENROM=1
            fi
        fi

        if (( ${GENROM} == 1 )); then
            cat /tmp/mrom.rom "${f}" > /tmp/tmp.size
            FILESIZE=$(stat -c%s "/tmp/tmp.size")
            if (( ${FILESIZE} < 524288 )); then
                echo "Adding $f to Monitor Rom"
                cat "${f}" >> /tmp/mrom.rom
            else
                GENROM=2
            fi
        fi

        if (( ${GENROM} == 2 )); then
            cat /tmp/user2.rom "${f}" > /tmp/tmp.size
            FILESIZE=$(stat -c%s "/tmp/tmp.size")
            if (( ${FILESIZE} < 524288 )); then
                echo "Adding $f to User II Rom"
                cat "${f}" >> /tmp/user.rom
            else
                GENROM=3
            fi
        fi

        if (( ${GENROM} == 3 )); then
            echo "Limit reached ROMS full, skipping from ${f}..."
            break
        fi
    else
        echo "ALERT! File:${f} not found."
    fi
done
if [ -f /tmp/user.rom ]; then
    mv /tmp/user.rom ${ROM_PATH}/USER_ROM_${SECTORSIZE}.bin
    FILESIZE=$(stat -c%s "${ROM_PATH}USER_ROM_${SECTORSIZE}.bin")
    echo "USER ROM I SIZE (${ROM_PATH}USER_ROM_${SECTORSIZE}.bin) = ${FILESIZE} Bytes"
fi
if [ -f /tmp/user2.rom ]; then
    mv /tmp/user2.rom ${ROM_PATH}/USER_ROM_II_${SECTORSIZE}.bin
    FILESIZE=$(stat -c%s "${ROM_PATH}USER_ROM_II_${SECTORSIZE}.bin")
    echo "USER ROM II SIZE (${ROM_PATH}USER_ROM_II_${SECTORSIZE}.bin) = ${FILESIZE} Bytes"
fi
if [ -f /tmp/mrom.rom ]; then
    mv /tmp/mrom.rom ${ROM_PATH}/MROM_${SECTORSIZE}.bin
    FILESIZE=$(stat -c%s "${ROM_PATH}/MROM_${SECTORSIZE}.bin")
    echo "MROM SIZE (${ROM_PATH}/MROM_${SECTORSIZE}.bin) = ${FILESIZE} Bytes"
fi
exit 0
