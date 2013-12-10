----------------------------------------------------------------------------------
-- FPGA Design Using VHDL
-- Final Project
--
-- Authors: Eric Beales &  James Frank
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
USE work.std_logic_1164_additions.ALL;
use ieee.numeric_std.all;
use work.final_project_lib.all;

package final_project_test_package is
	
	procedure check_square (
		game_board : byte_array(63 downto 0);
		square : integer;
		value : unsigned(3 downto 0)
	);

end final_project_test_package;

package body final_project_test_package is

	-- This procedure checks the given square for the given value.
	procedure check_square (
		game_board : byte_array(63 downto 0);
		square : integer;
		value : unsigned(3 downto 0)
	) is 
		
	begin
		assert game_board(square) = resize(value,8)
			report 
				"Square " & integer'image(square) & " was " & to_string(std_logic_vector(game_board(square))) & 
				" but expected " & to_string(std_logic_vector(resize(value,8)))
			severity error;
	end check_square;
 
end final_project_test_package;
