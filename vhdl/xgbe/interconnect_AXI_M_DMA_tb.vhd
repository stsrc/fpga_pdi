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

		BRST_0		: in std_logic_vector(7 downto 0);
		BRST_1		: in std_logic_vector(7 downto 0);
		BRST_TO_AXI	: out std_logic_vector(7 downto 0);

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
		AXI_TXN_STRB	: in std_logic;
		AXI_RXN_STRB	: in std_logic;

		INIT_AXI_TXN_0	: in  std_logic;
		AXI_TXN_DONE_0	: out std_logic;
		AXI_TXN_STRB_0	: out std_logic;
		INIT_AXI_RXN_0	: in  std_logic;
		AXI_RXN_DONE_0 	: out std_logic;
		AXI_RXN_STRB_0	: out std_logic;

		INIT_AXI_TXN_1	: in  std_logic;
		AXI_TXN_DONE_1	: out std_logic;
		AXI_TXN_STRB_1	: out std_logic;
		INIT_AXI_RXN_1	: in  std_logic;
		AXI_RXN_DONE_1 	: out std_logic;
		AXI_RXN_STRB_1	: out std_logic

	);
end component;

signal clk, aresetn, INIT_AXI_TXN, INIT_AXI_RXN, AXI_TXN_DONE, AXI_RXN_DONE : std_logic := '0';
signal AXI_TXN_STRB, AXI_RXN_STRB	: std_logic := '0';
signal INIT_AXI_TXN_0, AXI_TXN_DONE_0, INIT_AXI_RXN_0, AXI_RXN_DONE_0 : std_logic := '0';
signal AXI_RXN_STRB_0, AXI_RXN_STRB_1 	: std_logic := '0';
signal AXI_TXN_STRB_0, AXI_TXN_STRB_1 	: std_logic := '0';
signal INIT_AXI_TXN_1, AXI_TXN_DONE_1, INIT_AXI_RXN_1, AXI_RXN_DONE_1 : std_logic := '0';

signal DATA_OUT_0, DATA_OUT_1, DATA_TO_AXI, DATA_FROM_AXI : std_logic_vector(31 downto 0) := (others => '0');
signal DATA_IN_0, DATA_IN_1, ADDR_0, ADDR_1, ADDR_TO_AXI : std_logic_vector(31 downto 0) := (others => '0');
signal BRST_TO_AXI, BRST_0, BRST_1 : std_logic_vector(7 downto 0) := (others => '0');
begin

interconnect_AXI_M_DMA_0 : interconnect_AXI_M_DMA
port map (
	clk 		=> clk,
	aresetn 	=> aresetn,
	DATA_OUT_0 	=> DATA_OUT_0,
	DATA_OUT_1 	=> DATA_OUT_1,
	DATA_TO_AXI 	=> DATA_TO_AXI,
	DATA_FROM_AXI 	=> DATA_FROM_AXI,
	DATA_IN_0 	=> DATA_IN_0,
	DATA_IN_1 	=> DATA_IN_1,
	ADDR_0 		=> ADDR_0,
	ADDR_1 		=> ADDR_1,
	ADDR_TO_AXI 	=> ADDR_TO_AXI,
	INIT_AXI_TXN 	=> INIT_AXI_TXN,
	INIT_AXI_RXN 	=> INIT_AXI_RXN,
	AXI_TXN_DONE 	=> AXI_TXN_DONE,
	AXI_RXN_DONE 	=> AXI_RXN_DONE,
	AXI_TXN_STRB   => AXI_TXN_STRB,
	AXI_RXN_STRB   => AXI_RXN_STRB,
	INIT_AXI_TXN_0 	=> INIT_AXI_TXN_0,
	AXI_TXN_DONE_0 	=> AXI_TXN_DONE_0,
	INIT_AXI_RXN_0 	=> INIT_AXI_RXN_0,
	AXI_RXN_DONE_0 	=> AXI_RXN_DONE_0,
	INIT_AXI_TXN_1 	=> INIT_AXI_TXN_1,
	AXI_TXN_DONE_1 	=> AXI_TXN_DONE_1,
	INIT_AXI_RXN_1 	=> INIT_AXI_RXN_1,
	AXI_RXN_DONE_1 	=> AXI_RXN_DONE_1,
	AXI_RXN_STRB_0 	=> AXI_RXN_STRB_0,
	AXI_TXN_STRB_0 	=> AXI_TXN_STRB_0,
	AXI_RXN_STRB_1 	=> AXI_RXN_STRB_1,
	AXI_TXN_STRB_1	=> AXI_TXN_STRB_1,
	BRST_0		=> BRST_0,
	BRST_1		=> BRST_1,
	BRST_TO_AXI	=> BRST_TO_AXI
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
	wait for 20 ns;
	BRST_0 <= std_logic_vector(to_unsigned(0, 8));
	INIT_AXI_TXN_0	<= '1';
	wait until INIT_AXI_TXN = '1';
	INIT_AXI_TXN_0 <= '0';
	AXI_TXN_STRB	<= '1';
	wait until AXI_TXN_STRB_0 = '1';
	AXI_TXN_STRB	<= '0';
	wait for 10 ns;
	AXI_TXN_DONE	<= '1';
	wait for 10 ns;
	AXI_TXN_DONE	<= '0';
	wait;
end process;
end tb_arch;
