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
		
		INIT_AXI_TXN	: out std_logic;
		AXI_TXN_DONE	: in  std_logic;
		INIT_AXI_RXN	: out std_logic;
		AXI_RXN_DONE 	: in  std_logic;

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


	);
