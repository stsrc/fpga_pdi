library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reset_con is
	port (
		clk		: in std_logic;
		resetn_1	: in std_logic;
		resetn_2	: in std_logic;
		out_resetn	: out std_logic
	);
end reset_con;

architecture reset_con_arch of reset_con is
begin
	process (clk) begin
		if (rising_edge(clk)) then
			out_resetn <= resetn_1 and resetn_2;
		end if;
	end process;
end reset_con_arch;
