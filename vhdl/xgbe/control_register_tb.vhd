library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture tb_arch of tb is
component control_register is
	generic (
		DATA_WIDTH : integer := 32
	);

	port (
		clk 		: in std_logic;
		clk_resetn 	: in std_logic;
		reg_input 	: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		reg_strb 	: in std_logic;
		rcv_en		: out std_logic
	);
end component;

signal clk, clk_resetn, reg_strb, rcv_en : std_logic := '0';
signal reg_input : std_logic_vector(31 downto 0);

begin

control_reg_0 : control_register 
generic map (DATA_WIDTH => 32)
port map (
	clk => clk,
	clk_resetn => clk_resetn,
	reg_input => reg_input,
	reg_strb => reg_strb,
	rcv_en => rcv_en
);

process begin
	clk <= '0';
wait for 5 ns;
	clk <= '1';
wait for 5 ns;
end process;

process begin
	clk_resetn <= '0';
wait for 10 ns;
	clk_resetn <= '1';
wait for 20 ns;
	reg_input <= x"00ff00ff";
	reg_strb <= '1';
wait for 10 ns;
	reg_input <= x"ff00ff00";
	reg_strb <= '0';
wait for 10 ns;
	reg_strb <= '1';
wait for 10 ns;
	reg_strb <= '0';
wait;
end process;

end tb_arch;
