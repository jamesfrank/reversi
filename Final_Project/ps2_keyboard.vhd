library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ps2_keyboard is
    port (
        reset : in  std_logic;
        clk : in  std_logic;
        ps2_data : in  std_logic;
        ps2_clk : in  std_logic;
        available : out std_logic;
        out_byte : out std_logic_vector(7 downto 0)
    );
end ps2_keyboard;

architecture Behavioral of ps2_keyboard is
    signal st : std_logic;
    signal sh : std_logic;

    signal s1 : std_logic;
    signal s2 : std_logic;
    signal ps2_clk_fe : std_logic;

    signal shift9 : std_logic_vector(8 downto 0);
    signal error : std_logic;
    
begin
    EDGE : process (reset, clk)
    begin
        if reset = '1' then
            s1 <= '0';
            s2 <= '0';
            
        elsif rising_edge(clk) then
            s2 <= s1;
            s1 <= ps2_clk;
        end if;
    end process;

    ps2_clk_fe <= '1' when s1 = '0' and s2 = '1' else '0';

    SHIFT : process (reset, clk)
    begin
        if reset = '1' then
            shift9 <= "000000000";
        elsif rising_edge(clk) then
            if sh = '1' then
            shift9(7 downto 0) <= shift9(8 downto 1);
                shift9(8)          <= ps2_data;
            end if;
        end if;
    end process;

    OUTPUT : process (reset, clk)
    begin
    if reset = '1' then
            out_byte <= "00000000";
        elsif rising_edge(clk) then
            if st = '1' then
                out_byte <= shift9(7 downto 0);
            end if;
        end if;
    end process;
    
    -- error checking
    error <= not (shift9(0) xor shift9(1) xor shift9(2) xor shift9(3) xor shift9(4) xor
                     shift9(5) xor shift9(6) xor shift9(7) xor shift9(8));

    CONTROL : block
        type state_type is (
				idle, start, bit_1a, bit_1b, bit_2a, bit_2b,
            bit_3a, bit_3b, bit_4a, bit_4b, bit_5a, bit_5b,
				bit_6a, bit_6b, bit_7a, bit_7b, bit_8a, bit_8b,
				bit_9a, bit_9b, stop, store, notify
			);

        signal state : state_type;
        signal op    : std_logic_vector(2 downto 0);
    begin
        process (reset, clk)
        begin
            if reset = '1' then
                state <= idle;
            elsif rising_edge(clk) then
                case (state) is
                    
                    when idle =>
                        if ps2_clk_fe = '1' and ps2_data = '0' then
                            state <= start;
                        end if;
                        
                    when start =>
                        if ps2_clk_fe = '1' then
                            state <= bit_1a;
                        end if;
                        
                    when bit_1a => state                        <= bit_1b;
                    when bit_1b => if ps2_clk_fe = '1' then state <= bit_2a; end if;
                    when bit_2a => state                        <= bit_2b;
                    when bit_2b => if ps2_clk_fe = '1' then state <= bit_3a; end if;
                    when bit_3a => state                        <= bit_3b;
                    when bit_3b => if ps2_clk_fe = '1' then state <= bit_4a; end if;
                    when bit_4a => state                        <= bit_4b;
                    when bit_4b => if ps2_clk_fe = '1' then state <= bit_5a; end if;
                    when bit_5a => state                        <= bit_5b;
                    when bit_5b => if ps2_clk_fe = '1' then state <= bit_6a; end if;
                    when bit_6a => state                        <= bit_6b;
                    when bit_6b => if ps2_clk_fe = '1' then state <= bit_7a; end if;
                    when bit_7a => state                        <= bit_7b;
                    when bit_7b => if ps2_clk_fe = '1' then state <= bit_8a; end if;
                    when bit_8a => state                        <= bit_8b;
                    when bit_8b => if ps2_clk_fe = '1' then state <= bit_9a; end if;
                    when bit_9a => state                        <= bit_9b;
                    when bit_9b =>
                        if ps2_clk_fe = '1' then
                            if ps2_data = '1' then
                                state <= stop;
                            else
                                state <= idle;
                            end if;
                        end if;
                    when stop   =>
                        if error = '0' then
                            state <= store;
                        else
                            state <= idle;
                        end if;
                    when store  => state <= notify;
                    when notify => state <= idle;
                                                 
                end case;
            end if;
        end process;

        sh      <= op(2);
        st      <= op(1);
        available <= op(0);

        process (state)
        begin
            case state is
                when idle   => op <= "000";
                when start  => op <= "000";
                when bit_1a => op <= "100";
                when bit_1b => op <= "000";
                when bit_2a => op <= "100";
                when bit_2b => op <= "000";
                when bit_3a => op <= "100";
                when bit_3b => op <= "000";
                when bit_4a => op <= "100";
                when bit_4b => op <= "000";
                when bit_5a => op <= "100";
                when bit_5b => op <= "000";
                when bit_6a => op <= "100";
                when bit_6b => op <= "000";
                when bit_7a => op <= "100";
                when bit_7b => op <= "000";
                when bit_8a => op <= "100";
                when bit_8b => op <= "000";
                when bit_9a => op <= "100";
                when bit_9b => op <= "000";
                when stop   => op <= "000";
                when store  => op <= "010";
                when notify => op <= "001";
            end case;
        end process;
    end block CONTROL;
 
end Behavioral;