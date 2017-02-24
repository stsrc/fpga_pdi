library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture tb_arch of tb is

component fsm_DMA_RX is
	port (
		clk	: in std_logic;
		aresetn	: in std_logic;
	

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
		RX_DESC_ADDR			: in std_logic_vector(31 downto 0);
		RX_DESC_ADDR_STRB 		: in std_logic;
		RX_SIZE			: in std_logic_vector(31 downto 0);
		RX_SIZE_STRB		: in std_logic;

		--Read RX descriptors size
		RX_READ			: in std_logic_vector(31 downto 0);
		RX_READ_STRB		: in std_logic;

		--Processed RX descriptor interrupt.
		RX_PRCSSD_INT		: out std_logic;

		RX_WSTRB		: out std_logic_vector(3 downto 0);
		XGBE_PCKT_RCV		: in std_logic;
		DMA_EN			: in std_logic;
		RCV_EN			: in std_logic;
		RX_PCKT_DATA		: in std_logic_vector(31 downto 0);
		RX_PCKT_DATA_STRB	: out std_logic;
		RX_PCKT_CNT		: in std_logic_vector(31 downto 0);
		RX_PCKT_CNT_STRB	: out std_logic	
	);
end component;

signal clk, aresetn 									: std_logic := '0';
signal INIT_AXI_TXN, AXI_TXN_DONE, INIT_AXI_RXN, AXI_RXN_DONE 				: std_logic := '0';
signal AXI_RXN_STRB, AXI_TXN_STRB, AXI_TXN_IN_STRB					: std_logic := '0';

signal DMA_EN, RCV_EN	 								: std_logic := '0';
signal RX_PCKT_DATA_STRB, RX_PCKT_CNT_STRB 						: std_logic := '0';

signal BURST 				: std_logic_vector(7 downto 0) 	:= (others => '0');
signal DATA_IN, DATA_OUT, ADDR 		: std_logic_vector(31 downto 0) := (others => '0');
signal RX_DESC_ADDR, RX_SIZE, RX_READ   : std_logic_vector(31 downto 0) := (others => '0');
signal RX_PCKT_DATA, RX_PCKT_CNT	: std_logic_vector(31 downto 0) := (others => '0');
signal RX_WSTRB				: std_logic_vector(3 downto 0) := (others => '0');

signal RX_DESC_ADDR_STRB, RX_SIZE_STRB, RX_READ_STRB, RX_PRCSSD_INT : std_logic := '0';
signal XGBE_PACKET_RCV	: std_logic := '0';

begin
	fsm_DMA_RX_0 : fsm_DMA_RX
	port map (
		clk 		=> clk,
		aresetn 	=> aresetn,
		DATA_IN 	=> DATA_IN,
		DATA_OUT 	=> DATA_OUT,
		ADDR 		=> ADDR,
		INIT_AXI_TXN	=> INIT_AXI_TXN,
		AXI_TXN_DONE 	=> AXI_TXN_DONE,
		AXI_TXN_STRB 	=> AXI_TXN_STRB,
		AXI_TXN_IN_STRB => AXI_TXN_IN_STRB,
		INIT_AXI_RXN 	=> INIT_AXI_RXN,
		AXI_RXN_DONE 	=> AXI_RXN_DONE,
		AXI_RXN_STRB 	=> AXI_RXN_STRB,
		BURST 		=> BURST,
		RX_DESC_ADDR 	=> RX_DESC_ADDR,
		RX_DESC_ADDR_STRB 	=> RX_DESC_ADDR_STRB,
		RX_SIZE 	=> RX_SIZE,
		RX_SIZE_STRB 	=> RX_SIZE_STRB,
		RX_READ		=> RX_READ,
		RX_READ_STRB	=> RX_READ_STRB,
		RX_PRCSSD_INT	=> RX_PRCSSD_INT,
		RX_WSTRB	=> RX_WSTRB,
		XGBE_PCKT_RCV => XGBE_PACKET_RCV,
		DMA_EN		=> DMA_EN,
		RCV_EN		=> RCV_EN,
		RX_PCKT_DATA	=> RX_PCKT_DATA,
		RX_PCKT_DATA_STRB	=> RX_PCKT_DATA_STRB,
		RX_PCKT_CNT		=> RX_PCKT_CNT,
		RX_PCKT_CNT_STRB 	=> RX_PCKT_CNT_STRB
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

process
begin
	wait for 1 ns;
	if RX_PCKT_DATA_STRB = '1' then
		RX_PCKT_DATA <= std_logic_vector(unsigned(RX_PCKT_DATA) + 1);
	elsif RX_PCKT_CNT_STRB = '1' then
		RX_PCKT_DATA <= std_logic_vector(to_unsigned(65536, 32));
	end if;
	wait until clk = '0';
	wait until clk = '1';
end process;

process 
	variable to_add : integer := 0;	
	variable loop_cnt: integer := 0;
begin
	wait for 10 ns;
	RX_DESC_ADDR <= std_logic_vector(to_unsigned(64, 32));
	RX_DESC_ADDR_STRB <= '1';
	wait for 10 ns;
	RX_DESC_ADDR_STRB <= '0';
	RX_SIZE <= std_logic_vector(to_unsigned(128, 32));
	RX_SIZE_STRB <= '1';
	wait for 10 ns;
	RX_SIZE_STRB <= '0';
	DMA_EN <= '1';
	RCV_EN <= '1';
	wait for 10 ns;
	while(true) loop
	for i in 0 to 9 loop
		XGBE_PACKET_RCV <= '1';
		RX_PCKT_CNT <= std_logic_vector(to_unsigned(56 + i, 32));
		DATA_IN <= std_logic_vector(to_unsigned(128 + 2, 32));
		wait for 10 ns;
		XGBE_PACKET_RCV <= '0';
		wait until INIT_AXI_TXN = '1';
		wait for 10 ns;
		AXI_TXN_DONE <= '1';
		wait until INIT_AXI_RXN = '1';
		wait for 10 ns;
		AXI_TXN_DONE <= '0';
		wait for 10 ns;
		AXI_RXN_DONE <= '1';
		wait for 10 ns;
		AXI_RXN_DONE <= '0';
		if (i >= 7) then
			to_add := 1;
		else
			to_add := 0;
		end if;
		for i in 0 to 1 + to_add loop
			wait until INIT_AXI_TXN = '1';
			wait for 10 ns;
			loop_cnt := to_integer(unsigned(BURST));
			for j in 0 to loop_cnt loop
				AXI_TXN_STRB <= '1';
				wait for 10 ns;
				AXI_TXN_STRB <= '0';
				if (AXI_TXN_IN_STRB /= '1') then
					wait until AXI_TXN_IN_STRB = '1';
				end if;
				wait until AXI_TXN_IN_STRB = '0';
				wait for 10 ns;
			end loop;
			AXI_TXN_DONE <= '1';
			wait for 10 ns;
			AXI_TXN_DONE <= '0';
		end loop;
	end loop;
	wait for 10 ns;
	RX_READ <= std_logic_vector(to_unsigned(8 * 10, 32));
	RX_READ_STRB <= '1';
	wait for 10 ns;
	RX_READ_STRB <= '0'; 	
	end loop;
end process;

end tb_arch;
