library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm_DMA_TX is
	port (
		clk			: in  std_logic;
		aresetn			: in  std_logic;

		--AXI_Master interface
		DATA_IN 		: in  std_logic_vector(31 downto 0);
		ADDR			: out std_logic_vector(31 downto 0);
		
		INIT_AXI_TXN		: out std_logic;
		AXI_TXN_DONE		: in  std_logic;
		AXI_TXN_STRB		: in  std_logic;
		INIT_AXI_RXN		: out std_logic;
		AXI_RXN_DONE 		: in  std_logic;
		AXI_RXN_STRB		: in  std_logic;
		BURST			: out std_logic_vector(7 downto 0);

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
end fsm_DMA_TX;

architecture fsm_DMA_arch of fsm_DMA_TX is

procedure BURST_SIZE (
		signal BURST 		: out unsigned(7 downto 0);
		signal ADDR_MOD		: in unsigned(1 downto 0);
		signal TX_BYTES_REG 	: in unsigned(31 downto 0))
is
begin
	if (TX_BYTES_REG <= 4) then
		BURST <= (others => '0');
	elsif (TX_BYTES_REG <= 8) then
		BURST <= to_unsigned(1, 8);
	elsif (TX_BYTES_REG <= 12) then
		BURST <= to_unsigned(2, 8);
	elsif (TX_BYTES_REG <= 16) then
		BURST <= to_unsigned(3, 8);
	elsif (TX_BYTES_REG <= 20) then
		BURST <= to_unsigned(4, 8);
	elsif (TX_BYTES_REG <= 24) then
		BURST <= to_unsigned(5, 8);
	elsif (TX_BYTES_REG <= 28) then
		BURST <= to_unsigned(6, 8);
	else
		BURST <= to_unsigned(7, 8);
	end if;		
end BURST_SIZE; 
	

--Descriptor base address
signal TX_DESC_ADDR_REG		: unsigned(31 downto 0);
--Actual descriptor address
signal TX_DESC_ADDR_ACTUAL	: unsigned(31 downto 0);
--Size of descriptor ring
signal TX_SIZE_REG		: unsigned(31 downto 0);
--
signal TX_PRCSSD_REG		: unsigned(31 downto 0);
--
signal TX_BUFF_ADDR		: unsigned(31 downto 0);
signal TX_NEXT_BUFF_ADDR	: unsigned(31 downto 0);
--
signal TX_BUFF_ADDR_MOD		: unsigned(1 downto 0);
--
signal TX_PCKT_SAVE		: unsigned(15 downto 0);
--
signal TX_WRITE_PHASE		: std_logic;
--
signal TX_INCR_STRB_CNT		: unsigned(31 downto 0);
--Packet size in bytes
signal TX_BYTES_REG		: unsigned(31 downto 0);
--Pending packets bytes to send
signal TX_BYTES_ACTUAL		: unsigned(31 downto 0);
--fsm_axi_to_fifo conversion does not allow something
signal TX_FAKE_READ		: std_logic;
signal TX_PRCSSD_INT_S 		: std_logic;
--Size of AXI Burst
signal BURST_S			: unsigned(7 downto 0);
signal TX_BYTES_REG_CNT		: unsigned(31 downto 0);


type tx_states is (
		IDLE,
		FETCH_DESC,
		FETCH_DESC_WAIT_0,
		FETCH_DESC_WAIT_1,
		FETCH_DESC_WAIT_2,
		SET_FLAGS, 
		FETCH_WORDS,
		FETCH_WORDS_WAIT,
		FAKE_TX_STRB,
		PUSH_PCKT_CNT
		);
signal TX_STATE	: tx_states;

begin

TX_PRCSSD 	<= std_logic_vector(TX_PRCSSD_REG);
BURST		<= std_logic_vector(BURST_S);
TX_PRCSSD_INT 	<= TX_PRCSSD_INT_S;

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
			BURST_S <= (others => '0');
			TX_STATE <= IDLE;
		else			

			INIT_AXI_RXN 		<= '0';
			TX_PCKT_DATA_STRB 	<= '0';
			TX_PCKT_CNT_STRB 	<= '0';
			TX_PRCSSD_INT_S 	<= '0';	
	
			--TODO: Move it somewhere else	
			if (TX_PRCSSD_STRB = '1') then
				TX_PRCSSD_REG <= (others => '0');
				if (TX_PRCSSD_INT_S = '1') then
					TX_PRCSSD_REG <= to_unsigned(12, 32);
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
				TX_BYTES_REG_CNT <= (others => '0');
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
							TX_STATE <= FETCH_DESC;
						end if;
					end if;
				end if;

			when FETCH_DESC =>
				ADDR <= std_logic_vector(TX_DESC_ADDR_ACTUAL);
				BURST_S <= to_unsigned(2, 8);
				INIT_AXI_RXN <= '1';
				TX_DESC_ADDR_ACTUAL <= TX_DESC_ADDR_ACTUAL + 12;
				if (TX_DESC_ADDR_ACTUAL + 12 = TX_DESC_ADDR_REG + TX_SIZE_REG) then
					TX_DESC_ADDR_ACTUAL <= TX_DESC_ADDR_REG;
				end if;
				TX_STATE <= FETCH_DESC_WAIT_0;

			when FETCH_DESC_WAIT_0 =>
				if (AXI_RXN_STRB = '1') then
					TX_BYTES_REG <= unsigned(DATA_IN);
					TX_BYTES_ACTUAL <= unsigned(DATA_IN);
					TX_BYTES_REG_CNT <= TX_BYTES_REG_CNT + unsigned(DATA_IN);
					TX_STATE <= FETCH_DESC_WAIT_1; 
				end if;
			when FETCH_DESC_WAIT_1 =>
				if (AXI_RXN_STRB = '1') then
					TX_BUFF_ADDR <= unsigned(DATA_IN(31 downto 2) & "00");
					TX_BUFF_ADDR_MOD <= unsigned(DATA_IN(1 downto 0));
					TX_STATE <= FETCH_DESC_WAIT_2;
				end if;
 			when FETCH_DESC_WAIT_2 =>
				if (AXI_RXN_STRB = '1') then
					TX_NEXT_BUFF_ADDR <= unsigned(DATA_IN);
					TX_STATE <= SET_FLAGS;
				end if;
			when SET_FLAGS =>
				if (AXI_RXN_DONE = '1') then
					TX_STATE <= FETCH_WORDS;	
				else
					TX_STATE <= SET_FLAGS;
				end if;

				TX_WRITE_PHASE <= '0';
				if (TX_BYTES_REG_CNT mod 8 /= 0 and
				    TX_BYTES_REG_CNT mod 8 <= 4) then
					TX_FAKE_READ <= '1';
				else
					TX_FAKE_READ <= '0';
				end if;

			when FETCH_WORDS =>
				ADDR <= std_logic_vector(TX_BUFF_ADDR);
				TX_BUFF_ADDR <= TX_BUFF_ADDR + 32;
				BURST_SIZE(BURST_S, TX_BUFF_ADDR_MOD, 
					   TX_BYTES_ACTUAL);
				INIT_AXI_RXN <= '1';
				TX_STATE <= FETCH_WORDS_WAIT;

			when FETCH_WORDS_WAIT =>
				if (AXI_RXN_STRB = '1' and TX_BYTES_ACTUAL /= 0) then
					case (to_integer(TX_BUFF_ADDR_MOD)) is
					when 0 =>
						if (TX_BYTES_ACTUAL >= 4) then
							TX_BYTES_ACTUAL <= TX_BYTES_ACTUAL - 4;
						else
							TX_BYTES_ACTUAL <= (others => '0');
						end if;

						TX_PCKT_DATA <= DATA_IN;
						TX_PCKT_DATA_STRB <= '1';
						TX_STATE <= FETCH_WORDS_WAIT;
					when 2 =>
						case (TX_WRITE_PHASE) is
						when '0' =>
							TX_PCKT_SAVE <= unsigned(DATA_IN(31 downto 16));
							TX_WRITE_PHASE <= '1';
							TX_STATE <= FETCH_WORDS_WAIT;
						when '1' =>
							TX_PCKT_DATA <= DATA_IN(15 downto 0) &
									std_logic_vector(TX_PCKT_SAVE);
							TX_PCKT_DATA_STRB <= '1';
							TX_PCKT_SAVE <= unsigned(DATA_IN(31 downto 16));
							if (TX_BYTES_ACTUAL >= 4) then
								TX_BYTES_ACTUAL <= TX_BYTES_ACTUAL - 4;
							else
								TX_BYTES_ACTUAL <= (others => '0');
							end if;
					when others =>
						TX_WRITE_PHASE <= '0';
					end case;
				when others =>
				end case;
				elsif (AXI_RXN_DONE = '1') then
					if (TX_BYTES_ACTUAL  > 0) then
						TX_STATE <= FETCH_WORDS;
					elsif (TX_NEXT_BUFF_ADDR /= 0) then
						TX_STATE <= FETCH_DESC;
					elsif (TX_FAKE_READ = '1') then
						TX_STATE <= FAKE_TX_STRB;
					else
						TX_STATE <= PUSH_PCKT_CNT;
					end if;
				else
					TX_STATE <= FETCH_WORDS_WAIT;
				end if;

			when FAKE_TX_STRB =>
				TX_PCKT_DATA <= (others => '0');
				TX_PCKT_DATA_STRB <= '1';
				TX_STATE <= PUSH_PCKT_CNT;
			when PUSH_PCKT_CNT =>
				TX_PCKT_CNT <= std_logic_vector(TX_BYTES_REG_CNT);
				TX_PCKT_CNT_STRB <= '1';
				TX_PRCSSD_INT_S <= '1';
				TX_PRCSSD_REG <= TX_PRCSSD_REG + 12;
				if (TX_PRCSSD_STRB = '1') then
					TX_PRCSSD_REG <= to_unsigned(12, 32);
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
		end if;
	end if;
end process;

end fsm_DMA_arch;

