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
		rst		    : in std_logic;
		clk_in		: in std_logic;
		clk_out		: in std_logic;
		data_in		: in std_logic_vector(31 downto 0);
		data_out	: out std_logic_vector(31 downto 0);
		strb_in		: in std_logic;
		strb_out	: in std_logic;
		drop_in     : in std_logic
	);
end component;
	signal rst, strb_in, strb_out, last_in, clk_in, clk_out, drop_in : std_logic := '0';
    signal data_in, data_out : std_logic_vector(31 downto 0);


begin
	fifo_1 : fifo 
	generic map (DATA_WIDTH => 32, DATA_HEIGHT => 10)
	port map (rst => rst, clk_in => clk_in, clk_out => clk_out, 
	data_in => data_in, data_out => data_out,  
	strb_in => strb_in, strb_out => strb_out, drop_in => drop_in);


	process begin
		clk_in <= '0';
		wait for 5 ns;
		clk_in <= '1';
		wait for 5 ns;
	end process;

	process begin
		clk_out <= '1';
		wait for 5 ns;
		clk_out <= '0';
		wait for 5 ns;
	end process;

	process begin
	    rst <= '0';
	    wait for 10 ns;
	    rst <= '1';
		data_in <= std_logic_vector(to_unsigned(100, 32));
		strb_in <= '1';
		wait for 10 ns; -- data_out == 100
		data_in <= std_logic_vector(to_unsigned(101, 32));
		strb_in <= '1';
		wait for 10 ns; -- data_out == 100
		strb_in <= '0';
		wait for 10 ns; -- data_out == 100
        data_in <= std_logic_vector(to_unsigned(200, 32));
        strb_in <= '1';
		wait for 10 ns; -- data_out == 100
		data_in <= std_logic_vector(to_unsigned(201, 32));
        strb_in <= '1';
        drop_in <= '1';
        wait for 10 ns; -- data_out == 100
        drop_in <= '0';
        strb_in <= '0';
        wait for 10 ns; -- data_out == 100
        strb_out <= '1';
        wait for 10 ns; -- data_out == 101 <- clk_out rises and output looks like this.
        strb_out <= '0';
        wait for 10 ns; -- data_out == 101 <- clk_out rises and output looks like this.
        strb_out <= '1';
        wait for 10 ns; -- data_out == 200 <- clk_out rises and output looks like this if drop_in was 0, xx if drop_in was 1.
        wait for 10 ns; -- data_out == 201 <- clk_out rises and output looks like this if drop_in was 0, xx if drop_in was 1.
        wait for 10 ns; -- data_out == 0 <- clk_out rises and output looks like this.
        strb_out <= '0';
		wait;
	end process;
end tb_arch;
