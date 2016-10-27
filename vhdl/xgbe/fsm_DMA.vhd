library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity fsm_DMA is

	port (
		clk		: in  std_logic;
		aresetn		: in  std_logic;

		--AXI_Master interface
		DATA_IN 	: in  std_logic_vector(31 downto 0);
		DATA_OUT	: out std_logic_vector(31 downto 0);
		ADDR		: out std_logic_vector(31 downto 0);
		
		INIT_AXI_TXN	: out std_logic;
		AXI_TXN_DONE	: in  std_logic;
		INIT_AXI_RXN	: out std_logic;
		AXI_RXN_DONE 	: in  std_logic;

		--physical address of TX DMA ring created by linux.
		TX_ADDR		: in std_logic_vector(31 downto 0);
		TX_ADDR_STRB 	: in std_logic;
		--size of TX DMA ring (in DMA descriptors count).
		TX_CNT		: in std_logic_vector(31 downto 0);
		TX_CNT_STRB	: in std_logic;
	
		--signal TX DMA to fetch one TX DMA descriptor and process.
		TX_INCR_STRB	: in std_logic;

		--Processed TX descriptors count from the last read.
		TX_PRCSSD	: out std_logic_vector(31 downto 0);
		--Processed TX descriptors count read strobe (resets counter).
		TX_PRCSSD_STRB	: in std_logic;
		--Processed TX descriptor interrupt.
		TX_PRCSSD_INT	: out std_logic;

		--physical address of RX DMA ring created by linux.
		RX_ADDR		: in std_logic_vector(31 downto 0);
		RX_ADDR_STRB 	: in std_logic;
		--size of RX DMA ring (in DMA descriptors count).
		RX_CNT		: in std_logic_vector(31 downto 0);
		RX_CNT_STRB	: in std_logic;

		--Processed RX descriptors count from the last read.
		RX_PRCSSD	: out std_logic_vector(31 downto 0);
		--Processed RX descriptors count read strobe (resets counter).
		RX_PRCSSD_STRB	: in std_logic;
		--Processed RX descriptor interrupt.
		RX_PRCSSD_INT	: out std_logic;

		--Packet received strobe.
		XGBE_PACKET_RCV	: in std_logic;
		--Enable MAC to work.
		--(ensure that DMA rings are set.).
		DMA_EN		: in std_logic;
	);
end fsm_DMA;

architecture fsm_DMA_arch of fsm_DMA is



begin

end fsm_DMA_arch;
