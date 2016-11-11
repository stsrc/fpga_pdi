library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture tb_arch of tb is

component AXI_Master is
	generic (
		C_M_AXI_ADDR_WIDTH	: integer	:= 32;
		C_M_AXI_DATA_WIDTH	: integer	:= 32;
		C_M_AXI_ID_WIDTH	: integer	:= 1;
		C_M_AXI_AWUSER_WIDTH	: integer	:= 0;
		C_M_AXI_WUSER_WIDTH	: integer	:= 0;
		C_M_AXI_BUSER_WIDTH	: integer	:= 0;
		C_M_AXI_ARUSER_WIDTH	: integer	:= 0;
		C_M_AXI_RUSER_WIDTH	: integer	:= 0;
		C_M_AXI_BURST_LEN	: integer	:= 8
	);
	port (

		M_DATA_IN			: in std_logic_vector(C_M_AXI_DATA_WIDTH - 1 downto 0);
		M_DATA_OUT			: out std_logic_vector(C_M_AXI_DATA_WIDTH - 1 downto 0);
		M_TARGET_BASE_ADDR	 	: in std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0);

		INIT_AXI_TXN	: in  std_logic;
		AXI_TXN_DONE	: out std_logic;
		AXI_TXN_STRB	: out std_logic;
		AXI_TXN_IN_STRB : in  std_logic;
		INIT_AXI_RXN	: in  std_logic;
		AXI_RXN_DONE	: out std_logic;
		AXI_RXN_STRB	: out std_logic;
		BURST		: in  std_logic_vector(7 downto 0);

		M_AXI_ACLK	: in  std_logic;
		M_AXI_ARESETN	: in  std_logic;
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
		M_AXI_AWREADY	: in  std_logic;
		M_AXI_WDATA	: out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		M_AXI_WSTRB	: out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
		M_AXI_WLAST	: out std_logic;
		M_AXI_WUSER	: out std_logic_vector(C_M_AXI_WUSER_WIDTH-1 downto 0);
		M_AXI_WVALID	: out std_logic;
		M_AXI_WREADY	: in  std_logic;
		M_AXI_BID	: in  std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		M_AXI_BRESP	: in  std_logic_vector(1 downto 0);
		M_AXI_BUSER	: in  std_logic_vector(C_M_AXI_BUSER_WIDTH-1 downto 0);
		M_AXI_BVALID	: in  std_logic;
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
		M_AXI_RREADY	: out std_logic

	);
end component;

component AXI_Slave is
	generic (
		C_S_AXI_ID_WIDTH	: integer	:= 1;
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 6;
		C_S_AXI_AWUSER_WIDTH	: integer	:= 0;
		C_S_AXI_ARUSER_WIDTH	: integer	:= 0;
		C_S_AXI_WUSER_WIDTH	: integer	:= 0;
		C_S_AXI_RUSER_WIDTH	: integer	:= 0;
		C_S_AXI_BUSER_WIDTH	: integer	:= 0
	);
	port (
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


	signal aclk, aresetn, awvalid, awready 	: std_logic := '0';
	signal arvalid, arready, rvalid, rready	: std_logic := '0';
	signal wvalid, wready, bvalid, bready	: std_logic := '0';

	signal awid 	: std_logic_vector(0 downto 0) 	:= (others => '0');
	signal awlen 	: std_logic_vector(7 downto 0) 	:= (others => '0');
	signal awsize 	: std_logic_vector(2 downto 0) 	:= (others => '0');
	signal awburst 	: std_logic_vector(1 downto 0) 	:= (others => '0');
	signal awlock 	: std_logic := '0';
	signal awcache 	: std_logic_vector(3 downto 0) 	:= (others => '0');
	signal awqos 	: std_logic_vector(3 downto 0) 	:= (others => '0');
	signal awuser 	: std_logic_vector(-1 downto 0) := (others => '0');
	signal wlast 	: std_logic := '0';
	signal wuser	: std_logic_vector(-1 downto 0) := (others => '0');
	signal bid 	: std_logic_vector(0 downto 0) 	:= (others => '0'); 
	signal buser 	: std_logic_vector(-1 downto 0) := (others => '0');
	signal arid 	: std_logic_vector(0 downto 0) := (others => '0');
	signal arlen 	: std_logic_vector(7 downto 0) 	:= (others => '0');
	signal arsize 	: std_logic_vector(2 downto 0) 	:= (others => '0');
	signal arburst 	: std_logic_vector(1 downto 0) 	:= (others => '0');
	signal arlock 	: std_logic := '0';
	signal arcache 	: std_logic_vector(3 downto 0) 	:= (others => '0');
	signal arqos 	: std_logic_vector(3 downto 0) 	:= (others => '0');
	signal aruser 	: std_logic_vector(-1 downto 0) := (others => '0');
	signal rid 	: std_logic_vector(0 downto 0) 	:= (others => '0');
	signal rlast 	: std_logic := '0';
	signal ruser 	: std_logic_vector(-1 downto 0) := (others => '0');
	
	signal axi_txn_in_strb	: std_logic := '0';
	 
	signal awprot, arprot		: std_logic_vector(2 downto 0) := (others => '0');
	signal bresp, rresp		: std_logic_vector(1 downto 0) := (others => '0');
	signal wdata, rdata		: std_logic_vector(31 downto 0) := (others => '0');
	signal wstrb			: std_logic_vector(3 downto 0) := (others => '0');
	signal awaddr, araddr	: std_logic_vector(31 downto 0) := (others => '0');

	signal m_data_in, m_data_out 	: std_logic_vector(31 downto 0) := (others => '0');
	signal m_target_addr : std_logic_vector(31 downto 0) := (others => '0');

	signal axi_init_txn, axi_done_txn, axi_init_rxn, axi_done_rxn : std_logic := '0';
	signal axi_rxn_strb, axi_txn_strb : std_logic := '0';
	signal burst	: std_logic_vector(7 downto 0) := (others => '0');
begin
	

	AXI_Master_0 : AXI_Master
		port map (
			M_DATA_IN => m_data_in,
			M_DATA_OUT => m_data_out,
			M_TARGET_BASE_ADDR => m_target_addr,
			INIT_AXI_TXN => axi_init_txn,
			AXI_TXN_DONE => axi_done_txn,
			INIT_AXI_RXN => axi_init_rxn,
			AXI_RXN_DONE => axi_done_rxn,
			AXI_TXN_STRB => axi_txn_strb,
			AXI_TXN_IN_STRB => axi_txn_in_strb,
			AXI_RXN_STRB => axi_rxn_strb,
			BURST	=> burst,
			M_AXI_ACLK => aclk,
			M_AXI_ARESETN => aresetn,
			M_AXI_AWADDR => awaddr,
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
			M_AXI_ARADDR => araddr,
			M_AXI_ARPROT => arprot,
			M_AXI_ARVALID => arvalid,
			M_AXI_ARREADY => arready,
			M_AXI_RDATA => rdata,
			M_AXI_RRESP => rresp,
			M_AXI_RVALID => rvalid,
			M_AXI_RREADY => rready,
			M_AXI_AWID => awid,
			M_AXI_AWLEN => awlen,
			M_AXI_AWSIZE => awsize,
			M_AXI_AWBURST => awburst,
			M_AXI_AWLOCK => awlock,
			M_AXI_AWCACHE => awcache,
			M_AXI_AWQOS => awqos,
			M_AXI_AWUSER => awuser,
			M_AXI_WLAST => wlast,
			M_AXI_WUSER => wuser,
			M_AXI_BID => bid,
			M_AXI_BUSER => buser,
			M_AXI_ARID => arid,
			M_AXI_ARLEN => arlen,
			M_AXI_ARSIZE => arsize,
			M_AXI_ARBURST => arburst,
			M_AXI_ARLOCK => arlock,
			M_AXI_ARCACHE => arcache,
			M_AXI_ARQOS => arqos,
			M_AXI_ARUSER => aruser,
			M_AXI_RID => rid,
			M_AXI_RLAST => rlast,
			M_AXI_RUSER => ruser
		);

AXI_Slave_0 : AXI_Slave
	port map (
		S_AXI_ACLK	=> aclk,
		S_AXI_ARESETN	=> aresetn,
		S_AXI_AWID	=> awid,
		S_AXI_AWADDR	=> awaddr(5 downto 0),
		S_AXI_AWLEN	=> awlen,
		S_AXI_AWSIZE	=> awsize,
		S_AXI_AWBURST	=> awburst,
		S_AXI_AWLOCK	=> awlock,
		S_AXI_AWCACHE	=> awcache,
		S_AXI_AWPROT	=> awprot,
		S_AXI_AWQOS	=> awqos,
		S_AXI_AWREGION	=> (others => '0'),
		S_AXI_AWUSER	=> awuser,
		S_AXI_AWVALID	=> awvalid,
		S_AXI_AWREADY	=> awready,
		S_AXI_WDATA	=> wdata,
		S_AXI_WSTRB	=> wstrb,
		S_AXI_WLAST	=> wlast,
		S_AXI_WUSER	=> wuser,
		S_AXI_WVALID	=> wvalid,
		S_AXI_WREADY	=> wready,
		S_AXI_BID	=> bid,
		S_AXI_BRESP	=> bresp,
		S_AXI_BUSER	=> buser,
		S_AXI_BVALID	=> bvalid,
		S_AXI_BREADY	=> bready,
		S_AXI_ARID	=> arid,
		S_AXI_ARADDR	=> araddr(5 downto 0),
		S_AXI_ARLEN	=> arlen,
		S_AXI_ARSIZE	=> arsize,
		S_AXI_ARBURST	=> arburst,
		S_AXI_ARLOCK	=> arlock,
		S_AXI_ARCACHE	=> arcache,
		S_AXI_ARPROT	=> arprot,
		S_AXI_ARQOS	=> arqos,
		S_AXI_ARREGION	=> (others => '0'),
		S_AXI_ARUSER	=> aruser,
		S_AXI_ARVALID	=> arvalid,
		S_AXI_ARREADY	=> arready,
		S_AXI_RID	=> rid,
		S_AXI_RDATA	=> rdata,
		S_AXI_RRESP	=> rresp,
		S_AXI_RLAST	=> rlast,
		S_AXI_RUSER	=> ruser,
		S_AXI_RVALID	=> rvalid,
		S_AXI_RREADY	=> rready
	);


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
	wait for 20 ns;

	for i in 0 to 7 loop
		m_target_addr <= std_logic_vector(to_unsigned(64 * i, 32));
		m_data_in <= std_logic_vector(to_unsigned(64, 32));
		burst <= std_logic_vector(to_unsigned(i, 8));
		axi_init_txn <= '1';
		wait for 10 ns;
		axi_init_txn <= '0';

		while (axi_done_txn /= '1') loop
			wait for 10 ns;
			axi_txn_in_strb <= '0';
			if (axi_txn_strb = '1') then
				m_data_in <= std_logic_vector(unsigned(m_data_in) + 1);
				axi_txn_in_strb <= '1';
			end if;
		end loop;
		axi_txn_in_strb <= '0';
	end loop;


	wait for 10 ns;

	for i in 0 to 7 loop
		m_target_addr <= std_logic_vector(to_unsigned(64 * i, 32));
		burst <=  std_logic_vector(to_unsigned(i, 8));
		axi_init_rxn <= '1';
		wait for 11 ns;
		burst <= (others => '0');
		axi_init_rxn <= '0';	
		while (axi_done_rxn /= '1') loop
			wait until axi_rxn_strb = '1';
			wait until axi_rxn_strb = '0';
		end loop;

	end loop;

end process;
end tb_arch;
