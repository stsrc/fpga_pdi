-- This block is used to transmit i.e. eop_strb or packet_strb signal through 
-- different clock domains.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity flagn_over_clocks is
	port (
		clk_in 			: in std_logic;
		clk_in_resetn 		: in std_logic;
		clk_out 		: in std_logic;
		clk_out_resetn 		: in std_logic;
		flagn_in 		: in std_logic;
		flagn_out 		: out std_logic
	);
end flagn_over_clocks;

architecture flagn_over_clocks_arch of flagn_over_clocks is

signal sig_reg_in : std_logic;
signal sig_reg_out : std_logic_vector(2 downto 0);

begin

process (clk_in) begin
	if (rising_edge(clk_in)) then
		if (clk_in_resetn = '0') then
			sig_reg_in <= '0';
		else
			sig_reg_in <= not(flagn_in) xor sig_reg_in;
		end if;
	end if; 

end process;

process (clk_out) begin
	if (rising_edge(clk_out)) then
		if (clk_out_resetn = '0') then
			sig_reg_out <= (others => '0');
		else
			sig_reg_out <= sig_reg_out(1 downto 0) & sig_reg_in;
		end if;
	end if;

end process;

flagn_out <= not(sig_reg_out(2) xor sig_reg_out(1));

end flagn_over_clocks_arch;
