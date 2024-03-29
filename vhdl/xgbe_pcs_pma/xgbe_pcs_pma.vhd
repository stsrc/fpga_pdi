library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity xgbe_pcs_pma is
	port (
		clk_156_25MHz_p		: in std_logic;
		clk_156_25MHz_n     	: in std_logic;
		rstn_clk_156_25MHz 	: in std_logic;
    
 	    clk_100MHz : in std_logic;
        rstn_clk_100MHz : in std_logic;

		interrupt		: out std_logic;
		s_axi_aclk		: in  std_logic;
		s_axi_aresetn		: in  std_logic;
		s_axi_awaddr		: in  std_logic_vector(4 downto 0);
		s_axi_awprot		: in  std_logic_vector(2 downto 0);
		s_axi_awvalid		: in  std_logic;
		s_axi_awready		: out std_logic;
		s_axi_wdata		: in  std_logic_vector(31 downto 0);
		s_axi_wstrb		: in  std_logic_vector(3 downto 0);
		s_axi_wvalid		: in  std_logic;
		s_axi_wready		: out std_logic;
		s_axi_bresp		: out std_logic_vector(1 downto 0);
		s_axi_bvalid		: out std_logic;
		s_axi_bready		: in  std_logic;
		s_axi_araddr		: in  std_logic_vector(4 downto 0);
		s_axi_arprot		: in  std_logic_vector(2 downto 0);
		s_axi_arvalid		: in  std_logic;
		s_axi_arready		: out std_logic;
		s_axi_rdata		: out std_logic_vector(31 downto 0);
		s_axi_rresp		: out std_logic_vector(1 downto 0);
		s_axi_rvalid		: out std_logic;
		s_axi_rready		: in  std_logic;

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

		awvalid : out std_logic;
		awready	: out std_logic;
		wvalid	: out std_logic;
		wready	: out std_logic;
		wlast	: out std_logic;

		rxp 			: in  std_logic;
		rxn 			: in  std_logic;
		txp 			: out std_logic;
		txn 			: out std_logic;
		
		coreclk_out		: out std_logic;
		core_status		: out std_logic_vector(7 downto 0);
		sim_speedup_control	: in  std_logic;
		resetdone		: out std_logic	
	);
end xgbe_pcs_pma;

architecture xgbe_pcs_pma_arch of xgbe_pcs_pma is

signal awvalid_s, awready_s, wvalid_s, wready_s, wlast_s : std_logic;

component ten_gig_eth_pcs_pma_0 is
	port (
		dclk               : in  std_logic;
		rxrecclk_out       : out std_logic;
		refclk_p           : in  std_logic;
      refclk_n           : in  std_logic;
      sim_speedup_control: in  std_logic := '0';
      coreclk_out    : out std_logic;
      qplloutclk_out     : out std_logic;
      qplloutrefclk_out  : out std_logic;
      qplllock_out       : out std_logic;
      txusrclk_out       : out std_logic;
      txusrclk2_out      : out std_logic;
      areset_datapathclk_out  : out std_logic;
      gttxreset_out      : out std_logic;
      gtrxreset_out      : out std_logic;
      txuserrdy_out      : out std_logic;
      reset_counter_done_out : out std_logic;
      reset              : in  std_logic;
      xgmii_txd        : in  std_logic_vector(63 downto 0);
      xgmii_txc        : in  std_logic_vector(7 downto 0);
      xgmii_rxd        : out std_logic_vector(63 downto 0);
      xgmii_rxc        : out std_logic_vector(7 downto 0);
      txp              : out std_logic;
      txn              : out std_logic;
      rxp              : in  std_logic;
      rxn              : in  std_logic;
      configuration_vector : in  std_logic_vector(535 downto 0);
      status_vector        : out std_logic_vector(447 downto 0);
      core_status      : out std_logic_vector(7 downto 0);
      resetdone_out    : out std_logic;
      signal_detect    : in  std_logic;
      tx_fault         : in  std_logic;
      drp_req          : out std_logic;
      drp_gnt          : in  std_logic;
      drp_den_o        : out std_logic;
      drp_dwe_o        : out std_logic;
      drp_daddr_o      : out std_logic_vector(15 downto 0);
      drp_di_o         : out std_logic_vector(15 downto 0);
      drp_drdy_i       : in  std_logic;
      drp_drpdo_i      : in  std_logic_vector(15 downto 0);
      drp_den_i        : in  std_logic;
      drp_dwe_i        : in  std_logic;
      drp_daddr_i      : in  std_logic_vector(15 downto 0);
      drp_di_i         : in  std_logic_vector(15 downto 0);
      drp_drdy_o       : out std_logic;
      drp_drpdo_o      : out std_logic_vector(15 downto 0);
      pma_pmd_type     : in std_logic_vector(2 downto 0);
      tx_disable       : out std_logic);
end component;

component xgbe_0 is 
	port (
		clk_156_25MHz		: in std_logic;
		rst_clk_156_25MHz 	: in std_logic;
		clk_20MHz		: in std_logic;
		rst_clk_20MHz		: in std_logic;
		interrupt		: out std_logic;
		s_axi_aclk		: in std_logic;
		s_axi_aresetn		: in std_logic;
		s_axi_awaddr		: in std_logic_vector(4 downto 0);
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
		s_axi_araddr		: in std_logic_vector(4 downto 0);
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

		xgmii_rxc 		: in std_logic_vector(7 downto 0);
		xgmii_rxd 		: in std_logic_vector(63 downto 0);
		xgmii_txc 		: out std_logic_vector(7 downto 0);
		xgmii_txd 		: out std_logic_vector(63 downto 0);
		xgmii_tx_clk 		: in std_logic;
		xgmii_rx_clk 		: in std_logic
	);
end component;

component reset_gen_0 IS
  PORT (
    clk : IN STD_LOGIC;
    asynchr_rst : IN STD_LOGIC;
    locked : IN STD_LOGIC;
    rst_out_n : OUT STD_LOGIC;
    rst_out_p : OUT STD_LOGIC
  );
END component;

signal xgmii_rxc, xgmii_rxc_reg, xgmii_txc, xgmii_txc_reg : std_logic_vector(7 downto 0);
signal xgmii_rxd, xgmii_rxd_reg, xgmii_txd, xgmii_txd_reg : std_logic_vector(63 downto 0);
signal xgmii_rx_clk, xgmii_tx_clk : std_logic := '0';

signal dclk, dclk_buf, rxrecclk_out, refclk_p, refclk_n : std_logic := '0';
signal qplloutclk_out, qplloutrefclk_out, qplllock_out : std_logic := '0';
--signal coreclk_out, sim_speedup_control : std_logic := '0';
signal coreclk_out_s: std_logic := '0';
signal txusrclk_out, txusrclk2_out, areset_datapathclk_out : std_logic := '0';
signal gttxreset_out, gtrxreset_out, txuserrdy_out, reset_counter_done_out : std_logic := '0';
signal signal_detect, tx_fault, tx_disable : std_logic := '0';
signal reset : std_logic := '0';

signal rstn_coreclk, rstp_coreclk : std_logic := '0';

signal drp_req, drp_gnt, drp_den_o, drp_dwe_o, drp_drdy_i : std_logic := '0';
signal drp_den_i, drp_dwe_i, drp_drdy_o : std_logic := '0';

signal drp_daddr_o, drp_di_o, drp_drpdo_i : std_logic_vector(15 downto 0) := (others => '0');
signal drp_daddr_i, drp_di_i, drp_drpdo_o : std_logic_vector(15 downto 0) := (others => '0');

signal pma_pmd_type : std_logic_vector(2 downto 0);

signal configuration_vector : std_logic_vector(535 downto 0) := (others => '0');
signal status_vector : std_logic_vector(447 downto 0);
--signal core_status : std_logic_vector(7 downto 0);


begin
	xgmii_tx_clk 	<= coreclk_out_s;
	xgmii_rx_clk 	<= coreclk_out_s;
	coreclk_out 	<= coreclk_out_s;
	dclk 		<= clk_100MHz;
	refclk_p 	<= clk_156_25MHz_p;
	refclk_n 	<= clk_156_25MHz_n;
	signal_detect 	<= '1';
	tx_fault 	<= '0';
	configuration_vector(399 downto 384) <= x"4C4B";
	pma_pmd_type 	<= "111";
	drp_gnt 	<= drp_req;
	drp_den_i 	<= drp_den_o;
	drp_dwe_i 	<= drp_dwe_o;
	drp_daddr_i 	<= drp_daddr_o;
	drp_di_i 	<= drp_di_o;
	drp_drdy_i 	<= drp_drdy_o;
	drp_drpdo_i 	<= drp_drpdo_o;
	reset 		<= not(rstn_clk_156_25MHz);

	wlast 		<= wlast_s;
	M_AXI_WLAST	<= wlast_s;
	awvalid		<= awvalid_s;
	M_AXI_AWVALID	<= awvalid_s;
	wvalid		<= wvalid_s;
	M_AXI_WVALID	<= wvalid_s;


	wready		<= wready_s;
	wready_s	<= M_AXI_WREADY;

	awready		<= awready_s;
	awready_s	<= M_AXI_AWREADY;

	xgbe_0_0 : xgbe_0
	port map (
		clk_156_25MHz 		=> coreclk_out_s,
		rst_clk_156_25MHz 	=> rstn_coreclk,
		clk_20MHz 	=> clk_100MHz,
		rst_clk_20MHz 	=> rstn_clk_100MHz,
		interrupt 	=> interrupt,
		s_axi_aclk 	=> s_axi_aclk,
		s_axi_aresetn 	=> s_axi_aresetn,
		s_axi_awaddr 	=> s_axi_awaddr,
		s_axi_awprot 	=> s_axi_awprot,
		s_axi_awvalid => s_axi_awvalid,
		s_axi_awready => s_axi_awready,
		s_axi_wdata   => s_axi_wdata,
		s_axi_wstrb   => s_axi_wstrb,
		s_axi_wvalid  => s_axi_wvalid,
		s_axi_wready  => s_axi_wready,
		s_axi_bresp   => s_axi_bresp,
		s_axi_bvalid  => s_axi_bvalid,
		s_axi_bready  => s_axi_bready,
		s_axi_araddr  => s_axi_araddr,
		s_axi_arprot  	=> s_axi_arprot,
		s_axi_arvalid 	=> s_axi_arvalid,
		s_axi_arready 	=> s_axi_arready,
		s_axi_rdata   	=> s_axi_rdata,
		s_axi_rresp   	=> s_axi_rresp,
		s_axi_rvalid  	=> s_axi_rvalid,
		s_axi_rready  	=> s_axi_rready,

		M_AXI_ACLK => M_AXI_ACLK,
		M_AXI_ARESETN => M_AXI_ARESETN,
		M_AXI_AWADDR => M_AXI_AWADDR,
		M_AXI_AWPROT => M_AXI_AWPROT,
		M_AXI_AWVALID => awvalid_s,
		M_AXI_AWREADY => awready_s,
		M_AXI_WDATA => M_AXI_WDATA,
		M_AXI_WSTRB => M_AXI_WSTRB,
		M_AXI_WVALID => wvalid_s,
		M_AXI_WREADY => wready_s,
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
		M_AXI_WLAST => wlast_s,
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

		xgmii_rxc     => xgmii_rxc_reg,
		xgmii_rxd     => xgmii_rxd_reg,
		xgmii_txc     => xgmii_txc,
		xgmii_txd     => xgmii_txd,
		xgmii_tx_clk  => xgmii_tx_clk,
		xgmii_rx_clk  => xgmii_rx_clk
	);	
	
	ten_gig_eth_pcs_pma_0_0 : ten_gig_eth_pcs_pma_0
	port map (
		dclk => dclk_buf,
		rxrecclk_out => rxrecclk_out,
		refclk_p => refclk_p,
		refclk_n => refclk_n,
		sim_speedup_control => sim_speedup_control,
		coreclk_out => coreclk_out_s,
		qplloutclk_out => qplloutclk_out,
		qplloutrefclk_out => qplloutrefclk_out,
		qplllock_out => qplllock_out,
		txusrclk_out => txusrclk_out,
		txusrclk2_out => txusrclk2_out,
		areset_datapathclk_out => areset_datapathclk_out,
		gttxreset_out => gttxreset_out,
		gtrxreset_out => gtrxreset_out,
		txuserrdy_out => txuserrdy_out,
		reset_counter_done_out => reset_counter_done_out,
		reset => reset,
		xgmii_txd => xgmii_txd_reg,
		xgmii_txc => xgmii_txc_reg,
		xgmii_rxd => xgmii_rxd,
		xgmii_rxc => xgmii_rxc,
		txp => txp,
		txn => txn,
		rxp => rxp,
		rxn => rxn,
		configuration_vector => configuration_vector,
		status_vector => status_vector,
		core_status => core_status,
		resetdone_out => resetdone,
		signal_detect => signal_detect,
		tx_fault => tx_fault,
		drp_req => drp_req,
		drp_gnt => drp_gnt,
		drp_den_o => drp_den_o,
		drp_dwe_o => drp_dwe_o,
		drp_daddr_o => drp_daddr_o,
		drp_di_o => drp_di_o,
		drp_drdy_i => drp_drdy_i,
		drp_drpdo_i => drp_drpdo_i,
		drp_den_i => drp_den_i,
		drp_dwe_i => drp_dwe_i,
		drp_daddr_i => drp_daddr_i,
		drp_di_i => drp_di_i,
		drp_drdy_o => drp_drdy_o,
		drp_drpdo_o => drp_drpdo_o,
		pma_pmd_type => pma_pmd_type,
		tx_disable => tx_disable
	);

	reset_gen_0_0 : reset_gen_0
	port map (
		clk => coreclk_out_s,
		asynchr_rst => rstn_clk_156_25MHz,
		locked => '1',
		rst_out_n => rstn_coreclk,
		rst_out_p => rstp_coreclk
	);
	--xgmii is registered, because ten gig eth pcs pma documentation states, that it improves placing.
	process (coreclk_out_s) begin
		if (rising_edge(coreclk_out_s)) then
		       xgmii_txc_reg <= xgmii_txc;
		       xgmii_rxc_reg <= xgmii_rxc;
		       xgmii_txd_reg <= xgmii_txd;
		       xgmii_rxd_reg <= xgmii_rxd;
		end if;
	end process;
   	
	dclk_bufg_i : BUFG
	port map (
		I => dclk,
		O => dclk_buf
	);
end;
