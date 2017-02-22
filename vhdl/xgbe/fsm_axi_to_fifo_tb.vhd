----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/29/2016 04:23:49 PM
-- Design Name: 
-- Module Name: tb_fsm_axi_to_fifo - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_fsm_axi_to_fifo is
--  Port ( );
end tb_fsm_axi_to_fifo;

architecture Behavioral of tb_fsm_axi_to_fifo is
component fsm_axi_to_fifo is
port (
	clk 			: in std_logic;
	resetn 			: in std_logic;
	data_from_axi 		: in std_logic_vector(31 downto 0);
	data_from_axi_strb 	: in std_logic;
	data_to_fifo 		: out std_logic_vector(63 downto 0);
	data_to_fifo_strb 	: out std_logic;
	fifo_is_full        	: in std_logic;
	cnt_from_axi 		: in std_logic_vector(31 downto 0);
	cnt_from_axi_strb 	: in std_logic;
	cnt_to_fifo 		: out std_logic_vector(13 downto 0);
	cnt_to_fifo_strb 	: out std_logic;
	packet_strb 	: out std_logic;
	input_1		: out std_logic_vector(15 downto 0);
	input_2		: out std_logic_vector(15 downto 0);
	input_1_strb	: out std_logic;
	input_2_strb	: out std_logic;
	reset		: out std_logic;
	oe		: out std_logic
);

end component;
signal clk, resetn, data_from_axi_strb, data_to_fifo_strb : std_logic := '0';
signal cnt_from_axi_strb, cnt_to_fifo_strb, packet_strb : std_logic := '0';
signal data_from_axi, cnt_from_axi : std_logic_vector(31 downto 0) := (others => '0');
signal data_to_fifo : std_logic_vector(63 downto 0) := (others => '0');
signal cnt_to_fifo : std_logic_vector(13 downto 0) := (others => '0');
signal input_1, input_2 : std_logic_vector(15 downto 0) := (others => '0');
signal input_1_strb, input_2_strb : std_logic := '0';
signal reset: std_logic := '0';
signal oe: std_logic := '0';
signal fifo_is_full: std_logic := '0';

type packet is array (natural range 0 to 15) of std_logic_vector(31 downto 0);

constant packet_tcp : packet := (
0 => (X"FFFFFFFF"),
1 => (X"FFFFAAAA"),
2 => (X"AAAAAAAA"),
3 => (X"00000500"),
4 => (X"32001111"),
5 => (X"06000000"),
6 => (X"1234F0F0"),
7 => (X"F0F00F0F"),
8 => (X"0F0F1234"),
9 => (X"43210000"),
10 => (X"00001111"),
11 => (X"11112222"),
12 => (X"2222ABCD"),
13 => (X"FFFFFFFF"),
14 => (X"FFFFFFFF"),
15 => (X"FFFFFFFF"));

constant packet_udp : packet := (
0 => (X"FFFFFFFF"),
1 => (X"FFFFAAAA"),
2 => (X"AAAAAAAA"),
3 => (X"00000500"),
4 => (X"32001111"),
5 => (X"11000000"),
6 => (X"1234F0F0"),
7 => (X"F0F00F0F"),
8 => (X"0F0F1234"),
9 => (X"43210000"),
10 => (X"00001111"),
11 => (X"11112222"),
12 => (X"2222ABCD"),
13 => (X"FFFFFFFF"),
14 => (X"FFFFFFFF"),
15 => (X"FFFFFFFF"));

begin
fsm_1 : fsm_axi_to_fifo 
	port map (
		clk => clk, 
		resetn => resetn, 
		data_from_axi => data_from_axi,
		data_from_axi_strb => data_from_axi_strb,
		data_to_fifo => data_to_fifo,
		data_to_fifo_strb => data_to_fifo_strb,
		cnt_from_axi => cnt_from_axi,
		cnt_from_axi_strb => cnt_from_axi_strb,
		cnt_to_fifo => cnt_to_fifo,
		cnt_to_fifo_strb => cnt_to_fifo_strb,
		packet_strb => packet_strb,
		input_1 => input_1,
		input_2 => input_2,
		input_1_strb => input_1_strb,
		input_2_strb => input_2_strb,
		reset => reset,
		oe => oe,
		fifo_is_full => fifo_is_full
	);

process begin
clk <= '0';
wait for 5 ns;
clk <= '1';
wait for 5 ns;
end process;

process begin
resetn <= '0';
wait for 10 ns;
resetn <= '1';
wait;
end process;

process begin
    fifo_is_full <= '0';
	wait for 10 ns;
	for i in 0 to 15 loop
		data_from_axi <= packet_tcp(i);
		data_from_axi_strb <= '1';
		wait for 1 ns;
		case i is
		when 0 =>
			assert input_1_strb = '0' and input_2_strb = '0' severity failure;
		when 1 =>
			assert input_1_strb = '0' and input_2_strb = '0' severity failure;
		when 2 =>
			assert input_1_strb = '0' and input_2_strb = '0' severity failure;
		when 3 =>
			assert input_1_strb = '0' and input_2_strb = '0' severity failure;
		when 4 =>
			assert input_1_strb = '1' and input_2_strb = '0' severity failure;
		when 5 =>
			assert input_1_strb = '0' and input_2_strb = '1' severity failure;
		when 6 =>
			assert input_1_strb = '0' and input_2_strb = '1' severity failure;
		when 7 =>	
			assert input_1_strb = '1' and input_2_strb = '1' severity failure;
		when 8 =>
			assert input_1_strb = '1' and input_2_strb = '1' severity failure;
		when 9 =>
			assert input_1_strb = '1' and input_2_strb = '1' severity failure;
		when 10 =>
			assert input_1_strb = '1' and input_2_strb = '1' severity failure;
		when 11 =>
			assert input_1_strb = '1' and input_2_strb = '1' severity failure;
		when 13 =>
			assert input_1_strb = '1' and input_2_strb = '1' severity failure;
		when 14 =>
			assert input_1_strb = '1' and input_2_strb = '1' severity failure;
		when 15 =>
			assert input_1_strb = '1' and input_2_strb = '1' severity failure;
		when 12 =>
			assert input_1_strb = '1' and input_2_strb = '0' severity failure;
		when others =>
		end case;
		wait for 9 ns;
	end loop; 
	data_from_axi_strb <= '0';
	cnt_from_axi <= std_logic_vector(to_unsigned(64, 32));
	cnt_from_axi_strb <= '1';
	wait for 1 ns;
	assert oe = '1' and cnt_to_fifo_strb = '1' severity failure;
	wait for 9 ns;
	cnt_from_axi_strb <= '0';

	wait for 10 ns;
	for i in 0 to 15 loop
		data_from_axi <= packet_udp(i);
		data_from_axi_strb <= '1';
		wait for 1 ns;
		case i is
		when 0 =>
			assert input_1_strb = '0' and input_2_strb = '0' severity failure;
		when 1 =>
			assert input_1_strb = '0' and input_2_strb = '0' severity failure;
		when 2 =>
			assert input_1_strb = '0' and input_2_strb = '0' severity failure;
		when 3 =>
			assert input_1_strb = '0' and input_2_strb = '0' severity failure;
		when 4 =>
			assert input_1_strb = '1' and input_2_strb = '0' severity failure;
		when 5 =>
			assert input_1_strb = '0' and input_2_strb = '1' severity failure;
		when 6 =>
			assert input_1_strb = '0' and input_2_strb = '1' severity failure;
		when 7 =>	
			assert input_1_strb = '1' and input_2_strb = '1' severity failure;
		when 8 =>
			assert input_1_strb = '1' and input_2_strb = '1' severity failure;
		when 9 =>
			assert input_1_strb = '1' and input_2_strb = '1' severity failure;
		when 11 =>
			assert input_1_strb = '1' and input_2_strb = '1' severity failure;
		when 12 =>
			assert input_1_strb = '1' and input_2_strb = '1' severity failure;
		when 13 =>
			assert input_1_strb = '1' and input_2_strb = '1' severity failure;
		when 14 =>
			assert input_1_strb = '1' and input_2_strb = '1' severity failure;
		when 15 =>
			assert input_1_strb = '1' and input_2_strb = '1' severity failure;
		when 10 =>
			assert input_1_strb = '0' and input_2_strb = '1' severity failure;
		when others =>
		end case;
		wait for 9 ns;
	end loop; 
	data_from_axi_strb <= '0';
	cnt_from_axi <= std_logic_vector(to_unsigned(64, 32));
	cnt_from_axi_strb <= '1';
	wait for 1 ns;
	assert oe = '1' and cnt_to_fifo_strb = '1' severity failure;
	cnt_from_axi_strb <= '0';

	wait;
end process;
end Behavioral;
