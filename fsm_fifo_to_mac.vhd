----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/29/2016 05:25:47 PM
-- Design Name: 
-- Module Name: fsm_fifo_to_mac - Behavioral
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

entity fsm_fifo_to_mac is
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

end fsm_fifo_to_mac;

architecture Behavioral of fsm_fifo_to_mac is
signal state, state_tmp : std_logic_vector(1 downto 0);
signal cnt, cnt_tmp : unsigned(13 downto 0);

begin
	process (clk) begin
	if (rising_edge(clk)) then
		if (rst = '0') then
			state <= (others => '0');
			cnt <= (others => '0');
		else
			state <= state_tmp;
			cnt <= cnt_tmp;
		end if;
	end if;
	end process;

	process(state, cnt, packet_strb, fifo_cnt, fifo_data) begin
		state_tmp <= state;
		cnt_tmp <= cnt;
		fifo_cnt_strb <= '0';
		fifo_data_strb <= '0';
		pkt_tx_data <= (others => '0');
		pkt_tx_val <= '0';
		pkt_tx_sop <= '0';
		pkt_tx_eop <= '0';
		pkt_tx_mod <= (others => '0');
	case state is
	when "00" =>
		if (packet_strb = '1') then
			cnt_tmp <= unsigned(fifo_cnt) - 8;
			pkt_tx_data <= fifo_data;
			pkt_tx_val <= '1';
			pkt_tx_sop <= '1';
			fifo_data_strb <= '1';
			fifo_cnt_strb <= '1';
			state_tmp <= "01";
		end if;
	when "01" =>
		  cnt_tmp <= cnt - 8;
		  pkt_tx_data <= fifo_data;
		  pkt_tx_val <= '1';
		  fifo_data_strb <= '1';
		  if(cnt - 8 <= 8 ) then
		      state_tmp <= "11";
		  end if;
	when "11" =>
        
        
        pkt_tx_val <= '1';
        fifo_data_strb <= '1';
        pkt_tx_eop <= '1';
        
        case cnt is
        when to_unsigned(1, 14) =>
        pkt_tx_data(63 downto 8) <= fifo_data(63 downto 8);
        pkt_tx_data(7 downto 0) <= fifo_data(7 downto 0);
        pkt_tx_mod <= "001";
        when to_unsigned(2, 14) =>
        pkt_tx_data(63 downto 16) <= (others => '0');
        pkt_tx_data(15 downto 0) <= fifo_data(15 downto 0);
        pkt_tx_mod <= "010";
        when to_unsigned(3, 14) =>
        pkt_tx_data(63 downto 24) <= (others => '0');
        pkt_tx_data(23 downto 0) <= fifo_data(23 downto 0);
        pkt_tx_mod <= "011";
        when to_unsigned(4, 14) =>            
        pkt_tx_data(63 downto 32) <= (others => '0');
        pkt_tx_data(31 downto 0) <= fifo_data(31 downto 0);
        pkt_tx_mod <= "100";
        when to_unsigned(5, 14) =>
        pkt_tx_data(63 downto 40) <= (others => '0');
        pkt_tx_data(39 downto 0) <= fifo_data(39 downto 0);
        pkt_tx_mod <= "101";
        when to_unsigned(6, 14) =>
        pkt_tx_data(63 downto 48) <= (others => '0');
        pkt_tx_data(47 downto 0) <= fifo_data(47 downto 0);
        pkt_tx_mod <= "110";
        when to_unsigned(7, 14) =>
        pkt_tx_data(63 downto 56) <= (others => '0');
        pkt_tx_data(55 downto 0) <= fifo_data(55 downto 0);
        pkt_tx_mod <= "111";
        when to_unsigned(8, 14) =>
        pkt_tx_data <= fifo_data;
        pkt_tx_mod <= "000";
        when others =>
        end case;
	when others =>
		state_tmp <= (others => '0');
		cnt_tmp <= (others => '0');
	end case;

	end process;
end Behavioral;
