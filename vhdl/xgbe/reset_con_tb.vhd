library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is

end;

architecture tb_arch of tb is
component reset_con is
	port (
		clk		: in std_logic;
		resetn_1	: in std_logic;
		resetn_2	: in std_logic;
		out_resetn	: out std_logic
	);
end component reset_con;
signal clk, resetn_1, resetn_2, out_resetn : std_logic := '1';
begin

reset_con_0 : reset_con
port map (
    clk => clk,
    resetn_1 => resetn_1,
    resetn_2 => resetn_2,
    out_resetn => out_resetn
);

process begin
	clk <= '0';
	wait for 5 ns;
	clk <= '1';
	wait for 5 ns;
end process;

process begin
	resetn_1 <= '1';
	resetn_2 <= '1';
	wait for 10 ns;
	resetn_1 <= '0';
	wait for 10 ns;
	resetn_2 <= '0';
	wait for 10 ns;
	resetn_1 <= '1';
	wait;
end process;
end tb_arch;
