library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tb is
end tb;

architecture tb_arch of tb is
component flagn_over_clocks is
	port (
		clk_in 			: in std_logic;
		clk_in_resetn 		: in std_logic;
		clk_out 		: in std_logic;
		clk_out_resetn 		: in std_logic;
		flagn_in 		: in std_logic;
		flagn_out 		: out std_logic
	);
end component flagn_over_clocks;
	signal clk_in, clk_out, clk_in_resetn : std_logic := '0';
	signal clk_out_resetn, flagn_in, flagn_out : std_logic := '0';
begin

flagn_over_clocks_0 : flagn_over_clocks
port map (
    clk_in => clk_in,
    clk_in_resetn => clk_in_resetn,
    clk_out => clk_out,
    clk_out_resetn => clk_out_resetn,
    flagn_in => flagn_in,
    flagn_out => flagn_out
);

process begin
	clk_in <= '1';
	wait for 3.2 ns;
	clk_in <= '0';
	wait for 3.2 ns;
end process;

process begin
	clk_out <= '0';
	wait for 5 ns;
	clk_out <= '1';
	wait for 5 ns;
end process;

process begin
	flagn_in <= '1';
	clk_in_resetn <= '0';
	clk_out_resetn <= '0';
	wait for 10 ns;
	clk_in_resetn <= '1';
	clk_out_resetn <= '1';
	wait for 10 ns;
	flagn_in <= '0';
	wait for 10 ns;
	flagn_in <= '1';
	wait for 100 ns;
	flagn_in <= '0';
	wait for 100 ns;
	flagn_in <= '1';
	wait;
end process;
end tb_arch;



