library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signal_over_clocks is
	port (
		clk_in 			: in std_logic;
		clk_in_resetn 		: in std_logic;
		clk_out 		: in std_logic;
		clk_out_resetn 		: in std_logic;
		signal_in 		: in std_logic;
		signal_out 		: out std_logic
	);
end signal_over_clocks;

architecture signal_over_clocks_arch of signal_over_clocks is

signal sig_reg_in, sig_tmp_in : std_logic := '0';
signal sig_reg_out, sig_tmp_out : std_logic := '0';

begin

signal_out <= sig_reg_out;

process (clk_in) begin
	if (rising_edge(clk_in)) then
		if (clk_in_resetn = '0') then
			sig_reg_in <= '0';
		else
			sig_reg_in <= sig_tmp_in;
		end if; 
	end if;
end process;

process (clk_out) begin
	if (rising_edge(clk_out)) then
		if (clk_out_resetn = '0') then
			sig_reg_out <= '0';
		else
			sig_reg_out <= sig_tmp_out;
		end if;
	end if;
end process;

process(sig_reg_in, sig_reg_out, signal_in) begin
    
        sig_tmp_in <= sig_reg_in;
        sig_tmp_out <= sig_reg_out;
        
        if (signal_in = '1') then
            sig_tmp_in <= '1';
        end if;
        
        if (sig_reg_in = '1') then
            sig_tmp_out <= '1';
        end if;
        
        if (sig_reg_out = '1') then
            sig_tmp_in <= '0';
            sig_tmp_out <= '0';
       end if; 
end process;

end signal_over_clocks_arch;
