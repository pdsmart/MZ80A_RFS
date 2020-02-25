;--------------------------------------------------------------------------------------------------------
;-
;- Name:            cbios_bank4.asm
;- Created:         October 2018
;- Author(s):       Philip Smart
;- Description:     Sharp MZ series CPM BIOS System.
;-                  This assembly language program is written to utilise the banked flashroms added with
;-                  the MZ-80A RFS hardware upgrade for the CPM CBIOS in order to preserve RAM for actual
;-                  CPM TPA programs.
;-
;- Credits:         
;- Copyright:       (c) 2018-20 Philip Smart <philip.smart@net2net.org>
;-
;- History:         January 2020 - Seperated Bank from RFS for dedicated use with CPM CBIOS.
;--------------------------------------------------------------------------------------------------------
;- This source file is free software: you can redistribute it and-or modify
;- it under the terms of the GNU General Public License as published
;- by the Free Software Foundation, either version 3 of the License, or
;- (at your option) any later version.
;-
;- This source file is distributed in the hope that it will be useful,
;- but WITHOUT ANY WARRANTY; without even the implied warranty of
;- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;- GNU General Public License for more details.
;-
;- You should have received a copy of the GNU General Public License
;- along with this program.  If not, see <http://www.gnu.org/licenses/>.
;--------------------------------------------------------------------------------------------------------

            ;======================================
            ;
            ; USER ROM CPM CBIOS BANK 4
            ;
            ;======================================
            ORG      UROMADDR

            ;-----------------------------------------------------------------------------------------
            ; Common code spanning all banks to ensure that a Monitor is selected upon power up/reset.
            ;-----------------------------------------------------------------------------------------
            NOP
            XOR      A                                                        ; We shouldnt arrive here after a reset, if we do, select MROM bank 0
            LD       (RFSBK1),A                                               ; and start up - ie. SA1510 Monitor.
            NOP
            JP       00000h

            ; Jump table for entry into this pages functions.


            ALIGN_NOPS    UROMADDR + 0800h

            ; Bring in additional macros.
            INCLUDE "CPM_Definitions.asm"
            INCLUDE "Macros.asm"
