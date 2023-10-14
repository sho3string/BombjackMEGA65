----------------------------------------------------------------------------------
-- MiSTer2MEGA65 Framework
--
-- Wrapper for the MiSTer core that runs exclusively in the core's clock domanin
--
-- MiSTer2MEGA65 done by sy2002 and MJoergen in 2022 and licensed under GPL v3
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.video_modes_pkg.all;

entity main is
   generic (
      G_VDNUM                 : natural                     -- amount of virtual drives
   );
   port (
      
      clk_main_i              : in  std_logic;
      reset_soft_i            : in  std_logic;
      reset_hard_i            : in  std_logic;
      pause_i                 : in  std_logic;
      dim_video_o             : out std_logic;

      -- MiSTer core main clock speed:
      -- Make sure you pass very exact numbers here, because they are used for avoiding clock drift at derived clocks
      clk_main_speed_i        : in  natural;

      -- Video output
      video_ce_o              : out std_logic;
      video_ce_ovl_o          : out std_logic;
      video_red_o             : out std_logic_vector(3 downto 0);
      video_green_o           : out std_logic_vector(3 downto 0);
      video_blue_o            : out std_logic_vector(3 downto 0);
      video_vs_o              : out std_logic;
      video_hs_o              : out std_logic;
      video_hblank_o          : out std_logic;
      video_vblank_o          : out std_logic;

      -- Audio output (not signed)
      audio_left_o            : out signed(15 downto 0);
      audio_right_o           : out signed(15 downto 0);

      -- M2M Keyboard interface
      kb_key_num_i            : in  integer range 0 to 79;    -- cycles through all MEGA65 keys
      kb_key_pressed_n_i      : in  std_logic;                -- low active: debounced feedback: is kb_key_num_i pressed right now?

      -- MEGA65 joysticks and paddles/mouse/potentiometers
      joy_1_up_n_i            : in  std_logic;
      joy_1_down_n_i          : in  std_logic;
      joy_1_left_n_i          : in  std_logic;
      joy_1_right_n_i         : in  std_logic;
      joy_1_fire_n_i          : in  std_logic;

      joy_2_up_n_i            : in  std_logic;
      joy_2_down_n_i          : in  std_logic;
      joy_2_left_n_i          : in  std_logic;
      joy_2_right_n_i         : in  std_logic;
      joy_2_fire_n_i          : in  std_logic;

      pot1_x_i                : in  std_logic_vector(7 downto 0);
      pot1_y_i                : in  std_logic_vector(7 downto 0);
      pot2_x_i                : in  std_logic_vector(7 downto 0);
      pot2_y_i                : in  std_logic_vector(7 downto 0);
      
       -- Dipswitches
      dsw_1_i                 : in  std_logic_vector(7 downto 0);
      dsw_2_i                 : in  std_logic_vector(7 downto 0);

      dn_clk_i                : in  std_logic;
      dn_addr_i               : in  std_logic_vector(16 downto 0);
      dn_data_i               : in  std_logic_vector(7 downto 0);
      dn_wr_i                 : in  std_logic;

      
      osm_control_i      : in  std_logic_vector(255 downto 0)
      
   );
end entity main;

architecture synthesis of main is

signal keyboard_n        : std_logic_vector(79 downto 0);
signal pause_cpu         : std_logic;
signal flip_screen       : std_logic;
signal flip              : std_logic := '0';
signal video_rotated     : std_logic;
signal rotate_ccw        : std_logic := flip_screen;
signal direct_video      : std_logic;
signal forced_scandoubler: std_logic;
--signal no_rotate         : std_logic := status(2) OR direct_video;
signal gamma_bus         : std_logic_vector(21 downto 0);
signal audio             : std_logic_vector(7 downto 0);


-- I/O board button press simulation ( active high )
-- b[1]: user button
-- b[0]: osd button

signal buttons           : std_logic_vector(1 downto 0);
signal reset             : std_logic  := reset_hard_i or reset_soft_i;


-- highscore system
signal hs_address       : std_logic_vector(15 downto 0);
signal hs_data_in       : std_logic_vector(7 downto 0);
signal hs_data_out      : std_logic_vector(7 downto 0);
signal hs_write_enable  : std_logic;

signal hs_pause         : std_logic;
signal options          : std_logic_vector(1 downto 0);

constant C_MENU_OSMPAUSE     : natural := 2;
constant C_MENU_OSMDIM       : natural := 3;
constant C_MENU_FLIP         : natural := 9;

-- Game player inputs
constant m65_1             : integer := 56; --Player 1 Start
constant m65_2             : integer := 59; --Player 2 Start
constant m65_5             : integer := 16; --Insert coin 1
constant m65_6             : integer := 19; --Insert coin 2

-- Offer some keyboard controls in addition to Joy 1 Controls
constant m65_a             : integer := 10; --Player left
constant m65_d             : integer := 18; --Player right
constant m65_up_crsr       : integer := 73; --Player fire

-- Pause, credit button & test mode
constant m65_p             : integer := 41; --Pause button
constant m65_help          : integer := 67; --Help key

begin
   
    --audio_left_o  <= signed(audio) & signed(audio);
    --audio_right_o <= audio_left_o;
    audio_left_o(15) <= not audio(7);
    audio_left_o(14 downto 8) <= signed(audio(6 downto 0));
    audio_left_o(7) <= audio(7);
    audio_left_o(6 downto 0) <= signed(audio(6 downto 0));
    -- audio_right_o <= audio_left_o
    audio_right_o(15) <= not audio(7);
    audio_right_o(14 downto 8) <= signed(audio(6 downto 0));
    audio_right_o(7) <= audio(7);
    audio_right_o(6 downto 0) <= signed(audio(6 downto 0));
    
   
    options(0) <= osm_control_i(C_MENU_OSMPAUSE);
    options(1) <= osm_control_i(C_MENU_OSMDIM);
    flip_screen <= osm_control_i(C_MENU_FLIP);
    

    i_bombjack_top : entity work.bombjack_top
    port map (
    
    clk_48M    => clk_main_i,
    reset      => reset,
    
    VGA_R      => video_red_o,
    VGA_G      => video_green_o,
    VGA_B      => video_blue_o,
   
    VGA_HS     => video_hs_o,
    VGA_VS     => video_vs_o,
    O_HBLANK   => video_hblank_o,
    O_VBLANK   => video_vblank_o,
    
    audio      => audio,
    
    p1_coin    => not keyboard_n(m65_5),
    p2_coin    => not keyboard_n(m65_6),
    p1_start   => not keyboard_n(m65_1),
    p2_start   => not keyboard_n(m65_2),
    p1_up      => not joy_1_up_n_i,
    p1_down    => not joy_1_down_n_i,
    p1_left    => not joy_1_left_n_i or not keyboard_n(m65_a),
    p1_right   => not joy_1_right_n_i or not keyboard_n(m65_d),
    p1_jump    => not joy_1_fire_n_i or not keyboard_n(m65_up_crsr),
    -- player 2 joystick is only active in cocktail/table mode.
    p2_up      => not joy_2_up_n_i,
    p2_down    => not joy_2_down_n_i,
    p2_left    => not joy_2_left_n_i,
    p2_right   => not joy_2_right_n_i,
    p2_jump    => not joy_2_fire_n_i,
    flip_screen => flip_screen,
    
    SW_DEMOSOUNDS => not dsw_1_i(7),
    SW_CABINET    => not dsw_1_I(6),
    SW_LIVES      => dsw_1_i(5 downto 4),
    SW_ENEMIES    => dsw_2_i(6 downto 5),
    SW_BIRDSPEED  => dsw_2_i(4 downto 3),
    SW_BONUS      => dsw_2_i(2 downto 0),
    pause      => pause_cpu or pause_i,
   
    hs_address => hs_address,
    hs_data_out => hs_data_out,
    hs_data_in => hs_data_in,
    hs_write   => hs_write_enable,
    

    dn_clk     => dn_clk_i,
    dn_addr    => dn_addr_i,
    dn_data    => dn_data_i,
    dn_wr      => dn_wr_i
 );
 
    i_pause : entity work.pause
     generic map (
     
        RW  => 4,
        GW  => 4,
        BW  => 4,
        CLKSPD => 48
        
     )         
     port map (
     
         clk_sys        => clk_main_i,
         reset          => reset,
         user_button    => keyboard_n(m65_p),
         pause_request  => hs_pause,
         options        => options,  -- not status(11 downto 10), - TODO, hookup to OSD.
         OSD_STATUS     => '0',       -- disabled for now - TODO, to OSD
         r              => video_red_o,
         g              => video_green_o,
         b              => video_blue_o,
         pause_cpu      => pause_cpu,
         dim_video      => dim_video_o
         --rgb_out        TODO
         
      );
      
   -- @TODO: Keyboard mapping and keyboard behavior
   -- Each core is treating the keyboard in a different way: Some need low-active "matrices", some
   -- might need small high-active keyboard memories, etc. This is why the MiSTer2MEGA65 framework
   -- lets you define literally everything and only provides a minimal abstraction layer to the keyboard.
   -- You need to adjust keyboard.vhd to your needs
   i_keyboard : entity work.keyboard
      port map (
         clk_main_i           => clk_main_i,

         -- Interface to the MEGA65 keyboard
         key_num_i            => kb_key_num_i,
         key_pressed_n_i      => kb_key_pressed_n_i,

         keyboard_n_o          => keyboard_n
      ); -- i_keyboard

end architecture synthesis;

