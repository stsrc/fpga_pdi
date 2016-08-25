library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture tb_arch of tb is

component fifo is
	
	port (
		rst		    : in std_logic;
		clk_in		: in std_logic;
		clk_out		: in std_logic;
		data_in		: in std_logic_vector(31 downto 0);
		data_out	: out std_logic_vector(31 downto 0);
		cnt_out		: out std_logic_vector(9 downto 0);
		strb_in		: in std_logic;
		strb_out	: in std_logic
	);
end component;
	signal rst, strb_in, strb_out, last_in, clk_in, clk_out : std_logic := '0';
        signal data_in, data_out : std_logic_vector(31 downto 0);
	signal cnt_out : std_logic_vector(9 downto 0);       

begin
	fifo_1 : fifo port map (rst => rst, clk_in => clk_in, clk_out => clk_out, 
	data_in => data_in, data_out => data_out, cnt_out => cnt_out, 
	strb_in => strb_in, strb_out => strb_out);


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
		rst <= '0';
		wait for 15 ns;
		rst <= '1';
		data_in <= std_logic_vector(to_unsigned(100, 32));
		strb_in <= '1';
		wait for 10 ns; --cnt_out == 1, data_out == 100
		data_in <= std_logic_vector(to_unsigned(101, 32));
		strb_in <= '1';
		wait for 10 ns; --cnt_out == 2, data_out == 100
		strb_in <= '0';
		wait for 10 ns;
        data_in <= std_logic_vector(to_unsigned(200, 32));
        strb_in <= '1';
		wait for 10 ns; --cnt_out == 2, data_out == 100
        strb_in <= '0';
        wait for 10 ns;
        strb_out <= '1';
        wait for 10 ns; --cnt_out == 1, data_out == 101
        wait for 10 ns; --cnt_out == 1, data_out == 200
        wait for 30 ns; --cnt_out == xx, data_out == xx
        strb_out <= '0';
		wait;
	end process;
end tb_arch;
