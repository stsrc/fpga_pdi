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
signal state, state_tmp : std_logic := '0';
signal data_reg, data_reg_tmp : std_logic_vector(31 downto 0);
begin

cnt_to_fifo <= cnt_from_axi(13 downto 0);
cnt_to_fifo_strb <= cnt_from_axi_strb;
packet_strb <= cnt_from_axi_strb; 

process (clk) begin
	if (rising_edge(clk)) then
		if (resetn = '0') then
			state <= '0';
			data_reg <= (others => '0');
		else
			state <= state_tmp;
			data_reg <= data_reg_tmp;
		end if;
	end if;
end process;

process(state, data_reg, data_from_axi_strb, data_from_axi) begin
	state_tmp <= state;
	data_reg_tmp <= data_reg;
	data_to_fifo_strb <= '0';
	data_to_fifo <= (others => '0');
	case state is
	when '0' =>
		if (data_from_axi_strb = '1') then
    			data_reg_tmp <= data_from_axi;
    			state_tmp <= '1';
		end if;
	when '1' =>
		if (data_from_axi_strb = '1') then
    			data_to_fifo <= data_from_axi & data_reg;
			data_to_fifo_strb <= '1';
    			state_tmp <= '0';
		end if;
	when others => 
		state_tmp <= '0';
	end case;
end process;

end Behavioral;
