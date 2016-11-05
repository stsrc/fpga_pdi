library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity xgbe_pcs_pma_tb is
end xgbe_pcs_pma_tb;

architecture xgbe_pcs_pma_tb_arch of xgbe_pcs_pma_tb is

component xgbe_pcs_pma is
	port (
		clk_156_25MHz_p		: in std_logic;
        clk_156_25MHz_n     : in std_logic;
        rstn_clk_156_25MHz     : in std_logic;
    
        clk_100MHz        : in std_logic;
        rstn_clk_100MHz    : in std_logic;
    
		interrupt		: out std_logic;
		s_axi_aclk		: in std_logic;
		s_axi_aresetn		: in std_logic;
		s_axi_awaddr		: in std_logic_vector(3 downto 0);
		s_axi_awprot		: in std_logic_vector(2 downto 0);
		s_axi_awvalid		: in std_logic;
		s_axi_awready		: out std_logic;
		s_axi_wdata		: in std_logic_vector(31 downto 0);
		s_axi_wstrb		: in std_logic_vector(3 downto 0);
		s_axi_wvalid		: in std_logic;
		s_axi_wready		: out std_logic;
		s_axi_bresp		: out std_logic_vector(1 downto 0);
		s_axi_bvalid		: out std_logic;
		s_axi_bready		: in std_logic;
		s_axi_araddr		: in std_logic_vector(3 downto 0);
		s_axi_arprot		: in std_logic_vector(2 downto 0);
		s_axi_arvalid		: in std_logic;
		s_axi_arready		: out std_logic;
		s_axi_rdata		: out std_logic_vector(31 downto 0);
		s_axi_rresp		: out std_logic_vector(1 downto 0);
		s_axi_rvalid		: out std_logic;
		s_axi_rready		: in std_logic;

    M_AXI_ACLK : IN STD_LOGIC;
    M_AXI_ARESETN : IN STD_LOGIC;
    M_AXI_AWID : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    M_AXI_AWADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    M_AXI_AWLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    M_AXI_AWSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M_AXI_AWBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    M_AXI_AWLOCK : OUT STD_LOGIC;
    M_AXI_AWCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M_AXI_AWPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M_AXI_AWQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M_AXI_AWUSER : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    M_AXI_AWVALID : OUT STD_LOGIC;
    M_AXI_AWREADY : IN STD_LOGIC;
    M_AXI_WDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    M_AXI_WSTRB : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M_AXI_WLAST : OUT STD_LOGIC;
    M_AXI_WUSER : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    M_AXI_WVALID : OUT STD_LOGIC;
    M_AXI_WREADY : IN STD_LOGIC;
    M_AXI_BID : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    M_AXI_BRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    M_AXI_BUSER : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    M_AXI_BVALID : IN STD_LOGIC;
    M_AXI_BREADY : OUT STD_LOGIC;
    M_AXI_ARID : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    M_AXI_ARADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    M_AXI_ARLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    M_AXI_ARSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M_AXI_ARBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    M_AXI_ARLOCK : OUT STD_LOGIC;
    M_AXI_ARCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M_AXI_ARPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    M_AXI_ARQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    M_AXI_ARUSER : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    M_AXI_ARVALID : OUT STD_LOGIC;
    M_AXI_ARREADY : IN STD_LOGIC;
    M_AXI_RID : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    M_AXI_RDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    M_AXI_RRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    M_AXI_RLAST : IN STD_LOGIC;
    M_AXI_RUSER : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    M_AXI_RVALID : IN STD_LOGIC;
    M_AXI_RREADY : OUT STD_LOGIC;



		rxp 			: in std_logic;
		rxn 			: in std_logic;
		txp 			: out std_logic;
		txn 			: out std_logic;
		coreclk_out		: out std_logic;
		core_status		: out std_logic_vector(7 downto 0);
		sim_speedup_control	: in std_logic;
		resetdone		: out std_logic
	);
end component;


component AXI_Slave_for_tb is
	generic (	
	C_S_AXI_ID_WIDTH	: integer	:= 1;
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
	S_AXI_AWID	: in std_logic_vector(0 downto 0);
	S_AXI_AWADDR	: in std_logic_vector(31 downto 0);
	S_AXI_AWLEN	: in std_logic_vector(7 downto 0);
	S_AXI_AWSIZE	: in std_logic_vector(2 downto 0);
	S_AXI_AWBURST	: in std_logic_vector(1 downto 0);
	S_AXI_AWLOCK	: in std_logic;
	S_AXI_AWCACHE	: in std_logic_vector(3 downto 0);
	S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
	S_AXI_AWQOS	: in std_logic_vector(3 downto 0);
	S_AXI_AWREGION	: in std_logic_vector(3 downto 0);
	S_AXI_AWUSER	: in std_logic_vector(0 downto 0);
	S_AXI_AWVALID	: in std_logic;
	S_AXI_AWREADY	: out std_logic;
	S_AXI_WDATA	: in std_logic_vector(31 downto 0);
	S_AXI_WSTRB	: in std_logic_vector(3 downto 0);
	S_AXI_WLAST	: in std_logic;
	S_AXI_WUSER	: in std_logic_vector(0 downto 0);
	S_AXI_WVALID	: in std_logic;
	S_AXI_WREADY	: out std_logic;
	S_AXI_BID	: out std_logic_vector(0 downto 0);
	S_AXI_BRESP	: out std_logic_vector(1 downto 0);
	S_AXI_BUSER	: out std_logic_vector(0 downto 0);
	S_AXI_BVALID	: out std_logic;
	S_AXI_BREADY	: in std_logic;	
	S_AXI_ARID	: in std_logic_vector(0 downto 0);
	S_AXI_ARADDR	: in std_logic_vector(31 downto 0);
	S_AXI_ARLEN	: in std_logic_vector(7 downto 0);
	S_AXI_ARSIZE	: in std_logic_vector(2 downto 0);
	S_AXI_ARBURST	: in std_logic_vector(1 downto 0);
	S_AXI_ARLOCK	: in std_logic;
	S_AXI_ARCACHE	: in std_logic_vector(3 downto 0);
	S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
	S_AXI_ARQOS	: in std_logic_vector(3 downto 0);
	S_AXI_ARREGION	: in std_logic_vector(3 downto 0);
	S_AXI_ARUSER	: in std_logic_vector(0 downto 0);
	S_AXI_ARVALID	: in std_logic;
	S_AXI_ARREADY	: out std_logic;
	S_AXI_RID	: out std_logic_vector(0 downto 0);
	S_AXI_RDATA	: out std_logic_vector(31 downto 0); 
	S_AXI_RRESP	: out std_logic_vector(1 downto 0);
	S_AXI_RLAST	: out std_logic;
	S_AXI_RUSER	: out std_logic_vector(0 downto 0);
	S_AXI_RVALID	: out std_logic; 
	S_AXI_RREADY	: in std_logic
	);
end component;

  signal in_a_frame : std_logic := '0';

  -- Lock FSM states
  constant LOCK_INIT : integer := 0;
  constant RESET_CNT : integer := 1;
  constant TEST_SH_ST: integer := 2;
  shared variable send_my_packet : integer := 0;
	shared variable packet_cnt : integer := 0;
	shared variable bytes_cnt  : integer := 0;
	shared variable read_cnt   : integer := 0;
  signal coreclk_out : std_logic := '0';
  signal core_status : std_logic_vector(7 downto 0) := (others => '0');
  signal sim_speedup_control, resetdone : std_logic := '0';

  signal clk_156_25MHz_p, clk_156_25MHz_n, rstn_clk_156_25MHz : std_logic := '0';
  signal interrupt : std_logic := '0';
  signal s_axi_aclk, s_axi_aresetn, s_axi_arready, s_axi_arvalid, s_axi_awready, s_axi_awvalid : std_logic := '0';
  signal s_axi_bready, s_axi_bvalid, s_axi_rready, s_axi_rvalid, s_axi_wready, s_axi_wvalid : std_logic := '0';
  signal s_axi_rdata, s_axi_wdata : std_logic_vector(31 downto 0) := (others => '0');
  signal s_axi_araddr, s_axi_awaddr, s_axi_wstrb : std_logic_vector(3 downto 0) := (others => '0');
  signal s_axi_arprot, s_axi_awprot : std_logic_vector(2 downto 0) := (others => '0');
  signal s_axi_bresp, s_axi_rresp : std_logic_vector(1 downto 0) := (others => '0');

signal M_AXI_ACLK, M_AXI_ARESETN, M_AXI_AWLOCK, M_AXI_AWVALID, M_AXI_AWREADY, M_AXI_WLAST : std_logic := '0';
signal M_AXI_WVALID, M_AXI_WREADY, M_AXI_BVALID, M_AXI_BREADY, M_AXI_ARLOCK, M_AXI_ARVALID : std_logic := '0';
signal M_AXI_ARREADY, M_AXI_RLAST, M_AXI_RVALID, M_AXI_RREADY : std_logic := '0';
signal M_AXI_AWID, M_AXI_ARID : std_logic_vector(0 downto 0) := (others => '0');
signal M_AXI_AWADDR, M_AXI_ARADDR : std_logic_vector(31 downto 0);
signal M_AXI_WUSER	: std_logic_vector(0 downto 0); 
signal M_AXI_AWLEN	: std_logic_vector(7 downto 0)  := (others => '0');
signal M_AXI_AWSIZE	: std_logic_vector(2 downto 0)  := (others => '0');
signal M_AXI_AWBURST	: std_logic_vector(1 downto 0)  := (others => '0');
signal M_AXI_AWCACHE	: std_logic_vector(3 downto 0)  := (others => '0');
signal M_AXI_AWPROT	: std_logic_vector(2 downto 0)  := (others => '0');
signal M_AXI_AWQOS	: std_logic_vector(3 downto 0)  := (others => '0');
signal M_AXI_AWUSER	: std_logic_vector(0 downto 0) := (others => '0');
signal M_AXI_WSTRB	: std_logic_vector(3 downto 0)  := (others => '0');
signal M_AXI_BID	: std_logic_vector(0 downto 0)  := (others => '0');
signal M_AXI_BRESP	: std_logic_vector(1 downto 0)  := (others => '0');
signal M_AXI_BUSER	: std_logic_vector(0 downto 0) := (others => '0');
signal M_AXI_ARLEN	: std_logic_vector(7 downto 0)  := (others => '0');
signal M_AXI_ARSIZE	: std_logic_vector(2 downto 0)  := (others => '0');
signal M_AXI_ARBURST	: std_logic_vector(1 downto 0)  := (others => '0');
signal M_AXI_ARCACHE	: std_logic_vector(3 downto 0)  := (others => '0');
signal M_AXI_ARPROT	: std_logic_vector(2 downto 0)  := (others => '0');
signal M_AXI_ARQOS	: std_logic_vector(3 downto 0)  := (others => '0');
signal M_AXI_ARUSER	: std_logic_vector(0 downto 0) := (others => '0');
signal M_AXI_RID	: std_logic_vector(0 downto 0)  := (others => '0');
signal M_AXI_WDATA	: std_logic_vector(31 downto 0) := (others => '0');
signal M_AXI_RDATA	: std_logic_vector(31 downto 0) := (others => '0');
signal M_AXI_RRESP	: std_logic_vector(1 downto 0)  := (others => '0');
signal M_AXI_RUSER	: std_logic_vector(0 downto 0) := (others => '0');

signal M_RD_STRB, M_TX_STRB	: std_logic := '0';
signal M_RD_DATA, M_TX_DATA	: std_logic_vector(31 downto 0) := (others => '0');

  signal rxp, rxn, txp, txn : std_logic := '0';

  signal test_sh : std_logic := '0';
  signal slip : std_logic := '0';
  signal BLSTATE : integer := 0;
  signal next_blstate : integer := 0;
  signal RxD : std_logic_vector(65 downto 0);
  signal RxD_aligned : std_logic_vector(65 downto 0);
  signal nbits : integer := 0;
  signal sh_cnt : integer := 0;
  signal sh_invalid_cnt : integer := 0;

  signal DeScrambler_Register : std_logic_vector(57 downto 0) :=  "00" & x"00000000000003";
  signal RXD_input : std_logic_vector(63 downto 0) := x"0000000000000000";
  signal RX_Sync_header : std_logic_vector(1 downto 0) := "01";
  signal DeScr_wire : std_logic_vector(63 downto 0);
  signal DeScr_RXD : std_logic_vector(65 downto 0) := "00" & x"0000000000000079";

  signal TxEnc : std_logic_vector(65 downto 0) := (others => '0');
  signal d0 : std_logic_vector(31 downto 0) := (others => '0');
  signal c0 : std_logic_vector(3 downto 0) := (others => '0');
  signal d : std_logic_vector(63 downto 0) := (others => '0');
  signal c : std_logic_vector(7 downto 0) := (others => '0');
  signal decided_clk_edge : std_logic := '0';
  signal clk_edge : std_logic;

  signal TxEnc_Data : std_logic_vector(65 downto 0) := (others => '0');
  signal TxEnc_clock : std_logic;
  signal TXD_Scr : std_logic_vector(65 downto 0) := "00" & x"0000000000000002";

  signal Scrambler_Register : std_logic_vector(57 downto 0) :=  "00" & x"00000000000003";
  signal TXD_input : std_logic_vector(63 downto 0) := (others => '0');
  signal Sync_header : std_logic_vector(1 downto 0) :=  "10";
  signal Scr_wire : std_logic_vector(63 downto 0) := (others => '0');

  signal serial_word : std_logic_vector(65 downto 0) := (others => '0');

	signal bitclk : std_logic;
	signal block_lock : std_logic := '0';

	signal ReadIt, SendIt : std_logic := '0';

	constant BITPERIOD : time := 98 ps;
	constant PERIODCORECLK : time := 66*98 ps; 

	type column_typ is record
                       d : bit_vector(31 downto 0);
                       c : bit_vector(3 downto 0);
                     end record;

	type column_array_typ is array (natural range <>) of column_typ;

	type frame_typ is record
                      stim : column_array_typ(0 to 31);
                      length : integer;
                    end record;

  type frame_typ_array is array (natural range 0 to 3) of frame_typ;

  constant frame_data : frame_typ_array := (
    0      => ( -- frame 0
      stim => (
        0  => ( d => X"555555fb", c => X"1" ),
        1  => ( d => X"d5555555", c => X"0" ),
        2  => ( d => X"00000000", c => X"0" ),
        3  => ( d => X"00000000", c => X"0" ),
        4  => ( d => X"00000000", c => X"0" ),
        5  => ( d => X"00000000", c => X"0" ),
        6  => ( d => X"00000000", c => X"0" ),
        7  => ( d => X"00000000", c => X"0" ),
        8  => ( d => X"00000000", c => X"0" ),
        9  => ( d => X"00000000", c => X"0" ),
        10 => ( d => X"00000000", c => X"0" ),
        11 => ( d => X"00000000", c => X"0" ),
        12 => ( d => X"00000000", c => X"0" ),
        13 => ( d => X"00000000", c => X"0" ),
        14 => ( d => X"00000000", c => X"0" ),
        15 => ( d => X"00000000", c => X"0" ),
        16 => ( d => X"00000000", c => X"0" ),
        17 => ( d => X"00000000", c => X"0" ),
        18 => ( d => X"758d6336", c => X"0" ),
        19 => ( d => X"070707fd", c => X"F" ),
        20 => ( d => X"07070707", c => X"F" ),
        21 => ( d => X"07070707", c => X"F" ),
        22 => ( d => X"07070707", c => X"F" ),
        23 => ( d => X"07070707", c => X"F" ),
        24 => ( d => X"07070707", c => X"F" ),
        25 => ( d => X"07070707", c => X"F" ),
        26 => ( d => X"07070707", c => X"F" ),
        27 => ( d => X"07070707", c => X"F" ),
        28 => ( d => X"07070707", c => X"F" ),
        29 => ( d => X"07070707", c => X"F" ),
        30 => ( d => X"07070707", c => X"F" ),
        31 => ( d => X"07070707", c => X"F" )),
    length => 20),
    1      => ( -- frame 1
      stim => (
        0  => ( d => X"555555FB", c => X"1" ),
        1  => ( d => X"d5555555", c => X"0" ),
        2  => ( d => X"ffffffff", c => X"0" ),
        3  => ( d => X"ffffffff", c => X"0" ),
        4  => ( d => X"ffffffff", c => X"0" ),
        5  => ( d => X"ffffffff", c => X"0" ),
        6  => ( d => X"ffffffff", c => X"0" ),
        7  => ( d => X"ffffffff", c => X"0" ),
        8  => ( d => X"ffffffff", c => X"0" ),
        9  => ( d => X"ffffffff", c => X"0" ),
        10 => ( d => X"ffffffff", c => X"0" ),
        11 => ( d => X"ffffffff", c => X"0" ),
        12 => ( d => X"ffffffff", c => X"0" ),
        13 => ( d => X"ffffffff", c => X"0" ),
        14 => ( d => X"ffffffff", c => X"0" ),
        15 => ( d => X"ffffffff", c => X"0" ),
        16 => ( d => X"ffffffff", c => X"0" ),
        17 => ( d => X"ffffffff", c => X"0" ),
        18 => ( d => X"BB3B15ff", c => X"0" ),
        19 => ( d => X"0707fdD4", c => "1110" ),
        20 => ( d => X"07070707", c => X"F" ),
        21 => ( d => X"07070707", c => X"F" ),
        22 => ( d => X"07070707", c => X"F" ),
        23 => ( d => X"07070707", c => X"F" ),
        24 => ( d => X"07070707", c => X"F" ),
        25 => ( d => X"07070707", c => X"F" ),
        26 => ( d => X"07070707", c => X"F" ),
        27 => ( d => X"07070707", c => X"F" ),
        28 => ( d => X"07070707", c => X"F" ),
        29 => ( d => X"07070707", c => X"F" ),
        30 => ( d => X"07070707", c => X"F" ),
        31 => ( d => X"07070707", c => X"F" )),
    length => 20),
    2      => ( -- frame 2
      stim => (
        0  => ( d => X"555555FB", c => X"1" ),
        1  => ( d => X"d5555555", c => X"0" ),
        2  => ( d => X"ffffffff", c => X"0" ),
        3  => ( d => X"ffffffff", c => X"0" ),
        4  => ( d => X"ffffffff", c => X"0" ),
        5  => ( d => X"ffffffff", c => X"0" ),
        6  => ( d => X"ffffffff", c => X"0" ),
        7  => ( d => X"ffffffff", c => X"0" ),
        8  => ( d => X"ffffffff", c => X"0" ),
        9  => ( d => X"ffffffff", c => X"0" ),
        10 => ( d => X"ffffffff", c => X"0" ),
        11 => ( d => X"ffffffff", c => X"0" ),
        12 => ( d => X"ffffffff", c => X"0" ),
        13 => ( d => X"ffffffff", c => X"0" ),
        14 => ( d => X"ffffffff", c => X"0" ),
        15 => ( d => X"ffffffff", c => X"0" ),
        16 => ( d => X"ffffffff", c => X"0" ),
        17 => ( d => X"90ffffff", c => X"0" ),
        18 => ( d => X"fd6E14FE", c => "1000" ),
        19 => ( d => X"0707fdD4", c => X"F" ),
        20 => ( d => X"07070707", c => X"F" ),
        21 => ( d => X"07070707", c => X"F" ),
        22 => ( d => X"07070707", c => X"F" ),
        23 => ( d => X"07070707", c => X"F" ),
        24 => ( d => X"07070707", c => X"F" ),
        25 => ( d => X"07070707", c => X"F" ),
        26 => ( d => X"07070707", c => X"F" ),
        27 => ( d => X"07070707", c => X"F" ),
        28 => ( d => X"07070707", c => X"F" ),
        29 => ( d => X"07070707", c => X"F" ),
        30 => ( d => X"07070707", c => X"F" ),
        31 => ( d => X"07070707", c => X"F" )),
   length => 20), --TODO CHECK WHAT HAPPENS WHEN length = 19
    3      => ( -- frame 3
      stim => (
        0  => ( d => X"555555FB", c => X"1" ),
        1  => ( d => X"d5555555", c => X"0" ),
        2  => ( d => X"f0f0f0f0", c => X"0" ),
        3  => ( d => X"f0f0f0f0", c => X"0" ),
        4  => ( d => X"f0f0f0f0", c => X"0" ),
        5  => ( d => X"f0f0f0f0", c => X"0" ),
        6  => ( d => X"f0f0f0f0", c => X"0" ),
        7  => ( d => X"f0f0f0f0", c => X"0" ),
        8  => ( d => X"f0f0f0f0", c => X"0" ),
        9  => ( d => X"f0f0f0f0", c => X"0" ),
        10 => ( d => X"f0f0f0f0", c => X"0" ),
        11 => ( d => X"f0f0f0f0", c => X"0" ),
        12 => ( d => X"f0f0f0f0", c => X"0" ),
        13 => ( d => X"f0f0f0f0", c => X"0" ),
        14 => ( d => X"f0f0f0f0", c => X"0" ),
        15 => ( d => X"f0f0f0f0", c => X"0" ),
        16 => ( d => X"f0f0f0f0", c => X"0" ),
        17 => ( d => X"f0f0f0f0", c => X"0" ),
        18 => ( d => X"E97357f0", c => X"0" ),
        19 => ( d => X"0707fdD8", c => "1110" ),
        20 => ( d => X"07070707", c => X"F" ),
        21 => ( d => X"07070707", c => X"F" ),
        22 => ( d => X"07070707", c => X"F" ),
        23 => ( d => X"07070707", c => X"F" ),
        24 => ( d => X"07070707", c => X"F" ),
        25 => ( d => X"07070707", c => X"F" ),
        26 => ( d => X"07070707", c => X"F" ),
        27 => ( d => X"07070707", c => X"F" ),
        28 => ( d => X"07070707", c => X"F" ),
        29 => ( d => X"07070707", c => X"F" ),
        30 => ( d => X"07070707", c => X"F" ),
        31 => ( d => X"07070707", c => X"F" )),
    length => 20));


begin
	xgbe_pcs_pma_0 : xgbe_pcs_pma
	port map (
		clk_156_25MHz_p => clk_156_25MHz_p,
		clk_156_25MHz_n => clk_156_25MHz_n,
		rstn_clk_156_25MHz => rstn_clk_156_25MHz,
		
		clk_100MHz => s_axi_aclk,
        rstn_clk_100MHz => s_axi_aresetn,

		interrupt => interrupt,
		s_axi_aclk => s_axi_aclk,
      		s_axi_araddr(3 downto 0) => s_axi_araddr(3 downto 0),
      		s_axi_aresetn => s_axi_aresetn,
		s_axi_arprot(2 downto 0) => s_axi_arprot(2 downto 0),
		s_axi_arready => s_axi_arready,
		s_axi_arvalid => s_axi_arvalid,
		s_axi_awaddr(3 downto 0) => s_axi_awaddr(3 downto 0),
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

		rxp => rxp,
		rxn => rxn,
		txp => txp,
		txn => txn,
    
		coreclk_out => coreclk_out,
		core_status => core_status,
		sim_speedup_control => sim_speedup_control,

		resetdone => resetdone
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


  -- Generate the resets.
  reset_proc : process
  begin
    rstn_clk_156_25MHz <= '0';
    s_axi_aresetn <= '0';
    wait for 6.4 ns;
    rstn_clk_156_25MHz <= '1';
    wait for 3.6 ns;
    s_axi_aresetn <= '1';
    wait for 40 ns;
    wait until coreclk_out = '1';
    sim_speedup_control <= '1';
    wait;
  end process reset_proc;

  -- Generate the 156.25MHz
  gen_refclk : process
  begin
    clk_156_25MHz_p <= '0';
    clk_156_25MHz_n <= '1';
    wait for PERIODCORECLK/2;
    clk_156_25MHz_p <= '1';
    clk_156_25MHz_n <= '0';
    wait for PERIODCORECLK/2;
  end process gen_refclk;

  -- Generate the bitclk
  gen_bitclk : process
    variable first : integer := 1;
  begin
    bitclk <= '0';
    if(first = 1) then
      wait for BITPERIOD/4;
      first := 0;
    end if;
    wait for BITPERIOD/2;
    bitclk <= '1';
    wait for BITPERIOD/2;
  end process gen_bitclk;

  --generate s_axi_aclk
  gen_s_axi_aclk : process
  begin
	s_axi_aclk <= '0';
	wait for 5 ns;
	s_axi_aclk <= '1';
	wait for 5 ns;
  end process gen_s_axi_aclk;


  p_rx_stimulus : process

    -- Encode next 64 bits of frame;
    procedure rx_stimulus_send_column (
      constant d1 : in std_logic_vector(31 downto 0);
      constant c1 : in std_logic_vector(3 downto 0)) is
    begin
      wait until coreclk_out'event;
      d0 <= d1;
      c0 <= c1;

      d <= d1 & d0;
      c <= c1 & c0;

      -- Need to know when to apply the encoded data to the scrambler
      if(decided_clk_edge = '0' and (c0(0) = '1' or c0(1) = '1' or c0(2) = '1' or c0(3) = '1')) then -- Found first full 64 bit word
        clk_edge <= not(coreclk_out);
        decided_clk_edge <= '1';
      end if;

      -- Detect column of IDLEs vs T code in byte 0
      if(c = x"FF" and d(7 downto 0) /= x"FD") then -- Column of IDLEs
        TxEnc(1 downto 0) <= "01";
        TxEnc(65 downto 2) <= x"000000000000001E";
      elsif(c /= x"00") then -- Control code somewhere
        TxEnc(1 downto 0) <= "01";

        if(c = "00000001") then -- Start code
          TxEnc(9 downto 2) <= x"78";
          TxEnc(65 downto 10) <= d(63 downto 8);
        end if;
        if(c = "00011111") then -- Start code
          TxEnc(9 downto 2) <= x"33";
          TxEnc(41 downto 10) <= x"00000000";
          TxEnc(65 downto 42) <= d(63 downto 40);
        elsif(c = "10000000") then -- End code
          TxEnc(9 downto 2) <= x"FF";
          TxEnc(65 downto 10) <= d(55 downto 0);
        elsif(c = "11000000") then -- End code
          TxEnc(9 downto 2) <= x"E1";
          TxEnc(57 downto 10) <= d(47 downto 0);
          TxEnc(65 downto 58) <= x"00";
        elsif(c = "11100000") then -- End code
          TxEnc(9 downto 2) <= x"D2";
          TxEnc(49 downto 10) <= d(39 downto 0);
          TxEnc(65 downto 50) <= x"0000";
        elsif(c = "11110000") then -- End code
          TxEnc(9 downto 2) <= x"CC";
          TxEnc(41 downto 10) <= d(31 downto 0);
          TxEnc(65 downto 42) <= x"000000";
        elsif(c = "11111000") then -- End code
          TxEnc(9 downto 2) <= x"B4";
          TxEnc(33 downto 10) <= d(23 downto 0);
          TxEnc(65 downto 34) <= x"00000000";
        elsif(c = "11111100") then -- End code
          TxEnc(9 downto 2) <= x"AA";
          TxEnc(25 downto 10) <= d(15 downto 0);
          TxEnc(65 downto 26) <= x"0000000000";
        elsif(c = "11111110") then -- End code
          TxEnc(9 downto 2) <= x"99";
          TxEnc(17 downto 10) <= d(7 downto 0);
          TxEnc(65 downto 18) <= x"000000000000";
        elsif(c = "11111111") then -- End code
          TxEnc(9 downto 2) <= x"87";
          TxEnc(65 downto 10) <= x"00000000000000";
        end if;
      else -- all data
        TxEnc(1 downto 0) <= "10";
        TxEnc(65 downto 2) <= d;
      end if;
    end rx_stimulus_send_column;

    procedure rx_send_column (
      constant c : in column_typ) is
    begin -- send_column
      rx_stimulus_send_column(to_stdlogicvector(c.d), to_stdlogicvector(c.c));
    end rx_send_column;

    procedure rx_stimulus_send_idle is
    begin
      rx_stimulus_send_column(x"07070707", "1111");
    end rx_stimulus_send_idle;

    procedure rx_stimulus_send_frame (
      constant frame : in frame_typ) is
        variable column_index : integer := 0;
    begin
      column_index := 0;
      -- send columns
      while (column_index < frame.length) loop
        rx_send_column(frame.stim(column_index));
        column_index := column_index + 1;
      end loop;
      report "Receiver: frame inserted into Serial interface" severity note;
    end rx_stimulus_send_frame;

  begin
    	while (send_my_packet /= 1) loop
      		rx_stimulus_send_idle;
    	end loop;
	while (true) loop	
		for i in 0 to 3 loop
		    	rx_stimulus_send_frame(frame_data(i));
			rx_stimulus_send_idle;
		end loop;
	end loop;
    wait;
  end process p_rx_stimulus;

  -- Capture the 66 bit data for scrambling...
  TxEnc_clock <= clk_edge xnor coreclk_out;

  p_rxready : process(TxEnc_clock)
  begin
    if(rising_edge(TxEnc_clock)) then
      TxEnc_Data <= TxEnc;
    end if;
  end process;

  -- Scramble the TxEnc_Data before applying to rxn/p
  Scr_wire(0) <= TXD_input(0) xor Scrambler_Register(38) xor Scrambler_Register(57);
  Scr_wire(1) <= TXD_input(1) xor Scrambler_Register(37) xor Scrambler_Register(56);
  Scr_wire(2) <= TXD_input(2) xor Scrambler_Register(36) xor Scrambler_Register(55);
  Scr_wire(3) <= TXD_input(3) xor Scrambler_Register(35) xor Scrambler_Register(54);
  Scr_wire(4) <= TXD_input(4) xor Scrambler_Register(34) xor Scrambler_Register(53);
  Scr_wire(5) <= TXD_input(5) xor Scrambler_Register(33) xor Scrambler_Register(52);
  Scr_wire(6) <= TXD_input(6) xor Scrambler_Register(32) xor Scrambler_Register(51);
  Scr_wire(7) <= TXD_input(7) xor Scrambler_Register(31) xor Scrambler_Register(50);

  Scr_wire(8) <= TXD_input(8) xor Scrambler_Register(30) xor Scrambler_Register(49);
  Scr_wire(9) <= TXD_input(9) xor Scrambler_Register(29) xor Scrambler_Register(48);
  Scr_wire(10) <= TXD_input(10) xor Scrambler_Register(28) xor Scrambler_Register(47);
  Scr_wire(11) <= TXD_input(11) xor Scrambler_Register(27) xor Scrambler_Register(46);
  Scr_wire(12) <= TXD_input(12) xor Scrambler_Register(26) xor Scrambler_Register(45);
  Scr_wire(13) <= TXD_input(13) xor Scrambler_Register(25) xor Scrambler_Register(44);
  Scr_wire(14) <= TXD_input(14) xor Scrambler_Register(24) xor Scrambler_Register(43);
  Scr_wire(15) <= TXD_input(15) xor Scrambler_Register(23) xor Scrambler_Register(42);

  Scr_wire(16) <= TXD_input(16) xor Scrambler_Register(22) xor Scrambler_Register(41);
  Scr_wire(17) <= TXD_input(17) xor Scrambler_Register(21) xor Scrambler_Register(40);
  Scr_wire(18) <= TXD_input(18) xor Scrambler_Register(20) xor Scrambler_Register(39);
  Scr_wire(19) <= TXD_input(19) xor Scrambler_Register(19) xor Scrambler_Register(38);
  Scr_wire(20) <= TXD_input(20) xor Scrambler_Register(18) xor Scrambler_Register(37);
  Scr_wire(21) <= TXD_input(21) xor Scrambler_Register(17) xor Scrambler_Register(36);
  Scr_wire(22) <= TXD_input(22) xor Scrambler_Register(16) xor Scrambler_Register(35);
  Scr_wire(23) <= TXD_input(23) xor Scrambler_Register(15) xor Scrambler_Register(34);

  Scr_wire(24) <= TXD_input(24) xor Scrambler_Register(14) xor Scrambler_Register(33);
  Scr_wire(25) <= TXD_input(25) xor Scrambler_Register(13) xor Scrambler_Register(32);
  Scr_wire(26) <= TXD_input(26) xor Scrambler_Register(12) xor Scrambler_Register(31);
  Scr_wire(27) <= TXD_input(27) xor Scrambler_Register(11) xor Scrambler_Register(30);
  Scr_wire(28) <= TXD_input(28) xor Scrambler_Register(10) xor Scrambler_Register(29);
  Scr_wire(29) <= TXD_input(29) xor Scrambler_Register(9) xor Scrambler_Register(28);
  Scr_wire(30) <= TXD_input(30) xor Scrambler_Register(8) xor Scrambler_Register(27);
  Scr_wire(31) <= TXD_input(31) xor Scrambler_Register(7) xor Scrambler_Register(26);

  Scr_wire(32) <= TXD_input(32) xor Scrambler_Register(6) xor Scrambler_Register(25);
  Scr_wire(33) <= TXD_input(33) xor Scrambler_Register(5) xor Scrambler_Register(24);
  Scr_wire(34) <= TXD_input(34) xor Scrambler_Register(4) xor Scrambler_Register(23);
  Scr_wire(35) <= TXD_input(35) xor Scrambler_Register(3) xor Scrambler_Register(22);
  Scr_wire(36) <= TXD_input(36) xor Scrambler_Register(2) xor Scrambler_Register(21);
  Scr_wire(37) <= TXD_input(37) xor Scrambler_Register(1) xor Scrambler_Register(20);
  Scr_wire(38) <= TXD_input(38) xor Scrambler_Register(0) xor Scrambler_Register(19);
  Scr_wire(39) <= TXD_input(39) xor TXD_input(0) xor Scrambler_Register(38) xor Scrambler_Register(57) xor Scrambler_Register(18);
  Scr_wire(40) <= TXD_input(40) xor (TXD_input(1) xor Scrambler_Register(37) xor Scrambler_Register(56)) xor Scrambler_Register(17);
  Scr_wire(41) <= TXD_input(41) xor (TXD_input(2) xor Scrambler_Register(36) xor Scrambler_Register(55)) xor Scrambler_Register(16);
  Scr_wire(42) <= TXD_input(42) xor (TXD_input(3) xor Scrambler_Register(35) xor Scrambler_Register(54)) xor Scrambler_Register(15);
  Scr_wire(43) <= TXD_input(43) xor (TXD_input(4) xor Scrambler_Register(34) xor Scrambler_Register(53)) xor Scrambler_Register(14);
  Scr_wire(44) <= TXD_input(44) xor (TXD_input(5) xor Scrambler_Register(33) xor Scrambler_Register(52)) xor Scrambler_Register(13);
  Scr_wire(45) <= TXD_input(45) xor (TXD_input(6) xor Scrambler_Register(32) xor Scrambler_Register(51)) xor Scrambler_Register(12);
  Scr_wire(46) <= TXD_input(46) xor (TXD_input(7) xor Scrambler_Register(31) xor Scrambler_Register(50)) xor Scrambler_Register(11);
  Scr_wire(47) <= TXD_input(47) xor (TXD_input(8) xor Scrambler_Register(30) xor Scrambler_Register(49)) xor Scrambler_Register(10);

  Scr_wire(48) <= TXD_input(48) xor (TXD_input(9) xor Scrambler_Register(29) xor Scrambler_Register(48)) xor Scrambler_Register(9);
  Scr_wire(49) <= TXD_input(49) xor (TXD_input(10) xor Scrambler_Register(28) xor Scrambler_Register(47)) xor Scrambler_Register(8);
  Scr_wire(50) <= TXD_input(50) xor (TXD_input(11) xor Scrambler_Register(27) xor Scrambler_Register(46)) xor Scrambler_Register(7);
  Scr_wire(51) <= TXD_input(51) xor (TXD_input(12) xor Scrambler_Register(26) xor Scrambler_Register(45)) xor Scrambler_Register(6);
  Scr_wire(52) <= TXD_input(52) xor (TXD_input(13) xor Scrambler_Register(25) xor Scrambler_Register(44)) xor Scrambler_Register(5);
  Scr_wire(53) <= TXD_input(53) xor (TXD_input(14) xor Scrambler_Register(24) xor Scrambler_Register(43)) xor Scrambler_Register(4);
  Scr_wire(54) <= TXD_input(54) xor (TXD_input(15) xor Scrambler_Register(23) xor Scrambler_Register(42)) xor Scrambler_Register(3);
  Scr_wire(55) <= TXD_input(55) xor (TXD_input(16) xor Scrambler_Register(22) xor Scrambler_Register(41)) xor Scrambler_Register(2);

  Scr_wire(56) <= TXD_input(56) xor (TXD_input(17) xor Scrambler_Register(21) xor Scrambler_Register(40)) xor Scrambler_Register(1);
  Scr_wire(57) <= TXD_input(57) xor (TXD_input(18) xor Scrambler_Register(20) xor Scrambler_Register(39)) xor Scrambler_Register(0);
  Scr_wire(58) <= TXD_input(58) xor (TXD_input(19) xor Scrambler_Register(19) xor Scrambler_Register(38)) xor (TXD_input(0) xor Scrambler_Register(38) xor Scrambler_Register(57));
  Scr_wire(59) <= TXD_input(59) xor (TXD_input(20) xor Scrambler_Register(18) xor Scrambler_Register(37)) xor (TXD_input(1) xor Scrambler_Register(37) xor Scrambler_Register(56));
  Scr_wire(60) <= TXD_input(60) xor (TXD_input(21) xor Scrambler_Register(17) xor Scrambler_Register(36)) xor (TXD_input(2) xor Scrambler_Register(36) xor Scrambler_Register(55));
  Scr_wire(61) <= TXD_input(61) xor (TXD_input(22) xor Scrambler_Register(16) xor Scrambler_Register(35)) xor (TXD_input(3) xor Scrambler_Register(35) xor Scrambler_Register(54));
  Scr_wire(62) <= TXD_input(62) xor (TXD_input(23) xor Scrambler_Register(15) xor Scrambler_Register(34)) xor (TXD_input(4) xor Scrambler_Register(34) xor Scrambler_Register(53));
  Scr_wire(63) <= TXD_input(63) xor (TXD_input(24) xor Scrambler_Register(14) xor Scrambler_Register(33)) xor (TXD_input(5) xor Scrambler_Register(33) xor Scrambler_Register(52));


  p_scramble : process(TxEnc_clock)
  begin
    if(rising_edge(TxEnc_clock)) then
      TXD_input(63 downto 0) <= TxEnc_Data(65 downto 2);
      Sync_header(1 downto 0) <= TxEnc_Data(1 downto 0);
      TXD_Scr(65 downto 0) <= Scr_wire(63 downto 0) & Sync_header(1 downto 0);

      Scrambler_Register(57) <= Scr_wire(6);
      Scrambler_Register(56) <= Scr_wire(7);
      Scrambler_Register(55) <= Scr_wire(8);
      Scrambler_Register(54) <= Scr_wire(9);
      Scrambler_Register(53) <= Scr_wire(10);
      Scrambler_Register(52) <= Scr_wire(11);
      Scrambler_Register(51) <= Scr_wire(12);
      Scrambler_Register(50) <= Scr_wire(13);

      Scrambler_Register(49) <= Scr_wire(14);
      Scrambler_Register(48) <= Scr_wire(15);
      Scrambler_Register(47) <= Scr_wire(16);
      Scrambler_Register(46) <= Scr_wire(17);
      Scrambler_Register(45) <= Scr_wire(18);
      Scrambler_Register(44) <= Scr_wire(19);
      Scrambler_Register(43) <= Scr_wire(20);
      Scrambler_Register(42) <= Scr_wire(21);

      Scrambler_Register(41) <= Scr_wire(22);
      Scrambler_Register(40) <= Scr_wire(23);
      Scrambler_Register(39) <= Scr_wire(24);
      Scrambler_Register(38) <= Scr_wire(25);
      Scrambler_Register(37) <= Scr_wire(26);
      Scrambler_Register(36) <= Scr_wire(27);
      Scrambler_Register(35) <= Scr_wire(28);
      Scrambler_Register(34) <= Scr_wire(29);

      Scrambler_Register(33) <= Scr_wire(30);
      Scrambler_Register(32) <= Scr_wire(31);
      Scrambler_Register(31) <= Scr_wire(32);
      Scrambler_Register(30) <= Scr_wire(33);
      Scrambler_Register(29) <= Scr_wire(34);
      Scrambler_Register(28) <= Scr_wire(35);
      Scrambler_Register(27) <= Scr_wire(36);
      Scrambler_Register(26) <= Scr_wire(37);

      Scrambler_Register(25) <= Scr_wire(38);
      Scrambler_Register(24) <= Scr_wire(39);
      Scrambler_Register(23) <= Scr_wire(40);
      Scrambler_Register(22) <= Scr_wire(41);
      Scrambler_Register(21) <= Scr_wire(42);
      Scrambler_Register(20) <= Scr_wire(43);
      Scrambler_Register(19) <= Scr_wire(44);
      Scrambler_Register(18) <= Scr_wire(45);

      Scrambler_Register(17) <= Scr_wire(46);
      Scrambler_Register(16) <= Scr_wire(47);
      Scrambler_Register(15) <= Scr_wire(48);
      Scrambler_Register(14) <= Scr_wire(49);
      Scrambler_Register(13) <= Scr_wire(50);
      Scrambler_Register(12) <= Scr_wire(51);
      Scrambler_Register(11) <= Scr_wire(52);
      Scrambler_Register(10) <= Scr_wire(53);

      Scrambler_Register(9) <=  Scr_wire(54);
      Scrambler_Register(8) <=  Scr_wire(55);
      Scrambler_Register(7) <=  Scr_wire(56);
      Scrambler_Register(6) <=  Scr_wire(57);
      Scrambler_Register(5) <=  Scr_wire(58);
      Scrambler_Register(4) <=  Scr_wire(59);
      Scrambler_Register(3) <=  Scr_wire(60);
      Scrambler_Register(2) <=  Scr_wire(61);
      Scrambler_Register(1) <=  Scr_wire(62);
      Scrambler_Register(0) <=  Scr_wire(63);
    end if;
  end process p_scramble;

  -- Serialize the RX stimulus
  rxn <= not(rxp);

  p_rx_serialize : process(bitclk)
    variable rxbitno : integer := 0;
  begin
    if(rising_edge(bitclk)) then
      rxp <= serial_word(rxbitno);
      if(rxbitno = 65) then
        serial_word <= TXD_Scr;
      end if;
      rxbitno := (rxbitno + 1) mod 66;
    end if;
  end process p_rx_serialize;

  -- Fill RxD with 66 bits...
  p_tx_serial_capture : process (bitclk)
  begin
    if(rising_edge(bitclk)) then
      if(slip = '0') then
      -- Just grab next 66 bits
        RxD(64 downto 0) <= RxD(65 downto 1);
        RxD(65) <= txp;
        if(nbits < 65) then
          nbits <= nbits + 1;
          test_sh <= '0';
        else
          nbits <= 0;
          test_sh <= '1';
        end if;
      else -- SLIP!!
      -- Just grab single bit
        RxD(64 downto 0) <= RxD(65 downto 1);
        RxD(65) <= txp;
        test_sh <= '1';
        nbits <= 0;
      end if;
    end if;
  end process p_tx_serial_capture;


  -- Implement the block lock state machine on serial TX...
  p_tx_block_lock : process (BLSTATE, test_sh, RxD)
  begin

    case (BLSTATE) is
      when LOCK_INIT =>
        block_lock <= '0';
        next_blstate <= RESET_CNT;
        slip <= '0';
        sh_cnt <= 0;
        sh_invalid_cnt <= 0;
      when RESET_CNT =>
        slip <= '0';
        if(test_sh = '1') then
          next_blstate <= TEST_SH_ST;
        else
          next_blstate <= RESET_CNT;
        end if;
      when TEST_SH_ST =>
        slip <= '0';
        next_blstate <= TEST_SH_ST;
        if(test_sh = '1' and (RxD(0) /= RxD(1))) then -- Good sync header candidate
          sh_cnt <= sh_cnt + 1; -- Immediate update!
          if(sh_cnt < 64) then
            next_blstate <= TEST_SH_ST;
          elsif(sh_cnt = 64 and sh_invalid_cnt > 0) then
            next_blstate <= RESET_CNT;
            sh_cnt <= 0;
            sh_invalid_cnt <= 0;
          elsif(sh_cnt = 64 and sh_invalid_cnt = 0) then
            block_lock <= '1';
            next_blstate <= RESET_CNT;
            sh_cnt <= 0;
            sh_invalid_cnt <= 0;
          end if;
        elsif(test_sh = '1') then -- Bad sync header
          sh_cnt <= sh_cnt + 1;
          sh_invalid_cnt <= sh_invalid_cnt + 1;
          if(sh_cnt = 64 and sh_invalid_cnt < 16 and block_lock = '1') then
            next_blstate <= RESET_CNT;
            sh_cnt <= 0;
            sh_invalid_cnt <= 0;
          elsif(sh_cnt < 64 and sh_invalid_cnt < 16
                  and test_sh = '1' and block_lock = '1') then
            next_blstate <= TEST_SH_ST;
          elsif(sh_invalid_cnt = 16 or block_lock = '0') then
            block_lock <= '0';
            slip <= '1';
            sh_cnt <= 0;
            sh_invalid_cnt <= 0;
            next_blstate <= RESET_CNT;
          end if;
        end if;
      when others =>
        block_lock <= '0';
        next_blstate <= RESET_CNT;
        slip <= '0';
        sh_cnt <= 0;
        sh_invalid_cnt <= 0;
    end case;
  end process p_tx_block_lock;

  -- Implement the block lock state machine on serial TX
  -- And capture the aligned 66 bit words....
  p_tx_block_lock_next_blstate : process (bitclk)
  begin
    if(rising_edge(bitclk)) then
      if(resetdone = '0') then
        BLSTATE <= LOCK_INIT;
      else
        BLSTATE <= next_blstate;
      end if;
      if(test_sh = '1' and block_lock = '1') then
        RxD_aligned <= RxD;
      end if;
    end if;
  end process p_tx_block_lock_next_blstate;

  -- Descramble the TX serial data

  DeScr_wire(0) <= RXD_input(0) xor DeScrambler_Register(38) xor DeScrambler_Register(57);
  DeScr_wire(1) <= RXD_input(1) xor DeScrambler_Register(37) xor DeScrambler_Register(56);
  DeScr_wire(2) <= RXD_input(2) xor DeScrambler_Register(36) xor DeScrambler_Register(55);
  DeScr_wire(3) <= RXD_input(3) xor DeScrambler_Register(35) xor DeScrambler_Register(54);
  DeScr_wire(4) <= RXD_input(4) xor DeScrambler_Register(34) xor DeScrambler_Register(53);
  DeScr_wire(5) <= RXD_input(5) xor DeScrambler_Register(33) xor DeScrambler_Register(52);
  DeScr_wire(6) <= RXD_input(6) xor DeScrambler_Register(32) xor DeScrambler_Register(51);
  DeScr_wire(7) <= RXD_input(7) xor DeScrambler_Register(31) xor DeScrambler_Register(50);

  DeScr_wire(8) <= RXD_input(8) xor DeScrambler_Register(30) xor DeScrambler_Register(49);
  DeScr_wire(9) <= RXD_input(9) xor DeScrambler_Register(29) xor DeScrambler_Register(48);
  DeScr_wire(10) <= RXD_input(10) xor DeScrambler_Register(28) xor DeScrambler_Register(47);
  DeScr_wire(11) <= RXD_input(11) xor DeScrambler_Register(27) xor DeScrambler_Register(46);
  DeScr_wire(12) <= RXD_input(12) xor DeScrambler_Register(26) xor DeScrambler_Register(45);
  DeScr_wire(13) <= RXD_input(13) xor DeScrambler_Register(25) xor DeScrambler_Register(44);
  DeScr_wire(14) <= RXD_input(14) xor DeScrambler_Register(24) xor DeScrambler_Register(43);
  DeScr_wire(15) <= RXD_input(15) xor DeScrambler_Register(23) xor DeScrambler_Register(42);

  DeScr_wire(16) <= RXD_input(16) xor DeScrambler_Register(22) xor DeScrambler_Register(41);
  DeScr_wire(17) <= RXD_input(17) xor DeScrambler_Register(21) xor DeScrambler_Register(40);
  DeScr_wire(18) <= RXD_input(18) xor DeScrambler_Register(20) xor DeScrambler_Register(39);
  DeScr_wire(19) <= RXD_input(19) xor DeScrambler_Register(19) xor DeScrambler_Register(38);
  DeScr_wire(20) <= RXD_input(20) xor DeScrambler_Register(18) xor DeScrambler_Register(37);
  DeScr_wire(21) <= RXD_input(21) xor DeScrambler_Register(17) xor DeScrambler_Register(36);
  DeScr_wire(22) <= RXD_input(22) xor DeScrambler_Register(16) xor DeScrambler_Register(35);
  DeScr_wire(23) <= RXD_input(23) xor DeScrambler_Register(15) xor DeScrambler_Register(34);

  DeScr_wire(24) <= RXD_input(24) xor DeScrambler_Register(14) xor DeScrambler_Register(33);
  DeScr_wire(25) <= RXD_input(25) xor DeScrambler_Register(13) xor DeScrambler_Register(32);
  DeScr_wire(26) <= RXD_input(26) xor DeScrambler_Register(12) xor DeScrambler_Register(31);
  DeScr_wire(27) <= RXD_input(27) xor DeScrambler_Register(11) xor DeScrambler_Register(30);
  DeScr_wire(28) <= RXD_input(28) xor DeScrambler_Register(10) xor DeScrambler_Register(29);
  DeScr_wire(29) <= RXD_input(29) xor DeScrambler_Register(9) xor DeScrambler_Register(28);
  DeScr_wire(30) <= RXD_input(30) xor DeScrambler_Register(8) xor DeScrambler_Register(27);
  DeScr_wire(31) <= RXD_input(31) xor DeScrambler_Register(7) xor DeScrambler_Register(26);

  DeScr_wire(32) <= RXD_input(32) xor DeScrambler_Register(6) xor DeScrambler_Register(25);
  DeScr_wire(33) <= RXD_input(33) xor DeScrambler_Register(5) xor DeScrambler_Register(24);
  DeScr_wire(34) <= RXD_input(34) xor DeScrambler_Register(4) xor DeScrambler_Register(23);
  DeScr_wire(35) <= RXD_input(35) xor DeScrambler_Register(3) xor DeScrambler_Register(22);
  DeScr_wire(36) <= RXD_input(36) xor DeScrambler_Register(2) xor DeScrambler_Register(21);
  DeScr_wire(37) <= RXD_input(37) xor DeScrambler_Register(1) xor DeScrambler_Register(20);
  DeScr_wire(38) <= RXD_input(38) xor DeScrambler_Register(0) xor DeScrambler_Register(19);

  DeScr_wire(39) <= RXD_input(39) xor RXD_input(0) xor DeScrambler_Register(18);
  DeScr_wire(40) <= RXD_input(40) xor RXD_input(1) xor DeScrambler_Register(17);
  DeScr_wire(41) <= RXD_input(41) xor RXD_input(2) xor DeScrambler_Register(16);
  DeScr_wire(42) <= RXD_input(42) xor RXD_input(3) xor DeScrambler_Register(15);
  DeScr_wire(43) <= RXD_input(43) xor RXD_input(4) xor DeScrambler_Register(14);
  DeScr_wire(44) <= RXD_input(44) xor RXD_input(5) xor DeScrambler_Register(13);
  DeScr_wire(45) <= RXD_input(45) xor RXD_input(6) xor DeScrambler_Register(12);
  DeScr_wire(46) <= RXD_input(46) xor RXD_input(7) xor DeScrambler_Register(11);
  DeScr_wire(47) <= RXD_input(47) xor RXD_input(8) xor DeScrambler_Register(10);

  DeScr_wire(48) <= RXD_input(48) xor RXD_input(9) xor DeScrambler_Register(9);
  DeScr_wire(49) <= RXD_input(49) xor RXD_input(10) xor DeScrambler_Register(8);
  DeScr_wire(50) <= RXD_input(50) xor RXD_input(11) xor DeScrambler_Register(7);
  DeScr_wire(51) <= RXD_input(51) xor RXD_input(12) xor DeScrambler_Register(6);
  DeScr_wire(52) <= RXD_input(52) xor RXD_input(13) xor DeScrambler_Register(5);
  DeScr_wire(53) <= RXD_input(53) xor RXD_input(14) xor DeScrambler_Register(4);
  DeScr_wire(54) <= RXD_input(54) xor RXD_input(15) xor DeScrambler_Register(3);

  DeScr_wire(55) <= RXD_input(55) xor RXD_input(16) xor DeScrambler_Register(2);
  DeScr_wire(56) <= RXD_input(56) xor RXD_input(17) xor DeScrambler_Register(1);
  DeScr_wire(57) <= RXD_input(57) xor RXD_input(18) xor DeScrambler_Register(0);
  DeScr_wire(58) <= RXD_input(58) xor RXD_input(19) xor RXD_input(0);
  DeScr_wire(59) <= RXD_input(59) xor RXD_input(20) xor RXD_input(1);
  DeScr_wire(60) <= RXD_input(60) xor RXD_input(21) xor RXD_input(2);
  DeScr_wire(61) <= RXD_input(61) xor RXD_input(22) xor RXD_input(3);
  DeScr_wire(62) <= RXD_input(62) xor RXD_input(23) xor RXD_input(4);
  DeScr_wire(63) <= RXD_input(63) xor RXD_input(24) xor RXD_input(5);

  -- Synchronous part of descrambler
  p_descramble : process (coreclk_out)
  begin
    if(rising_edge(coreclk_out)) then
      RXD_input(63 downto 0) <= RxD_aligned(65 downto 2);
      RX_Sync_header <= RxD_aligned(1 downto 0);
      DeScr_RXD(65 downto 0) <= DeScr_wire(63 downto 0) & RX_Sync_header(1 downto 0);

      DeScrambler_Register(57) <= RXD_input(6);
      DeScrambler_Register(56) <= RXD_input(7);
      DeScrambler_Register(55) <= RXD_input(8);
      DeScrambler_Register(54) <= RXD_input(9);
      DeScrambler_Register(53) <= RXD_input(10);
      DeScrambler_Register(52) <= RXD_input(11);
      DeScrambler_Register(51) <= RXD_input(12);
      DeScrambler_Register(50) <= RXD_input(13);

      DeScrambler_Register(49) <= RXD_input(14);
      DeScrambler_Register(48) <= RXD_input(15);
      DeScrambler_Register(47) <= RXD_input(16);
      DeScrambler_Register(46) <= RXD_input(17);
      DeScrambler_Register(45) <= RXD_input(18);
      DeScrambler_Register(44) <= RXD_input(19);
      DeScrambler_Register(43) <= RXD_input(20);
      DeScrambler_Register(42) <= RXD_input(21);

      DeScrambler_Register(41) <= RXD_input(22);
      DeScrambler_Register(40) <= RXD_input(23);
      DeScrambler_Register(39) <= RXD_input(24);
      DeScrambler_Register(38) <= RXD_input(25);
      DeScrambler_Register(37) <= RXD_input(26);
      DeScrambler_Register(36) <= RXD_input(27);
      DeScrambler_Register(35) <= RXD_input(28);
      DeScrambler_Register(34) <= RXD_input(29);

      DeScrambler_Register(33) <= RXD_input(30);
      DeScrambler_Register(32) <= RXD_input(31);
      DeScrambler_Register(31) <= RXD_input(32);
      DeScrambler_Register(30) <= RXD_input(33);
      DeScrambler_Register(29) <= RXD_input(34);
      DeScrambler_Register(28) <= RXD_input(35);
      DeScrambler_Register(27) <= RXD_input(36);
      DeScrambler_Register(26) <= RXD_input(37);

      DeScrambler_Register(25) <= RXD_input(38);
      DeScrambler_Register(24) <= RXD_input(39);
      DeScrambler_Register(23) <= RXD_input(40);
      DeScrambler_Register(22) <= RXD_input(41);
      DeScrambler_Register(21) <= RXD_input(42);
      DeScrambler_Register(20) <= RXD_input(43);
      DeScrambler_Register(19) <= RXD_input(44);
      DeScrambler_Register(18) <= RXD_input(45);

      DeScrambler_Register(17) <= RXD_input(46);
      DeScrambler_Register(16) <= RXD_input(47);
      DeScrambler_Register(15) <= RXD_input(48);
      DeScrambler_Register(14) <= RXD_input(49);
      DeScrambler_Register(13) <= RXD_input(50);
      DeScrambler_Register(12) <= RXD_input(51);
      DeScrambler_Register(11) <= RXD_input(52);
      DeScrambler_Register(10) <= RXD_input(53);

      DeScrambler_Register(9) <= RXD_input(54);
      DeScrambler_Register(8) <= RXD_input(55);
      DeScrambler_Register(7) <= RXD_input(56);
      DeScrambler_Register(6) <= RXD_input(57);
      DeScrambler_Register(5) <= RXD_input(58);
      DeScrambler_Register(4) <= RXD_input(59);
      DeScrambler_Register(3) <= RXD_input(60);
      DeScrambler_Register(2) <= RXD_input(61);
      DeScrambler_Register(1) <= RXD_input(62);
      DeScrambler_Register(0) <= RXD_input(63);
    end if;
  end process p_descramble;

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

	working_process : process
	begin
	wait until s_axi_aresetn = '1';
 	s_axi_awaddr<="1000";
        s_axi_wdata<=x"00000002";
        s_axi_wstrb<=b"1111";
        sendit<='1';                --start axi write to slave
        wait for 1 ns; 
        sendit<='0'; --clear start send flag
	wait until s_axi_bvalid = '1';
	wait until s_axi_bvalid = '0';  --axi write finished
        s_axi_wstrb<=b"0000";

	wait until resetdone = '1'; 
	wait until block_lock = '1';

	while(true) loop
		s_axi_awaddr<="0100";
	        s_axi_wdata<=x"00000100";
		s_axi_wstrb<=b"1111";
	 	sendit<='1';                --start axi write to slave
		wait for 1 ns; 
		sendit<='0'; --clear start send flag
		wait until s_axi_bvalid = '1';
		wait until s_axi_bvalid = '0';  --axi write finished
	       	s_axi_wstrb<=b"0000";

		s_axi_awaddr<="0100";
		s_axi_wdata<=x"00010010";
		s_axi_wstrb<=b"1111";
	        sendit<='1';                --start axi write to slave
	        wait for 1 ns; 
	        sendit<='0'; --clear start send flag
		wait until s_axi_bvalid = '1';
		wait until s_axi_bvalid = '0';  --axi write finished
	        s_axi_wstrb<=b"0000";  

		s_axi_awaddr<="0100";
	        s_axi_wdata<=x"94000002";
	        s_axi_wstrb<=b"1111";
	        sendit<='1';                --start axi write to slave
	        wait for 1 ns; 
	        sendit<='0'; --clear start send flag
		wait until s_axi_bvalid = '1';
		wait until s_axi_bvalid = '0';  --axi write finished
	        s_axi_wstrb<=b"0000";

		s_axi_awaddr<="0100";
	        s_axi_wdata<=x"88b50001";
        	s_axi_wstrb<=b"1111";
		sendit<='1';                --start axi write to slave
		wait for 1 ns; 
		sendit<='0'; --clear start send flag
		wait until s_axi_bvalid = '1';
		wait until s_axi_bvalid = '0';  --axi write finished
		s_axi_wstrb<=b"0000";
	 
		for i in 0 to 7 loop
			s_axi_awaddr<="0100";
		        s_axi_wdata<=x"ffffff00" or std_logic_vector(to_unsigned(i, 32));
		        s_axi_wstrb<=b"1111";
		        sendit<='1';                --start axi write to slave
		        wait for 1 ns; 
		        sendit<='0'; --clear start send flag
			wait until s_axi_bvalid = '1';
			wait until s_axi_bvalid = '0';  --axi write finished
			s_axi_wstrb<=b"0000";
			s_axi_awaddr<="0100";
			s_axi_wdata<=x"f0000000" or std_logic_vector(to_unsigned(i, 32));
			s_axi_wstrb<=b"1111";
			sendit<='1';                --start axi write to slave
			wait for 1 ns; 
			sendit<='0'; --clear start send flag
			wait until s_axi_bvalid = '1';
			wait until s_axi_bvalid = '0';  --axi write finished
			s_axi_wstrb<=b"0000";
		end loop;

		s_axi_awaddr<="0000";
		s_axi_wdata<=x"00000040";
		s_axi_wstrb<=b"1111";
		sendit<='1';                --start axi write to slave
		wait for 1 ns; 
		sendit<='0'; --clear start send fla
		wait until s_axi_bvalid = '1';
		wait until s_axi_bvalid = '0';  --axi write finished
		s_axi_wstrb<=b"0000";
   
		send_my_packet := 1; 
		wait until interrupt = '1';

		s_axi_araddr<="1100";
		readit<='1';                --start axi read from slave
		wait for 1 ns; 
		readit<='0';                --clear "start read" flag
		wait until s_axi_rready = '1';
		wait until s_axi_rready = '0';    --axi_data should be equal to 64
		packet_cnt := to_integer(unsigned(s_axi_rdata));

		for i in 0 to packet_cnt - 1 loop
			s_axi_araddr<="0000";
			readit<='1'; 
			wait for 1 ns;
			readit<='0';
			wait until s_axi_rready = '1';
			wait until s_axi_rready = '0';    
			bytes_cnt := to_integer(unsigned(s_axi_rdata));

			if (bytes_cnt = 64) then
 				read_cnt := 15;
			elsif (bytes_cnt = 63) then
				read_cnt := 15;
			elsif (bytes_cnt = 65) then
				read_cnt := 17;
			else
				assert false report "bytes_cnt strange value." severity failure;
			end if;   

			s_axi_araddr<="0100";    
			for j in 0 to read_cnt loop
				readit<='1';                --start axi read from slave
				wait for 1 ns; 
				readit<='0';                --clear "start read" flag
				wait until s_axi_rready = '1';    --axi_data should be equal to 00000000...
				wait until s_axi_rready = '0';
			end loop;
		end loop;
	end loop; 
end process;


end xgbe_pcs_pma_tb_arch;
