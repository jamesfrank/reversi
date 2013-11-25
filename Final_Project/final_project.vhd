----------------------------------------------------------------------------------
-- FPGA Design Using VHDL
-- Final Project
--
-- Authors: Eric Beales &  James Frank
-- Date:    25-Nov-2013
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity final_project_top is port(
   clk50  : in  std_logic;
   reset  : in  std_logic;
   vga    : out std_logic_vector(7 downto 0);
   vga_hs : out std_logic;
   vga_vs : out std_logic );
end final_project_top;

architecture behavioral of final_project_top is
   -- Setup the vga-related variables.
   signal h_count : unsigned(9 downto 0);
   signal v_count : unsigned(9 downto 0); 
   signal vga_en : std_logic;

   -- Setup the game board arrays.
   type byte_array is array (integer range <>) of unsigned(7 downto 0);
   signal game_board : byte_array(63 downto 0);
   signal current_position : unsigned(5 downto 0); 
begin

   -- Setup a test current_position somewhere in the middle.
   current_position <= "100000";

   -- Setup a test game_board array.
   process(clk50,reset)
   begin
      if(reset = '1') then
         game_board <= (others => x"0F");

      elsif(rising_edge(clk50)) then
		   -- First row.
         game_board(0)  <= x"00";
         game_board(1)  <= x"01";
         game_board(2)  <= x"02";
         game_board(3)  <= x"03";
         game_board(4)  <= x"00";
         game_board(5)  <= x"01";
         game_board(6)  <= x"02";
         game_board(7)  <= x"03";
			
		   -- Last Row.
         game_board(56)  <= x"00";
         game_board(57)  <= x"01";
         game_board(58)  <= x"02";
         game_board(59)  <= x"03";
         game_board(60)  <= x"00";
         game_board(61)  <= x"01";
         game_board(62)  <= x"02";
         game_board(63)  <= x"03";
      end if;
   end process;

   -- Generate the VGA enable signal (25 MHz)
   process(clk50,reset)
   begin
      if(reset = '1') then
         vga_en <= '0';
      elsif(rising_edge(clk50)) then
         vga_en <= vga_en xor '1';
      end if;
   end process;
   
   -- Count across the horizontal and vertical lines.
   process(clk50, reset)
   begin
      if(reset = '1') then
         h_count <= (others => '0');
         v_count <= (others => '0');

      elsif(rising_edge(clk50)) then
         if(vga_en = '1') then
            if(h_count < x"31F") then
               h_count <= h_count + 1;
            else
               h_count <= (others => '0');
               if(v_count < x"208") then
                  v_count <= v_count + 1;
               else
                  v_count <= (others => '0');
               end if;
            end if;
         end if;
      end if;
   end process;
   
   -- Create Vsync and Hsync based on the vcount and hcount.
   vga_hs <= '0' when (h_count < x"60") else '1';
   vga_vs <= '0' when (v_count < x"02") else '1';

   -- Put out the pixel.
   process(h_count, v_count)
     variable hori_off : unsigned(5 downto 0);
     variable vert_off : unsigned(5 downto 0);
     variable block_num : unsigned(5 downto 0);
     variable display_enum : unsigned(3 downto 0);
     
   begin
      -- Put 0's for pixels outside the bounds.
      if((h_count < x"90") or (h_count >= x"310") or (v_count < x"1F") or (v_count >= x"1FF")) then
         vga <= x"00";

      else
         -- Calculate the horizontal block offset
         if(h_count > x"2C0") then
            hori_off := "000111";
         elsif(h_count > x"270") then
            hori_off := "000110";
         elsif(h_count > x"220") then
            hori_off := "000101";
         elsif(h_count > x"1D0") then
            hori_off := "000100";
         elsif(h_count > x"180") then
            hori_off := "000011";
         elsif(h_count > x"130") then
            hori_off := "000010";
         elsif(h_count > x"E0") then
            hori_off := "000001";
         else
            hori_off := "000000";
         end if;
      
         -- Calculate the vertical block offset
         if(v_count > x"1C3") then
            vert_off := "111000";
         elsif(v_count > x"187") then
            vert_off := "110000";
         elsif(v_count > x"14B") then
            vert_off := "101000";
         elsif(v_count > x"10F") then
            vert_off := "100000";
         elsif(v_count > x"D3") then
            vert_off := "011000";
         elsif(v_count > x"97") then
            vert_off := "010000";
         elsif(v_count > x"5B") then
            vert_off := "001000";
         else
            vert_off := "000000";
         end if;
         
         -- Combine the vertical and horizontal into the block number (between 0 & 63).
         block_num := vert_off + hori_off;
         
         -- Grab the enum from the game board based on the current position.
         if(current_position = block_num) then
            display_enum := game_board(to_integer(block_num))(7 downto 4);
         else 
            display_enum := game_board(to_integer(block_num))(3 downto 0);
         end if;
         
         -- Put out the right color based on the enum.
         case display_enum is
            when x"0"   => vga <= "00000111"; -- Red
            when x"1"   => vga <= "00111000"; -- Green
            when x"2"   => vga <= "11111111"; -- White
            when x"3"   => vga <= "00000000"; -- Black
            when others => vga <= "11000000"; -- Blue
         end case;
         
      end if;
   end process;

end Behavioral;