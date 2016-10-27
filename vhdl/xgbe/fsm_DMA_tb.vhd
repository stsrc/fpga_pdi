library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture tb_arch of tb is

component  fsm_DMA is
	port (
		clk			: in  std_logic;
		aresetn			: in  std_logic;

		DATA_IN 		: in  std_logic_vector(31 downto 0);
		DATA_OUT		: out std_logic_vector(31 downto 0);
		ADDR			: out std_logic_vector(31 downto 0);		
		INIT_AXI_TXN		: out std_logic;
		AXI_TXN_DONE		: in  std_logic;
		INIT_AXI_RXN		: out std_logic;
		AXI_RXN_DONE 		: in  std_logic;

		TX_DESC_ADDR		: in std_logic_vector(31 downto 0);
		TX_DESC_ADDR_STRB 	: in std_logic;
		TX_SIZE			: in std_logic_vector(31 downto 0);
		TX_SIZE_STRB		: in std_logic;
		TX_INCR_STRB		: in std_logic;
		TX_PRCSSD		: out std_logic_vector(31 downto 0);
		TX_PRCSSD_STRB		: in std_logic;
		TX_PRCSSD_INT		: out std_logic;

		RX_ADDR			: in std_logic_vector(31 downto 0);
		RX_ADDR_STRB 		: in std_logic;
		RX_SIZE			: in std_logic_vector(31 downto 0);
		RX_SIZE_STRB		: in std_logic;
		RX_PRCSSD		: out std_logic_vector(31 downto 0);
		RX_PRCSSD_STRB		: in std_logic;
		RX_PRCSSD_INT		: out std_logic;

		XGBE_PACKET_RCV		: in std_logic;
		DMA_EN			: in std_logic;

		TX_PCKT_DATA		: out std_logic_vector(31 downto 0);
		TX_PCKT_DATA_STRB	: out std_logic;
		TX_PCKT_CNT		: out std_logic_vector(31 downto 0);
		TX_PCKT_CNT_STRB	: out std_logic
	);
end component;

signal clk, aresetn 									: std_logic := '0';
signal INIT_AXI_TXN, AXI_TXN_DONE, INIT_AXI_RXN, AXI_RXN_DONE 				: std_logic := '0';
signal TX_DESC_ADDR_STRB, TX_SIZE_STRB, TX_INCR_STRB, TX_PRCSSD_STRB, TX_PRCSSD_INT 	: std_logic := '0';
signal RX_ADDR_STRB, RX_SIZE_STRB, RX_PRCSSD_STRB, RX_PRCSSD_INT 			: std_logic := '0';
signal XGBE_PACKET_RCV, DMA_EN 								: std_logic := '0';
signal TX_PCKT_DATA_STRB, TX_PCKT_CNT_STRB 						: std_logic := '0';

signal DATA_IN, DATA_OUT, ADDR 		: std_logic_vector(31 downto 0) := (others => '0');
signal TX_DESC_ADDR, TX_SIZE, TX_PRCSSD : std_logic_vector(31 downto 0) := (others => '0');
signal RX_ADDR, RX_SIZE, RX_PRCSSD	: std_logic_vector(31 downto 0) := (others => '0');
signal TX_PCKT_DATA, TX_PCKT_CNT	: std_logic_vector(31 downto 0) := (others => '0');

begin

fsm_DMA_0 : fsm_DMA
	port map (
		clk => clk,
		aresetn => aresetn,
	
		DATA_IN => DATA_IN,
		DATA_OUT => DATA_OUT,
		ADDR => ADDR,
		INIT_AXI_TXN => INIT_AXI_TXN,
		AXI_TXN_DONE => AXI_TXN_DONE,
		INIT_AXI_RXN => INIT_AXI_RXN,
		AXI_RXN_DONE => AXI_RXN_DONE,
		TX_DESC_ADDR => TX_DESC_ADDR,
		TX_DESC_ADDR_STRB => TX_DESC_ADDR_STRB,
		TX_SIZE => TX_SIZE,
		TX_SIZE_STRB => TX_SIZE_STRB,
		TX_INCR_STRB => TX_INCR_STRB,
		TX_PRCSSD => TX_PRCSSD,
		TX_PRCSSD_STRB => TX_PRCSSD_STRB,
		TX_PRCSSD_INT => TX_PRCSSD_INT,
		RX_ADDR => RX_ADDR,
		RX_ADDR_STRB => RX_ADDR_STRB,
		RX_SIZE => RX_SIZE,
		RX_SIZE_STRB => RX_SIZE_STRB,
		RX_PRCSSD => RX_PRCSSD,
		RX_PRCSSD_STRB => RX_PRCSSD_STRB,
		RX_PRCSSD_INT => RX_PRCSSD_INT,
		XGBE_PACKET_RCV => XGBE_PACKET_RCV,
		DMA_EN => DMA_EN,
		TX_PCKT_DATA => TX_PCKT_DATA,
		TX_PCKT_DATA_STRB => TX_PCKT_DATA_STRB,
		TX_PCKT_CNT => TX_PCKT_CNT,
		TX_PCKT_CNT_STRB => TX_PCKT_CNT_STRB
	);

process begin
	clk <= '1';
	wait for 5 ns;
	clk <= '0';
	wait for 5 ns;
end process;

process begin
	aresetn <= '0';
	wait for 10 ns;
	aresetn <= '1';
	wait;
end process;

process begin
	wait until aresetn = '1';
	TX_DESC_ADDR <= std_logic_vector(to_unsigned(10, 32));
	TX_DESC_ADDR_STRB <= '1';
	wait for 10 ns;
	TX_DESC_ADDR_STRB <= '0';
	TX_SIZE <= std_logic_vector(to_unsigned(16, 32));
	TX_SIZE_STRB <= '1';
	wait for 10 ns;
	TX_SIZE_STRB <= '0';
	DMA_EN <= '1';
	TX_INCR_STRB <= '1';
	wait for 10 ns;
	--state FETCH_CNT 
	TX_INCR_STRB <= '0';
	assert INIT_AXI_RXN = '1' report "Wrong 1." severity failure;
	assert ADDR = std_logic_vector(to_unsigned(10, 32)) report "Wrong 2." severity failure;
	wait for 20 ns;
	--state FETCH_CNT_WAIT
	DATA_IN <= std_logic_vector(to_unsigned(9, 32));
	AXI_RXN_DONE <= '1';
	wait for 10 ns;
	--state FETCH PTR
	AXI_RXN_DONE <= '0';
	assert INIT_AXI_RXN = '1' report "Wrong 4." severity failure;
	assert ADDR = std_logic_vector(to_unsigned(14, 32)) report "Wrong 5." severity failure;
	wait for 20 ns;
	--state FETCH_PTR_WAIT
	DATA_IN <= std_logic_vector(to_unsigned(64, 32));
	AXI_RXN_DONE <= '1';
	wait for 10 ns;
	--state FETCH_WORD
	AXI_RXN_DONE <= '0';
	assert INIT_AXI_RXN = '1' report "Wrong 6." severity failure;
	assert ADDR = std_logic_vector(to_unsigned(14, 32)) report "Wrong 7." severity failure;
	wait for 20 ns;
	--state FETCH_WORD_WAIT
	DATA_IN <= std_logic_vector(to_unsigned(1, 32));
	AXI_RXN_DONE <= '1';
	assert TX_PCKT_DATA = std_logic_vector(to_unsigned(1, 32)) report "Wrong 8." severity failure;
	assert TX_PCKT_DATA_STRB = '1' report "Wrong 9." severity failure;
	wait for 10 ns;
	AXI_RXN_DONE <= '0';
	wait;
end process;

end tb_arch; 
