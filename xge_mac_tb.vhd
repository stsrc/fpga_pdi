----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/01/2016 01:31:35 PM
-- Design Name: 
-- Module Name: xge_mac_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity xge_mac_tb is
--  Port ( );
end xge_mac_tb;

architecture Behavioral of xge_mac_tb is

component xge_mac_wrapper is
  port (
    clk_156m25 : in STD_LOGIC;
    clk_xgmii_rx : in STD_LOGIC;
    clk_xgmii_tx : in STD_LOGIC;
    pkt_rx_avail : out STD_LOGIC;
    pkt_rx_data : out STD_LOGIC_VECTOR ( 63 downto 0 );
    pkt_rx_eop : out STD_LOGIC;
    pkt_rx_err : out STD_LOGIC;
    pkt_rx_mod : out STD_LOGIC_VECTOR ( 2 downto 0 );
    pkt_rx_ren : in STD_LOGIC;
    pkt_rx_sop : out STD_LOGIC;
    pkt_rx_val : out STD_LOGIC;
    pkt_tx_data : in STD_LOGIC_VECTOR ( 63 downto 0 );
    pkt_tx_eop : in STD_LOGIC;
    pkt_tx_full : out STD_LOGIC;
    pkt_tx_mod : in STD_LOGIC_VECTOR ( 2 downto 0 );
    pkt_tx_sop : in STD_LOGIC;
    pkt_tx_val : in STD_LOGIC;
    reset_156m25_n : in STD_LOGIC;
    reset_xgmii_rx_n : in STD_LOGIC;
    reset_xgmii_tx_n : in STD_LOGIC;
    wb_ack_o : out STD_LOGIC;
    wb_adr_i : in STD_LOGIC_VECTOR ( 7 downto 0 );
    wb_clk_i : in STD_LOGIC;
    wb_cyc_i : in STD_LOGIC;
    wb_dat_i : in STD_LOGIC_VECTOR ( 31 downto 0 );
    wb_dat_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
    wb_int_o : out STD_LOGIC;
    wb_rst_i : in STD_LOGIC;
    wb_stb_i : in STD_LOGIC;
    wb_we_i : in STD_LOGIC;
    xgmii_rxc : in STD_LOGIC_VECTOR ( 7 downto 0 );
    xgmii_rxd : in STD_LOGIC_VECTOR ( 63 downto 0 );
    xgmii_txc : out STD_LOGIC_VECTOR ( 7 downto 0 );
    xgmii_txd : out STD_LOGIC_VECTOR ( 63 downto 0 )
  );
end component xge_mac_wrapper;

    signal clk_156m25, clk_xgmii_rx, clk_xgmii_tx, pkt_rx_avail, pkt_rx_eop, pkt_rx_err,
    pkt_rx_ren, pkt_rx_sop, pkt_rx_val, pkt_tx_eop, pkt_tx_full, pkt_tx_sop, pkt_tx_val,
    reset_156m25_n, reset_xgmii_rx_n, reset_xgmii_tx_n, wb_ack_o, wb_clk_i, wb_cyc_i, 
    wb_int_o, wb_rst_i, wb_stb_i, wb_we_i : std_logic := '0';
    signal pkt_rx_data, pkt_tx_data, xgmii_rxd, xgmii_txd : std_logic_vector(63 downto 0) := (others => '0');
    signal pkt_rx_mod, pkt_tx_mod : std_logic_vector(2 downto 0) := (others => '0');
    signal wb_adr_i, xgmii_rxc, xgmii_txc : std_logic_vector(7 downto 0) := (others => '0');
    signal wb_dat_i, wb_dat_o : std_logic_vector(31 downto 0) := (others => '0');

begin


xge_mac_wrapper_1 : xge_mac_wrapper port map (
clk_156m25 => clk_156m25, clk_xgmii_rx => clk_xgmii_rx, clk_xgmii_tx => clk_xgmii_tx, pkt_rx_avail => pkt_rx_avail,
pkt_rx_data => pkt_rx_data, pkt_rx_eop => pkt_rx_eop, pkt_rx_err => pkt_rx_err, pkt_rx_mod => pkt_rx_mod,
pkt_rx_ren => pkt_rx_ren, pkt_rx_sop => pkt_rx_sop, pkt_rx_val => pkt_rx_val, pkt_tx_data => pkt_tx_data,
pkt_tx_eop =>pkt_tx_eop, pkt_tx_full => pkt_tx_full, pkt_tx_mod => pkt_tx_mod, pkt_tx_sop => pkt_tx_sop,
pkt_tx_val => pkt_tx_val, reset_156m25_n => reset_156m25_n, reset_xgmii_rx_n => reset_xgmii_rx_n, 
reset_xgmii_tx_n => reset_xgmii_tx_n, wb_ack_o => wb_ack_o, wb_adr_i => wb_adr_i, wb_clk_i => wb_clk_i,
wb_cyc_i => wb_cyc_i, wb_dat_i => wb_dat_i, wb_dat_o => wb_dat_o, wb_int_o => wb_int_o, wb_rst_i =>
wb_rst_i, wb_stb_i => wb_stb_i, wb_we_i => wb_we_i, xgmii_rxc => xgmii_rxc, xgmii_rxd => xgmii_rxd,
xgmii_txc => xgmii_txc, xgmii_txd => xgmii_txd);

process begin
	clk_156m25 <= '0';
	clk_xgmii_rx <= '0';
	clk_xgmii_tx <= '0';
	wait for 5 ns;
	clk_156m25 <= '1';
	clk_xgmii_rx <= '1';
	clk_xgmii_tx <= '1';
	wait for 5 ns;
end process;


xgmii_rxc <= xgmii_txc;
xgmii_rxd <= xgmii_txd;

process begin
	wb_clk_i <= '0';
	wait for 5 ns;
	wb_clk_i <= '1';
	wait for 5 ns;
end process;

process begin
	reset_156m25_n <= '0';
	reset_xgmii_rx_n <= '0';
	reset_xgmii_tx_n <= '0';
	wait for 20 ns;
	reset_156m25_n <= '1';
	reset_xgmii_rx_n <= '1';
	reset_xgmii_tx_n <= '1';
	wb_adr_i <= (others => '0');
	wb_cyc_i <= '0';
	wb_dat_i <= (others => '0');
	wb_rst_i <= '1';
	wb_stb_i <= '0';
	wait until rising_edge(wb_clk_i);
	wb_rst_i <= '0';
	wait;
end process;

process begin
	wait for 30 ns;
	pkt_tx_val <= '1';
	pkt_tx_sop <= '1';
	pkt_tx_data <= x"0000010000010010";
	wait for 10 ns;
	pkt_tx_sop <= '0';
	pkt_tx_data <= x"9400000288b50001";
	wait for 10 ns;
	pkt_tx_data <= x"0203040506070809";
	wait for 10 ns;
	pkt_tx_data <= x"0a0b0c0d0e0f1011";
	wait for 10 ns;
	pkt_tx_data <= x"1213141516171819";
	wait for 10 ns;
	pkt_tx_data <= x"1a1b1c1d1e1f2021";
	wait for 10 ns;
	pkt_tx_data <= x"2223242526272829";
	wait for 10 ns;
	pkt_tx_eop <= '1';
	pkt_tx_data <= x"2a2b2c2d2e2f3031";
	wait for 10 ns;
	pkt_tx_val <= '0';
	pkt_tx_eop <= '0';
	wait until pkt_rx_avail = '1';
	pkt_rx_ren <= '1';
	wait until pkt_rx_eop = '1';
	wait until pkt_rx_eop = '0';
	pkt_rx_ren <= '0';
	wait;
end process;

end Behavioral;
