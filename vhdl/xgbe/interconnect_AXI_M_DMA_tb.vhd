library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is 
end tb;

architecture tb_arch of tb is 

component interconnect_AXI_M_DMA is
	port (
		clk 		: in  std_logic;
		aresetn		: in  std_logic;

		DATA_OUT_0 	: in  std_logic_vector(31 downto 0);
		DATA_OUT_1 	: in  std_logic_vector(31 downto 0);
		DATA_TO_AXI  	: out std_logic_vector(31 downto 0);

		DATA_FROM_AXI	: in  std_logic_vector(31 downto 0);
		DATA_IN_0	: out std_logic_vector(31 downto 0);
		DATA_IN_1	: out std_logic_vector(31 downto 0);

		ADDR_0 		: in  std_logic_vector(31 downto 0);
		ADDR_1 		: in  std_logic_vector(31 downto 0);
		ADDR_TO_AXI  	: out std_logic_vector(31 downto 0);

		INIT_AXI_TXN	: out std_logic;
		INIT_AXI_RXN	: out std_logic;
		AXI_TXN_DONE	: in std_logic;
		AXI_RXN_DONE	: in std_logic;

		INIT_AXI_TXN_0	: in  std_logic;
		AXI_TXN_DONE_0	: out std_logic;
		INIT_AXI_RXN_0	: in  std_logic;
		AXI_RXN_DONE_0 	: out std_logic;

		INIT_AXI_TXN_1	: in  std_logic;
		AXI_TXN_DONE_1	: out std_logic;
		INIT_AXI_RXN_1	: in  std_logic;
		AXI_RXN_DONE_1 	: out std_logic
	);
end component;

signal clk, aresetn, INIT_AXI_TXN, INIT_AXI_RXN, AXI_TXN_DONE, AXI_RXN_DONE : std_logic := '0';
signal INIT_AXI_TXN_0, AXI_TXN_DONE_0, INIT_AXI_RXN_0, AXI_RXN_DONE_0 : std_logic := '0';
signal INIT_AXI_TXN_1, AXI_TXN_DONE_1, INIT_AXI_RXN_1, AXI_RXN_DONE_1 : std_logic := '0';

signal DATA_OUT_0, DATA_OUT_1, DATA_TO_AXI, DATA_FROM_AXI : std_logic_vector(31 downto 0) := (others => '0');
signal DATA_IN_0, DATA_IN_1, ADDR_0, ADDR_1, ADDR_TO_AXI : std_logic_vector(31 downto 0) := (others => '0');

begin

interconnect_AXI_M_DMA_0 : interconnect_AXI_M_DMA
port map (
	clk => clk,
	aresetn => aresetn,
	DATA_OUT_0 => DATA_OUT_0,
	DATA_OUT_1 => DATA_OUT_1,
	DATA_TO_AXI => DATA_TO_AXI,
	DATA_FROM_AXI => DATA_FROM_AXI,
	DATA_IN_0 => DATA_IN_0,
	DATA_IN_1 => DATA_IN_1,
	ADDR_0 => ADDR_0,
	ADDR_1 => ADDR_1,
	ADDR_TO_AXI => ADDR_TO_AXI,
	INIT_AXI_TXN => INIT_AXI_TXN,
	INIT_AXI_RXN => INIT_AXI_RXN,
	AXI_TXN_DONE => AXI_TXN_DONE,
	AXI_RXN_DONE => AXI_RXN_DONE,
	INIT_AXI_TXN_0 => INIT_AXI_TXN_0,
	AXI_TXN_DONE_0 => AXI_TXN_DONE_0,
	INIT_AXI_RXN_0 => INIT_AXI_RXN_0,
	AXI_RXN_DONE_0 => AXI_RXN_DONE_0,
	INIT_AXI_TXN_1 => INIT_AXI_TXN_1,
	AXI_TXN_DONE_1 => AXI_TXN_DONE_1,
	INIT_AXI_RXN_1 => INIT_AXI_RXN_1,
	AXI_RXN_DONE_1 => AXI_RXN_DONE_1
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
	wait for 21 ns;
	--single TX from 0 CHN.
	DATA_OUT_0 <= std_logic_vector(to_unsigned(50, 32));
	ADDR_0 <= std_logic_vector(to_unsigned(32, 32));
	INIT_AXI_TXN_0 <= '1';
	wait for 10 ns;
	INIT_AXI_TXN_0 <= '0';
	wait for 10 ns;
	assert ADDR_TO_AXI = std_logic_vector(to_unsigned(32, 32)) report "1." severity failure;
	assert DATA_TO_AXI = std_logic_vector(to_unsigned(50, 32)) report "2." severity failure;
	assert INIT_AXI_TXN = '1' report "3." severity failure;
	wait for 20 ns;
	AXI_TXN_DONE <= '1';
	wait for 10 ns;
	assert AXI_TXN_DONE_0 = '1' report "4." severity failure;
	AXI_TXN_DONE <= '0';

	--single RX from 0 CHN.
	wait for 20 ns;
	ADDR_0 <= std_logic_vector(to_unsigned(64, 32));
	INIT_AXI_RXN_0 <= '1';
	wait for 10 ns;
	INIT_AXI_RXN_0 <= '0';
	wait for 10 ns;
	DATA_FROM_AXI <= std_logic_vector(to_unsigned(666, 32));
	assert ADDR_TO_AXI = std_logic_vector(to_unsigned(64, 32)) report "1." severity failure;
	assert INIT_AXI_RXN = '1' report "3." severity failure;
	wait for 20 ns;
	AXI_RXN_DONE <= '1';
	wait for 10 ns;
	assert AXI_RXN_DONE_0 = '1' report "4." severity failure;
	assert DATA_IN_0 = std_logic_vector(to_unsigned(666, 32)) report "5." severity failure; 
	AXI_RXN_DONE <= '0';

	
	--signle TX from 0 CHN.
	wait for 10 ns;
	DATA_OUT_1 <= std_logic_vector(to_unsigned(1337, 32));
	ADDR_1 <= std_logic_vector(to_unsigned(96, 32));
	INIT_AXI_TXN_1 <= '1';
	wait for 10 ns;
	INIT_AXI_TXN_1 <= '0';
	wait for 10 ns;
	assert ADDR_TO_AXI = std_logic_vector(to_unsigned(96, 32)) report "1." severity failure;
	assert DATA_TO_AXI = std_logic_vector(to_unsigned(1337, 32)) report "2." severity failure;
	assert INIT_AXI_TXN = '1' report "3." severity failure;
	wait for 20 ns;
	AXI_TXN_DONE <= '1';
	wait for 10 ns;
	assert AXI_TXN_DONE_1 = '1' report "4." severity failure;
	AXI_TXN_DONE <= '0';

	--single RX from 1 CHN.
	wait for 20 ns;
	ADDR_1 <= std_logic_vector(to_unsigned(128, 32));
	INIT_AXI_RXN_1 <= '1';
	wait for 10 ns;
	INIT_AXI_RXN_1 <= '0';
	wait for 10 ns;
	DATA_FROM_AXI <= std_logic_vector(to_unsigned(3113, 32));
	assert ADDR_TO_AXI = std_logic_vector(to_unsigned(128, 32)) report "1." severity failure;
	assert INIT_AXI_RXN = '1' report "3." severity failure;
	wait for 20 ns;
	AXI_RXN_DONE <= '1';
	wait for 10 ns;
	assert AXI_RXN_DONE_1 = '1' report "4." severity failure;
	assert DATA_IN_1 = std_logic_vector(to_unsigned(3113, 32)) report "5." severity failure; 
	AXI_RXN_DONE <= '0';
	wait for 10 ns;

	--simultanous TX from 0 CHN and RX from 1 CHN. First TX should take place, next RX.
	DATA_OUT_0 <= std_logic_vector(to_unsigned(50, 32));
	ADDR_0 <= std_logic_vector(to_unsigned(32, 32));
	DATA_OUT_1 <= std_logic_vector(to_unsigned(1337, 32));
	ADDR_1 <= std_logic_vector(to_unsigned(96, 32));
	INIT_AXI_TXN_0 <= '1';
	INIT_AXI_RXN_1 <= '1';
	wait for 10 ns;
	INIT_AXI_TXN_0 <= '0';
	INIT_AXI_RXN_1 <= '0';
	wait for 10 ns;
	assert ADDR_TO_AXI = std_logic_vector(to_unsigned(32, 32)) report "1." severity failure;
	assert DATA_TO_AXI = std_logic_vector(to_unsigned(50, 32)) report "2." severity failure;
	assert INIT_AXI_TXN = '1' report "3." severity failure;
	wait for 20 ns;
	AXI_TXN_DONE <= '1';
	wait for 10 ns;
	assert AXI_TXN_DONE_0 = '1' report "4." severity failure;
	AXI_TXN_DONE <= '0';
	wait for 10 ns;
	assert ADDR_TO_AXI = std_logic_vector(to_unsigned(96, 32)) report "1." severity failure;
	assert INIT_AXI_RXN = '1' report "3." severity failure;
	wait for 10 ns;
	DATA_FROM_AXI <= std_logic_vector(to_unsigned(666, 32));
	AXI_RXN_DONE <= '1';
	wait for 10 ns;
	assert AXI_RXN_DONE_1 = '1' report "4." severity failure;
	assert DATA_IN_1 = std_logic_vector(to_unsigned(666, 32)) report "5." severity failure; 
	AXI_RXN_DONE <= '0';
	wait for 10 ns;

	--simultanous RX from 0 CHN and TX from 1 CHN. First RX should take place, next TX.
	ADDR_0 <= std_logic_vector(to_unsigned(32, 32));
	DATA_OUT_1 <= std_logic_vector(to_unsigned(1337, 32));
	ADDR_1 <= std_logic_vector(to_unsigned(96, 32));
	INIT_AXI_RXN_0 <= '1';
	INIT_AXI_TXN_1 <= '1';
	wait for 10 ns;
	INIT_AXI_RXN_0 <= '0';
	INIT_AXI_TXN_1 <= '0';
	wait for 10 ns;
	assert ADDR_TO_AXI = std_logic_vector(to_unsigned(32, 32)) report "1." severity failure;
	assert INIT_AXI_RXN = '1' report "3." severity failure;
	wait for 20 ns;
	DATA_FROM_AXI <= std_logic_vector(to_unsigned(666, 32));
	AXI_RXN_DONE <= '1';
	wait for 10 ns;
	assert AXI_RXN_DONE_0 = '1' report "4." severity failure;
	assert DATA_IN_0 = std_logic_vector(to_unsigned(666, 32)) report "5." severity failure;
	AXI_RXN_DONE <= '0';
	wait for 10 ns;
	assert ADDR_TO_AXI = std_logic_vector(to_unsigned(96, 32)) report "1." severity failure;
	assert DATA_TO_AXI = std_logic_vector(to_unsigned(1337, 32)) report "2." severity failure;
	assert INIT_AXI_TXN = '1' report "3." severity failure;
	wait for 10 ns;
	AXI_TXN_DONE <= '1';
	wait for 10 ns;
	assert AXI_TXN_DONE_1 = '1' report "4." severity failure; 
	AXI_TXN_DONE <= '0';
	wait;
end process;
end tb_arch;
