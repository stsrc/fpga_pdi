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
	clk 			: in std_logic;
	resetn 			: in std_logic;
	data_from_axi 		: in std_logic_vector(31 downto 0);
	data_from_axi_strb 	: in std_logic;
	data_to_fifo 		: out std_logic_vector(63 downto 0);
	data_to_fifo_strb 	: out std_logic;
	cnt_from_axi 		: in std_logic_vector(31 downto 0);
	cnt_from_axi_strb 	: in std_logic;
	cnt_to_fifo : out std_logic_vector(13 downto 0);
	cnt_to_fifo_strb : out std_logic;
	packet_strb : out std_logic;
	fifo_is_full : in std_logic
);

end component;
signal clk, resetn, data_from_axi_strb, data_to_fifo_strb : std_logic := '0';
signal cnt_from_axi_strb, cnt_to_fifo_strb, packet_strb : std_logic := '0';
signal data_from_axi, cnt_from_axi : std_logic_vector(31 downto 0) := (others => '0');
signal data_to_fifo : std_logic_vector(63 downto 0) := (others => '0');
signal cnt_to_fifo : std_logic_vector(13 downto 0) := (others => '0');
signal fifo_is_full : std_logic := '0';
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
wait for 15 ns;
resetn <= '1';
data_from_axi <= (others => '1');
wait for 10 ns;
data_from_axi_strb <= '1';
data_from_axi <= x"ff000000";
wait for 10 ns;
data_from_axi <= x"000000ff";
wait for 10 ns;
data_from_axi_strb <= '0';
cnt_from_axi <= x"000000ff";
cnt_from_axi_strb <= '1';
wait for 10 ns;
cnt_from_axi_strb <= '0';

wait for 10 ns;
fifo_is_full <= '1';
data_from_axi_strb <= '1';
data_from_axi <= x"ff000000";
wait for 10 ns;
fifo_is_full <= '0';
data_from_axi <= x"000000ff";
wait for 10 ns;
data_from_axi_strb <= '0';
cnt_from_axi <= x"000000ff";
cnt_from_axi_strb <= '1';
wait for 10 ns;
cnt_from_axi_strb <= '0';
wait for 10 ns;
data_from_axi_strb <= '1';
data_from_axi <= x"ff000000";
wait for 10 ns;
data_from_axi <= x"000000ff";
wait for 10 ns;
data_from_axi_strb <= '0';
cnt_from_axi <= x"000000ff";
cnt_from_axi_strb <= '1';
wait for 10 ns;
cnt_from_axi_strb <= '0';
wait;
end process;

end Behavioral;
