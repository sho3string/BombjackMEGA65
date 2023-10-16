----------------------------------------------------------------------------------
-- MiSTer2MEGA65 Framework
--
-- Dual Port Dual Clock RAM: Drop-in replacement for "dpram.vhd"
--
-- Experimental and enhanced version that supports clock enable based on
-- the original M2M/vhdl/2port2clk_ram.vhdl. Done because Arcade-BombJack_MiSTer
-- needs this.
--
-- This file is currently meant to be part of sho3string's Bomb Jack port.
-- TODO: In case this is stable, working and double-checked, we might think of
-- enhancing M2M's official dualport_2clk_ram to support clkock enable.
--
-- MEGA65 port done by sy2002 in 2021 and 2023 and licensed under GPL v3
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dualport_2clk_ram_clken is
   generic (
       ADDR_WIDTH     : integer := 11;           -- The size of the RAM will be 2**ADDR_WIDTH
       DATA_WIDTH     : integer := 8;
       MAXIMUM_SIZE   : integer := integer'high; -- Maximum size of RAM, independent from ADDR_WIDTH
       ROM_PRELOAD    : boolean := false;        -- Preload a ROM
       ROM_FILE       : string  := "";
       ROM_FILE_HEX   : boolean := false;        -- hexadecimal format (using hread) instead of binary format (using read)
       LATCH_ADDR_A   : boolean := false;        -- latch address a when "do_latch_addr_a" = '1'
       LATCH_ADDR_B   : boolean := false;        -- ditto address b
       FALLING_A      : boolean := false;        -- read/write on falling edge for clock a
       FALLING_B      : boolean := false         -- ditto clock b
   );
   port
   (
      clock_a         : in  std_logic := '0';
      clock_a_en      : in  std_logic := '1';
      address_a       : in  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
      do_latch_addr_a : in  std_logic := '0';
      data_a          : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
      wren_a          : in  std_logic := '0';
      q_a             : out std_logic_vector(DATA_WIDTH-1 downto 0);

      clock_b         : in  std_logic := '0';
      clock_b_en      : in  std_logic := '1';      
      address_b       : in  std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
      do_latch_addr_b : in  std_logic := '0';
      data_b          : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
      wren_b          : in  std_logic := '0';
      q_b             : out std_logic_vector(DATA_WIDTH-1 downto 0)
   );
end entity dualport_2clk_ram_clken;

architecture beh of dualport_2clk_ram_clken is

   signal address_a_int : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
   signal address_b_int : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');

   pure function to_stdlogic(arg : boolean) return std_logic is
   begin
      if arg then
         return '1';
      else
         return '0';
      end if;
   end function to_stdlogic;

begin

   -- Optional latch management for A and B
   latch_address_a : process (clock_a)
   begin
      if LATCH_ADDR_A then
         if not FALLING_A then
            if rising_edge(clock_a) then
               if clock_a_en = '1' and do_latch_addr_a = '1' then
                  address_a_int <= address_a;
               end if;
            end if;
         else
            if falling_edge(clock_a) then
               if clock_a_en = '1' and do_latch_addr_a = '1' then
                  address_a_int <= address_a;
               end if;
            end if;
         end if;
      else
         address_a_int <= address_a;
      end if;
   end process latch_address_a;

   latch_address_b : process (clock_b)
   begin
      if LATCH_ADDR_B then
         if not FALLING_B then
            if rising_edge(clock_b) then
               if clock_b_en = '1' and do_latch_addr_b = '1' then
                  address_b_int <= address_b;
               end if;
            end if;
         else
            if falling_edge(clock_b) then
               if clock_b_en = '1' and do_latch_addr_b = '1' then
                  address_b_int <= address_b;
               end if;
            end if;
         end if;
      else
         address_b_int <= address_b;
      end if;
   end process latch_address_b;

   i_tdp_ram : entity work.tdp_ram
      generic map (
         ADDR_WIDTH   => ADDR_WIDTH,
         DATA_WIDTH   => DATA_WIDTH,
         ROM_PRELOAD  => ROM_PRELOAD,
         ROM_FILE     => ROM_FILE,
         ROM_FILE_HEX => ROM_FILE_HEX
      )
      port map (
         clock_a   => clock_a xor to_stdlogic(FALLING_A),
         clen_a    => clock_a_en,
         address_a => address_a_int,
         data_a    => data_a,
         wren_a    => wren_a,
         q_a       => q_a,
         clock_b   => clock_b xor to_stdlogic(FALLING_B),
         clen_b    => clock_b_en,
         address_b => address_b_int,
         data_b    => data_b,
         wren_b    => wren_b,
         q_b       => q_b
      ); -- i_tdp_ram

end architecture beh;

