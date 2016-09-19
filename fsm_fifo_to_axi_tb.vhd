----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/28/2016 07:19:37 PM
-- Design Name: 
-- Module Name: fsm_fifo_to_axi_rx_tb - Behavioral
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

entity fsm_fifo_to_axi_tb is
--  Port ( );
end fsm_fifo_to_axi_tb;

architecture Behavioral of fsm_fifo_to_axi_tb is
component fsm_fifo_to_axi is
    port (
    clk     : in std_logic;
    rst     : in std_logic;
    
    fifo_out : in std_logic_vector(63 downto 0);
    fifo_strb : out std_logic;
    axi_in   : out std_logic_vector(31 downto 0);
    axi_strb  : in std_logic;
    
    cnt_in : in std_logic_vector(13 downto 0);
    cnt_out : out std_logic_vector(31 downto 0);
    cnt_strb_in : in std_logic;
    cnt_strb_out : out std_logic
    );
end component;

signal clk, rst, fifo_strb, axi_strb, cnt_strb_in, cnt_strb_out : std_logic := '0';
signal fifo_out : std_logic_vector(63 downto 0) := (others => '0');
signal axi_in, cnt_out : std_logic_vector(31 downto 0) := (others => '0');
signal cnt_in : std_logic_vector(13 downto 0);

begin
fsm1 : fsm_fifo_to_axi port map 
(clk => clk, rst => rst, fifo_out => fifo_out, fifo_strb => fifo_strb,
axi_in => axi_in, axi_strb => axi_strb, cnt_in => cnt_in, cnt_out => cnt_out,
cnt_strb_in => cnt_strb_in, cnt_strb_out => cnt_strb_out);

process begin
clk <= '0';
wait for 5 ns;
clk <= '1';
wait for 5 ns;
end process;

process begin
cnt_in <= (others => '1');
rst <= '0';
wait for 15 ns;
rst <= '1';
fifo_out <= "1000000010000000100000001000000000000001000000010000000100000001";
wait for 10 ns; --1 on front, fifo_strb = '0';
axi_strb <= '1';
wait for 10 ns; --1 on back, fifo_strb = '1';
wait for 10 ns; --1 on front, fifo_strb = '0';
axi_strb <= '0';
wait; --1 on front, fifo_strb = '0';
end process;
end Behavioral;
