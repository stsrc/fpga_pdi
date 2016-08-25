library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture tb_arch of tb is

component fifo is
	generic (
		DATA_WIDTH	: integer := 32;
		HEIGHT		: integer := 8192;
		HEIGHT_LOG_2	: integer := 13
	);
	port (
		rst		: in std_logic;
		data_in		: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		data_out	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
		cnt_out		: out std_logic_vector(HEIGHT_LOG_2 - 1 downto 0);
		strb_in		: in std_logic;
		strb_out	: in std_logic;
		last_in		: in std_logic
	);
end component;
	signal rst, strb_in, strb_out, last_in : std_logic := '0';
        signal data_in, data_out : std_logic_vector(31 downto 0);
	signal cnt_out : std_logic_vector(12 downto 0);       

begin
	fifo_1 : fifo port map (rst => rst, data_in => data_in, data_out => data_out, cnt_out => cnt_out, 
	strb_in => strb_in, strb_out => strb_out, last_in => last_in);

	process begin
		rst <= '0';
		wait for 5 ns;
		rst <= '1';
		data_in <= std_logic_vector(to_unsigned(100, 32));
		last_in <= '0';
		strb_in <= '1';
		wait for 5 ns; --cnt_out == 0, data_out == 100
		strb_in <= '0';
		data_in <= std_logic_vector(to_unsigned(101, 32));
		wait for 5 ns; 
		strb_in <= '1';
		wait for 5 ns; --cnt_out == 0, data_out == 100
		strb_in <= '0';
		data_in <= std_logic_vector(to_unsigned(102, 32));
		wait for 5 ns; 
		strb_in <= '1';
		wait for 5 ns; --cnt_out == 0, data_out == 100
		strb_in <= '0';
		data_in <= std_logic_vector(to_unsigned(103, 32));
		wait for 5 ns; 
		strb_in <= '1';
		wait for 5 ns; --cnt_out == 0, data_out == 100
		strb_in <= '0';
		data_in <= std_logic_vector(to_unsigned(104, 32));
		wait for 5 ns; 
		strb_in <= '1';
		wait for 5 ns; --cnt_out == 0, data_out == 100
		strb_in <= '0';
		data_in <= std_logic_vector(to_unsigned(105, 32));
		wait for 5 ns; 
		last_in <= '1';
		strb_in <= '1';
		wait for 5 ns; --cnt_out == 5, data_out == 100
		strb_in <= '0';
		last_in <= '0';
		wait for 10 ns;
		data_in <= std_logic_vector(to_unsigned(200, 32));
		last_in <= '0';
		strb_in <= '1';
		wait for 5 ns; --cnt_out == 5, data_out == 100
		strb_in <= '0';
		data_in <= std_logic_vector(to_unsigned(201, 32));
		wait for 5 ns; 
		strb_in <= '1';
		wait for 5 ns; --cnt_out == 5, data_out == 100
		strb_in <= '0';
		data_in <= std_logic_vector(to_unsigned(202, 32));
		wait for 5 ns; 
		strb_in <= '1';
		wait for 5 ns; --cnt_out == 5, data_out == 100
		strb_in <= '0';
		data_in <= std_logic_vector(to_unsigned(203, 32));
		wait for 5 ns; 
		strb_in <= '1';
		wait for 5 ns; --cnt_out == 5, data_out == 100
		strb_in <= '0';
		data_in <= std_logic_vector(to_unsigned(204, 32));
		wait for 5 ns; 
		last_in <= '1';
		strb_in <= '1';
		wait for 5 ns; --cnt_out == 5, data_out == 100
		strb_in <= '0';
		last_in <= '0';
		strb_out <= '1';
		wait for 5 ns; --cnt_out == 4, data_out == 101
		strb_out <= '0';
		wait for 5 ns;
		strb_out <= '1';
		wait for 5 ns; --cnt_out == 3, data_out == 102
		strb_out <= '0';
		wait for 5 ns; 
		strb_out <= '1';
		wait for 5 ns; --cnt_out == 2, data_out == 103
		strb_out <= '0';
		wait for 5 ns;
		strb_out <= '1';
		wait for 5 ns; --cnt_out == 1, data_out == 104
		strb_out <= '0';
		wait for 5 ns;
		strb_out <= '1';
		wait for 5 ns; --cnt_out == 0, data_out == 105
		strb_out <= '0';
		wait for 5 ns;
		strb_out <= '1';
		wait for 5 ns; --cnt_out == 4, data_out == 200
		strb_out <= '0';
		wait for 5 ns;
		strb_out <= '1';
		wait for 5 ns; --cnt_out == 3, data_out == 201
		strb_out <= '0';
		wait for 5 ns;
		strb_out <= '1';
		wait for 5 ns; --cnt_out == 2, data_out == 202
		strb_out <= '0';
		wait for 5 ns;
		strb_out <= '1';
		wait for 5 ns; --cnt_out == 1, data_out == 203
		strb_out <= '0';
		wait for 5 ns;
		strb_out <= '1';
		wait for 5 ns; --cnt_out == 0, data_out == 204
		strb_out <= '0';
		wait for 5 ns;
		strb_out <= '1';
		wait for 5 ns; --cnt_out == 0, data_out == 0
		strb_out <= '0';
		wait;
	end process;
end tb_arch;
