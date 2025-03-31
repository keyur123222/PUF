library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PUF_tb is
end PUF_tb;

architecture Behavioral of PUF_tb is
    -- Component declaration for the PUF
    component PUF
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               enable : in STD_LOGIC;
               challenge : in STD_LOGIC_VECTOR(3 downto 0);
               puf_key : out STD_LOGIC_VECTOR(1 downto 0));
    end component;

    -- Signals for the test bench
    signal clk_tb : STD_LOGIC := '0';
    signal rst_tb : STD_LOGIC := '0';
    signal enable_tb : STD_LOGIC := '0';
    signal challenge_tb : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal puf_key_tb : STD_LOGIC_VECTOR(1 downto 0);

    -- Clock generation
    constant clk_period : time := 10 ns;
begin
    -- Instantiate the PUF
    uut: PUF port map (
        clk => clk_tb,
        rst => rst_tb,
        enable => enable_tb,
        challenge => challenge_tb,
        puf_key => puf_key_tb
    );

    -- Clock process
    clk_process : process
    begin
        clk_tb <= '0';
        wait for clk_period / 2;
        clk_tb <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset the system
        rst_tb <= '1';
        wait for 20 ns;
        rst_tb <= '0';

        -- Apply test vectors
        enable_tb <= '1';
        challenge_tb <= "0001";
        wait for 100 ns;

        challenge_tb <= "0010";
        wait for 100 ns;

        challenge_tb <= "0100";
        wait for 100 ns;

        challenge_tb <= "1000";
        wait for 100 ns;

        -- End simulation
        wait;
    end process;
end Behavioral;