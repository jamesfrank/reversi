----------------------------------------------------------------------------------
-- FPGA Design Using VHDL
-- Final Project
--
-- Authors: Eric Beales & James Frank
--
-- Description: This package contains constants and procedures used for testing.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
USE work.std_logic_1164_additions.ALL;
use ieee.numeric_std.all;
use work.final_project_package.all;

package final_project_test_package is

    -- Clock period definitions
    constant clk_period : time := 20 ns; -- 50 MHz
    constant process_period : time := 400 us; -- Wait for processing between operations
    
    procedure check_square (
        game_board : byte_array(63 downto 0);
        square : integer;
        value : unsigned(3 downto 0)
    );
    
    procedure check_multiple_squares (
        game_board : byte_array(63 downto 0);
        start_square : integer;
        end_square : integer;
        value : unsigned(3 downto 0)
    );
   
    procedure play_square (
        square : integer;
        signal current_position : out unsigned(5 downto 0);
        signal play : out std_logic
    );

end final_project_test_package;

package body final_project_test_package is

    -- This procedure checks the given square for the given value.
    -- Mismatch will raise an error.
    procedure check_square (
        game_board : byte_array(63 downto 0);
        square : integer;
        value : unsigned(3 downto 0)
    ) is 
    begin
        assert (game_board(square) and x"0F") = resize(value,8) -- square upper nibble indicates "can play" status; ignore it
            report 
                "Square " & integer'image(square) & " was " & to_string(std_logic_vector(game_board(square))) & 
                " but expected " & to_string(std_logic_vector(resize(value,8)))
            severity error;
    end check_square;
    
    -- This procedure checks all squares from start_squre to end_square for given value.
    -- Mismatches will raise errors.
    procedure check_multiple_squares (
        game_board : byte_array(63 downto 0);
        start_square : integer;
        end_square : integer;
        value : unsigned(3 downto 0)
    ) is
        variable square : integer;
    begin
        square := start_square;
        while square <= end_square loop
            check_square(game_board, square, value);
            square := square + 1;
        end loop;
    end check_multiple_squares;
   
   -- Plays on the given square.
   procedure play_square (
        square : integer;
        signal current_position : out unsigned(5 downto 0);
        signal play : out std_logic
    ) is
   begin
      current_position <= to_unsigned(square,6);
      wait for clk_period;
      play <= '1';
      wait for clk_period*2;
      play <= '0';
      wait for process_period;
   end play_square;
 
end final_project_test_package;
