library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PUF is
    Port (
        clk:        in  std_logic;
        rst:        in  std_logic;
        en:         in  std_logic;
        challenge:  in  std_logic_vector(3 downto 0);   
        led:        out std_logic_vector(3 downto 0)    -- 4-bit count value
    );
end PUF;

architecture Behavioral of PUF is
    
    component ring_oscillator
        port(
            en: in  std_logic;
            RO_out: out std_logic
        );
    end component;
    
    component mux4to1
        port(
            a0, a1, a2, a3: in std_logic;
            sel: in std_logic_vector(1 downto 0);
            b: out std_logic
        );
    end component;
    
    -- Signals and constants
    signal ro_out_signal: std_logic_vector(7 downto 0);
    signal mux_out1_signal, mux_out2_signal: std_logic;
    signal counter_1, counter_2: unsigned(29 downto 0) := (others => '0');
    signal on_counter: unsigned(23 downto 0) := (others => '0');  -- Reduced size for faster measurement
    constant MEASUREMENT_CYCLES: unsigned(23 downto 0) := x"00FFFF"; -- Shorter measurement window
    
    signal measurement_done : std_logic := '0';
    signal result_latched : std_logic_vector(3 downto 0) := "0000";
    signal mux1_sync, mux2_sync : std_logic := '0';
    signal mux1_prev, mux2_prev : std_logic := '0';
    signal edge_detect1, edge_detect2 : std_logic := '0';
    
    -- Debug signals
    signal ro_active : std_logic := '0';
    signal edge_detected : std_logic := '0';
    
    -- attributes to preserve hierarchy and prevent synthesis optimization
    attribute dont_touch: string;
    attribute keep_hierarchy: string;
    
    attribute dont_touch of RO1, RO2, RO3, RO4, RO5, RO6, RO7, RO8: label is "true";
    attribute keep_hierarchy of RO1, RO2, RO3, RO4, RO5, RO6, RO7, RO8: label is "true";
    attribute dont_touch of mux1, mux2: label is "true";
    attribute keep_hierarchy of mux1, mux2: label is "true";
    
    attribute dont_touch of ro_out_signal, mux_out1_signal, mux_out2_signal: signal is "true";
    attribute dont_touch of counter_1, counter_2, on_counter: signal is "true";
   
begin

    RO1: ring_oscillator 
        port map (
            en => en,
            RO_out => ro_out_signal(0) 
        );
    RO2: ring_oscillator 
        port map (
            en => en,
            RO_out => ro_out_signal(1) 
        );
    RO3: ring_oscillator 
        port map (
            en => en,
            RO_out => ro_out_signal(2) 
        );
    RO4: ring_oscillator 
        port map (
            en => en,
            RO_out => ro_out_signal(3) 
        );
    RO5: ring_oscillator 
        port map (
            en => en,
            RO_out => ro_out_signal(4) 
        );
    RO6: ring_oscillator 
        port map (
            en => en,
            RO_out => ro_out_signal(5) 
        );
    RO7: ring_oscillator 
        port map (
            en => en,
            RO_out => ro_out_signal(6) 
        );
    RO8: ring_oscillator 
        port map (
            en => en,
            RO_out => ro_out_signal(7) 
        );

    mux1: mux4to1 
        port map (
            a0 => ro_out_signal(0),
            a1 => ro_out_signal(1),
            a2 => ro_out_signal(2),
            a3 => ro_out_signal(3),
            sel => challenge(1 downto 0), 
            b => mux_out1_signal       
        );
        
    mux2: mux4to1 
        port map (
            a0 => ro_out_signal(4),
            a1 => ro_out_signal(5),
            a2 => ro_out_signal(6),
            a3 => ro_out_signal(7),
            sel => challenge(3 downto 2), 
            b => mux_out2_signal       
        );        

    -- Synchronize RO signals to clock domain and detect edges
    process(clk)
    begin
        if rising_edge(clk) then
            mux1_prev <= mux_out1_signal;
            mux2_prev <= mux_out2_signal;
            mux1_sync <= mux1_prev;
            mux2_sync <= mux2_prev;
            
            -- Detect rising edges
            edge_detect1 <= mux1_sync and not mux1_prev;
            edge_detect2 <= mux2_sync and not mux2_prev;
            
            -- Debug signal to show RO activity
            if edge_detect1 = '1' or edge_detect2 = '1' then
                edge_detected <= '1';
            else
                edge_detected <= '0';
            end if;
        end if;
    end process;

    -- Main measurement process
    process(clk, rst)
    begin
        if rst = '1' then
            counter_1 <= (others => '0');
            counter_2 <= (others => '0');
            on_counter <= (others => '0');
            measurement_done <= '0';
            result_latched <= "0000";
            ro_active <= '0';
        elsif rising_edge(clk) then
            ro_active <= en;  -- Debug signal
            
            if en = '1' then
                if measurement_done = '0' then
                    -- Count RO edges
                    if edge_detect1 = '1' then
                        counter_1 <= counter_1 + 1;
                    end if;
                    
                    if edge_detect2 = '1' then
                        counter_2 <= counter_2 + 1;
                    end if;
                    
                    -- Increment measurement window counter
                    if on_counter < MEASUREMENT_CYCLES then
                        on_counter <= on_counter + 1;
                    else
                        -- Capture the 4 LSBs of counter_1
                        result_latched <= std_logic_vector(counter_1(3 downto 0));
                        measurement_done <= '1';
                    end if;
                end if;
            else
                -- Reset for new measurement
                counter_1 <= (others => '0');
                counter_2 <= (others => '0');
                on_counter <= (others => '0');
                measurement_done <= '0';
            end if;
        end if;
    end process;
     
    -- Continuous output
    led <= result_latched;
    
end Behavioral;