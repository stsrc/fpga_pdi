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
	signal clk_in_resetn, strb_in, strb_out, last_in : std_logic := '0';
	signal clk_out_resetn, clk_in, clk_out, drop_in : std_logic := '0';
	signal data_in, data_out : std_logic_vector(31 downto 0);
	signal is_full_clk_in : std_logic := '0';
    


begin
	fifo_1 : fifo 
	generic map (DATA_WIDTH => 32, DATA_HEIGHT => 10)
	port map (clk_in => clk_in, clk_in_resetn => clk_in_resetn,
	clk_out => clk_out, clk_out_resetn => clk_out_resetn, data_in => data_in, 
	data_out => data_out, strb_in => strb_in, strb_out => strb_out,
	drop_in => drop_in, is_full_clk_in => is_full_clk_in
	);


	process begin
		clk_in <= '0';
		wait for 5 ns;
		clk_in <= '1';
		wait for 5 ns;
	end process;

	process begin
		clk_out <= '0';
		wait for 5 ns;
		clk_out <= '1';
		wait for 5 ns;
	end process;

	process begin
	    clk_in_resetn <= '0';
	    clk_out_resetn <= '0';
	    wait for 10 ns;
	    clk_in_resetn <= '1';
	    clk_out_resetn <= '1';
	    data_in <= std_logic_vector(to_unsigned(100, 32));
	    strb_in <= '1';
	    wait for 10 ns; 
	    data_in <= std_logic_vector(to_unsigned(101, 32));
	    strb_in <= '1';
	    wait for 10 ns; 
	    strb_in <= '0';
	    wait for 10 ns; 
	    data_in <= std_logic_vector(to_unsigned(200, 32));
            strb_in <= '1';
	    wait for 10 ns;
	    data_in <= std_logic_vector(to_unsigned(201, 32));
            strb_in <= '1';
            wait for 10 ns;
            drop_in <= '0';
            strb_in <= '0';
            wait for 10 ns; 
            strb_out <= '1';
            wait for 10 ns;
            strb_out <= '0';
            wait for 10 ns; 
            strb_out <= '1';
            wait for 10 ns; 
			  
            wait for 10 ns; 

	    strb_out <= '0';
	    wait for 20 ns;
	    data_in <= std_logic_vector(to_unsigned(1024, 32));
	    strb_in <= '1';
	    wait until is_full_clk_in = '1';
	    strb_in <= '0';
	    wait;
	end process;
end tb_arch;
