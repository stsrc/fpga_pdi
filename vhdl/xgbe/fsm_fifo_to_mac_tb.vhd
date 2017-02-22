library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb is
end tb;

architecture tb_arch of tb is

component fsm_fifo_to_mac is
	port (
	clk : in std_logic;
	rst : in std_logic;
	pkt_tx_data : out std_logic_vector(63 downto 0);
	pkt_tx_val : out std_logic;
	pkt_tx_sop : out std_logic;
	pkt_tx_eop : out std_logic;
	pkt_tx_mod : out std_logic_vector(2 downto 0);
	pkt_tx_full : in std_logic;

	packet_strb : in std_logic;
	fifo_data : in std_logic_vector(63 downto 0);
	fifo_cnt : in std_logic_vector(13 downto 0);
	fifo_data_strb : out std_logic;
	fifo_cnt_strb : out std_logic;

	fifo_chcks: in std_logic_vector(15 downto 0);
	fifo_chcks_strb : out std_logic
);

end component;

type packet is array (natural range 0 to 7) of std_logic_vector(63 downto 0);

constant packet_tcp : packet := (
0 => (X"FFFFFFFFFFFFAAAA"),
1 => (X"AAAAAAAA00000500"),
2 => (X"0700000032001111"),
3 => (X"1234F0F0F0F00F0F"),
4 => (X"0F0F123443210000"),
5 => (X"0000111111112222"),
6 => (X"2222ABCDFFFFFFFF"),
7 => (X"FFFFFFFFFFFFFFFF"));

constant data_tcp_ref : packet := (
0 => (X"FFFFFFFFFFFFAAAA"),
1 => (X"AAAAAAAA00000500"),
2 => (X"0700000032001111"),
3 => (X"1234F0F0F0F00F0F"),
4 => (X"0F0F123443210000"),
5 => (X"0000111111112222"),
6 => (X"2222ABCD0d05FFFF"),
7 => (X"FFFFFFFFFFFFFFFF"));

constant packet_udp : packet := (
0 => (X"FFFFFFFFFFFFAAAA"),
1 => (X"AAAAAAAA00000500"),
2 => (X"1100000032001111"),
3 => (X"1234F0F0F0F00F0F"),
4 => (X"0F0F123443210000"),
5 => (X"000011111111FFFF"),
6 => (X"2222ABCDFFFFFFFF"),
7 => (X"FFFFFFFFFFFFFFFF"));

constant data_udp_ref : packet := (
0 => (X"FFFFFFFFFFFFAAAA"),
1 => (X"AAAAAAAA00000500"),
2 => (X"1100000032001111"),
3 => (X"1234F0F0F0F00F0F"),
4 => (X"0F0F123443210000"),
5 => (X"0000111111110d05"),
6 => (X"2222ABCDFFFFFFFF"),
7 => (X"FFFFFFFFFFFFFFFF"));


type ref is array (natural range 0 to 9) of std_logic;
constant val_ref : ref := (
0 => '0',
1 => '1',
2 => '1',
3 => '1',
4 => '1',
5 => '1',
6 => '1',
7 => '1',
8 => '1',
9 => '0');

constant sop_ref : ref := (
0 => '0',
1 => '1',
2 => '0',
3 => '0',
4 => '0',
5 => '0',
6 => '0',
7 => '0',
8 => '0',
9 => '0');

constant eop_ref : ref := (
0 => '0',
1 => '0',
2 => '0',
3 => '0',
4 => '0',
5 => '0',
6 => '0',
7 => '0',
8 => '1',
9 => '0');

constant data_strb_ref : ref := (
0 => '1',
1 => '1',
2 => '1',
3 => '1',
4 => '1',
5 => '1',
6 => '1',
7 => '1',
8 => '0',
9 => '0');

constant cnt_strb_ref : ref := (
0 => '1',
1 => '0',
2 => '0',
3 => '0',
4 => '0',
5 => '0',
6 => '0',
7 => '0',
8 => '0',
9 => '0');

constant chcks_strb_ref : ref := (
0 => '0',
1 => '0',
2 => '0',
3 => '0',
4 => '0',
5 => '0',
6 => '1',
7 => '0',
8 => '0',
9 => '0');

constant chcks_strb_ref_udp : ref := (
0 => '0',
1 => '0',
2 => '0',
3 => '0',
4 => '0',
5 => '1',
6 => '0',
7 => '0',
8 => '0',
9 => '0');

signal clk, rst, pkt_tx_val, pkt_tx_sop, pkt_tx_eop, pkt_tx_full, packet_strb, fifo_data_strb,
fifo_cnt_strb : std_logic := '0';
signal pkt_tx_data, fifo_data : std_logic_vector(63 downto 0) := (others => '0');
signal fifo_cnt : std_logic_vector(13 downto 0) := (others => '0');
signal pkt_tx_mod : std_logic_vector(2 downto 0) := (others => '0');

signal fifo_chcks : std_logic_vector(15 downto 0);
signal fifo_chcks_strb : std_logic;

begin

fsm : fsm_fifo_to_mac port map (
clk => clk, rst => rst, pkt_tx_data => pkt_tx_data, pkt_tx_val => pkt_tx_val, pkt_tx_sop => pkt_tx_sop, 
pkt_tx_eop => pkt_tx_eop, 
pkt_tx_mod => pkt_tx_mod, pkt_tx_full => pkt_tx_full, packet_strb => packet_strb, fifo_data => fifo_data,
fifo_cnt => fifo_cnt, fifo_data_strb => fifo_data_strb, fifo_cnt_strb => fifo_cnt_strb,
fifo_chcks => fifo_chcks, fifo_chcks_strb => fifo_chcks_strb
);

process begin
	clk <= '0';
	wait for 5 ns;
	clk <= '1';
	wait for 5 ns;
end process;

process begin
	rst <= '0';
	wait for 10 ns;
	rst <= '1';
	wait;
end process;

process begin
	wait for 10 ns;
	fifo_data <= packet_tcp(0);
	fifo_cnt <= std_logic_vector(to_unsigned(64, 14));
	fifo_chcks <= std_logic_vector(to_unsigned(3333, 16));
	packet_strb <= '1';

	for i in 0 to 0 loop
		wait for 1 ns;
		assert pkt_tx_val = val_ref(i) severity failure;
		assert pkt_tx_sop = sop_ref(i) severity failure;	
		assert pkt_tx_eop = eop_ref(i) severity failure;
		assert fifo_data_strb = data_strb_ref(i) severity failure;
		assert fifo_cnt_strb = cnt_strb_ref(i) severity failure;
		assert fifo_chcks_strb = chcks_strb_ref(i) severity failure;
		fifo_data <= packet_tcp(i);
		wait for 9 ns;
	end loop;

	packet_strb <= '0';

	for i in 1 to 7 loop
		assert pkt_tx_data = data_tcp_ref(i - 1) severity failure;
		assert pkt_tx_val = val_ref(i) severity failure;
		assert pkt_tx_sop = sop_ref(i) severity failure;	
		assert pkt_tx_eop = eop_ref(i) severity failure;
		assert fifo_data_strb = data_strb_ref(i) severity failure;
		assert fifo_cnt_strb = cnt_strb_ref(i) severity failure;
		assert fifo_chcks_strb = chcks_strb_ref(i) severity failure;
		fifo_data <= packet_tcp(i);
		wait for 10 ns;
	end loop;

	for i in 8 to 8 loop
		assert pkt_tx_data = data_tcp_ref(i - 1) severity failure;
		assert pkt_tx_val = val_ref(i) severity failure;
		assert pkt_tx_sop = sop_ref(i) severity failure;	
		assert pkt_tx_eop = eop_ref(i) severity failure;
		assert fifo_data_strb = data_strb_ref(i) severity failure;
		assert fifo_cnt_strb = cnt_strb_ref(i) severity failure;
		assert fifo_chcks_strb = chcks_strb_ref(i) severity failure;
		wait for 10 ns;
	end loop;

	for i in 9 to 9 loop
		assert pkt_tx_val = val_ref(i) severity failure;
		assert pkt_tx_sop = sop_ref(i) severity failure;	
		assert pkt_tx_eop = eop_ref(i) severity failure;
		assert fifo_data_strb = data_strb_ref(i) severity failure;
		assert fifo_cnt_strb = cnt_strb_ref(i) severity failure;
		assert fifo_chcks_strb = chcks_strb_ref(i) severity failure;
		wait for 10 ns;
	end loop;

	wait for 10 ns;
	fifo_data <= packet_udp(0);
	fifo_cnt <= std_logic_vector(to_unsigned(64, 14));
	fifo_chcks <= std_logic_vector(to_unsigned(3333, 16));
	packet_strb <= '1';

	for i in 0 to 0 loop
		wait for 1 ns;
		assert pkt_tx_val = val_ref(i) severity failure;
		assert pkt_tx_sop = sop_ref(i) severity failure;	
		assert pkt_tx_eop = eop_ref(i) severity failure;
		assert fifo_data_strb = data_strb_ref(i) severity failure;
		assert fifo_cnt_strb = cnt_strb_ref(i) severity failure;
		assert fifo_chcks_strb = chcks_strb_ref_udp(i) severity failure;
		fifo_data <= packet_udp(i);
		wait for 9 ns;
	end loop;

	packet_strb <= '0';

	for i in 1 to 7 loop
		assert pkt_tx_data = data_udp_ref(i - 1) severity failure;
		assert pkt_tx_val = val_ref(i) severity failure;
		assert pkt_tx_sop = sop_ref(i) severity failure;	
		assert pkt_tx_eop = eop_ref(i) severity failure;
		assert fifo_data_strb = data_strb_ref(i) severity failure;
		assert fifo_cnt_strb = cnt_strb_ref(i) severity failure;
		assert fifo_chcks_strb = chcks_strb_ref_udp(i) severity failure;
		fifo_data <= packet_udp(i);
		wait for 10 ns;
	end loop;

	for i in 8 to 8 loop
		assert pkt_tx_data = data_udp_ref(i - 1) severity failure;
		assert pkt_tx_val = val_ref(i) severity failure;
		assert pkt_tx_sop = sop_ref(i) severity failure;	
		assert pkt_tx_eop = eop_ref(i) severity failure;
		assert fifo_data_strb = data_strb_ref(i) severity failure;
		assert fifo_cnt_strb = cnt_strb_ref(i) severity failure;
		assert fifo_chcks_strb = chcks_strb_ref_udp(i) severity failure;
		wait for 10 ns;
	end loop;

	for i in 9 to 9 loop
		assert pkt_tx_val = val_ref(i) severity failure;
		assert pkt_tx_sop = sop_ref(i) severity failure;	
		assert pkt_tx_eop = eop_ref(i) severity failure;
		assert fifo_data_strb = data_strb_ref(i) severity failure;
		assert fifo_cnt_strb = cnt_strb_ref(i) severity failure;
		assert fifo_chcks_strb = chcks_strb_ref_udp(i) severity failure;
		wait for 10 ns;
	end loop;

	wait;
end process;

end tb_arch;
