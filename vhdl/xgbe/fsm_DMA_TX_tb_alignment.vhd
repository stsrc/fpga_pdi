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
		AXI_TXN_STRB		: in  std_logic;
		INIT_AXI_RXN		: out std_logic;
		AXI_RXN_DONE 		: in  std_logic;
		AXI_RXN_STRB		: in  std_logic;
		BURST			: out std_logic_vector(7 downto 0);

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
signal TX_PCKT_DATA_STRB, TX_PCKT_CNT_STRB 						: std_logic := '0';
signal AXI_RXN_STRB, AXI_TXN_STRB							: std_logic := '0';

signal DMA_EN 								: std_logic := '0';
signal DATA_IN, DATA_OUT, ADDR 		: std_logic_vector(31 downto 0) := (others => '0');
signal TX_DESC_ADDR, TX_SIZE, TX_PRCSSD : std_logic_vector(31 downto 0) := (others => '0');
signal TX_PCKT_DATA, TX_PCKT_CNT	: std_logic_vector(31 downto 0) := (others => '0');
signal BURST 				: std_logic_vector(7 downto 0) 	:= (others => '0');

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
		BURST => BURST,
		AXI_RXN_STRB => AXI_RXN_STRB,
		AXI_TXN_STRB => AXI_TXN_STRB,
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
	TX_INCR_STRB <= '1';
    wait for 10 ns;
    TX_INCR_STRB <= '0';
    wait for 10 ns;
    TX_INCR_STRB <= '1';
    wait for 10 ns;
    TX_INCR_STRB <= '0';
    wait for 10 ns;
end process;

process begin
	wait for 10 ns;
	TX_DESC_ADDR <= std_logic_vector(to_unsigned(0, 32));
	TX_DESC_ADDR_STRB <= '1';
	wait for 10 ns;
	TX_DESC_ADDR_STRB <= '0';
	TX_SIZE <= std_logic_vector(to_unsigned(120, 32));
	TX_SIZE_STRB <= '1';
	wait for 10 ns;
	TX_SIZE_STRB <= '0';
	DMA_EN <= '1';
	wait for 10 ns;
	
	while(true) loop

		wait until INIT_AXI_RXN = '1';
		wait until INIT_AXI_RXN = '0';
		wait for 1 ns;
		DATA_IN <= std_logic_vector(to_unsigned(64, 32));
		AXI_RXN_STRB <= '1';
		wait for 10 ns;
		AXI_RXN_STRB <= '0';
		wait for 10 ns;
		DATA_IN <= std_logic_vector(to_unsigned(66, 32));
		AXI_RXN_STRB <= '1';
		wait for 10 ns;
		AXI_RXN_STRB <= '0';
		wait for 10 ns;
		DATA_IN <= std_logic_vector(to_unsigned(0, 32));
		AXI_RXN_STRB <= '1';
		wait for 10 ns;
		AXI_RXN_STRB <= '0';
		wait for 10 ns;
		AXI_RXN_DONE <= '1';
		wait for 10 ns;
		AXI_RXN_DONE <= '0';
	
		for j in 0 to 2 loop
			wait until INIT_AXI_RXN = '1';
			wait until INIT_AXI_RXN = '0';
			for k in 0 to to_integer(unsigned(BURST)) loop
				DATA_IN <= std_logic_vector(to_unsigned(16#00010000# +
								k * 16#00010001# +
								j * 16#10001000#,
								32));
				wait for 1 ns;
				AXI_RXN_STRB <= '1';
				wait for 10 ns;
				AXI_RXN_STRB <= '0';
				wait for 10 ns;
			end loop;
			AXI_RXN_DONE <= '1';
			wait for 10 ns;
			AXI_RXN_DONE <= '0';
		end loop;

		TX_PRCSSD_STRB <= '1';
		wait for 10 ns;
		TX_PRCSSD_STRB <= '0';
		wait for 10 ns;
	end loop;
	wait;

end process;




end tb_arch; 
