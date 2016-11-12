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
		AXI_TXN_IN_STRB		: out std_logic;
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
signal RX_FAKE_READ        		: std_logic;
signal XGBE_PCKT_RCV_CNT		: unsigned(31 downto 0);

signal delay_flag			: std_logic;

type rx_states is 
	(
		IDLE,
		SEND_DATA,
		SEND_DATA_WAIT
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
			AXI_TXN_IN_STRB			<= '0';
			INIT_AXI_TXN			<= '0';
			INIT_AXI_RXN			<= '0';
			RX_PCKT_DATA_STRB		<= '0';
			RX_PCKT_CNT_STRB		<= '0';
			RX_PRCSSD_INT_S			<= '0';
			RX_FAKE_READ			<= '0';
			RX_STATE 			<= IDLE;

			delay_flag			<= '0';
		else
			INIT_AXI_TXN 			<= '0';
			INIT_AXI_RXN 			<= '0';
			RX_PCKT_CNT_STRB 		<= '0';
			RX_PCKT_DATA_STRB		<= '0';
			RX_PRCSSD_INT_S			<= '0';
			AXI_TXN_IN_STRB			<= '0';

			if (RX_DESC_ADDR_STRB = '1') then
				RX_DESC_ADDR_REG <= unsigned(RX_DESC_ADDR);
				RX_DESC_ADDR_ACTUAL <= unsigned(RX_DESC_ADDR);
				RX_PRCSSD_REG <= (others => '0');
			end if;
				
			case(RX_STATE) is

			when IDLE =>
				if (XGBE_PCKT_RCV = '1' and DMA_EN = '1') then
					RX_STATE <= SEND_DATA;
				end if;
			when SEND_DATA =>
				ADDR 			<= std_logic_vector(RX_DESC_ADDR_ACTUAL);
				BURST			<= std_logic_vector(to_unsigned(0, 8));
				DATA_OUT 		<= RX_PCKT_CNT;
				RX_BYTES_REG		<= unsigned(RX_PCKT_CNT);
				INIT_AXI_TXN		<= '1';
				RX_STATE 		<= SEND_DATA_WAIT;
			when SEND_DATA_WAIT =>
				if (AXI_TXN_DONE = '1') then
					RX_STATE <= IDLE;
			--		RX_PRCSSD_INT_S	<= '1';
				elsif (AXI_TXN_STRB = '1') then
					AXI_TXN_IN_STRB <= '1';
				end if;	
			when others =>
				RX_STATE <= IDLE;
			end case;
		end if;
	end if;
end process;

end fsm_DMA_RX_arch;
