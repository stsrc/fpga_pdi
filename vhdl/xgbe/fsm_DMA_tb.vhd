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
	wait for 11 ns;
	TX_DESC_ADDR <= std_logic_vector(to_unsigned(10, 32));
	TX_DESC_ADDR_STRB <= '1';
	wait for 10 ns;
	TX_DESC_ADDR_STRB <= '0';
	TX_SIZE <= std_logic_vector(to_unsigned(128, 32));
	TX_SIZE_STRB <= '1';
	wait for 10 ns;
	TX_SIZE_STRB <= '0';
	DMA_EN <= '1';

	for j in 0 to 1 loop
		TX_INCR_STRB <= '1';
		wait for 10 ns;
		TX_INCR_STRB <= '0';
		wait for 10 ns;
		assert INIT_AXI_RXN = '1' report "1." severity failure;
		assert ADDR = std_logic_vector(to_unsigned(10 + 8 * j, 32)) report "2." severity failure;
		wait for 10 ns;
		assert INIT_AXI_RXN = '0' report "2." severity failure;
		DATA_IN <= std_logic_vector(to_unsigned(9 + 8 * j, 32));
		AXI_RXN_DONE <= '1';
		wait for 10 ns;
		AXI_RXN_DONE <= '0';
		wait for 10 ns;
		assert INIT_AXI_RXN = '1' report "3." severity failure;
		assert ADDR = std_logic_vector(to_unsigned(10 + 8*j + 4, 32)) report "4." severity failure;
		wait for 10 ns;
		assert INIT_AXI_RXN = '0' report "5." severity failure;
		DATA_IN <= std_logic_vector(to_unsigned(64, 32));
		AXI_RXN_DONE <= '1';
		wait for 10 ns;
		AXI_RXN_DONE <= '0';
		wait for 10 ns;

		for i in 0 to 2 * (1 + j) loop
			assert INIT_AXI_RXN = '1' report "6." severity failure;
			assert ADDR = std_logic_vector(to_unsigned(64 + i * 4, 32));
			wait for 10 ns;
			assert INIT_AXI_RXN = '0' report "7." severity failure;
			DATA_IN <= std_logic_vector(to_unsigned(90 + 5 * i, 32));
			AXI_RXN_DONE <= '1';
			wait for 10 ns;
			AXI_RXN_DONE <= '0';
			assert TX_PCKT_DATA = std_logic_vector(to_unsigned(90 + 5 * i, 32)) report "8." severity failure;
			assert TX_PCKT_DATA_STRB = '1' report "9." severity failure;
			wait for 10 ns;
		end loop;

		assert TX_PCKT_DATA = std_logic_vector(to_unsigned(0, 32)) report "8." severity failure;
		assert TX_PCKT_DATA_STRB = '1' report "8." severity failure;
		wait for 10 ns;
		assert TX_PCKT_CNT = std_logic_vector(to_unsigned(9 + 8 * j, 32)) report "9." severity failure;
		assert TX_PCKT_CNT_STRB = '1' report "10." severity failure;
		assert TX_PRCSSD_INT = '1' report "12." severity failure;
		wait for 10 ns;
	end loop;

	assert TX_PCKT_CNT_strb = '0' report "11." severity failure;
	assert TX_PRCSSD = std_logic_vector(to_unsigned(16 , 32)) report "12." severity failure;
	TX_PRCSSD_STRB <= '1';
	wait for 10 ns;
	TX_PRCSSD_STRB <= '0';
	wait;
end process;

end tb_arch; 
