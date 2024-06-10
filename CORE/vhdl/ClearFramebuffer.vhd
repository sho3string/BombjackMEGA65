----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/31/2023 07:58:19 PM
-- Design Name: 
-- Module Name: ClearFramebuffer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


entity ClearFramebuffer is
    Port ( 
           clk: in std_logic;
           reset: in std_logic;
           
           ddram_addr_i     : in std_logic_vector(28 downto 0);
           ddram_data_i     : in std_logic_vector(63 downto 0);
           ddram_be_i       : in std_logic_vector( 7 downto 0);
           ddram_we_i       : in std_logic;
           
           ddram_addr_int_o : out std_logic_vector(28 downto 0);
           ddram_data_int_o : out std_logic_vector(63 downto 0);
           ddram_be_int_o   : out std_logic_vector( 7 downto 0);
           ddram_we_int_o   : out std_logic
         );
end ClearFramebuffer;

architecture Behavioral of ClearFramebuffer is
    type State_Type is (NormalOperation, ResetState);
    signal Current_State: State_Type;
    signal C_MAX_ADDRESS : integer := 65559;
    signal counter : integer range 0 to 65559;


begin
    p_clear_buffer : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                counter <= C_MAX_ADDRESS;
                Current_State <= ResetState;
            else
                case Current_State is
                    when NormalOperation =>
                        ddram_addr_int_o <= ddram_addr_i;
                        ddram_data_int_o <= ddram_data_i;
                        ddram_be_int_o   <= ddram_be_i;
                        ddram_we_int_o   <= ddram_we_i;
                    when ResetState =>
                        if counter /= 0 then
                            ddram_addr_int_o <= std_logic_vector(to_unsigned(counter,ddram_addr_int_o'length));
                            counter <= counter + 1;          
                            ddram_data_int_o <= (others => '0');
                            ddram_be_int_o   <= (others => '1');
                            ddram_we_int_o   <= '1';
                            counter <= counter-1;
                        else
                            Current_State <= NormalOperation;
                        end if;
                 end case;
             end if;
         end if;
    end process;
end Behavioral;
