----------------------------------------------------------------------------------
-- FPGA Design Using VHDL
-- Final Project
--
-- Authors: Eric Beales &  James Frank
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.final_project_package.all;
use work.final_project_test_package.all;
 
ENTITY game_logic_tb IS
END game_logic_tb;
 
ARCHITECTURE behavior OF game_logic_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT game_logic
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         play : IN  std_logic;
         current_player : OUT std_logic;
         game_board_out : OUT  byte_array(63 downto 0);
         current_position : IN  unsigned(5 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal play : std_logic := '0';
   signal current_position : unsigned(5 downto 0) := (others => '0');

   --Outputs
   signal current_player : std_logic := '0';
   signal game_board : byte_array(63 downto 0);
 
BEGIN
 
   -- Instantiate the Unit Under Test (UUT)
   uut: game_logic PORT MAP (
          clk => clk,
          reset => reset,
          play => play,
          current_player => current_player,
          game_board_out => game_board,
          current_position => current_position
        );

   -- Clock process definitions
   clk_process :process
   begin
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin    
      -- hold reset state for 100 ns
      reset <= '1';
      wait for 100 ns;
      reset <= '0';
      wait for process_period;
      
      -- verify starting game board
      check_multiple_squares(game_board, 0, 26, SPACE_BOARD);
      check_square(game_board, 27, SPACE_WHITE);
      check_square(game_board, 28, SPACE_BLACK);
      check_multiple_squares(game_board, 29, 34, SPACE_BOARD);
      check_square(game_board, 35, SPACE_BLACK);
      check_square(game_board, 36, SPACE_WHITE);
      check_multiple_squares(game_board, 37, 63, SPACE_BOARD);
      
      -- illegal play on square 20
      play_square(20, current_position, play);
      assert false report "Attempted illegal play on square 20" severity note;
      
      -- re-verify starting game board, since last move was illegal
      check_multiple_squares(game_board, 0, 26, SPACE_BOARD);
      check_square(game_board, 27, SPACE_WHITE);
      check_square(game_board, 28, SPACE_BLACK);
      check_multiple_squares(game_board, 29, 34, SPACE_BOARD);
      check_square(game_board, 35, SPACE_BLACK);
      check_square(game_board, 36, SPACE_WHITE);
      check_multiple_squares(game_board, 37, 63, SPACE_BOARD);
      
      -- play on square 19
      play_square(19, current_position, play);
      assert false report "Played on square 19" severity note;
      
      -- verify 19 and 27 were captured by black and no other changes were made
      check_multiple_squares(game_board, 0, 18, SPACE_BOARD);
      check_square(game_board, 19, SPACE_BLACK);
      check_multiple_squares(game_board, 20, 26, SPACE_BOARD);
      check_square(game_board, 27, SPACE_BLACK);
      check_square(game_board, 28, SPACE_BLACK);
      check_multiple_squares(game_board, 29, 34, SPACE_BOARD);
      check_square(game_board, 35, SPACE_BLACK);
      check_square(game_board, 36, SPACE_WHITE);
      check_multiple_squares(game_board, 37, 63, SPACE_BOARD);
      
      -- play on square 20
      play_square(20, current_position, play);
      assert false report "Played on square 20" severity note;
      
      -- verify 20 and 28 were captured by white and no other changes were made
      check_multiple_squares(game_board, 0, 18, SPACE_BOARD);
      check_square(game_board, 19, SPACE_BLACK);
      check_square(game_board, 20, SPACE_WHITE);
      check_multiple_squares(game_board, 21, 26, SPACE_BOARD);
      check_square(game_board, 27, SPACE_BLACK);
      check_square(game_board, 28, SPACE_WHITE);
      check_multiple_squares(game_board, 29, 34, SPACE_BOARD);
      check_square(game_board, 35, SPACE_BLACK);
      check_square(game_board, 36, SPACE_WHITE);
      check_multiple_squares(game_board, 37, 63, SPACE_BOARD);
      
      -- reset board and play new game (white wins this one)
      assert false report "Starting complete game" severity note;
      
      reset <= '1';
      wait for 100 ns;
      reset <= '0';
      wait for process_period;
      
      play_square(19, current_position, play);
      play_square(20, current_position, play);
      play_square(29, current_position, play);
      play_square(34, current_position, play);
      play_square(43, current_position, play);
      play_square(44, current_position, play);
      play_square(37, current_position, play);
      play_square(42, current_position, play);
      play_square(21, current_position, play);
      play_square(26, current_position, play);
      play_square(49, current_position, play);
      play_square(50, current_position, play);
      play_square(51, current_position, play);
      play_square(52, current_position, play);
      play_square(41, current_position, play);
      play_square(25, current_position, play);
      play_square(18, current_position, play);
      play_square(59, current_position, play);
      play_square(60, current_position, play);
      play_square(61, current_position, play);
      play_square(53, current_position, play);
      play_square(45, current_position, play);
      play_square(46, current_position, play);
      play_square(33, current_position, play);
      play_square(54, current_position, play);
      play_square(58, current_position, play);
      play_square(57, current_position, play);
      play_square(40, current_position, play);
      play_square(62, current_position, play);
      play_square(11, current_position, play);
      play_square(17, current_position, play);
      play_square(10, current_position, play);
      play_square(2, current_position, play);
      play_square(12, current_position, play);
      play_square(13, current_position, play);
      play_square(22, current_position, play);
      play_square(31, current_position, play);
      play_square(30, current_position, play);
      play_square(38, current_position, play);
      play_square(39, current_position, play);
      play_square(47, current_position, play);
      play_square(55, current_position, play);
      play_square(63, current_position, play);
      play_square(14, current_position, play);
      play_square(6, current_position, play);
      play_square(7, current_position, play);
      play_square(15, current_position, play);
      play_square(23, current_position, play);
      play_square(24, current_position, play);
      play_square(32, current_position, play);
      play_square(48, current_position, play);
      play_square(56, current_position, play);
      play_square(1, current_position, play);
      play_square(3, current_position, play);
      play_square(9, current_position, play);
      play_square(8, current_position, play);
      play_square(5, current_position, play);
      play_square(16, current_position, play);
      play_square(4, current_position, play);
      play_square(0, current_position, play);
      
      -- check results
      assert false report "Finished complete game, now verifying that white won" severity note;
      check_multiple_squares(game_board, 0, 63, SPACE_WHITE);
      
      -- reset board and play new game (white wins this one)
      assert false report "Starting complete game" severity note;
      
      reset <= '1';
      wait for 100 ns;
      reset <= '0';
      wait for process_period;
      
      play_square(19, current_position, play);
      play_square(20, current_position, play);
      play_square(29, current_position, play);
      play_square(18, current_position, play);
      play_square(26, current_position, play);
      play_square(22, current_position, play);
      play_square(37, current_position, play);
      play_square(25, current_position, play);
      play_square(21, current_position, play);
      play_square(46, current_position, play);
      play_square(45, current_position, play);
      play_square(38, current_position, play);
      play_square(12, current_position, play);
      play_square(54, current_position, play);
      play_square(53, current_position, play);
      play_square(61, current_position, play);
      play_square(44, current_position, play);
      play_square(5, current_position, play);
      play_square(11, current_position, play);
      play_square(2, current_position, play);
      play_square(30, current_position, play);
      play_square(31, current_position, play);
      play_square(33, current_position, play);
      play_square(40, current_position, play);
      play_square(17, current_position, play);
      play_square(16, current_position, play);
      play_square(10, current_position, play);
      play_square(1, current_position, play);
      play_square(14, current_position, play);
      play_square(6, current_position, play);
      play_square(24, current_position, play);
      play_square(32, current_position, play);
      play_square(9, current_position, play);
      play_square(0, current_position, play);
      play_square(4, current_position, play);
      play_square(3, current_position, play);
      play_square(34, current_position, play);
      play_square(52, current_position, play);
      play_square(60, current_position, play);
      play_square(43, current_position, play);
      play_square(62, current_position, play);
      play_square(51, current_position, play);
      play_square(59, current_position, play);
      play_square(58, current_position, play);
      play_square(50, current_position, play);
      play_square(63, current_position, play);
      play_square(55, current_position, play);
      play_square(47, current_position, play);
      play_square(39, current_position, play);
      play_square(57, current_position, play);
      play_square(49, current_position, play);
      play_square(41, current_position, play);
      play_square(48, current_position, play);
      play_square(42, current_position, play);
      play_square(8, current_position, play);
      play_square(56, current_position, play);
      play_square(23, current_position, play);
      play_square(13, current_position, play);
      play_square(7, current_position, play);
      play_square(15, current_position, play);
      
      -- check results
      assert false report "Finished complete game, now verifying that white won" severity note;
      check_multiple_squares(game_board, 0, 63, SPACE_WHITE);
      
      -- end
      assert false
         report "End of testbench, ended normally"
         severity failure;
      wait;
   end process;

END;
