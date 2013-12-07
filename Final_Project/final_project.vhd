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

entity final_project_top is port(
   clk50    : in  std_logic;
   button   : in  std_logic_vector(3 downto 0);
   ps2_data : in  std_logic;
   ps2_clk  : in  std_logic;
   vga      : out std_logic_vector(7 downto 0);
   vga_hs   : out std_logic;
   vga_vs   : out std_logic );
end final_project_top;

architecture behavioral of final_project_top is

   -- Declare keyboard constants.
   constant ARROW_U   : std_logic_vector(7 downto 0) := x"75";
   constant ARROW_R   : std_logic_vector(7 downto 0) := x"74";
   constant ARROW_D   : std_logic_vector(7 downto 0) := x"72";
   constant ARROW_L   : std_logic_vector(7 downto 0) := x"6B";
   constant ENTER     : std_logic_vector(7 downto 0) := x"5A";

   alias reset : std_logic is button(3);

   -- Counters for debouncing each button.
   signal clk_counter    : unsigned(19 downto 0);
   signal ten_ms_en      : std_logic;
   signal button_0_count : unsigned(2 downto 0);
   signal button_2_count : unsigned(2 downto 0);
   signal button_1_count : unsigned(2 downto 0);

   -- Setup the vga-related variables.
   signal h_count : unsigned(9 downto 0);
   signal v_count : unsigned(9 downto 0); 
   signal vga_en  : std_logic;

   -- Setup the game board arrays.
   type byte_array is array (integer range <>) of unsigned(7 downto 0);
   signal game_board : byte_array(63 downto 0);
   signal current_position : unsigned(5 downto 0);

   -- Signals between the picoblaze and it's rom.
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

   -- Pico-blaze output handling code.
   process(clk50,reset)
   begin
      if(reset = '1') then
         game_board <= (others => x"10");
      elsif(rising_edge(clk50)) then
         if (write_strobe_signal = '1') then
            if (port_id_signal(7 downto 6) = "00") then -- 00xxxxxx will change the game board
               game_board(to_integer(unsigned(port_id_signal(5 downto 0)))) <= unsigned(out_port_signal);
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

   -- Generate the VGA enable signal (25 MHz)
   process(clk50,reset)
      variable keyup : std_logic := '0';
   begin
      if(reset = '1') then
         current_position <= (others => '0');
         interrupt_signal <= '0';
         button_0_count <= (others => '0');
         button_1_count <= (others => '0');
         button_2_count <= (others => '0');
         keyup := '0';

      elsif(rising_edge(clk50)) then
         -- Handle keyboard input if available
         if( keyboard_data_available = '1' ) then
            -- Ignore repeated keys
            if( keyboard_data_out = x"E0" ) then
               -- Beginning of BREAK code, prepare to ignore next input
               keyup := '1';
            elsif( keyup = '1' ) then
               -- This is a BREAK code, so ignore it
               keyup := '0';

            -- Handle navigational keys
            elsif( keyboard_data_out = ARROW_R ) then
               current_position <= current_position + 1;
            elsif( keyboard_data_out = ARROW_L ) then
               current_position <= current_position - 1;
            elsif( keyboard_data_out = ARROW_D ) then
               current_position <= current_position + 8;
            elsif( keyboard_data_out = ARROW_U ) then
               current_position <= current_position - 8;

            -- Handle play keys
            elsif( keyboard_data_out = ENTER ) then
               interrupt_signal <= '1';
            end if;
         end if;

         if( ten_ms_en = '1' ) then

            -- Handle button 0 (increment current position)
            if(button(0) = '0') then
               button_0_count <= (others => '0');
            elsif( button_0_count = "100") then
               current_position <= current_position + 1;
               button_0_count <= (others => '1');
            elsif( button_0_count /= "111") then
               button_0_count <= button_0_count + 1;
            end if;
            
            -- Handle button 1 (decrement current position)
            if(button(1) = '0') then
               button_1_count <= (others => '0');
            elsif( button_1_count = x"4") then
               current_position <= current_position - 1;
               button_1_count <= (others => '1');
            elsif( button_1_count /= "111") then
               button_1_count <= button_1_count + 1;
            end if;

            -- Handle button 2 (Play - Interrupt Picoblaze)
            if(button(2) = '0') then
               button_2_count <= (others => '0');
            elsif( button_2_count = x"4") then
               interrupt_signal <= '1';
               button_2_count <= (others => '1');
            elsif( button_2_count /= "111") then
               button_2_count <= button_2_count + 1;
            end if;

         end if;

         -- Clear the interrupt signal if we see an 'ack'
         if interrupt_ack_signal  = '1' then
            interrupt_signal <= '0';
         end if;

      end if;
   end process;

   -- 10 milliseconds clock scaler code.
   process(clk50, reset)
   begin
      if reset = '1' then -- Reset
         clk_counter <= (others => '0');
         ten_ms_en   <= '0';

      elsif rising_edge(clk50) then
         ten_ms_en <= '0';
         clk_counter <= clk_counter + 1;
         if clk_counter = 500000 then
            ten_ms_en <= '1';
            clk_counter <= (others => '0');
         end if;
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
   process(h_count, v_count, current_position)
     variable hori_off     : unsigned(5 downto 0);
     variable vert_off     : unsigned(5 downto 0);
     variable block_number : unsigned(5 downto 0);
     variable display_enum : unsigned(3 downto 0);
     
   begin
      -- Put blank for pixels outside the bounds.
      if((h_count  < x"090") or (h_count >= x"310") or
         (v_count  < x"01F") or (v_count >= x"1FF")) then
         vga <= x"00";

      -- Adding a blue single pixel border around the spaces.
      elsif( h_count = x"2C0" or v_count = x"1C3" or
             h_count = x"270" or v_count = x"187" or
             h_count = x"220" or v_count = x"14B" or
             h_count = x"1D0" or v_count = x"10F" or
             h_count = x"180" or v_count = x"0D3" or
             h_count = x"130" or v_count = x"097" or
             h_count = x"0E0" or v_count = x"05B" ) then
         vga <= "11000000";

      else
         -- Calculate the horizontal block offset
         if   (h_count > x"2C0") then hori_off := "000111";
         elsif(h_count > x"270") then hori_off := "000110";
         elsif(h_count > x"220") then hori_off := "000101";
         elsif(h_count > x"1D0") then hori_off := "000100";
         elsif(h_count > x"180") then hori_off := "000011";
         elsif(h_count > x"130") then hori_off := "000010";
         elsif(h_count > x"0E0") then hori_off := "000001";
         else                         hori_off := "000000";
         end if;

         -- Calculate the vertical block offset
         if   (v_count > x"1C3") then vert_off := "111000";
         elsif(v_count > x"187") then vert_off := "110000";
         elsif(v_count > x"14B") then vert_off := "101000";
         elsif(v_count > x"10F") then vert_off := "100000";
         elsif(v_count > x"0D3") then vert_off := "011000";
         elsif(v_count > x"097") then vert_off := "010000";
         elsif(v_count > x"05B") then vert_off := "001000";
         else                         vert_off := "000000";
         end if;

         -- Combine the vertical and horizontal into the block number (between 0 & 63).
         block_number := vert_off + hori_off;
         
         -- Grab the enum from the game board based on the current position.
         if (current_position = block_number) then
            display_enum := game_board(to_integer(block_number))(7 downto 4);
         else 
            display_enum := game_board(to_integer(block_number))(3 downto 0);
         end if;

         -- Put out the right color based on the enum.
         case display_enum is
            when x"0"   => vga <= "00000111"; -- Red (No Play)
            when x"1"   => vga <= "00100000"; -- Green (Board)
            when x"2"   => vga <= "11111111"; -- White
            when x"3"   => vga <= "00000000"; -- Black
            when x"4"   => vga <= "11110111"; -- Light Pink (White Can Play)
            when x"5"   => vga <= "00000001"; -- Dark Pink (Black Can Play)
            when others => vga <= "11000000"; -- Blue
         end case;
      end if;
   end process;

   -- Declaration for the picoblaze.
   processor: entity kcpsm3
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
             clk => clk50 );

   -- Declaration for the picoblaze's rom.
   program: entity finpropb
   port map( address => address_signal,
             instruction => instruction_signal,
             clk => clk50 );

   -- Keyboard interface
   keyboard : entity ps2_keyboard 
      port map( reset => reset,
                clk => clk50,
                ps2_data => ps2_data,
                ps2_clk => ps2_clk,
                available => keyboard_data_available,
                out_byte => keyboard_data_out );

end Behavioral;