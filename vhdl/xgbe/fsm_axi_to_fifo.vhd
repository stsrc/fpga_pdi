library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm_axi_to_fifo is
port (
	clk 			: in std_logic;
	resetn 			: in std_logic;
	-- 4 bytes of packet which comes from MB.
	data_from_axi 		: in std_logic_vector(31 downto 0);
	data_from_axi_strb 	: in std_logic;
	-- 8 bytes of packet which goes to the MAC (through FIFO)
	data_to_fifo 		: out std_logic_vector(63 downto 0);
	data_to_fifo_strb 	: out std_logic;
	
	fifo_is_full		: in std_logic;
	-- Packet size in bytes.
	cnt_from_axi 		: in std_logic_vector(31 downto 0);
	-- This strobe also starts a transmission!
	cnt_from_axi_strb 	: in std_logic;
	-- Packet size in bytes to fifo.
	cnt_to_fifo : out std_logic_vector(13 downto 0);
	cnt_to_fifo_strb : out std_logic;
	-- Signal informs about new packet to be send.
	packet_strb : out std_logic
);
end fsm_axi_to_fifo;

architecture Behavioral of fsm_axi_to_fifo is
signal state, state_tmp : std_logic_vector(1 downto 0);
signal data_reg, data_reg_tmp : std_logic_vector(31 downto 0);
begin

process (clk) begin
	if (rising_edge(clk)) then
		if (resetn = '0') then
			state <= (others => '0');
			data_reg <= (others => '0');

		else
			state <= state_tmp;
			data_reg <= data_reg_tmp;
		end if;
	end if;
end process;

process(state, data_reg, data_from_axi_strb, data_from_axi, cnt_from_axi, cnt_from_axi_strb, fifo_is_full) begin
	state_tmp <= state;
	data_reg_tmp <= data_reg;
	data_to_fifo_strb <= '0';
	data_to_fifo <= (others => '0');

	cnt_to_fifo <= cnt_from_axi(13 downto 0);
	cnt_to_fifo_strb <= cnt_from_axi_strb;
	packet_strb <= cnt_from_axi_strb; 

	case state is
	when "00" =>
		if (fifo_is_full = '1') then
			state_tmp <= "11";
		elsif (data_from_axi_strb = '1') then
    			data_reg_tmp <= data_from_axi;
    			state_tmp <= "01";
		end if;
	when "01" =>
		if (fifo_is_full = '1') then
			state_tmp <= "11";
		elsif (data_from_axi_strb = '1') then
    			data_to_fifo <= data_from_axi & data_reg;
			data_to_fifo_strb <= '1';
    			state_tmp <= "00";
		end if;
	when "11" =>
		if (cnt_from_axi_strb = '1') then
			state_tmp <= "00";
		else
			state_tmp <= "11";
		end if;
		cnt_to_fifo <= (others => '0');
		cnt_to_fifo_strb <= '0';
		packet_strb <= '0';

	when others => 
		state_tmp <= "00";
	end case;
end process;

end Behavioral;
