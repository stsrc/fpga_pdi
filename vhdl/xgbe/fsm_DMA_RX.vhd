library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm_DMA_RX is
	port (
		clk	: in std_logic;
		aresetn	: in std_logic;
	
		--AXI_Master interface
		DATA_IN 	: in  std_logic_vector(31 downto 0);
		DATA_OUT	: out std_logic_vector(31 downto 0);
		ADDR		: out std_logic_vector(31 downto 0);
		
		INIT_AXI_TXN		: out std_logic;
		AXI_TXN_DONE		: in  std_logic;
		AXI_TXN_STRB		: in  std_logic;
		INIT_AXI_RXN		: out std_logic;
		AXI_RXN_DONE 		: in  std_logic;
		AXI_RXN_STRB		: in  std_logic;
		BURST			: out std_logic_vector(7 downto 0);

		--physical address of RX DMA ring created by linux.
		RX_DESC_ADDR		: in std_logic_vector(31 downto 0);
		RX_DESC_ADDR_STRB 	: in std_logic;
		--size of RX DMA ring (in bytes).
		RX_SIZE			: in std_logic_vector(31 downto 0);
		RX_SIZE_STRB		: in std_logic;

		--Processed RX descriptors size from the last read.
		RX_PRCSSD		: out std_logic_vector(31 downto 0);
		--Processed RX descriptors size read strobe (resets counter).
		RX_PRCSSD_STRB		: in std_logic;
		--Processed RX descriptor interrupt.
		RX_PRCSSD_INT		: out std_logic;

		--Packet received strobe.
		XGBE_PCKT_RCV		: in std_logic;
		--Enable MAC to work.
		--(ensure that DMA rings are set.).
		DMA_EN			: in std_logic;
		RCV_EN			: in std_logic;
		RX_PCKT_DATA		: in std_logic_vector(31 downto 0);
		RX_PCKT_DATA_STRB	: out std_logic;

		RX_PCKT_CNT		: in std_logic_vector(31 downto 0);
		RX_PCKT_CNT_STRB	: out std_logic	
	);
end fsm_DMA_RX;

architecture fsm_DMA_RX_arch of fsm_DMA_RX is

signal RX_BYTES_REG			: unsigned(31 downto 0);
signal RX_DESC_ADDR_REG 		: unsigned(31 downto 0);
signal RX_SIZE_REG			: unsigned(31 downto 0);
signal RX_DESC_ADDR_ACTUAL		: unsigned(31 downto 0);
signal RX_PRCSSD_REG			: unsigned(31 downto 0);
signal RX_PRCSSD_INT_S			: std_logic;
signal RX_BUFF_ADDR			: unsigned(31 downto 0);
signal RX_FAKE_READ         : std_logic;

signal XGBE_PCKT_RCV_CNT		: unsigned(31 downto 0);

type rx_states is 
	(
		IDLE,
		SET_CNT,
		SET_CNT_WAIT,
		FETCH_DESC_WAIT,
		WRITE_WORD,
		WRITE_WORD_WAIT,
		FAKE_RX_STRB
	);
signal RX_STATE : rx_states;

begin
	RX_PRCSSD <= std_logic_vector(RX_PRCSSD_REG);
	RX_PRCSSD_INT	<= RX_PRCSSD_INT_S;

process(clk) begin
	if (rising_edge(clk)) then
		if (aresetn = '0') then
 			RX_BYTES_REG			<= (others => '0');
			RX_DESC_ADDR_REG 		<= (others => '0');
			RX_SIZE_REG			<= (others => '0');
			RX_PRCSSD_REG			<= (others => '0');
			RX_DESC_ADDR_ACTUAL		<= (others => '0');
			RX_BUFF_ADDR			<= (others => '0');
			BURST 				<= (others => '0');
			DATA_OUT			<= (others => '0');
			ADDR 				<= (others => '0');
			XGBE_PCKT_RCV_CNT		<= (others => '0');
			INIT_AXI_TXN			<= '0';
			INIT_AXI_RXN			<= '0';
			RX_PCKT_DATA_STRB		<= '0';
			RX_PCKT_CNT_STRB		<= '0';
			RX_PRCSSD_INT_S			<= '0';
			RX_FAKE_READ			<= '0';
			RX_STATE 			<= IDLE;
		else
			INIT_AXI_TXN 			<= '0';
			INIT_AXI_RXN 			<= '0';
			RX_PCKT_CNT_STRB 		<= '0';
			RX_PCKT_DATA_STRB		<= '0';
			RX_PRCSSD_INT_S			<= '0';

			--TODO: Move it somewhere else	
			if (RX_PRCSSD_STRB = '1') then
				RX_PRCSSD_REG <= (others => '0');
				if (RX_PRCSSD_INT_S = '1') then
					RX_PRCSSD_REG <= to_unsigned(8, 32);
				end if;
			end if;

			if (RX_DESC_ADDR_STRB = '1') then
				RX_DESC_ADDR_REG <= unsigned(RX_DESC_ADDR);
				RX_DESC_ADDR_ACTUAL <= unsigned(RX_DESC_ADDR);
				RX_PRCSSD_REG <= (others => '0');
			
			elsif (RX_SIZE_STRB = '1') then
				RX_SIZE_REG <= unsigned(RX_SIZE);
				RX_DESC_ADDR_ACTUAL <= RX_DESC_ADDR_REG;
				RX_PRCSSD_REG <= (others => '0');
			
			end if;
		

			if (XGBE_PCKT_RCV = '1' and RCV_EN = '1') then
				if (RX_STATE = WRITE_WORD_WAIT 
					and AXI_TXN_DONE = '1' 
					and RX_BYTES_REG = 0)
				then
					XGBE_PCKT_RCV_CNT <= XGBE_PCKT_RCV_CNT;
				else
					if (RX_PRCSSD_REG /= RX_SIZE_REG) then 
						XGBE_PCKT_RCV_CNT <= XGBE_PCKT_RCV_CNT + 1;
					else
						XGBE_PCKT_RCV_CNT <= XGBE_PCKT_RCV_CNT;
					end if;
				end if;
			else
				if (RX_STATE = WRITE_WORD_WAIT 
					and AXI_TXN_DONE = '1' and
					RX_BYTES_REG = 0)
				then
					XGBE_PCKT_RCV_CNT <= XGBE_PCKT_RCV_CNT - 1;
				end if;
			end if;
	
			case(RX_STATE) is
			when IDLE =>
				if (XGBE_PCKT_RCV_CNT /= 0 and DMA_EN = '1') then
					if (RX_PRCSSD_REG = RX_SIZE_REG) then
						RX_STATE <= IDLE;
					else
						RX_STATE <= SET_CNT; 
					end if;
				end if;
			when SET_CNT =>
				ADDR 			<= std_logic_vector(RX_DESC_ADDR_ACTUAL);
				RX_DESC_ADDR_ACTUAL	<= RX_DESC_ADDR_ACTUAL + 4;
				BURST			<= std_logic_vector(to_unsigned(0, 8));
				DATA_OUT 		<= RX_PCKT_CNT;
				RX_BYTES_REG		<= unsigned(RX_PCKT_CNT);
				RX_PCKT_CNT_STRB 	<= '1';
				INIT_AXI_TXN		<= '1';
				RX_STATE <= SET_CNT_WAIT;

				if (unsigned(RX_PCKT_CNT) mod 8 /= 0 and
				    unsigned(RX_PCKT_CNT) mod 8 <= 4) then
					RX_FAKE_READ <= '1';
				else
					RX_FAKE_READ <= '0';
	            end if;
	            
			when SET_CNT_WAIT =>
				if (AXI_TXN_DONE = '1') then
					ADDR 			<= std_logic_vector(RX_DESC_ADDR_ACTUAL);

					if(RX_DESC_ADDR_ACTUAL + 4 = RX_DESC_ADDR_REG + RX_SIZE_REG) then
						RX_DESC_ADDR_ACTUAL <= RX_DESC_ADDR_REG;
					else
						RX_DESC_ADDR_ACTUAL <= RX_DESC_ADDR_ACTUAL + 4;
					end if;

					INIT_AXI_RXN		<= '1';
					RX_STATE		<= FETCH_DESC_WAIT;
				else
					RX_STATE		<= SET_CNT_WAIT;
				end if;
			when FETCH_DESC_WAIT =>
				if (AXI_RXN_DONE = '1') then
					RX_BUFF_ADDR 	<= unsigned(DATA_IN);
					RX_STATE	<= WRITE_WORD;
				else
					RX_STATE	<= FETCH_DESC_WAIT;
				end if;
			when WRITE_WORD	=>
				BURST 			<= std_logic_vector(to_unsigned(7, 8));
				ADDR			<= std_logic_vector(RX_BUFF_ADDR);
				RX_BUFF_ADDR 		<= RX_BUFF_ADDR + 32;
				DATA_OUT		<= RX_PCKT_DATA;
				RX_PCKT_DATA_STRB	<= '1';	
				INIT_AXI_TXN 		<= '1';
				RX_STATE 		<= WRITE_WORD_WAIT;

				if(RX_BYTES_REG >= 4) then
					RX_BYTES_REG <= RX_BYTES_REG - 4;
				else
					RX_BYTES_REG <= (others => '0');
				end if;

			when WRITE_WORD_WAIT =>
				if (AXI_TXN_DONE = '1') then
					if (RX_BYTES_REG = 0) then
						if (RX_FAKE_READ = '1') then
							RX_STATE 	<= FAKE_RX_STRB;
						else
							RX_STATE	<= IDLE;
						end if;
						RX_PRCSSD_INT_S <= '1';
						if (RX_PRCSSD_STRB = '0') then
							RX_PRCSSD_REG	<= RX_PRCSSD_REG + 8;
						else
							RX_PRCSSD_REG 	<= to_unsigned(8, 32);
						end if;
					else
						RX_STATE <= WRITE_WORD;
					end if;
				elsif (AXI_TXN_STRB = '1' and RX_BYTES_REG /= 0) then

					if(RX_BYTES_REG >= 4) then
						RX_BYTES_REG <= RX_BYTES_REG - 4;
					else
						RX_BYTES_REG <= (others => '0');
					end if;

					DATA_OUT <= RX_PCKT_DATA;
					RX_PCKT_DATA_STRB <= '1';
				else
					RX_STATE <= WRITE_WORD_WAIT;
				end if;
			when FAKE_RX_STRB =>
				RX_PCKT_DATA_STRB <= '1';
				RX_FAKE_READ <= '0';
				RX_STATE <= IDLE;
			when others =>
				RX_STATE <= IDLE;
			end case;
		end if;
	end if;
end process;

end fsm_DMA_RX_arch;
