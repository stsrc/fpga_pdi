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
clk : in std_logic;
rst : in std_logic;
axi_strb    : in std_logic;
axi_data : in std_logic_vector(31 downto 0);
fifo_data : out std_logic_vector(63 downto 0);
fifo_strb : out std_logic;
cnt_axi : in std_logic_vector(31 downto 0);
cnt_fifo : out std_logic_vector(13 downto 0);
cnt_axi_strb : in std_logic;
packet_strb : out std_logic;
cnt_fifo_strb : out std_logic
);
end component;
signal clk, rst, axi_strb, fifo_strb, cnt_axi_strb, cnt_fifo_strb, packet_strb : std_logic := '0';
signal axi_data, cnt_axi : std_logic_vector(31 downto 0) := (others => '0');
signal fifo_data : std_logic_vector(63 downto 0) := (others => '0');
signal cnt_fifo : std_logic_vector(13 downto 0) := (others => '0');
begin
fsm_1 : fsm_axi_to_fifo port map (clk => clk, rst => rst, axi_strb => axi_strb, fifo_strb => fifo_strb,
axi_data => axi_data, fifo_data => fifo_data, cnt_axi => cnt_axi, cnt_fifo => cnt_fifo, cnt_axi_strb => cnt_axi_strb,
packet_strb => packet_strb, cnt_fifo_strb => cnt_fifo_strb);

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
axi_data <= (others => '1');
wait for 10 ns; -- nothing changes
axi_strb <= '1';
wait for 10 ns;
axi_data <= "10101010101010101010101010101010";
wait for 10 ns; -- nothing changes
axi_strb <= '0';
cnt_axi_strb <= '1';
wait for 10 ns;
cnt_axi_strb <= '0';
wait;
end process;

end Behavioral;
