library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture arch_tb of tb is

component counter is
	generic (
		REG_WIDTH : integer := 32;
		INT_GEN_DELAY : integer := 100
	);
	port (
		clk		: in std_logic;
		resetn		: in std_logic;
		incr   		: in std_logic;
		get_val		: in std_logic;
		cnt_out		: out std_logic_vector(REG_WIDTH - 1 downto 0);
		interrupt   : out std_logic
	);
end component;


signal clk, resetn, incr, get_val, interrupt : std_logic := '0';
signal cnt_out : std_logic_vector(31 downto 0);
begin
counter_0 : counter
	generic map (REG_WIDTH => 32)
	port map (
		clk => clk,
		resetn => resetn,
		incr => incr,
		get_val => get_val,
		cnt_out => cnt_out,
		interrupt => interrupt
	);

process begin
	clk <= '0';
	wait for 5 ns;
	clk <= '1';
	wait for 5 ns;
end process;

process begin
	resetn <= '0';
	wait for 10 ns;
	resetn <= '1';
	wait;
end process;

process begin
    wait for 30 ns;
    incr <= '1';
    wait for 10 ns;
    incr <= '0';
end process;

process begin
	wait for 10 ns;
	wait for 100 ns;
	get_val <= '1';
	wait for 10 ns;
	get_val <= '0';
    wait for 200 ns;
    get_val <= '1';
    wait for 40 ns;
    get_val <= '0';
end process;

end arch_tb;
