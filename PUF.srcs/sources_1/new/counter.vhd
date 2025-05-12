library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter_module is
    Port (
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        edge_detect: in std_logic;
        count_out: out unsigned(29 downto 0)
    );
end counter_module;

architecture Behavioral of counter_module is
    signal counter: unsigned(29 downto 0) := (others => '0');
    constant MAX_COUNT: unsigned(29 downto 0) := "000000111111111111111111111111";
    attribute dont_touch: string;
    attribute dont_touch of counter: signal is "true";
begin
    process(clk, rst)
    begin
        if rst = '1' then
            counter <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' and edge_detect = '1' and counter < MAX_COUNT then
                counter <= counter + 1;
            elsif en = '0' then
                counter <= (others => '0');
            end if;
        end if;
    end process;
    
    count_out <= counter;
end Behavioral;