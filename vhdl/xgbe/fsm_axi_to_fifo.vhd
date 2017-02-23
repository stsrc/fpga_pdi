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
	packet_strb : out std_logic;

	-- signals to checksum generator
	input_1		: out std_logic_vector(15 downto 0);
	input_2		: out std_logic_vector(15 downto 0);
	input_1_strb	: out std_logic;
	input_2_strb	: out std_logic;
	reset		: out std_logic;
	oe		: out std_logic
);
end fsm_axi_to_fifo;

architecture Behavioral of fsm_axi_to_fifo is
signal state, state_tmp : std_logic_vector(1 downto 0);
signal data_reg, data_reg_tmp : std_logic_vector(31 downto 0);
signal prot, prot_tmp: unsigned(7 downto 0);

type chcks_states is
	(
		ETH,
		ETH_IP,
		IP_LEN,
		IP_PROT,
		IP_SRC_1,
		IP_SRC_2,
		IP_UDP_TCP,
		UDP,
		TCP,
		PROT_CHCK_UDP,
		PROT_CHCK_TCP,
		REST
	);

signal chcks_state, chcks_state_tmp : chcks_states;
signal cnt, cnt_tmp: unsigned(31 downto 0);

begin

process (clk) begin
	if (rising_edge(clk)) then
		if (resetn = '0') then
			state <= (others => '0');
			data_reg <= (others => '0');
			cnt <= (others => '0');
			prot <= (others => '0');
			chcks_state <= ETH;
		else
			state <= state_tmp;
			data_reg <= data_reg_tmp;
			chcks_state <= chcks_state_tmp;
			cnt <= cnt_tmp;
			prot <= prot_tmp;
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

	when others => 		state_tmp <= "00";
	end case;
end process;

process(chcks_state, cnt, data_from_axi_strb, data_from_axi, cnt_from_axi_strb, fifo_is_full) begin
	oe <= '0';
	reset <= '0';
	input_1_strb <= '0';
	input_2_strb <= '0';
	input_1 <= data_from_axi(15 downto 0);
	input_2	<= data_from_axi(31 downto 16);
	cnt_tmp <= cnt;
	chcks_state_tmp <= chcks_state;
	prot_tmp <= prot;

	if (fifo_is_full = '1') then
		reset <= '1';
		cnt_tmp <= (others => '0');
		chcks_state_tmp <= ETH;
	elsif (data_from_axi_strb = '1') then
		cnt_tmp <= cnt + 4;
		case chcks_state is
		when ETH =>
			if (cnt + 4 = 12) then
				chcks_state_tmp <= ETH_IP;
			end if;
		when ETH_IP =>
			if (unsigned(data_from_axi(31 downto 16)) = X"0800") then
				chcks_state_tmp <= IP_LEN;
			else
				chcks_state_tmp <= ETH;
			end if;
		when IP_LEN =>
			input_1 <= std_logic_vector(unsigned(data_from_axi(15 downto 0)) - 20);
			input_1_strb <= '1';
			chcks_state_tmp <= IP_PROT;
		when IP_PROT =>
			input_2 <= "00000000" & data_from_axi(31 downto 24);
			prot_tmp <= unsigned(data_from_axi(31 downto 24));	
			input_2_strb <= '1';
			chcks_state_tmp <= IP_SRC_1;
		when IP_SRC_1 =>
			input_2_strb <= '1';
			chcks_state_tmp <= IP_SRC_2;
		when IP_SRC_2 =>
			input_1_strb <= '1';
			input_2_strb <= '1';
			chcks_state_tmp <= IP_UDP_TCP;
		when IP_UDP_TCP =>
			cnt_tmp <= to_unsigned(2, 32);
			input_1_strb <= '1';
			input_2_strb <= '1';
			if (prot = 6) then
				chcks_state_tmp <= TCP;
			elsif (prot = 17) then
				chcks_state_tmp <= UDP;
			else
				reset <= '1';
				chcks_state_tmp <= ETH;
			end if;
		when TCP =>
			input_1_strb <= '1';
			input_2_strb <= '1';
			if (cnt + 4 = 14) then
				chcks_state_tmp <= PROT_CHCK_TCP;
			end if;
		when UDP =>
			input_1_strb <= '1';
			input_2_strb <= '1';
			if (cnt + 4 = 6) then
				chcks_state_tmp <= PROT_CHCK_UDP;
			end if;
		when PROT_CHCK_TCP =>
			input_1_strb <= '1';
			chcks_state_tmp <= REST;
		when PROT_CHCK_UDP =>
			input_2_strb <= '1';
			chcks_state_tmp <= REST;
		when REST =>
			input_1_strb <= '1';
			input_2_strb <= '1';
		when others =>
			chcks_state_tmp <= ETH;
			cnt_tmp <= (others => '0');
		end case;
	elsif (cnt_from_axi_strb = '1') then
		if (chcks_state /= ETH) then
			oe <= '1';
			chcks_state_tmp <= ETH;
		end if;
		cnt_tmp <= (others => '0');
	end if;

end process;


end Behavioral;
