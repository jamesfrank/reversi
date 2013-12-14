----------------------------------------------------------------------------------
-- FPGA Design Using VHDL
-- Final Project
--
-- Authors: Eric Beales & James Frank
--
-- Description: This entity interfaces with the PicoBlaze game logic code. The 
--              current_position input value should be tracked externally based 
--              on the human interface device in use. A move may be made by 
--              emitting a pulse on the play input. The game_board_out output 
--              contains the complete game board status and will be updated in 
--              response to play commands. The current_player output value will 
--              be updated in response to play commands.
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.final_project_package.all;

entity game_logic is port(
   clk    : in  std_logic;
   reset : in  std_logic;
   play : in std_logic;
   current_player : out std_logic;
   game_board_out : out byte_array(63 downto 0);
   current_position : in unsigned(5 downto 0) );
end game_logic;

architecture behavioral of game_logic is

   -- Setup the game board array.
   signal game_board : byte_array(63 downto 0);

   -- Signals between the picoblaze and its rom.
   signal address_signal       : std_logic_vector( 9 downto 0);
   signal instruction_signal   : std_logic_vector(17 downto 0);

   -- Signals to/from the picoblaze.
   signal port_id_signal       : std_logic_vector( 7 downto 0);
   signal write_strobe_signal  : std_logic;
   signal out_port_signal      : std_logic_vector( 7 downto 0);
   signal in_port_signal       : std_logic_vector( 7 downto 0);
   signal read_strobe_signal   : std_logic;
   signal interrupt_signal     : std_logic;
   signal interrupt_ack_signal : std_logic;

   -- Signals for keyboard.
   signal keyboard_data_available : std_logic;
   signal keyboard_data_out       : std_logic_vector(7 downto 0);

begin

   -- Output game board.
   game_board_out <= game_board;

   -- Pico-blaze output handling code.
   process(clk,reset)
   begin
      if(reset = '1') then
         game_board <= (others => x"10");
      elsif(rising_edge(clk)) then
         if (write_strobe_signal = '1') then
            if (port_id_signal(7 downto 6) = "00") then -- 00xxxxxx will change the game board
               game_board(to_integer(unsigned(port_id_signal(5 downto 0)))) <= unsigned(out_port_signal);
            elsif (port_id_signal = x"40") then -- x40 changes current player
               current_player <= out_port_signal(0);
            end if;
         end if;
      end if;
   end process;

   -- Pico-blaze input handling code.
   process(port_id_signal, game_board, current_position)
   begin
      if (port_id_signal(7 downto 6) = "00") then -- 00xxxxxx will get the game board
         in_port_signal <= std_logic_vector(game_board(to_integer(unsigned(port_id_signal(5 downto 0)))));
      elsif (port_id_signal = x"40") then -- x40 will get the current position
         in_port_signal <= "00" & std_logic_vector(current_position);
      else
         in_port_signal <= x"00";
      end if;
   end process;

   -- Manage play command and interrupt.
   process(clk,reset)
   begin
      if(reset = '1') then
         interrupt_signal <= '0';

      elsif(rising_edge(clk)) then
         -- Handle keyboard input if available
         if( play = '1' ) then
             interrupt_signal <= '1';
         end if;

         -- Clear the interrupt signal if we see an 'ack'
         if interrupt_ack_signal  = '1' then
            interrupt_signal <= '0';
         end if;

      end if;
   end process;

   -- Declaration for the picoblaze.
   processor: entity work.kcpsm3
   port map( address => address_signal,
             instruction => instruction_signal,
             port_id => port_id_signal,
             write_strobe => write_strobe_signal,
             out_port => out_port_signal,
             read_strobe => read_strobe_signal,
             in_port => in_port_signal,
             interrupt => interrupt_signal,
             interrupt_ack => interrupt_ack_signal,
             reset => reset,
             clk => clk );

   -- Declaration for the picoblaze's rom.
   program: entity work.finpropb
   port map( address => address_signal,
             instruction => instruction_signal,
             clk => clk );

end behavioral;
