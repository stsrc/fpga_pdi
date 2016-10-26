library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture tb_arch of tb is

component AXI_Master is
	generic (
		C_M_AXI_ADDR_WIDTH	: integer	:= 32;
		C_M_AXI_DATA_WIDTH	: integer	:= 32
	);
	port (

		M_DATA_IN			: in std_logic_vector(C_M_AXI_DATA_WIDTH - 1 downto 0);
		M_DATA_OUT			: out std_logic_vector(C_M_AXI_DATA_WIDTH - 1 downto 0);
		M_TARGET_SLAVE_BASE_ADDR 	: in std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0);

		INIT_AXI_TXN	: in std_logic;
		AXI_TXN_DONE	: out std_logic;
		INIT_AXI_RXN	: in std_logic;
		AXI_RXN_DONE	: out std_logic;

		ERROR	: out std_logic;

		M_AXI_ACLK	: in std_logic;
		M_AXI_ARESETN	: in std_logic;
		M_AXI_AWADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		M_AXI_AWPROT	: out std_logic_vector(2 downto 0);
		M_AXI_AWVALID	: out std_logic;
		M_AXI_AWREADY	: in std_logic;
		M_AXI_WDATA	: out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		M_AXI_WSTRB	: out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
		M_AXI_WVALID	: out std_logic;
		M_AXI_WREADY	: in std_logic;
		M_AXI_BRESP	: in std_logic_vector(1 downto 0);
		M_AXI_BVALID	: in std_logic;
		M_AXI_BREADY	: out std_logic;
		M_AXI_ARADDR	: out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
		M_AXI_ARPROT	: out std_logic_vector(2 downto 0);
		M_AXI_ARVALID	: out std_logic;
		M_AXI_ARREADY	: in std_logic;
		M_AXI_RDATA	: in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		M_AXI_RRESP	: in std_logic_vector(1 downto 0);
		M_AXI_RVALID	: in std_logic;
		M_AXI_RREADY	: out std_logic
	);
end component;

component AXI_to_regs is
	generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 5
	);
	port (
		interrupt : out std_logic;
		interrupt_in    : in std_logic;       

		slv_reg0_rd	: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg0_wr	: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg1_rd	: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg1_wr	: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg2_rd	: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg2_wr    : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg3_rd	: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg3_wr    : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
        
		slv_reg0_rd_strb   : out std_logic;
		slv_reg1_rd_strb  : out std_logic;
		slv_reg2_rd_strb   : out std_logic;
		slv_reg3_rd_strb   : out std_logic;
		slv_reg0_wr_strb   : out std_logic;
		slv_reg1_wr_strb   : out std_logic;
		slv_reg2_wr_strb   : out std_logic;
		slv_reg3_wr_strb   : out std_logic;

		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
	);
end component;
	signal aclk, aresetn, awvalid, awready, wvalid, wready, bvalid, bready 	: std_logic := '0';
	signal arvalid, arready, rvalid, rready				: std_logic := '0';
	signal awprot, arprot		: std_logic_vector(2 downto 0) := (others => '0');
	signal bresp, rresp		: std_logic_vector(1 downto 0) := (others => '0');
	signal wdata, rdata		: std_logic_vector(31 downto 0) := (others => '0');
	signal wstrb			: std_logic_vector(3 downto 0) := (others => '0');
	signal s_awaddr, s_araddr	: std_logic_vector(4 downto 0) := (others => '0');
	signal m_awaddr, m_araddr	: std_logic_vector(31 downto 0) := (others => '0');
	signal slv_reg0_rd, slv_reg1_rd, slv_reg2_rd, slv_reg3_rd : std_logic_vector(31 downto 0) := (others => '0');
	signal slv_reg0_wr, slv_reg1_wr, slv_reg2_wr, slv_reg3_wr : std_logic_vector(31 downto 0) := (others => '0');
	signal slv_reg0_rd_strb, slv_reg1_rd_strb, slv_reg2_rd_strb, slv_reg3_rd_strb : std_logic := '0';
	signal slv_reg0_wr_strb, slv_reg1_wr_strb, slv_reg2_wr_strb, slv_reg3_wr_strb : std_logic := '0';

	signal interrupt, interrupt_in	: std_logic := '0';	

	signal m_data_in, m_data_out 	: std_logic_vector(31 downto 0) := (others => '0');
	signal m_target_addr : std_logic_vector(31 downto 0) := (others => '0');
	signal axi_init_txn, axi_done_txn, axi_init_rxn, axi_done_rxn, axi_error : std_logic := '0';
begin
	
	AXI_to_regs_0 : AXI_to_regs 
		generic map (
			C_S_AXI_DATA_WIDTH => 32,
			C_S_AXI_ADDR_WIDTH => 5
		)
		port map (
			interrupt => interrupt,
			interrupt_in => interrupt_in,
			slv_reg0_rd => slv_reg0_rd,
			slv_reg0_wr => slv_reg0_wr,
			slv_reg1_rd => slv_reg1_rd,
			slv_reg1_wr => slv_reg1_wr,
			slv_reg2_rd => slv_reg2_rd,
			slv_reg2_wr => slv_reg2_wr,
			slv_reg3_rd => slv_reg3_rd,
			slv_reg3_wr => slv_reg3_wr,
			slv_reg0_rd_strb => slv_reg0_rd_strb,
			slv_reg1_rd_strb => slv_reg1_rd_strb,
			slv_reg2_rd_strb => slv_reg2_rd_strb,
			slv_reg3_rd_strb => slv_reg3_rd_strb,
			slv_reg0_wr_strb => slv_reg0_wr_strb,
			slv_reg1_wr_strb => slv_reg1_wr_strb,
			slv_reg2_wr_strb => slv_reg2_wr_strb,
			slv_reg3_wr_strb => slv_reg3_wr_strb,
			S_AXI_ACLK => aclk,
			S_AXI_ARESETN => aresetn,
			S_AXI_AWADDR => s_awaddr,
			S_AXI_AWPROT => awprot,
			S_AXI_AWVALID => awvalid,
			S_AXI_AWREADY => awready,
			S_AXI_WDATA => wdata,
			S_AXI_WSTRB => wstrb,
			S_AXI_WVALID => wvalid,
			S_AXI_WREADY => wready,
			S_AXI_BRESP => bresp,
			S_AXI_BVALID => bvalid,
			S_AXI_BREADY => bready,
			S_AXI_ARADDR => s_araddr,
			S_AXI_ARPROT => arprot,
			S_AXI_ARVALID => arvalid,
			S_AXI_ARREADY => arready,
			S_AXI_RDATA => rdata,
			S_AXI_RRESP => rresp,
			S_AXI_RVALID => rvalid,
			S_AXI_RREADY => rready
		);

	AXI_Master_0 : AXI_Master
		port map (
			M_DATA_IN => m_data_in,
			M_DATA_OUT => m_data_out,
			M_TARGET_SLAVE_BASE_ADDR => m_target_addr,
			INIT_AXI_TXN => axi_init_txn,
			AXI_TXN_DONE => axi_done_txn,
			INIT_AXI_RXN => axi_init_rxn,
			AXI_RXN_DONE => axi_done_rxn,
			ERROR => axi_error,

			M_AXI_ACLK => aclk,
			M_AXI_ARESETN => aresetn,
			M_AXI_AWADDR => m_awaddr,
			M_AXI_AWPROT => awprot,
			M_AXI_AWVALID => awvalid,
			M_AXI_AWREADY => awready,
			M_AXI_WDATA => wdata,
			M_AXI_WSTRB => wstrb,
			M_AXI_WVALID => wvalid,
			M_AXI_WREADY => wready,
			M_AXI_BRESP => bresp,
			M_AXI_BVALID => bvalid,
			M_AXI_BREADY => bready,
			M_AXI_ARADDR => m_araddr,
			M_AXI_ARPROT => arprot,
			M_AXI_ARVALID => arvalid,
			M_AXI_ARREADY => arready,
			M_AXI_RDATA => rdata,
			M_AXI_RRESP => rresp,
			M_AXI_RVALID => rvalid,
			M_AXI_RREADY => rready		
		);

	s_araddr <= m_araddr(4 downto 0);
	s_awaddr <= m_awaddr(4 downto 0);
process
begin
	aclk <= '1';
	wait for 5 ns;
	aclk <= '0';
	wait for 5 ns;
end process;

process
begin
	aresetn <= '0';
	wait for 10 ns;
	aresetn <= '1';
	wait;
end process;

process
begin
	wait until aresetn = '1';
	wait for 10 ns;
	m_data_in <= std_logic_vector(to_unsigned(1212, 32));
	m_target_addr <= std_logic_vector(to_unsigned(0, 32));
	axi_init_txn <= '1';
	wait for 10 ns;
	axi_init_txn <= '0';
	wait until axi_done_txn = '1';
	wait until slv_reg0_wr_strb = '1';
	assert unsigned(slv_reg0_wr) = 1212 report "Wrong first test." severity failure;		
	wait;
end process;
end tb_arch;
