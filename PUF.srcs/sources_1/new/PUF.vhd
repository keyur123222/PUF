library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PUF is
    Port (
        clk:        in  std_logic;
        rst:        in  std_logic;
        en:         in  std_logic;
        challenge:  in  std_logic_vector(3 downto 0);   
        led:        out std_logic_vector(1 downto 0)    -- response
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
    
    --signals and constants
    signal ro_out_signal: std_logic_vector(7 downto 0);
    signal mux_out1_signal, mux_out2_signal: std_logic;
    signal counter_1, counter_2: unsigned(29 downto 0):= (others => '0');
    signal on_counter: unsigned(31 downto 0):= (others => '0');
    constant MAX_COUNT: unsigned(29 downto 0):= "000000111111111111111111111111";
    
    
    
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
            a0    => ro_out_signal(0),
            a1    => ro_out_signal(1),
            a2    => ro_out_signal(2),
            a3    => ro_out_signal(3),
            sel   => challenge(1 downto 0), 
            b     => mux_out1_signal       
        );
    mux2: mux4to1 
        port map (
            a0    => ro_out_signal(4),
            a1    => ro_out_signal(5),
            a2    => ro_out_signal(6),
            a3    => ro_out_signal(7),
            sel   => challenge(3 downto 2), 
            b     => mux_out2_signal       
        );        
     
     process(mux_out1_signal, rst)
     begin
        if rst = '1' then
            counter_1 <= (others => '0');
        elsif rising_edge(mux_out1_signal) then 
            if counter_1 = (counter_1'range => '1') then
                counter_1 <= counter_1;
            else 
                counter_1 <= counter_1 + 1;
            end if;
        end if;
     end process;
     
     process(mux_out2_signal, rst)
     begin
        if rst = '1' then
            counter_2 <= (others => '0');
        elsif rising_edge(mux_out2_signal) then 
            if counter_2 = (counter_1'range => '1') then
                counter_2 <= counter_2;
            else 
                counter_2 <= counter_2 + 1;
            end if;
        end if;
     end process;
     
     process(clk, rst) 
     begin
        if rst = '1' then
            on_counter <= (others => '0');
        elsif rising_edge(clk) then
            if en = '0' then
                on_counter <= on_counter;
            elsif en = '1' then
                on_counter <= on_counter + 1;
            end if;
         end if;
     end process;
     
     process(mux_out1_signal, rst)
     begin
        if rst = '1' then
            led <= "11";
        elsif rising_edge(mux_out1_signal) then
            if counter_1 = MAX_COUNT then
                if counter_1 > counter_2 then
                    led <= "01";
                elsif counter_1 < counter_2 then
                    led <= "10";
                else 
                    led <= "00";
                end if;
             end if;
        end if;
     end process; 
     
    
end Behavioral;