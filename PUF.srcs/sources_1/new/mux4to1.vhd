library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity mux4to1 is
  Port ( 
        a0, a1, a2, a3: in std_logic;
        sel: in std_logic_vector(1 downto 0);
        b: out std_logic
  );
end mux4to1;

architecture Behavioral of mux4to1 is

begin
    process_mux: process(a0, a1, a2, a3, sel)
    begin
        case sel is
        when "00" => b <= a0;
        when "01" => b <= a1;
        when "10" => b <= a2;
        when "11" => b <= a3;
        when others => b <= '0'; 
        end case;    
    end process;
end Behavioral;
