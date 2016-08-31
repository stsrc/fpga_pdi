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
	fifo_cnt_strb : out std_logic
);

end component;

signal clk, rst, pkt_tx_val, pkt_tx_sop, pkt_tx_eop, pkt_tx_full, packet_strb, fifo_data_strb,
fifo_cnt_strb : std_logic := '0';
signal pkt_tx_data, fifo_data : std_logic_vector(63 downto 0) := (others => '0');
signal fifo_cnt : std_logic_vector(13 downto 0) := (others => '0');
signal pkt_tx_mod : std_logic_vector(2 downto 0) := (others => '0');

begin

fsm : fsm_fifo_to_mac port map (
clk => clk, rst => rst, pkt_tx_data => pkt_tx_data, pkt_tx_val => pkt_tx_val, pkt_tx_sop => pkt_tx_sop, 
pkt_tx_eop => pkt_tx_eop, 
pkt_tx_mod => pkt_tx_mod, pkt_tx_full => pkt_tx_full, packet_strb => packet_strb, fifo_data => fifo_data,
fifo_cnt => fifo_cnt, fifo_data_strb => fifo_data_strb, fifo_cnt_strb => fifo_cnt_strb
);

process begin
	clk <= '0';
	wait for 5 ns;
	clk <= '1';
	wait for 5 ns;
end process;

process begin
	rst <= '0';
	wait for 15 ns;
	rst <= '1';
	fifo_data <= std_logic_vector(to_unsigned(100, 64));
	fifo_cnt <= std_logic_vector(to_unsigned(20, 14));
	packet_strb <= '1';
	wait for 10 ns; -- fifo_cnt_strb = '1', fifo_data_strb = '1', pkt_tx_val = '1', pkt_tx_sop = '1',
			-- pkt_tx_eop = '0', pkt_tx_mod = "000".
	packet_strb <= '0';
	pkt_tx_full <= '1';
	fifo_data <= std_logic_vector(to_unsigned(101, 64));
	wait for 10 ns; -- happens nothing.
	pkt_tx_full <= '0';
	wait for 10 ns; -- fifo_cnt_strb = '0', fifo_data_strb = '1', pkt_tx_val = '1', pkt_tx_sop = '0',
			-- pkt_tx_eop = '0', pkt_tx_mod = "000".
	wait for 10 ns; -- fifo_cnt_strb = '0', fifo_data_strb = '1', pkt_tx_val = '1', pkt_tx_sop = '0',
			-- pkt_tx_eop = '1', pkt_tx_mod = "100".
	wait for 10 ns; -- fifo_cnt_strb = '0', fifo_data_strb = '0', pkt_tx_val = '0', pkt_tx_sop = '0',
			-- pkt_tx_eop = '0', pkt_tx_mod = "000".
	wait;
end process;

end tb_arch;
