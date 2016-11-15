--AXI tb from https://github.com/frobino/axi_custom_ip_tb/blob/master/led_controller_1.0/hdl/testbench.vhd

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity tb is
 
end tb;

architecture STRUCTURE of tb is
	component xgbe is 
	generic (
		C_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 5;
		C_M_AXI_ADDR_WIDTH	: integer	:= 32;
		C_M_AXI_DATA_WIDTH	: integer	:= 32;
		C_M_AXI_ID_WIDTH	: integer	:= 0;
		C_M_AXI_AWUSER_WIDTH	: integer	:= 0;
		C_M_AXI_WUSER_WIDTH	: integer	:= 0;
		C_M_AXI_BUSER_WIDTH	: integer	:= 0;
		C_M_AXI_ARUSER_WIDTH	: integer	:= 0;
		C_M_AXI_RUSER_WIDTH	: integer	:= 0;
		C_M_AXI_BURST_LEN	: integer	:= 8
	);
	port (
		clk_156_25MHz	: in std_logic;
		rst_clk_156_25MHz : in std_logic;
		clk_20MHz	: in std_logic;
		rst_clk_20MHz	: in std_logic;

		interrupt	: out std_logic;

		s_axi_aclk	: in std_logic;
		s_axi_aresetn	: in std_logic;
		s_axi_awaddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_awprot	: in std_logic_vector(2 downto 0);
		s_axi_awvalid	: in std_logic;
		s_axi_awready	: out std_logic;
		s_axi_wdata	: in std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
		s_axi_wstrb	: in std_logic_vector((C_AXI_DATA_WIDTH/8)-1 downto 0);
		s_axi_wvalid	: in std_logic;
		s_axi_wready	: out std_logic;
		s_axi_bresp	: out std_logic_vector(1 downto 0);
		s_axi_bvalid	: out std_logic;
		s_axi_bready	: in std_logic;
		s_axi_araddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_arprot	: in std_logic_vector(2 downto 0);
		s_axi_arvalid	: in std_logic;
		s_axi_arready	: out std_logic;
		s_axi_rdata	: out std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
		s_axi_rresp	: out std_logic_vector(1 downto 0);
		s_axi_rvalid	: out std_logic;
		s_axi_rready	: in std_logic;

		M_AXI_ACLK	: in std_logic;
		M_AXI_ARESETN	: in std_logic;
		M_AXI_AWID	: out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		M_AXI_AWADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		M_AXI_AWLEN	: out std_logic_vector(7 downto 0);
		M_AXI_AWSIZE	: out std_logic_vector(2 downto 0);
		M_AXI_AWBURST	: out std_logic_vector(1 downto 0);
		M_AXI_AWLOCK	: out std_logic;
		M_AXI_AWCACHE	: out std_logic_vector(3 downto 0);
		M_AXI_AWPROT	: out std_logic_vector(2 downto 0);
		M_AXI_AWQOS	: out std_logic_vector(3 downto 0);
		M_AXI_AWUSER	: out std_logic_vector(C_M_AXI_AWUSER_WIDTH-1 downto 0);
		M_AXI_AWVALID	: out std_logic;
		M_AXI_AWREADY	: in std_logic;
		M_AXI_WDATA	: out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		M_AXI_WSTRB	: out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
		M_AXI_WLAST	: out std_logic;
		M_AXI_WUSER	: out std_logic_vector(C_M_AXI_WUSER_WIDTH-1 downto 0);
		M_AXI_WVALID	: out std_logic;
		M_AXI_WREADY	: in std_logic;
		M_AXI_BID	: in std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		M_AXI_BRESP	: in std_logic_vector(1 downto 0);
		M_AXI_BUSER	: in std_logic_vector(C_M_AXI_BUSER_WIDTH-1 downto 0);
		M_AXI_BVALID	: in std_logic;
		M_AXI_BREADY	: out std_logic;
		M_AXI_ARID	: out std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		M_AXI_ARADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		M_AXI_ARLEN	: out std_logic_vector(7 downto 0);
		M_AXI_ARSIZE	: out std_logic_vector(2 downto 0);
		M_AXI_ARBURST	: out std_logic_vector(1 downto 0);
		M_AXI_ARLOCK	: out std_logic;
		M_AXI_ARCACHE	: out std_logic_vector(3 downto 0);
		M_AXI_ARPROT	: out std_logic_vector(2 downto 0);
		M_AXI_ARQOS	: out std_logic_vector(3 downto 0);
		M_AXI_ARUSER	: out std_logic_vector(C_M_AXI_ARUSER_WIDTH-1 downto 0);
		M_AXI_ARVALID	: out std_logic;
		M_AXI_ARREADY	: in std_logic;
		M_AXI_RID	: in std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		M_AXI_RDATA	: in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		M_AXI_RRESP	: in std_logic_vector(1 downto 0);
		M_AXI_RLAST	: in std_logic;
		M_AXI_RUSER	: in std_logic_vector(C_M_AXI_RUSER_WIDTH-1 downto 0);
		M_AXI_RVALID	: in std_logic;
		M_AXI_RREADY	: out std_logic;

		xgmii_rxc : in STD_LOGIC_VECTOR (7 downto 0);
		xgmii_rxd : in STD_LOGIC_VECTOR (63 downto 0);
		xgmii_txc : out STD_LOGIC_VECTOR (7 downto 0);
		xgmii_txd : out STD_LOGIC_VECTOR (63 downto 0);
		xgmii_tx_clk : in std_logic;
		xgmii_rx_clk : in std_logic			
	);
end component xgbe;

component AXI_Slave_for_tb is
	generic (	
	C_S_AXI_ID_WIDTH	: integer	:= 0;
	C_S_AXI_DATA_WIDTH	: integer	:= 32;
	C_S_AXI_ADDR_WIDTH	: integer	:= 32;
	C_S_AXI_AWUSER_WIDTH	: integer	:= 0;
	C_S_AXI_ARUSER_WIDTH	: integer	:= 0;
	C_S_AXI_WUSER_WIDTH	: integer	:= 0;
	C_S_AXI_RUSER_WIDTH	: integer	:= 0;
	C_S_AXI_BUSER_WIDTH	: integer	:= 0
);
port (
	
	M_RD_STRB		: out std_logic;
	M_RD_DATA		: in  std_logic_vector(31 downto 0);
	M_TX_STRB		: out std_logic;
	M_TX_DATA		: out std_logic_vector(31 downto 0);

	S_AXI_ACLK	: in std_logic;
	S_AXI_ARESETN	: in std_logic;
	S_AXI_AWID	: in std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
	S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	S_AXI_AWLEN	: in std_logic_vector(7 downto 0);
	S_AXI_AWSIZE	: in std_logic_vector(2 downto 0);
	S_AXI_AWBURST	: in std_logic_vector(1 downto 0);
	S_AXI_AWLOCK	: in std_logic;
	S_AXI_AWCACHE	: in std_logic_vector(3 downto 0);
	S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
	S_AXI_AWQOS	: in std_logic_vector(3 downto 0);
	S_AXI_AWREGION	: in std_logic_vector(3 downto 0);
	S_AXI_AWUSER	: in std_logic_vector(C_S_AXI_AWUSER_WIDTH-1 downto 0);
	S_AXI_AWVALID	: in std_logic;
	S_AXI_AWREADY	: out std_logic;
	S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
	S_AXI_WLAST	: in std_logic;
	S_AXI_WUSER	: in std_logic_vector(C_S_AXI_WUSER_WIDTH-1 downto 0);
	S_AXI_WVALID	: in std_logic;
	S_AXI_WREADY	: out std_logic;
	S_AXI_BID	: out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
	S_AXI_BRESP	: out std_logic_vector(1 downto 0);
	S_AXI_BUSER	: out std_logic_vector(C_S_AXI_BUSER_WIDTH-1 downto 0);
	S_AXI_BVALID	: out std_logic;
	S_AXI_BREADY	: in std_logic;	
	S_AXI_ARID	: in std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
	S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	S_AXI_ARLEN	: in std_logic_vector(7 downto 0);
	S_AXI_ARSIZE	: in std_logic_vector(2 downto 0);
	S_AXI_ARBURST	: in std_logic_vector(1 downto 0);
	S_AXI_ARLOCK	: in std_logic;
	S_AXI_ARCACHE	: in std_logic_vector(3 downto 0);
	S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
	S_AXI_ARQOS	: in std_logic_vector(3 downto 0);
	S_AXI_ARREGION	: in std_logic_vector(3 downto 0);
	S_AXI_ARUSER	: in std_logic_vector(C_S_AXI_ARUSER_WIDTH-1 downto 0);
	S_AXI_ARVALID	: in std_logic;
	S_AXI_ARREADY	: out std_logic;
	S_AXI_RID	: out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
	S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0); 
	S_AXI_RRESP	: out std_logic_vector(1 downto 0);
	S_AXI_RLAST	: out std_logic;
	S_AXI_RUSER	: out std_logic_vector(C_S_AXI_RUSER_WIDTH-1 downto 0);
	S_AXI_RVALID	: out std_logic; 
	S_AXI_RREADY	: in std_logic
	);
end component;

signal M_RD_STRB, M_TX_STRB	: std_logic := '0';
signal M_RD_DATA, M_TX_DATA	: std_logic_vector(31 downto 0) := (others => '0');

signal xgmii_tx_clk, xgmii_rx_clk : std_logic := '0';
signal clk_156_25MHz, clk_20MHz, rst_clk_156_25MHz, rst_clk_20MHz : std_logic := '0';
signal interrupt : std_logic := '0';

signal s_axi_aclk, s_axi_aresetn, s_axi_arready, s_axi_arvalid, s_axi_awready, s_axi_awvalid : std_logic := '0';
signal s_axi_bready, s_axi_bvalid, s_axi_rready, s_axi_rvalid, s_axi_wready, s_axi_wvalid : std_logic := '0';
signal s_axi_rdata, s_axi_wdata : std_logic_vector(31 downto 0) := (others => '0');
signal s_axi_wstrb : std_logic_vector(3 downto 0) := (others => '0');
signal s_axi_araddr, s_axi_awaddr : std_logic_vector(4 downto 0) := (others => '0');
signal s_axi_arprot, s_axi_awprot : std_logic_vector(2 downto 0) := (others => '0');
signal s_axi_bresp, s_axi_rresp : std_logic_vector(1 downto 0) := (others => '0');

signal M_AXI_ACLK, M_AXI_ARESETN, M_AXI_AWLOCK, M_AXI_AWVALID, M_AXI_AWREADY, M_AXI_WLAST : std_logic := '0';
signal M_AXI_WVALID, M_AXI_WREADY, M_AXI_BVALID, M_AXI_BREADY, M_AXI_ARLOCK, M_AXI_ARVALID : std_logic := '0';
signal M_AXI_ARREADY, M_AXI_RLAST, M_AXI_RVALID, M_AXI_RREADY : std_logic := '0';
signal M_AXI_AWID, M_AXI_ARID : std_logic_vector(-1 downto 0) := (others => '0');
signal M_AXI_AWADDR, M_AXI_ARADDR : std_logic_vector(31 downto 0);
signal M_AXI_WUSER	: std_logic_vector(-1 downto 0); 
signal M_AXI_AWLEN	: std_logic_vector(7 downto 0)  := (others => '0');
signal M_AXI_AWSIZE	: std_logic_vector(2 downto 0)  := (others => '0');
signal M_AXI_AWBURST	: std_logic_vector(1 downto 0)  := (others => '0');
signal M_AXI_AWCACHE	: std_logic_vector(3 downto 0)  := (others => '0');
signal M_AXI_AWPROT	: std_logic_vector(2 downto 0)  := (others => '0');
signal M_AXI_AWQOS	: std_logic_vector(3 downto 0)  := (others => '0');
signal M_AXI_AWUSER	: std_logic_vector(-1 downto 0) := (others => '0');
signal M_AXI_WSTRB	: std_logic_vector(3 downto 0)  := (others => '0');
signal M_AXI_BID	: std_logic_vector(-1 downto 0)  := (others => '0');
signal M_AXI_BRESP	: std_logic_vector(1 downto 0)  := (others => '0');
signal M_AXI_BUSER	: std_logic_vector(-1 downto 0) := (others => '0');
signal M_AXI_ARLEN	: std_logic_vector(7 downto 0)  := (others => '0');
signal M_AXI_ARSIZE	: std_logic_vector(2 downto 0)  := (others => '0');
signal M_AXI_ARBURST	: std_logic_vector(1 downto 0)  := (others => '0');
signal M_AXI_ARCACHE	: std_logic_vector(3 downto 0)  := (others => '0');
signal M_AXI_ARPROT	: std_logic_vector(2 downto 0)  := (others => '0');
signal M_AXI_ARQOS	: std_logic_vector(3 downto 0)  := (others => '0');
signal M_AXI_ARUSER	: std_logic_vector(-1 downto 0) := (others => '0');
signal M_AXI_RID	: std_logic_vector(-1 downto 0)  := (others => '0');
signal M_AXI_WDATA	: std_logic_vector(31 downto 0) := (others => '0');
signal M_AXI_RDATA	: std_logic_vector(31 downto 0) := (others => '0');
signal M_AXI_RRESP	: std_logic_vector(1 downto 0)  := (others => '0');
signal M_AXI_RUSER	: std_logic_vector(-1 downto 0) := (others => '0');

  
  signal xgmii_rxd, xgmii_txd : std_logic_vector(63 downto 0) := (others => '0');
  signal xgmii_rxc, xgmii_txc : std_logic_vector(7 downto 0) := (others => '0');

  signal ReadIt, SendIt : std_logic := '0';
  shared variable cnt : integer := 0;


shared variable packet_cnt : integer := 0;
shared variable bytes_cnt  : integer := 0;
shared variable read_cnt   : integer := 0;


type column_typ is record
                      d : std_logic_vector(63 downto 0);
                      c : std_logic_vector(7 downto 0);
                    end record;

type column_array_typ is array (natural range <>) of column_typ;

type frame_typ is record
                     stim : column_array_typ(0 to 31);
                     length : integer;
                   end record;

type frame_typ_array is array (natural range 0 to 3) of frame_typ;

constant frame_data : frame_typ_array := (

0 => (
stim => (
0 => ( d => X"555555fb07070707", c => "00011111"),
1 => ( d => X"00000000d5555555", c => X"00"),
2 => ( d => X"0000000000000000", c => X"00"),
3 => ( d => X"0000000000000000", c => X"00"),
4 => ( d => X"0000000000000000", c => X"00"),
5 => ( d => X"0000000000000000", c => X"00"),
6 => ( d => X"0000000000000000", c => X"00"),
7 => ( d => X"0000000000000000", c => X"00"),
8 => ( d => X"0000000000000000", c => X"00"),
9 => ( d => X"758d633600000000", c => X"00"),
10 => ( d => X"07070707070707fd", c => X"FF"),
11 => ( d => X"0707070707070707", c => X"FF"),
12 => ( d => X"0707070707070707", c => X"FF"),
13 => ( d => X"0707070707070707", c => X"FF"),
14 => ( d => X"0707070707070707", c => X"FF"),
15 => ( d => X"0707070707070707", c => X"FF"),
16 => ( d => X"0707070707070707", c => X"FF"),
17 => ( d => X"0707070707070707", c => X"FF"),
18 => ( d => X"0707070707070707", c => X"FF"),
19 => ( d => X"0707070707070707", c => X"FF"),
20 => ( d => X"0707070707070707", c => X"FF"),
21 => ( d => X"0707070707070707", c => X"FF"),
22 => ( d => X"0707070707070707", c => X"FF"),
23 => ( d => X"0707070707070707", c => X"FF"),
24 => ( d => X"0707070707070707", c => X"FF"),
25 => ( d => X"0707070707070707", c => X"FF"),
26 => ( d => X"0707070707070707", c => X"FF"),
27 => ( d => X"0707070707070707", c => X"FF"),
28 => ( d => X"0707070707070707", c => X"FF"),
29 => ( d => X"0707070707070707", c => X"FF"),
30 => ( d => X"0707070707070707", c => X"FF"),
31 => ( d => X"0707070707070707", c => X"FF")),
length => 11),
1 => (
stim => (
0 => ( d => X"555555fb07070707", c => "00011111"),
1 => ( d => X"ffffffffd5555555", c => X"00"),
2 => ( d => X"ffffffffffffffff", c => X"00"),
3 => ( d => X"ffffffffffffffff", c => X"00"),
4 => ( d => X"ffffffffffffffff", c => X"00"),
5 => ( d => X"ffffffffffffffff", c => X"00"),
6 => ( d => X"ffffffffffffffff", c => X"00"),
7 => ( d => X"ffffffffffffffff", c => X"00"),
8 => ( d => X"ffffffffffffffff", c => X"00"),
9 => ( d => X"BB3B15ffffffffff", c => X"00"),
10 => ( d => X"070707070707fdD4", c => "11111110"),
11 => ( d => X"0707070707070707", c => X"FF"),
12 => ( d => X"0707070707070707", c => X"FF"),
13 => ( d => X"0707070707070707", c => X"FF"),
14 => ( d => X"0707070707070707", c => X"FF"),
15 => ( d => X"0707070707070707", c => X"FF"),
16 => ( d => X"0707070707070707", c => X"FF"),
17 => ( d => X"0707070707070707", c => X"FF"),
18 => ( d => X"0707070707070707", c => X"FF"),
19 => ( d => X"0707070707070707", c => X"FF"),
20 => ( d => X"0707070707070707", c => X"FF"),
21 => ( d => X"0707070707070707", c => X"FF"),
22 => ( d => X"0707070707070707", c => X"FF"),
23 => ( d => X"0707070707070707", c => X"FF"),
24 => ( d => X"0707070707070707", c => X"FF"),
25 => ( d => X"0707070707070707", c => X"FF"),
26 => ( d => X"0707070707070707", c => X"FF"),
27 => ( d => X"0707070707070707", c => X"FF"),
28 => ( d => X"0707070707070707", c => X"FF"),
29 => ( d => X"0707070707070707", c => X"FF"),
30 => ( d => X"0707070707070707", c => X"FF"),
31 => ( d => X"0707070707070707", c => X"FF")),
length => 11),
2 => (
stim => (
0 => ( d => X"555555fb07070707", c => "00011111"),
1 => ( d => X"ffffffffd5555555", c => X"00"),
2 => ( d => X"ffffffffffffffff", c => X"00"),
3 => ( d => X"ffffffffffffffff", c => X"00"),
4 => ( d => X"ffffffffffffffff", c => X"00"),
5 => ( d => X"ffffffffffffffff", c => X"00"),
6 => ( d => X"ffffffffffffffff", c => X"00"),
7 => ( d => X"ffffffffffffffff", c => X"00"),
8 => ( d => X"ffffffffffffffff", c => X"00"),
9 => ( d => X"fd6E14FE90ffffff", c => "10000000"),
10 => ( d => X"0707070707070707", c => X"FF"),
11 => ( d => X"0707070707070707", c => X"FF"),
12 => ( d => X"0707070707070707", c => X"FF"),
13 => ( d => X"0707070707070707", c => X"FF"),
14 => ( d => X"0707070707070707", c => X"FF"),
15 => ( d => X"0707070707070707", c => X"FF"),
16 => ( d => X"0707070707070707", c => X"FF"),
17 => ( d => X"0707070707070707", c => X"FF"),
18 => ( d => X"0707070707070707", c => X"FF"),
19 => ( d => X"0707070707070707", c => X"FF"),
20 => ( d => X"0707070707070707", c => X"FF"),
21 => ( d => X"0707070707070707", c => X"FF"),
22 => ( d => X"0707070707070707", c => X"FF"),
23 => ( d => X"0707070707070707", c => X"FF"),
24 => ( d => X"0707070707070707", c => X"FF"),
25 => ( d => X"0707070707070707", c => X"FF"),
26 => ( d => X"0707070707070707", c => X"FF"),
27 => ( d => X"0707070707070707", c => X"FF"),
28 => ( d => X"0707070707070707", c => X"FF"),
29 => ( d => X"0707070707070707", c => X"FF"),
30 => ( d => X"0707070707070707", c => X"FF"),
31 => ( d => X"0707070707070707", c => X"FF")),
length => 10),
3 => (
stim => (
0 => ( d => X"555555fb07070707", c => "00011111"),
1 => ( d => X"f0f0f0f0d5555555", c => X"00"),
2 => ( d => X"f0f0f0f0f0f0f0f0", c => X"00"),
3 => ( d => X"f0f0f0f0f0f0f0f0", c => X"00"),
4 => ( d => X"f0f0f0f0f0f0f0f0", c => X"00"),
5 => ( d => X"f0f0f0f0f0f0f0f0", c => X"00"),
6 => ( d => X"f0f0f0f0f0f0f0f0", c => X"00"),
7 => ( d => X"f0f0f0f0f0f0f0f0", c => X"00"),
8 => ( d => X"f0f0f0f0f0f0f0f0", c => X"00"),
9 => ( d => X"E97357f0f0f0f0f0", c => X"00"),
10 => ( d => X"070707070707fdD8", c => "11111110"),
11 => ( d => X"0707070707070707", c => X"FF"),
12 => ( d => X"0707070707070707", c => X"FF"),
13 => ( d => X"0707070707070707", c => X"FF"),
14 => ( d => X"0707070707070707", c => X"FF"),
15 => ( d => X"0707070707070707", c => X"FF"),
16 => ( d => X"0707070707070707", c => X"FF"),
17 => ( d => X"0707070707070707", c => X"FF"),
18 => ( d => X"0707070707070707", c => X"FF"),
19 => ( d => X"0707070707070707", c => X"FF"),
20 => ( d => X"0707070707070707", c => X"FF"),
21 => ( d => X"0707070707070707", c => X"FF"),
22 => ( d => X"0707070707070707", c => X"FF"),
23 => ( d => X"0707070707070707", c => X"FF"),
24 => ( d => X"0707070707070707", c => X"FF"),
25 => ( d => X"0707070707070707", c => X"FF"),
26 => ( d => X"0707070707070707", c => X"FF"),
27 => ( d => X"0707070707070707", c => X"FF"),
28 => ( d => X"0707070707070707", c => X"FF"),
29 => ( d => X"0707070707070707", c => X"FF"),
30 => ( d => X"0707070707070707", c => X"FF"),
31 => ( d => X"0707070707070707", c => X"FF")),
length => 11));

begin

block_design_i: xgbe
     port map (
       clk_156_25MHz => clk_156_25MHz,
       rst_clk_156_25MHz => rst_clk_156_25MHz,
	   clk_20MHz => clk_20MHz,
	   rst_clk_20MHz => rst_clk_20MHz,

      interrupt => interrupt,

      s_axi_aclk => s_axi_aclk,
      s_axi_araddr => s_axi_araddr,
      s_axi_aresetn => s_axi_aresetn,
      s_axi_arprot(2 downto 0) => s_axi_arprot(2 downto 0),
      s_axi_arready => s_axi_arready,
      s_axi_arvalid => s_axi_arvalid,
      s_axi_awaddr => s_axi_awaddr,
      s_axi_awprot(2 downto 0) => s_axi_awprot(2 downto 0),
      s_axi_awready => s_axi_awready,
      s_axi_awvalid => s_axi_awvalid,
      s_axi_bready => s_axi_bready,
      s_axi_bresp(1 downto 0) => s_axi_bresp(1 downto 0),
      s_axi_bvalid => s_axi_bvalid,
      s_axi_rdata(31 downto 0) => s_axi_rdata(31 downto 0),
      s_axi_rready => s_axi_rready,
      s_axi_rresp(1 downto 0) => s_axi_rresp(1 downto 0),
      s_axi_rvalid => s_axi_rvalid,
      s_axi_wdata(31 downto 0) => s_axi_wdata(31 downto 0),
      s_axi_wready => s_axi_wready,
      s_axi_wstrb(3 downto 0) => s_axi_wstrb(3 downto 0),
      s_axi_wvalid => s_axi_wvalid,

	M_AXI_ACLK => M_AXI_ACLK,
	M_AXI_ARESETN => M_AXI_ARESETN,
	M_AXI_AWADDR => M_AXI_AWADDR,
	M_AXI_AWPROT => M_AXI_AWPROT,
	M_AXI_AWVALID => M_AXI_AWVALID,
	M_AXI_AWREADY => M_AXI_AWREADY,
	M_AXI_WDATA => M_AXI_WDATA,
	M_AXI_WSTRB => M_AXI_WSTRB,
	M_AXI_WVALID => M_AXI_WVALID,
	M_AXI_WREADY => M_AXI_WREADY,
	M_AXI_BRESP => M_AXI_BRESP,
	M_AXI_BVALID => M_AXI_BVALID,
	M_AXI_BREADY => M_AXI_BREADY,
	M_AXI_ARADDR => M_AXI_ARADDR,
	M_AXI_ARPROT => M_AXI_ARPROT,
	M_AXI_ARVALID => M_AXI_ARVALID,
	M_AXI_ARREADY => M_AXI_ARREADY,
	M_AXI_RDATA => M_AXI_RDATA,
	M_AXI_RRESP => M_AXI_RRESP,
	M_AXI_RVALID => M_AXI_RVALID,
	M_AXI_RREADY => M_AXI_RREADY,
	M_AXI_AWID => M_AXI_AWID,
	M_AXI_AWLEN => M_AXI_AWLEN,
	M_AXI_AWSIZE => M_AXI_AWSIZE,
	M_AXI_AWBURST => M_AXI_AWBURST,
	M_AXI_AWLOCK => M_AXI_AWLOCK,
	M_AXI_AWCACHE => M_AXI_AWCACHE,
	M_AXI_AWQOS => M_AXI_AWQOS,
	M_AXI_AWUSER => M_AXI_AWUSER,
	M_AXI_WLAST => M_AXI_WLAST,
	M_AXI_WUSER => M_AXI_WUSER,
	M_AXI_BID => M_AXI_BID,
	M_AXI_BUSER => M_AXI_BUSER,
	M_AXI_ARID => M_AXI_ARID,
	M_AXI_ARLEN => M_AXI_ARLEN,
	M_AXI_ARSIZE => M_AXI_ARSIZE,
	M_AXI_ARBURST => M_AXI_ARBURST,
	M_AXI_ARLOCK => M_AXI_ARLOCK,
	M_AXI_ARCACHE => M_AXI_ARCACHE,
	M_AXI_ARQOS => M_AXI_ARQOS,
	M_AXI_ARUSER => M_AXI_ARUSER,
	M_AXI_RID => M_AXI_RID,
	M_AXI_RLAST => M_AXI_RLAST,
	M_AXI_RUSER => M_AXI_RUSER,

      xgmii_rxd => xgmii_rxd,
      xgmii_txd => xgmii_txd,
      xgmii_rxc => xgmii_rxc,
      xgmii_txc => xgmii_txc,
      xgmii_tx_clk => xgmii_tx_clk,
      xgmii_rx_clk => xgmii_rx_clk
);

AXI_Slave_for_tb_0 : AXI_Slave_for_tb
port map (
	M_RD_STRB => M_RD_STRB,
	M_RD_DATA => M_RD_DATA,
	M_TX_STRB => M_TX_STRB,
	M_TX_DATA => M_TX_DATA,
	S_AXI_ACLK => M_AXI_ACLK,
	S_AXI_ARESETN => M_AXI_ARESETN,
	S_AXI_AWADDR => M_AXI_AWADDR,
	S_AXI_AWPROT => M_AXI_AWPROT,
	S_AXI_AWVALID => M_AXI_AWVALID,
	S_AXI_AWREADY => M_AXI_AWREADY,
	S_AXI_WDATA => M_AXI_WDATA,
	S_AXI_WSTRB => M_AXI_WSTRB,
	S_AXI_WVALID => M_AXI_WVALID,
	S_AXI_WREADY => M_AXI_WREADY,
	S_AXI_BRESP => M_AXI_BRESP,
	S_AXI_BVALID => M_AXI_BVALID,
	S_AXI_BREADY => M_AXI_BREADY,
	S_AXI_ARADDR => M_AXI_ARADDR,
	S_AXI_ARPROT => M_AXI_ARPROT,
	S_AXI_ARVALID => M_AXI_ARVALID,
	S_AXI_ARREADY => M_AXI_ARREADY,
	S_AXI_RDATA => M_AXI_RDATA,
	S_AXI_RRESP => M_AXI_RRESP,
	S_AXI_RVALID => M_AXI_RVALID,
	S_AXI_RREADY => M_AXI_RREADY,
	S_AXI_AWID => M_AXI_AWID,
	S_AXI_AWLEN => M_AXI_AWLEN,
	S_AXI_AWSIZE => M_AXI_AWSIZE,
	S_AXI_AWBURST => M_AXI_AWBURST,
	S_AXI_AWLOCK => M_AXI_AWLOCK,
	S_AXI_AWCACHE => M_AXI_AWCACHE,
	S_AXI_AWQOS => M_AXI_AWQOS,
	S_AXI_AWUSER => M_AXI_AWUSER,
	S_AXI_WLAST => M_AXI_WLAST,
	S_AXI_WUSER => M_AXI_WUSER,
	S_AXI_BID => M_AXI_BID,
	S_AXI_BUSER => M_AXI_BUSER,
	S_AXI_ARID => M_AXI_ARID,
	S_AXI_ARLEN => M_AXI_ARLEN,
	S_AXI_ARSIZE => M_AXI_ARSIZE,
	S_AXI_ARBURST => M_AXI_ARBURST,
	S_AXI_ARLOCK => M_AXI_ARLOCK,
	S_AXI_ARCACHE => M_AXI_ARCACHE,
	S_AXI_ARQOS => M_AXI_ARQOS,
	S_AXI_ARUSER => M_AXI_ARUSER,
	S_AXI_RID => M_AXI_RID,
	S_AXI_RLAST => M_AXI_RLAST,
	S_AXI_RUSER => M_AXI_RUSER,
	S_AXI_ARREGION => (others => '0'),
	S_AXI_AWREGION => (others => '0')
);

process begin
	wait for 1 ns;
	while true loop
		xgmii_tx_clk <= '0';
		wait for 3.2 ns;
		xgmii_tx_clk <= '1';
		wait for 3.2 ns;
	end loop;
end process;

process begin
	wait for 1.3 ns;
	while true loop
		xgmii_rx_clk <= '1';
		wait for 3.2 ns;
		xgmii_rx_clk <= '0';
		wait for 3.2 ns;
	end loop;
end process;

process begin
	s_axi_aclk <= '0';
	m_axi_aclk <= '0';
	wait for 5 ns;
	s_axi_aclk <= '1';
	m_axi_aclk <= '1';
	wait for 5 ns;
end process;
 
process begin
	clk_156_25MHz <= '1';
	wait for 3.2 ns;
	clk_156_25MHz <= '0';
	wait for 3.2 ns;
end process;

process begin
	clk_20MHz <= '1';
	wait for 25 ns;
	clk_20MHz <= '0';
	wait for 25 ns;
end process;

process begin
	s_axi_aresetn <= '0';
	m_axi_aresetn <= '0';
	rst_clk_156_25MHz <= '0';
	rst_clk_20MHz <= '0';
	wait for 6.4 ns;
	rst_clk_156_25MHz <= '1';
	wait for 3.6 ns;
	s_axi_aresetn <= '1';
	m_axi_aresetn <= '1';
	wait for 40 ns;
	rst_clk_20MHz <= '1';
	wait;
end process;

send : process
 begin
    s_axi_awvalid<='0';
    s_axi_wvalid<='0';
    s_axi_bready<='0';
    loop
        wait until sendit = '1';
        wait until s_axi_aclk= '0';
            s_axi_awvalid<='1';
            s_axi_wvalid<='1';
        wait until (s_axi_awready and s_axi_wready) = '1';  --client ready to read address/data        
            s_axi_bready<='1';
        wait until s_axi_bvalid = '1';  -- write result valid
            assert s_axi_bresp = "00" report "axi data not written" severity failure;
            s_axi_awvalid<='0';
            s_axi_wvalid<='0';
            s_axi_bready<='1';
        wait until s_axi_bvalid = '0';  -- all finished
            s_axi_bready<='0';
    end loop;
 end process send;

 read : process
  begin
    s_axi_arvalid<='0';
    s_axi_rready<='0';
     loop
         wait until readit = '1';
         wait until s_axi_aclk= '0';
             s_axi_arvalid<='1';
            wait until (s_axi_rvalid) = '1';  --client provided data (removed and s_axi_arready???)
            s_axi_rready<='1';
            s_axi_arvalid <= '0';
            assert s_axi_rresp = "00" report "axi data not written" severity failure;
            wait until (s_axi_rvalid) = '0';
            s_axi_rready<='0';
     end loop;
  end process read;
      
process
begin
	wait until rst_clk_20MHz = '1';
	wait for 30 ns;
 	s_axi_awaddr<="01000";
	s_axi_wdata<=x"00000001";
	s_axi_wstrb<=b"1111";
	sendit<='1';                --start axi write to slave
	wait for 1 ns; 
	sendit<='0'; --clear start send flag
	wait until s_axi_bvalid = '1';
	wait until s_axi_bvalid = '0';  --axi write finished
	s_axi_wstrb<=b"0000";

	wait for 100 ns;
    
 	s_axi_awaddr<="01000";
	s_axi_wdata<=x"00000006";
	s_axi_wstrb<=b"1111";
	sendit<='1';                --start axi write to slave
	wait for 1 ns; 
	sendit<='0'; --clear start send flag
	wait until s_axi_bvalid = '1';
	wait until s_axi_bvalid = '0';  --axi write finished
	s_axi_wstrb<=b"0000";

	--Write TX descriptor ring start address. 64.
 	s_axi_awaddr<="10000";
	s_axi_wdata<=x"00000040";
	s_axi_wstrb<=b"1111";
	sendit<='1';                --start axi write to slave
	wait for 1 ns; 
	sendit<='0'; --clear start send flag
	wait until s_axi_bvalid = '1';
	wait until s_axi_bvalid = '0';  --axi write finished
	s_axi_wstrb<=b"0000";

	--Write RX descriptor ring start address. 128.
 	s_axi_awaddr<="11000";
	s_axi_wdata<=x"00000080";
	s_axi_wstrb<=b"1111";
	sendit<='1';                --start axi write to slave
	wait for 1 ns; 
	sendit<='0'; --clear start send flag
	wait until s_axi_bvalid = '1';
	wait until s_axi_bvalid = '0';  --axi write finished
	s_axi_wstrb<=b"0000";
	
	--Write TX and RX descriptor ring size in bytes. 128, (16 descriptors).
 	s_axi_awaddr<="10100";
	s_axi_wdata<=x"00000080";
	s_axi_wstrb<=b"1111";
	sendit<='1';                --start axi write to slave
	wait for 1 ns; 
	sendit<='0'; --clear start send flag
	wait until s_axi_bvalid = '1';
	wait until s_axi_bvalid = '0';  --axi write finished
	s_axi_wstrb<=b"0000";

	--Enable DMA, interrupt and data reception.
 	s_axi_awaddr<="01000";
	s_axi_wdata<=x"0000000E";
	s_axi_wstrb<=b"1111";
	sendit<='1';                --start axi write to slave
	wait for 1 ns; 
	sendit<='0'; --clear start send flag
	wait until s_axi_bvalid = '1';
	wait until s_axi_bvalid = '0';  --axi write finished
	s_axi_wstrb<=b"0000";

	while (true) loop
	wait for 10 us;
	if (interrupt /= '1') then
		wait until interrupt = '1';
	end if;
	s_axi_araddr<="01100";  
	readit<='1';
	wait for 1 ns; 
	readit<='0'; 
	wait until s_axi_rready = '1';
	wait until s_axi_rready = '0';	

	s_axi_araddr<="10000";  
	readit<='1';
	wait for 1 ns; 
	readit<='0'; 
	wait until s_axi_rready = '1';
	wait until s_axi_rready = '0';	

	end loop;

	wait;
end process;


process begin
	for i in 0 to 3 loop	
		xgmii_rxd <= x"0707070707070707";
		xgmii_rxc <= x"ff";
		wait until rising_edge(clk_156_25MHz);
		for j in 0 to frame_data(i).length - 1 loop
			xgmii_rxd <= frame_data(i).stim(j).d;
			xgmii_rxc <= frame_data(i).stim(j).c;
			wait until rising_edge(clk_156_25MHz);
		end loop;
	end loop;

	for i in 3 downto 0 loop	
		xgmii_rxd <= x"0707070707070707";
		xgmii_rxc <= x"ff";
		wait until rising_edge(clk_156_25MHz);

		for j in 0 to frame_data(i).length - 1 loop
			xgmii_rxd <= frame_data(i).stim(j).d;
			xgmii_rxc <= frame_data(i).stim(j).c;
			wait until rising_edge(clk_156_25MHz);
		end loop;
	end loop;
	xgmii_rxd <= x"0707070707070707";
	xgmii_rxc <= x"ff";
	wait for 100 ns;
end process;    
 
end structure;
