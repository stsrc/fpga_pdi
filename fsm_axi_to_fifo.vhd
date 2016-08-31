----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/29/2016 03:53:36 PM
-- Design Name: 
-- Module Name: fsm_axi_to_fifo - Behavioral
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

entity fsm_axi_to_fifo is
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

end fsm_axi_to_fifo;

architecture Behavioral of fsm_axi_to_fifo is
signal state, state_tmp : std_logic := '0';
signal data_reg, data_reg_tmp : std_logic_vector(31 downto 0);
begin

cnt_fifo <= cnt_axi(13 downto 0);
cnt_fifo_strb <= cnt_axi_strb;

process (clk) begin
if (rising_edge(clk)) then
if (rst = '0') then
    state <= '0';
    data_reg <= (others => '0');
else
    state <= state_tmp;
    data_reg <= data_reg_tmp;
    packet_strb <= cnt_axi_strb; 
    
    --TODO: add packet_strb signal to fifo (time domain convertion).
end if;
end if;
end process;

process(state, data_reg, axi_strb, axi_data) begin
state_tmp <= state;
fifo_strb <= '0';
data_reg_tmp <= data_reg;
fifo_data <= (others => '0');
case state is
when '0' =>
if (axi_strb = '1') then
    data_reg_tmp <= axi_data;
    state_tmp <= '1';
end if;
when '1' =>
if (axi_strb = '1') then
    fifo_data <= data_reg & axi_data;
    fifo_strb <= '1';
    state_tmp <= '0';
end if;
when others => 
    state_tmp <= '0';
end case;
end process;

end Behavioral;
