library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm_DMA is
	port (
		clk			: in  std_logic;
		aresetn			: in  std_logic;

		--AXI_Master interface
		DATA_IN 		: in  std_logic_vector(31 downto 0);
		DATA_OUT		: out std_logic_vector(31 downto 0);
		ADDR			: out std_logic_vector(31 downto 0);
		
		INIT_AXI_TXN		: out std_logic;
		AXI_TXN_DONE		: in  std_logic;
		INIT_AXI_RXN		: out std_logic;
		AXI_RXN_DONE 		: in  std_logic;

		--physical address of TX DMA ring created by linux.
		TX_DESC_ADDR		: in std_logic_vector(31 downto 0);
		TX_DESC_ADDR_STRB 	: in std_logic;
		--size of TX DMA ring (in bytes).
		TX_SIZE			: in std_logic_vector(31 downto 0);
		TX_SIZE_STRB		: in std_logic;
	
		--signal TX DMA to fetch one TX DMA descriptor and process.
		TX_INCR_STRB		: in std_logic;

		--Processed TX descriptors size.
		TX_PRCSSD		: out std_logic_vector(31 downto 0);
		--Processed TX descriptors size read strobe (resets counter).
		TX_PRCSSD_STRB		: in std_logic;
		--Processed TX descriptor interrupt.
		TX_PRCSSD_INT		: out std_logic;

		--physical address of RX DMA ring created by linux.
		RX_ADDR			: in std_logic_vector(31 downto 0);
		RX_ADDR_STRB 		: in std_logic;
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
		XGBE_PACKET_RCV		: in std_logic;
		--Enable MAC to work.
		--(ensure that DMA rings are set.).
		DMA_EN			: in std_logic;

		--TX data output
		TX_PCKT_DATA		: out std_logic_vector(31 downto 0);
		TX_PCKT_DATA_STRB	: out std_logic;
		--TX packet size output
		TX_PCKT_CNT		: out std_logic_vector(31 downto 0);
		TX_PCKT_CNT_STRB	: out std_logic
	);
end fsm_DMA;

architecture fsm_DMA_arch of fsm_DMA is

signal TX_DESC_ADDR_REG, TX_SIZE_REG	: unsigned(31 downto 0);
signal TX_PRCSSD_REG			: unsigned(31 downto 0);
signal TX_DESC_ADDR_ACTUAL		: unsigned(31 downto 0);
signal TX_BUFF_ADDR			: unsigned(31 downto 0);
signal TX_BUFF_ADDR_MOD			: unsigned(1 downto 0);
signal TX_PCKT_SAVE			: unsigned(15 downto 0);

signal TX_WRITE_PHASE			: std_logic;

signal TX_INCR_STRB_CNT			: unsigned(31 downto 0);

signal TX_BYTES_REG		: unsigned(31 downto 0);
signal TX_BYTES_ACTUAL		: unsigned(31 downto 0);

signal TX_FAKE_READ		: std_logic;
signal TX_PRCSSD_INT_S 		: std_logic;

type tx_states is (
		IDLE,
		FETCH_CNT,
		FETCH_CNT_WAIT,
		FETCH_PTR, 
		FETCH_PTR_WAIT,
		SET_FLAGS, 
		FETCH_WORD,
		FETCH_WORD_WAIT,
		FAKE_TX_STRB,
		PUSH_PCKT_CNT
		);
signal TX_STATE	: tx_states;

begin

TX_PRCSSD <= std_logic_vector(TX_PRCSSD_REG);
TX_PRCSSD_INT <= TX_PRCSSD_INT_S;

process(clk) begin
	if (rising_edge(clk)) then
		if (aresetn = '0') then
			ADDR <= (others => '0');
			TX_DESC_ADDR_REG <= (others => '0');
			TX_SIZE_REG <= (others => '0');
			TX_PRCSSD_REG <= (others => '0');
			TX_DESC_ADDR_ACTUAL <= (others => '0');
			TX_BUFF_ADDR <= (others => '0');
			TX_BUFF_ADDR_MOD <= (others => '0');
			TX_PCKT_SAVE <= (others => '0');
			TX_WRITE_PHASE <= '0';
			TX_INCR_STRB_CNT <= (others => '0');	
			TX_BYTES_REG <= (others => '0');
			TX_BYTES_ACTUAL <= (others => '0');
			TX_FAKE_READ <= '0';
			TX_PRCSSD_INT_S <= '0';

			INIT_AXI_RXN <= '0';
			TX_PCKT_CNT <= (others => '0');
			TX_PCKT_DATA <= (others => '0');
			TX_PCKT_DATA_STRB <= '0';
			TX_PCKT_CNT_STRB <= '0';
		else			

			INIT_AXI_RXN <= '0';
			TX_PCKT_DATA_STRB <= '0';
			TX_PCKT_CNT_STRB <= '0';
			TX_PRCSSD_INT_S <= '0';	
	
			--TODO: Move it somewhere else	
			if (TX_PRCSSD_STRB = '1') then
				TX_PRCSSD_REG <= (others => '0');
				if (TX_PRCSSD_INT_S = '1') then
					TX_PRCSSD_REG <= to_unsigned(8, 32);
				end if;
			end if;
			
			--TODO: Move it somewhere else
			if (TX_INCR_STRB = '1' and DMA_EN = '1') then
				if (TX_STATE /= PUSH_PCKT_CNT) then
					if (TX_PRCSSD_REG /= TX_SIZE_REG) then 
						TX_INCR_STRB_CNT <= TX_INCR_STRB_CNT + 1;
					else
						TX_INCR_STRB_CNT <= TX_INCR_STRB_CNT;
					end if;
				else
					TX_INCR_STRB_CNT <= TX_INCR_STRB_CNT;
				end if;
			else
				if (TX_STATE = PUSH_PCKT_CNT) then
					TX_INCR_STRB_CNT <= TX_INCR_STRB_CNT - 1;
				end if;
			end if;

			case(TX_STATE) is
			when IDLE =>
				if (TX_DESC_ADDR_STRB = '1') then
					TX_DESC_ADDR_REG <= unsigned(TX_DESC_ADDR);
					TX_DESC_ADDR_ACTUAL <= unsigned(TX_DESC_ADDR);
					TX_PRCSSD_REG <= (others => '0');
					TX_INCR_STRB_CNT <= (others => '0');
				elsif (TX_SIZE_STRB = '1') then
					TX_SIZE_REG <= unsigned(TX_SIZE);
					TX_DESC_ADDR_ACTUAL <= TX_DESC_ADDR_REG;
					TX_PRCSSD_REG <= (others => '0');
					TX_INCR_STRB_CNT <= (others => '0');
				else
					if(TX_INCR_STRB_CNT /= 0) then
						if (TX_PRCSSD_REG = TX_SIZE_REG) then
							TX_STATE <= IDLE;
						else
							TX_STATE <= FETCH_CNT;
						end if;
					end if;
				end if;

			when FETCH_CNT =>
				ADDR <= std_logic_vector(TX_DESC_ADDR_ACTUAL);
				INIT_AXI_RXN <= '1';	
				TX_DESC_ADDR_ACTUAL <= TX_DESC_ADDR_ACTUAL + 4;
				TX_STATE <= FETCH_CNT_WAIT;

			when FETCH_CNT_WAIT =>
				INIT_AXI_RXN <= '0';
				if (AXI_RXN_DONE = '1') then
					TX_BYTES_REG <= unsigned(DATA_IN);
					TX_BYTES_ACTUAL <= unsigned(DATA_IN);

					TX_STATE <= FETCH_PTR; 
				else
					TX_STATE <= FETCH_CNT_WAIT;
				end if;

			when FETCH_PTR =>
				ADDR <= std_logic_vector(TX_DESC_ADDR_ACTUAL);
				INIT_AXI_RXN <= '1';
				TX_DESC_ADDR_ACTUAL <= TX_DESC_ADDR_ACTUAL + 4;

				if (TX_DESC_ADDR_ACTUAL + 4 = TX_DESC_ADDR_REG + TX_SIZE_REG) then
					TX_DESC_ADDR_ACTUAL <= TX_DESC_ADDR_REG;
				end if;
				TX_STATE <= FETCH_PTR_WAIT;

			when FETCH_PTR_WAIT =>
				if (AXI_RXN_DONE = '1') then
					TX_BUFF_ADDR <= unsigned(DATA_IN(31 downto 2) & "00");
					TX_BUFF_ADDR_MOD <= unsigned(DATA_IN(1 downto 0));
					TX_STATE <= SET_FLAGS;
				else
					TX_STATE <= FETCH_PTR_WAIT;
				end if; 
			when SET_FLAGS =>
				TX_STATE <= FETCH_WORD;	
				TX_WRITE_PHASE <= '0';
				if (TX_BYTES_REG mod 8 /= 0 and
				    TX_BYTES_REG mod 8 <= 4) then
					TX_FAKE_READ <= '1';
				else
					TX_FAKE_READ <= '0';
				end if;
			when FETCH_WORD =>
				ADDR <= std_logic_vector(TX_BUFF_ADDR);
				TX_BUFF_ADDR <= TX_BUFF_ADDR + 4;
				if (TX_BYTES_ACTUAL <= 4) then
					TX_BYTES_ACTUAL <= (others => '0');
				else
					TX_BYTES_ACTUAL <= TX_BYTES_ACTUAL - 4;
					if ((TX_BUFF_ADDR_MOD /= 0) and (TX_WRITE_PHASE = '0')) then
						TX_BYTES_ACTUAL <= TX_BYTES_ACTUAL;
					end if;
				end if;
				INIT_AXI_RXN <= '1';
				TX_STATE <= FETCH_WORD_WAIT;

			when FETCH_WORD_WAIT =>
				if (AXI_RXN_DONE = '1') then
					case to_integer(TX_BUFF_ADDR_MOD) is
					when 0 =>
						TX_PCKT_DATA <= DATA_IN;
						TX_PCKT_DATA_STRB <= '1';
					when 2 =>
						case (TX_WRITE_PHASE) is
						when '0' =>
							TX_PCKT_SAVE <= unsigned(DATA_IN(31 downto 16));
							TX_WRITE_PHASE <= '1';
						when '1' =>
							TX_PCKT_DATA <= DATA_IN(15 downto 0) & 
									std_logic_vector(TX_PCKT_SAVE);
							TX_PCKT_SAVE <= unsigned(DATA_IN(31 downto 16));
							TX_PCKT_DATA_STRB <= '1';
							TX_WRITE_PHASE <= '1';					
						when others =>
							TX_WRITE_PHASE <= '0';
						end case;					
					when others =>
						
					end case;

					if (TX_BYTES_ACTUAL > 0) then
						TX_STATE <= FETCH_WORD;
					elsif (TX_FAKE_READ = '1') then
						TX_STATE <= FAKE_TX_STRB;
					else
						TX_STATE <= PUSH_PCKT_CNT;
					end if;

				else
					TX_STATE <= FETCH_WORD_WAIT;
				end if;
			when FAKE_TX_STRB =>
				TX_PCKT_DATA <= (others => '0');
				TX_PCKT_DATA_STRB <= '1';
				TX_STATE <= PUSH_PCKT_CNT;
			when PUSH_PCKT_CNT =>
				TX_PCKT_CNT <= std_logic_vector(TX_BYTES_REG);
				TX_PCKT_CNT_STRB <= '1';
				TX_PRCSSD_INT_S <= '1';
				TX_PRCSSD_REG <= TX_PRCSSD_REG + 8;
				if (TX_PRCSSD_STRB = '1') then
					TX_PRCSSD_REG <= to_unsigned(8, 32);
				end if;
				TX_STATE <= IDLE;
			when others =>
				TX_STATE <= IDLE;
			end case;	
		end if;
	end if;
end process;

process (clk) begin
	if (rising_edge(clk)) then
		if (aresetn = '0') then
			INIT_AXI_TXN <= '0';
			RX_PRCSSD <= (others => '0');
			RX_PRCSSD_INT <= '0';
			DATA_OUT <= (others => '0');	
		end if;
	end if;
end process;

end fsm_DMA_arch;

