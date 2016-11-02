library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture tb_arch of tb is

component fsm_DMA_TX is
	port (
		clk			: in  std_logic;
		aresetn			: in  std_logic;

		DATA_IN 		: in  std_logic_vector(31 downto 0);
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

signal DMA_EN		 								: std_logic := '0';
signal TX_PCKT_DATA_STRB, TX_PCKT_CNT_STRB 						: std_logic := '0';

signal DATA_IN, DATA_OUT, ADDR 		: std_logic_vector(31 downto 0) := (others => '0');
signal TX_DESC_ADDR, TX_SIZE, TX_PRCSSD : std_logic_vector(31 downto 0) := (others => '0');
signal TX_PCKT_DATA, TX_PCKT_CNT	: std_logic_vector(31 downto 0) := (others => '0');

signal trig_pckt_cnt_read	: std_logic := '0';
shared variable delay_tim	: time := 0 ns;
begin

fsm_DMA_0 : fsm_DMA_TX
	port map (
		clk => clk,
		aresetn => aresetn,
	
		DATA_IN => DATA_IN,
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
	wait until trig_pckt_cnt_read = '1';
	wait for delay_tim;
	TX_PRCSSD_STRB <= '1';
	wait for 10 ns;
	TX_PRCSSD_STRB <= '0';
end process;

process 
	variable tmp : integer := 0;
	variable cnt : integer := 0;
	begin
	wait for 10 ns;
	TX_DESC_ADDR <= std_logic_vector(to_unsigned(0, 32));
	TX_DESC_ADDR_STRB <= '1';
	wait for 10 ns;
	TX_DESC_ADDR_STRB <= '0';
	TX_SIZE <= std_logic_vector(to_unsigned(128, 32));
	TX_SIZE_STRB <= '1';
	wait for 10 ns;
	TX_SIZE_STRB <= '0';
	DMA_EN <= '1';
	for i in 0 to 9 loop
		wait for 20 ns;
		TX_INCR_STRB <= '1';
		wait for 10 ns;
		TX_INCR_STRB <= '0';
		wait until INIT_AXI_RXN = '1';
		wait until INIT_AXI_RXN = '0';
		DATA_IN <= std_logic_vector(to_unsigned(64, 32));
		wait for 1 ns;
		AXI_RXN_DONE <= '1';
		wait for 10 ns;
		AXI_RXN_DONE <= '0';
		wait until INIT_AXI_RXN = '1';
		wait until INIT_AXI_RXN = '0';
		DATA_IN <= std_logic_vector(to_unsigned(64, 32));
		wait for 1 ns;
		AXI_RXN_DONE <= '1';
		wait for 10 ns;
		AXI_RXN_DONE <= '0';
		wait for 10 ns;
-- Uncomment to test TX_PRCSSD register.
--		if (i = 5) then
--			delay_tim := 510 ns;
--			trig_pckt_cnt_read <= '1';
--			wait for 1 ns;
--			trig_pckt_cnt_read <= '0';
--		end if;
		for j in 0 to 15 loop
			wait until INIT_AXI_RXN = '1';
			wait until INIT_AXI_RXN = '0';
			DATA_IN <= std_logic_vector(to_unsigned(0, 32));
			wait for 1 ns;
			AXI_RXN_DONE <= '1';
			wait for 10 ns;
			AXI_RXN_DONE <= '0';
		end loop;
	end loop;
	wait;
end process;




end tb_arch; 
