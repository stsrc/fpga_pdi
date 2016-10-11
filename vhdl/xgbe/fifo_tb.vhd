library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture tb_arch of tb is

component fifo is
	generic (
		DATA_WIDTH : integer := 32;
		DATA_HEIGHT : integer := 10
	);
	port (
		clk_in		: in std_logic;
		clk_in_resetn	: in std_logic;
		clk_out		: in std_logic;
		clk_out_resetn  : in std_logic;
		data_in		: in std_logic_vector(31 downto 0);
		data_out	: out std_logic_vector(31 downto 0);
		strb_in		: in std_logic;
		strb_out	: in std_logic;
		drop_in		: in std_logic;
		is_full_clk_in	: out std_logic
	);
end component;
	signal clk_in_resetn, strb_in, strb_out : std_logic := '0';
	signal clk_out_resetn, clk_in, clk_out, drop_in : std_logic := '0';
	signal data_in, data_out : std_logic_vector(31 downto 0);
	signal is_full_clk_in : std_logic := '0';
    


begin
	fifo_1 : fifo 
	generic map (DATA_WIDTH => 32, DATA_HEIGHT => 4)
	port map (clk_in => clk_in, clk_in_resetn => clk_in_resetn,
	clk_out => clk_out, clk_out_resetn => clk_out_resetn, data_in => data_in, 
	data_out => data_out, strb_in => strb_in, strb_out => strb_out,
	drop_in => drop_in, is_full_clk_in => is_full_clk_in
	);


	process begin
		clk_in <= '1';
		wait for 5 ns;
		clk_in <= '0';
		wait for 5 ns;
	end process;

	process begin
		clk_out <= '1';
		wait for 3.2 ns;
		clk_out <= '0';
		wait for 3.2 ns;
	end process;

	process begin
		clk_in_resetn <= '0';
		clk_out_resetn <= '0';
		wait for 10 ns;
		clk_in_resetn <= '1';
		clk_out_resetn <= '1';
		strb_in <= '1';
		for i in 1 to 5 loop
			data_in <= std_logic_vector(to_unsigned(i, 32));
			wait for 10 ns; 
		end loop;
		wait until is_full_clk_in = '1';
		strb_in <= '0';
		wait for 10 ns;
		strb_in <= '1';
		wait for 40 ns;
		drop_in <= '1';
		wait for 10 ns;
		strb_in <= '0';
		drop_in <= '0';
		wait for 10 ns;
		strb_in <= '1';
		for i in 32 to 36 loop
			data_in <= std_logic_vector(to_unsigned(i, 32));
			wait for 10 ns; 
		end loop;
		strb_in <= '0';
		strb_out <= '1';
		wait for 40 ns;
		strb_out <= '0';
		wait;
	end process;
end tb_arch;
