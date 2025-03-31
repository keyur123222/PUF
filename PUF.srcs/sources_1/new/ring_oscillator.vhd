library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ring_oscillator is
  Port ( 
     en: in std_logic;
     RO_out: out std_logic
  );
end ring_oscillator;

architecture Behavioral of ring_oscillator is
    signal w1, w2, w3, w4, w5, w6, w7, w8: std_logic;
    signal feedback: std_logic;
    
    attribute dont_touch: string;
    attribute dont_touch of w1, w2, w3, w4, w5, w6, w7, w8: signal is "true";
     
begin
    
    w1 <= en and feedback;
    w2 <= not w1;
    w3 <= not w2;
    w4 <= not w3;
    w5 <= not w4;
    w6 <= not w5;
    w7 <= not w6;
    w8 <= not w7;
    feedback <= w8;
    RO_out <= w8;
       
end Behavioral;
