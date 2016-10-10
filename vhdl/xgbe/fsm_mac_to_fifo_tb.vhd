----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/27/2016 01:13:55 PM
-- Design Name: 
-- Module Name: fsm_tb - Behavioral
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

entity fsm_tb is

end fsm_tb;

architecture Behavioral of fsm_tb is
component fsm_mac_to_fifo is
    
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
	    en_rcv	     : in std_logic;
        fifo_data     : out std_logic_vector(63 downto 0);
        fifo_cnt      : out std_logic_vector(13 downto 0);
        fifo_cnt_strb : out std_logic;
        fifo_strb    : out std_logic;
        fifo_drop    : out std_logic;
        eop_strb     : out std_logic;
	fifo_is_full : in std_logic;
        pkt_rx_data  : in  std_logic_vector(63 downto 0);
        pkt_rx_ren   : out std_logic;
        pkt_rx_avail : in  std_logic;
        pkt_rx_eop   : in  std_logic;
        pkt_rx_val   : in  std_logic;
        pkt_rx_sop   : in  std_logic;
        pkt_rx_mod   : in  std_logic_vector(2 downto 0);
        pkt_rx_err   : in  std_logic
       );
end component;

signal clk, rst, fifo_cnt_strb, fifo_strb, fifo_drop, eop_strb, pkt_rx_ren : std_logic := '0';
signal en_rcv, pkt_rx_avail, pkt_rx_eop, pkt_rx_val, pkt_rx_sop : std_logic := '0';
signal pkt_rx_err, fifo_is_full: std_logic := '0';
signal fifo_data, pkt_rx_data : std_logic_vector(63 downto 0) := (others => '0');
signal fifo_cnt  : std_logic_vector(13 downto 0) := (others => '0');
signal pkt_rx_mod : std_logic_vector(2 downto 0) := (others => '0');

begin
fsm_1 : fsm_mac_to_fifo port map (
clk => clk, rst => rst, en_rcv => en_rcv, fifo_data => fifo_data, 
fifo_cnt => fifo_cnt, fifo_cnt_strb => fifo_cnt_strb, fifo_strb => fifo_strb, fifo_drop => fifo_drop,
eop_strb => eop_strb, pkt_rx_data => pkt_rx_data, pkt_rx_ren => pkt_rx_ren, pkt_rx_avail => pkt_rx_avail,
pkt_rx_eop => pkt_rx_eop, pkt_rx_val => pkt_rx_val, pkt_rx_sop => pkt_rx_sop, pkt_rx_mod => pkt_rx_mod,
pkt_rx_err => pkt_rx_err, fifo_is_full => fifo_is_full
);

process begin
clk <= '0';
wait for 5 ns;
clk <= '1';
wait for 5 ns;
end process;

process begin
rst <= '0';
wait for 6 ns;
rst <= '1';
wait;
end process;

process begin
--en_rcv <= '1';
fifo_is_full <= '0';
en_rcv <= '0';
wait for 6 ns;
pkt_rx_avail <= '1';
pkt_rx_data <= std_logic_vector(to_unsigned(101, 64));
wait for 10 ns;
en_rcv <= '1';
wait for 10 ns;
pkt_rx_sop <= '1';
pkt_rx_val <= '1';
wait for 10 ns;
pkt_rx_sop <= '0';
pkt_rx_avail <= '0';
--pkt_rx_err <= '1';
pkt_rx_data <= std_logic_vector(to_unsigned(102, 64));
wait for 10 ns;
pkt_rx_eop <= '1';
pkt_rx_data <= (others => '1');
pkt_rx_mod <= std_logic_vector(to_unsigned(1, 3));
wait for 10 ns;
pkt_rx_eop <= '0';
pkt_rx_data <= (others => '0');
pkt_rx_mod <= (others => '0');
pkt_rx_val <= '0';

wait for 20 ns;
pkt_rx_avail <= '1';
pkt_rx_data <= std_logic_vector(to_unsigned(103, 64));
wait for 10 ns;
pkt_rx_sop <= '1';
pkt_rx_val <= '1';
wait for 10 ns;
pkt_rx_sop <= '0';
pkt_rx_avail <= '0';
pkt_rx_data <= std_logic_vector(to_unsigned(10, 64));
wait for 10 ns;
fifo_is_full <= '1';
wait for 10 ns;
fifo_is_full <= '0';
wait for 30 ns;
pkt_rx_eop <= '1';
wait for 10 ns;
pkt_rx_eop <= '0';
pkt_rx_val <= '0';
wait for 10 ns;

pkt_rx_avail <= '1';
pkt_rx_data <= std_logic_vector(to_unsigned(101, 64));
wait for 10 ns;
pkt_rx_sop <= '1';
pkt_rx_val <= '1';
wait for 10 ns;
pkt_rx_sop <= '0';
pkt_rx_avail <= '0';
pkt_rx_data <= std_logic_vector(to_unsigned(102, 64));
wait for 10 ns;
pkt_rx_eop <= '1';
pkt_rx_data <= (others => '1');
pkt_rx_mod <= std_logic_vector(to_unsigned(1, 3));
wait for 10 ns;
pkt_rx_eop <= '0';
pkt_rx_val <= '0';
pkt_rx_data <= (others => '0');
pkt_rx_mod <= (others => '0');
wait for 10 ns;


pkt_rx_avail <= '1';
pkt_rx_data <= std_logic_vector(to_unsigned(454, 64));
wait for 10 ns;
pkt_rx_sop <= '1';
pkt_rx_val <= '1';
wait for 10 ns;
pkt_rx_sop <= '0';
pkt_rx_avail <= '0';
pkt_rx_data <= std_logic_vector(to_unsigned(455, 64));
wait for 10 ns;
pkt_rx_err <= '1';
pkt_rx_eop <= '1';
pkt_rx_data <= (others => '1');
pkt_rx_mod <= std_logic_vector(to_unsigned(1, 3));
wait for 10 ns;
pkt_rx_val <= '0';
pkt_rx_err <= '0';
pkt_rx_eop <= '0';
pkt_rx_data <= (others => '0');
pkt_rx_mod <= (others => '0');
wait;
end process;
end Behavioral;
