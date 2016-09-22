library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xgbe_pcs_pma is
	port (
		clk_156_25MHz		: in std_logic;
		rst_clk_156_25MHz 	: in std_logic;
		clk_20MHz		: in std_logic;
		rst_clk_20MHz		: in std_logic;

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
		rxp 			: in std_logic;
		rxn 			: in std_logic;
		txp 			: out std_logic;
		txn 			: out std_logic;
		coreclk_out		: out std_logic;
		core_status		: out std_logic_vector(7 downto 0);
		sim_speedup_control	: in std_logic;
		reset			: in std_logic;
		resetdone		: out std_logic	
	);
end xgbe_pcs_pma;

architecture xgbe_pcs_pma_arch of xgbe_pcs_pma is

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

component xgbe_0 IS
  PORT (
    clk_156_25MHz : IN STD_LOGIC;
    rst_clk_156_25MHz : IN STD_LOGIC;
    clk_20MHz : IN STD_LOGIC;
    rst_clk_20MHz : IN STD_LOGIC;
    interrupt : OUT STD_LOGIC;
    s_axi_aclk : IN STD_LOGIC;
    s_axi_aresetn : IN STD_LOGIC;
    s_axi_awaddr : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi_awvalid : IN STD_LOGIC;
    s_axi_awready : OUT STD_LOGIC;
    s_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_wvalid : IN STD_LOGIC;
    s_axi_wready : OUT STD_LOGIC;
    s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_bvalid : OUT STD_LOGIC;
    s_axi_bready : IN STD_LOGIC;
    s_axi_araddr : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi_arvalid : IN STD_LOGIC;
    s_axi_arready : OUT STD_LOGIC;
    s_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_rvalid : OUT STD_LOGIC;
    s_axi_rready : IN STD_LOGIC;
    xgmii_rxc : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    xgmii_rxd : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    xgmii_txc : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    xgmii_txd : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
  );
END component;


signal xgmii_rxc, xgmii_txc : std_logic_vector(7 downto 0);
signal xgmii_rxd, xgmii_txd : std_logic_vector(63 downto 0);


signal dclk, rxrecclk_out, refclk_p, refclk_n : std_logic := '0';
signal qplloutclk_out, qplloutrefclk_out, qplllock_out : std_logic := '0';
--signal coreclk_out, sim_speedup_control : std_logic := '0';
signal txusrclk_out, txusrclk2_out, areset_datapathclk_out : std_logic := '0';
signal gttxreset_out, gtrxreset_out, txuserrdy_out, reset_counter_done_out : std_logic := '0';
signal signal_detect, tx_fault, tx_disable : std_logic := '0';
--signal reset, resetdone : std_logic := '0';
signal drp_req, drp_gnt, drp_den_o, drp_dwe_o, drp_drdy_i : std_logic := '0';
signal drp_den_i, drp_dwe_i, drp_drdy_o : std_logic := '0';

signal drp_daddr_o, drp_di_o, drp_drpdo_i : std_logic_vector(15 downto 0) := (others => '0');
signal drp_daddr_i, drp_di_i, drp_drpdo_o : std_logic_vector(15 downto 0) := (others => '0');

signal pma_pmd_type : std_logic_vector(2 downto 0);

signal configuration_vector : std_logic_vector(535 downto 0) := (others => '0');
signal status_vector : std_logic_vector(447 downto 0);
--signal core_status : std_logic_vector(7 downto 0);


begin

	dclk <= s_axi_aclk;
	refclk_p <= clk_156_25MHz;
	refclk_n <= not(refclk_p);

	signal_detect <= '1';
	tx_fault <= '0';
	configuration_vector(399 downto 384) <= x"4C4B";
	pma_pmd_type <= "111";

	drp_gnt <= drp_req;
	drp_den_i <= drp_den_o;
	drp_dwe_i <= drp_dwe_o;
	drp_daddr_i <= drp_daddr_o;
	drp_di_i <= drp_di_o;
	drp_drdy_i <= drp_drdy_o;
	drp_drpdo_i <= drp_drpdo_o;

	xgbe_0_0 : xgbe_0
	port map (
		clk_156_25MHz => clk_156_25MHz,
		rst_clk_156_25MHz => rst_clk_156_25MHz,
		clk_20MHz => clk_20MHz,
		rst_clk_20MHz => rst_clk_20MHz,
		interrupt => interrupt,
		s_axi_aclk => s_axi_aclk,
		s_axi_aresetn => s_axi_aresetn,
		s_axi_awaddr => s_axi_awaddr,
		s_axi_awprot => s_axi_awprot,
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
		s_axi_arprot  => s_axi_arprot,
		s_axi_arvalid => s_axi_arvalid,
		s_axi_arready => s_axi_arready,
		s_axi_rdata   => s_axi_rdata,
		s_axi_rresp   => s_axi_rresp,
		s_axi_rvalid  => s_axi_rvalid,
		s_axi_rready  => s_axi_rready,
		xgmii_rxc     => xgmii_rxc,
		xgmii_rxd     => xgmii_rxd,
		xgmii_txc     => xgmii_txc,
		xgmii_txd     => xgmii_txd
	);	
	
	ten_gig_eth_pcs_pma_0_0 : ten_gig_eth_pcs_pma_0
	port map (
		dclk => dclk,
		rxrecclk_out => rxrecclk_out,
		refclk_p => refclk_p,
		refclk_n => refclk_n,
		sim_speedup_control => sim_speedup_control,
		coreclk_out => coreclk_out,
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
		xgmii_txd => xgmii_txd,
		xgmii_txc => xgmii_txc,
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
		
end;
