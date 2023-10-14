----------------------------------------------------------------------------------
-- MiSTer2MEGA65 Framework
--
-- Global constants
--
-- MiSTer2MEGA65 done by sy2002 and MJoergen in 2022 and licensed under GPL v3
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.NUMERIC_STD_UNSIGNED.ALL;

library work;
use work.qnice_tools.all;
use work.video_modes_pkg.all;

package globals is

----------------------------------------------------------------------------------------------------------
-- QNICE Firmware
----------------------------------------------------------------------------------------------------------

-- QNICE Firmware: Use the regular QNICE "operating system" called "Monitor" while developing and
-- debugging the firmware/ROM itself. If you are using the M2M ROM (the "Shell") as provided by the
-- framework, then always use the release version of the M2M firmware: QNICE_FIRMWARE_M2M
--
-- Hint: You need to run QNICE/tools/make-toolchain.sh to obtain "monitor.rom" and
-- you need to run CORE/m2m-rom/make_rom.sh to obtain the .rom file
constant QNICE_FIRMWARE_MONITOR   : string  := "../../../M2M/QNICE/monitor/monitor.rom";    -- debug/development
constant QNICE_FIRMWARE_M2M       : string  := "../../../CORE/m2m-rom/m2m-rom.rom";         -- release

-- Select firmware here
constant QNICE_FIRMWARE           : string  := QNICE_FIRMWARE_M2M;

----------------------------------------------------------------------------------------------------------
-- Clock Speed(s)
--
-- Important: Make sure that you use very exact numbers - down to the actual Hertz - because some cores
-- rely on these exact numbers. By default M2M supports one core clock speed. In case you need more,
-- then add all the clocks speeds here by adding more constants.
----------------------------------------------------------------------------------------------------------

-- Galaga core's clock speed
-- Actual clock is 18_432 Mhz ( see MAME driver - galaga.cpp ).
-- MiSTer uses 18Mhz
constant CORE_CLK_SPEED       : natural := 18_000_000;   -- Galaga's main clock is 18 MHz 

-- System clock speed (crystal that is driving the FPGA) and QNICE clock speed
-- !!! Do not touch !!!
constant BOARD_CLK_SPEED      : natural := 100_000_000;
constant QNICE_CLK_SPEED      : natural := 50_000_000;   -- a change here has dependencies in qnice_globals.vhd

----------------------------------------------------------------------------------------------------------
-- Video Mode
----------------------------------------------------------------------------------------------------------

-- Rendering constants (in pixels)
--    VGA_*   size of the core's target output post scandoubler
--    FONT_*  size of one OSM character
constant VGA_DX               : natural := 576;
constant VGA_DY               : natural := 448;
constant FONT_FILE            : string  := "../font/Anikki-16x16-m2m.rom";
constant FONT_DX              : natural := 16;
constant FONT_DY              : natural := 16;

-- Constants for the OSM screen memory
constant CHARS_DX             : natural := VGA_DX / FONT_DX;
constant CHARS_DY             : natural := VGA_DY / FONT_DY;
constant CHAR_MEM_SIZE        : natural := CHARS_DX * CHARS_DY;
constant VRAM_ADDR_WIDTH      : natural := f_log2(CHAR_MEM_SIZE);

----------------------------------------------------------------------------------------------------------
-- HyperRAM memory map (in units of 4kW)
----------------------------------------------------------------------------------------------------------

constant C_HMAP_M2M           : std_logic_vector(15 downto 0) := x"0000";     -- Reserved for the M2M framework
constant C_HMAP_DEMO          : std_logic_vector(15 downto 0) := x"0200";     -- Start address reserved for core

----------------------------------------------------------------------------------------------------------
-- Virtual Drive Management System
----------------------------------------------------------------------------------------------------------

-- Virtual drive management system (handled by vdrives.vhd and the firmware)
-- If you are not using virtual drives, make sure that:
--    C_VDNUM        is 0
--    C_VD_DEVICE    is x"EEEE"
--    C_VD_BUFFER    is (x"EEEE", x"EEEE")
-- Otherwise make sure that you wire C_VD_DEVICE in the qnice_ramrom_devices process and that you
-- have as many appropriately sized RAM buffers for disk images as you have drives
type vd_buf_array is array(natural range <>) of std_logic_vector;
constant C_VDNUM              : natural := 0;
constant C_VD_DEVICE          : std_logic_vector(15 downto 0) := x"EEEE";
constant C_VD_BUFFER          : vd_buf_array := (x"EEEE", x"EEEE");

----------------------------------------------------------------------------------------------------------
-- System for handling simulated cartridges and ROM loaders
----------------------------------------------------------------------------------------------------------

type crtrom_buf_array is array(natural range<>) of std_logic_vector;
constant ENDSTR : character := character'val(0);

-- Cartridges and ROMs can be stored into QNICE devices, HyperRAM and SDRAM
constant C_CRTROMTYPE_DEVICE     : std_logic_vector(15 downto 0) := x"0000";
constant C_CRTROMTYPE_HYPERRAM   : std_logic_vector(15 downto 0) := x"0001";
constant C_CRTROMTYPE_SDRAM      : std_logic_vector(15 downto 0) := x"0002";           -- @TODO/RESERVED for future R4 boards

-- Types of automatically loaded ROMs:
-- If a mandatory file is missing, then the core outputs the missing file and goes fatal
constant C_CRTROMTYPE_MANDATORY  : std_logic_vector(15 downto 0) := x"0003";
constant C_CRTROMTYPE_OPTIONAL   : std_logic_vector(15 downto 0) := x"0004";


-- Manually loadable ROMs and cartridges as defined in config.vhd
-- If you are not using this, then make sure that:
--    C_CRTROM_MAN_NUM    is 0
--    C_CRTROMS_MAN       is (x"EEEE", x"EEEE", x"EEEE")
-- Each entry of the array consists of two constants:
--    1) Type of CRT or ROM: Load to a QNICE device, load into HyperRAM, load into SDRAM
--    2) If (1) = QNICE device, then this is the device ID
--       else it is a 4k window in HyperRAM or in SDRAM
-- In case we are loading to a QNICE device, then the control and status register is located at the 4k window 0xFFFF.
-- @TODO: See @TODO for more details about the control and status register
constant C_CRTROMS_MAN_NUM       : natural := 0;                                       -- amount of manually loadable ROMs and carts, if more than 3: also adjust CRTROM_MAN_MAX in M2M/rom/shell_vars.asm, Needs to be in sync with config.vhd. Maximum is 16
constant C_CRTROMS_MAN           : crtrom_buf_array := ( x"EEEE", x"EEEE",
                                                         x"EEEE");                     -- Always finish the array using x"EEEE"

-- Automatically loaded ROMs: These ROMs are loaded before the core starts
--
-- Works similar to manually loadable ROMs and cartridges and each line item has two additional parameters:
--    1) and 2) see above
--    3) Mandatory or optional ROM
--    4) Start address of ROM file name within C_CRTROM_AUTO_NAMES
-- If you are not using this, then make sure that:
--    C_CRTROMS_AUTO_NUM  is 0
--    C_CRTROMS_AUTO      is (x"EEEE", x"EEEE", x"EEEE", x"EEEE", x"EEEE")
-- How to pass the filenames of the ROMs to the framework:
-- C_CRTROMS_AUTO_NAMES is a concatenation of all filenames (see config.vhd's WHS_DATA for an example of how to concatenate)
--    The start addresses of the filename can be determined similarly to how it is done in config.vhd's HELP_x_START
--    using a concatenated addition and VHDL's string length operator.
--    IMPORTANT: a) The framework is not doing any consistency or error check when it comes to C_CRTROMS_AUTO_NAMES, so you
--                  need to be extra careful that the string itself plus the start position of the namex are correct.
--               b) Don't forget to zero-terminate each of your substrings of C_CRTROMS_AUTO_NAMES by adding "& ENDSTR;"
--               c) Don't forget to finish the C_CRTROMS_AUTO array with x"EEEE"

-- BOMBJACK MAINCPU
constant C_DEV_BJ_CPU1_ROM1           : std_logic_vector(15 downto 0) := x"0100";     
constant C_DEV_BJ_CPU1_ROM2           : std_logic_vector(15 downto 0) := x"0101";    
constant C_DEV_BJ_CPU1_ROM3           : std_logic_vector(15 downto 0) := x"0102";
constant C_DEV_BJ_CPU1_ROM4           : std_logic_vector(15 downto 0) := x"0103";
constant C_DEV_BJ_CPU1_ROM5           : std_logic_vector(15 downto 0) := x"0104";
-- BOMBJACK AUDIOCPU    
constant C_DEV_BJ_CPU2_ROM1           : std_logic_vector(15 downto 0) := x"0105";
-- BOMBJACK CHARACTERS
constant C_DEV_BJ_GFX1_ROM1           : std_logic_vector(15 downto 0) := x"0106";
constant C_DEV_BJ_GFX1_ROM2           : std_logic_vector(15 downto 0) := x"0107";
constant C_DEV_BJ_GFX1_ROM3           : std_logic_vector(15 downto 0) := x"0108";
-- BOMBJACK BGTILES
constant C_DEV_BJ_GFX2_ROM1           : std_logic_vector(15 downto 0) := x"0109";
constant C_DEV_BJ_GFX2_ROM2           : std_logic_vector(15 downto 0) := x"010A";
constant C_DEV_BJ_GFX2_ROM3           : std_logic_vector(15 downto 0) := x"010B";
-- BOMBJACK SPRITES
constant C_DEV_BJ_GFX3_ROM1           : std_logic_vector(15 downto 0) := x"010C";
constant C_DEV_BJ_GFX3_ROM2           : std_logic_vector(15 downto 0) := x"010D";
constant C_DEV_BJ_GFX3_ROM3           : std_logic_vector(15 downto 0) := x"010E";
-- BOMBJACK TILEMAPS
constant C_DEV_BJ_GFX4_ROM1           : std_logic_vector(15 downto 0) := x"010F";

-- BOMBJACK core specific ROMs
constant ROM1_MAIN_CPU_ROM            : string  := "arcade/bombjack/09_j01b.bin" & ENDSTR; -- z80 cpu 1
constant ROM2_MAIN_CPU_ROM            : string  := "arcade/bombjack/10_l01b.bin" & ENDSTR; -- z80 cpu 1
constant ROM3_MAIN_CPU_ROM            : string  := "arcade/bombjack/11_m01b.bin" & ENDSTR; -- z80 cpu 1
constant ROM4_MAIN_CPU_ROM            : string  := "arcade/bombjack/12_n01b.bin" & ENDSTR; -- z80 cpu 1
constant ROM5_MAIN_CPU_ROM            : string  := "arcade/bombjack/13.1r"       & ENDSTR; -- z80 cpu 1
constant ROM1_AUD_CPU_ROM             : string  := "arcade/bombjack/01_h03t.bin" & ENDSTR; -- z80 sound cpu 2
constant ROM1_GFX1_ROM                : string  := "arcade/bombjack/03_e08t.bin" & ENDSTR; -- gfx1 fg characters
constant ROM2_GFX1_ROM                : string  := "arcade/bombjack/04_h08t.bin" & ENDSTR; -- gfx1 fg characters
constant ROM3_GFX1_ROM                : string  := "arcade/bombjack/05_k08t.bin" & ENDSTR; -- gfx1 fg characters
constant ROM1_GFX2_ROM                : string  := "arcade/bombjack/06_l08t.bin" & ENDSTR; -- gfx2 bg characters
constant ROM2_GFX2_ROM                : string  := "arcade/bombjack/07_n08t.bin" & ENDSTR; -- gfx2 bg characters
constant ROM3_GFX2_ROM                : string  := "arcade/bombjack/08_r08t.bin" & ENDSTR; -- gfx2 bg characters
constant ROM1_GFX3_ROM                : string  := "arcade/bombjack/16_m07b.bin" & ENDSTR; -- gfx3 bg characters
constant ROM2_GFX3_ROM                : string  := "arcade/bombjack/15_l07b.bin" & ENDSTR; -- gfx3 bg characters
constant ROM3_GFX3_ROM                : string  := "arcade/bombjack/14_j07b.bin" & ENDSTR; -- gfx3 bg characters
constant ROM1_GFX4_ROM                : string  := "arcade/bombjack/02_p04t.bin" & ENDSTR; -- gfx4 tielmap


constant CPU_ROM1_MAIN_START          : std_logic_vector(15 downto 0) := X"0000";
constant CPU_ROM2_MAIN_START          : std_logic_vector(15 downto 0) := CPU_ROM1_MAIN_START + ROM1_MAIN_CPU_ROM'length;
constant CPU_ROM3_MAIN_START          : std_logic_vector(15 downto 0) := CPU_ROM2_MAIN_START + ROM2_MAIN_CPU_ROM'length;
constant CPU_ROM4_MAIN_START          : std_logic_vector(15 downto 0) := CPU_ROM3_MAIN_START + ROM3_MAIN_CPU_ROM'length;
constant CPU_ROM5_MAIN_START          : std_logic_vector(15 downto 0) := CPU_ROM4_MAIN_START + ROM4_MAIN_CPU_ROM'length;
constant CPU_ROM1_AUD_START           : std_logic_vector(15 downto 0) := CPU_ROM5_MAIN_START + ROM5_MAIN_CPU_ROM'length;
constant GFX1_ROM1_START              : std_logic_vector(15 downto 0) := CPU_ROM1_AUD_START  + ROM1_AUD_CPU_ROM'length;
constant GFX1_ROM2_START              : std_logic_vector(15 downto 0) := GFX1_ROM1_START     + ROM1_GFX1_ROM'length;
constant GFX1_ROM3_START              : std_logic_vector(15 downto 0) := GFX1_ROM2_START     + ROM2_GFX1_ROM'length;
constant GFX2_ROM1_START              : std_logic_vector(15 downto 0) := GFX1_ROM3_START     + ROM3_GFX1_ROM'length;
constant GFX2_ROM2_START              : std_logic_vector(15 downto 0) := GFX2_ROM1_START     + ROM1_GFX2_ROM'length;
constant GFX2_ROM3_START              : std_logic_vector(15 downto 0) := GFX2_ROM2_START     + ROM2_GFX2_ROM'length;
constant GFX3_ROM1_START              : std_logic_vector(15 downto 0) := GFX2_ROM3_START     + ROM3_GFX2_ROM'length;
constant GFX3_ROM2_START              : std_logic_vector(15 downto 0) := GFX3_ROM1_START     + ROM1_GFX3_ROM'length;
constant GFX3_ROM3_START              : std_logic_vector(15 downto 0) := GFX3_ROM2_START     + ROM2_GFX3_ROM'length;
constant GFX4_ROM1_START              : std_logic_vector(15 downto 0) := GFX3_ROM3_START     + ROM3_GFX3_ROM'length;

-- M2M framework constants
constant C_CRTROMS_AUTO_NUM      : natural := 16; -- Amount of automatically loadable ROMs and carts, if more tha    n 3: also adjust CRTROM_MAN_MAX in M2M/rom/shell_vars.asm, Needs to be in sync with config.vhd. Maximum is 16
constant C_CRTROMS_AUTO_NAMES    : string  := ROM1_MAIN_CPU_ROM & ROM2_MAIN_CPU_ROM & ROM3_MAIN_CPU_ROM & ROM4_MAIN_CPU_ROM & ROM5_MAIN_CPU_ROM &
                                              ROM1_AUD_CPU_ROM &
                                              ROM1_GFX1_ROM & ROM2_GFX1_ROM & ROM3_GFX1_ROM &
                                              ROM1_GFX2_ROM & ROM2_GFX2_ROM & ROM3_GFX2_ROM &
                                              ROM1_GFX3_ROM & ROM2_GFX3_ROM & ROM3_GFX3_ROM &
                                              ROM1_GFX4_ROM &
                                              ENDSTR;
                                              
constant C_CRTROMS_AUTO          : crtrom_buf_array := ( 
      C_CRTROMTYPE_DEVICE, C_DEV_BJ_CPU1_ROM1 , C_CRTROMTYPE_MANDATORY, CPU_ROM1_MAIN_START,
      C_CRTROMTYPE_DEVICE, C_DEV_BJ_CPU1_ROM2 , C_CRTROMTYPE_MANDATORY, CPU_ROM2_MAIN_START,
      C_CRTROMTYPE_DEVICE, C_DEV_BJ_CPU1_ROM3 , C_CRTROMTYPE_MANDATORY, CPU_ROM3_MAIN_START,
      C_CRTROMTYPE_DEVICE, C_DEV_BJ_CPU1_ROM4 , C_CRTROMTYPE_MANDATORY, CPU_ROM4_MAIN_START,
      C_CRTROMTYPE_DEVICE, C_DEV_BJ_CPU1_ROM5 , C_CRTROMTYPE_MANDATORY, CPU_ROM5_MAIN_START,
      C_CRTROMTYPE_DEVICE, C_DEV_BJ_CPU2_ROM1 , C_CRTROMTYPE_MANDATORY, CPU_ROM1_AUD_START,
      C_CRTROMTYPE_DEVICE, C_DEV_BJ_GFX1_ROM1 , C_CRTROMTYPE_MANDATORY, GFX1_ROM1_START,
      C_CRTROMTYPE_DEVICE, C_DEV_BJ_GFX1_ROM2 , C_CRTROMTYPE_MANDATORY, GFX1_ROM2_START,
      C_CRTROMTYPE_DEVICE, C_DEV_BJ_GFX1_ROM3 , C_CRTROMTYPE_MANDATORY, GFX1_ROM3_START,
      C_CRTROMTYPE_DEVICE, C_DEV_BJ_GFX2_ROM1 , C_CRTROMTYPE_MANDATORY, GFX2_ROM1_START,
      C_CRTROMTYPE_DEVICE, C_DEV_BJ_GFX2_ROM2 , C_CRTROMTYPE_MANDATORY, GFX2_ROM2_START,
      C_CRTROMTYPE_DEVICE, C_DEV_BJ_GFX2_ROM3 , C_CRTROMTYPE_MANDATORY, GFX2_ROM3_START,
      C_CRTROMTYPE_DEVICE, C_DEV_BJ_GFX3_ROM1 , C_CRTROMTYPE_MANDATORY, GFX3_ROM1_START,
      C_CRTROMTYPE_DEVICE, C_DEV_BJ_GFX3_ROM2 , C_CRTROMTYPE_MANDATORY, GFX3_ROM2_START,
      C_CRTROMTYPE_DEVICE, C_DEV_BJ_GFX3_ROM3 , C_CRTROMTYPE_MANDATORY, GFX3_ROM3_START,
      C_CRTROMTYPE_DEVICE, C_DEV_BJ_GFX4_ROM1 , C_CRTROMTYPE_MANDATORY, GFX4_ROM1_START,
                                                         x"EEEE");                     -- Always finish the array using x"EEEE"
                                                         
----------------------------------------------------------------------------------------------------------
-- Audio filters
--
-- If you use audio filters, then you need to copy the correct values from the MiSTer core
-- that you are porting: sys/sys_top.v
----------------------------------------------------------------------------------------------------------

-- Sample values from the C64: @TODO: Adjust to your needs
constant audio_flt_rate : std_logic_vector(31 downto 0) := std_logic_vector(to_signed(7056000, 32));
constant audio_cx       : std_logic_vector(39 downto 0) := std_logic_vector(to_signed(4258969, 40));
constant audio_cx0      : std_logic_vector( 7 downto 0) := std_logic_vector(to_signed(3, 8));
constant audio_cx1      : std_logic_vector( 7 downto 0) := std_logic_vector(to_signed(2, 8));
constant audio_cx2      : std_logic_vector( 7 downto 0) := std_logic_vector(to_signed(1, 8));
constant audio_cy0      : std_logic_vector(23 downto 0) := std_logic_vector(to_signed(-6216759, 24));
constant audio_cy1      : std_logic_vector(23 downto 0) := std_logic_vector(to_signed( 6143386, 24));
constant audio_cy2      : std_logic_vector(23 downto 0) := std_logic_vector(to_signed(-2023767, 24));
constant audio_att      : std_logic_vector( 4 downto 0) := "00000";
constant audio_mix      : std_logic_vector( 1 downto 0) := "00"; -- 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

end package globals;

