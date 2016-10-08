-- This block is used to transmit i.e. eop_strb or packet_strb signal through 
-- different clock domains.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bit_over_clocks is
	port (
		clk_in 			: in std_logic;
		clk_in_resetn 		: in std_logic;
		clk_out 		: in std_logic;
		clk_out_resetn 		: in std_logic;
		bit_in 			: in std_logic;
		bit_out 		: out std_logic
	);
end bit_over_clocks;

architecture bit_over_clocks_arch of bit_over_clocks is

signal sig_reg_out : std_logic_vector(2 downto 0) := (others => '0');

begin

bit_out <= sig_reg_out(1);

process (clk_out) begin
	if (rising_edge(clk_out)) then
		if (clk_out_resetn = '0') then
			sig_reg_out <= (others => '0');
		else
			sig_reg_out(0) <= bit_in;
			sig_reg_out(1) <= sig_reg_out(0);
		end if;
	end if;
end process;


end bit_over_clocks_arch;
