----------------------------------------------------------------------------------
-- FPGA Design Using VHDL
-- Final Project
--
-- Authors: Eric Beales &  James Frank
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

package final_project_package is

	-- Game board type def
	type byte_array is array (integer range <>) of unsigned(7 downto 0);
	
	-- Square color values (must match picoblaze code)
	constant SPACE_WHITE : unsigned(3 downto 0) := x"2";
	constant SPACE_BLACK : unsigned(3 downto 0) := x"3";

end final_project_package;

package body final_project_package is

end final_project_package;
