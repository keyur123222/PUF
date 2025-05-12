-- Comparator Module
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity comparator_module is
    Port (
        counter_1: in unsigned(29 downto 0);
        counter_2: in unsigned(29 downto 0);
        led: out std_logic_vector(1 downto 0)
    );
end comparator_module;

architecture Behavioral of comparator_module is
    attribute dont_touch: string;
    signal result: std_logic_vector(1 downto 0) := "00";
    attribute dont_touch of result: signal is "true";
begin
    process(counter_1, counter_2)
    begin
        if counter_1 > counter_2 then
            result <= "01";
        else
            result <= "10";
        end if;
    end process;
    
    led <= result;
end Behavioral;
