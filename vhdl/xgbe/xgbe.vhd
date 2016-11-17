library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xgbe is 
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
		clk_156_25MHz		: in std_logic;
		rst_clk_156_25MHz 	: in std_logic;
		clk_20MHz	: in std_logic;
		rst_clk_20MHz		: in std_logic;

		interrupt		: out std_logic;

		s_axi_aclk		: in std_logic;
		s_axi_aresetn		: in std_logic;
		s_axi_awaddr		: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_awprot		: in std_logic_vector(2 downto 0);
		s_axi_awvalid		: in std_logic;
		s_axi_awready		: out std_logic;
		s_axi_wdata		: in std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
		s_axi_wstrb		: in std_logic_vector((C_AXI_DATA_WIDTH/8)-1 downto 0);
		s_axi_wvalid		: in std_logic;
		s_axi_wready		: out std_logic;
		s_axi_bresp		: out std_logic_vector(1 downto 0);
		s_axi_bvalid		: out std_logic;
		s_axi_bready		: in std_logic;
		s_axi_araddr		: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_arprot		: in std_logic_vector(2 downto 0);
		s_axi_arvalid		: in std_logic;
		s_axi_arready		: out std_logic;
		s_axi_rdata		: out std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
		s_axi_rresp		: out std_logic_vector(1 downto 0);
		s_axi_rvalid		: out std_logic;
		s_axi_rready		: in std_logic;

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


		xgmii_rxc 		: in std_logic_vector(7 downto 0);
		xgmii_rxd 		: in std_logic_vector(63 downto 0);
		xgmii_txc 		: out std_logic_vector(7 downto 0);
		xgmii_txd 		: out std_logic_vector(63 downto 0);
		xgmii_tx_clk 		: in std_logic;
		xgmii_rx_clk 		: in std_logic
	);
end xgbe;

architecture xgbe_arch of xgbe is 

component MUX is
	generic (
		DATA_WIDTH : integer := 32
	);
	port (
		DIN_0 	: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		DIN_1	: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		DOUT	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
		ADDR	: in std_logic
	);
end component;

component interrupt_controller is
	port (
	int_0 : in std_logic;
	int_1 : in std_logic;
	int_out : out std_logic
);
end component;

component xge_mac is
	port (
		clk_156m25 	: in std_logic;
		clk_xgmii_rx 	: in std_logic;
		clk_xgmii_tx 	: in std_logic;
		pkt_rx_avail 	: out std_logic;
		pkt_rx_data 	: out std_logic_vector ( 63 downto 0 );
		pkt_rx_eop 	: out std_logic;
		pkt_rx_err 	: out std_logic;
		pkt_rx_mod 	: out std_logic_vector ( 2 downto 0 );
		pkt_rx_ren 	: in std_logic;
		pkt_rx_sop 	: out std_logic;
		pkt_rx_val 	: out std_logic;
		pkt_tx_data 	: in std_logic_vector ( 63 downto 0 );
		pkt_tx_eop 	: in std_logic;
		pkt_tx_full 	: out std_logic;
		pkt_tx_mod 	: in std_logic_vector ( 2 downto 0 );
		pkt_tx_sop 	: in std_logic;
		pkt_tx_val 	: in std_logic;
		reset_156m25_n 	: in std_logic;
		reset_xgmii_rx_n : in std_logic;
		reset_xgmii_tx_n : in std_logic;
		wb_ack_o 	: out std_logic;
		wb_adr_i 	: in std_logic_vector ( 7 downto 0 );
		wb_clk_i 	: in std_logic;
		wb_cyc_i 	: in std_logic;
		wb_dat_i 	: in std_logic_vector ( 31 downto 0 );
		wb_dat_o 	: out std_logic_vector ( 31 downto 0 );
		wb_int_o 	: out std_logic;
		wb_rst_i 	: in std_logic;
		wb_stb_i 	: in std_logic;
		wb_we_i 	: in std_logic;
		xgmii_rxc 	: in std_logic_vector ( 7 downto 0 );
		xgmii_rxd 	: in std_logic_vector ( 63 downto 0 );
		xgmii_txc 	: out std_logic_vector ( 7 downto 0 );
		xgmii_txd 	: out std_logic_vector ( 63 downto 0 )
	);
end component xge_mac;

component counter is
	generic (
		REG_WIDTH : integer := 32;
		INT_GEN_DELAY : integer := 100
	);
	port (
		clk		: in std_logic;
		resetn		: in std_logic;
		incr   		: in std_logic;
		get_val		: in std_logic;
		int_en		: in std_logic;
		cnt_out		: out std_logic_vector(REG_WIDTH - 1 downto 0);
		interrupt   : out std_logic
	);
end component counter;

component bit_over_clocks is
	port (
		clk_in 		: in std_logic;
		clk_in_resetn 	: in std_logic;
		clk_out 	: in std_logic;
		clk_out_resetn 	: in std_logic;
		bit_in 		: in std_logic;
		bit_out 	: out std_logic
	);
end component bit_over_clocks;

component flag_over_clocks is
	port (
		clk_in 		: in std_logic;
		clk_in_resetn 	: in std_logic;
		clk_out 	: in std_logic;
		clk_out_resetn 	: in std_logic;
		flag_in 	: in std_logic;
		flag_out 	: out std_logic
	);
end component flag_over_clocks;

component flagn_over_clocks is
	port (
		clk_in 		: in std_logic;
		clk_in_resetn 	: in std_logic;
		clk_out 	: in std_logic;
		clk_out_resetn 	: in std_logic;
		flagn_in 	: in std_logic;
		flagn_out 	: out std_logic
	);
end component flagn_over_clocks;

component fifo is
	generic (
		DATA_WIDTH : integer := 64;
		DATA_HEIGHT : integer := 10
	);
	port (
		clk_in		: in  std_logic;
		clk_in_resetn   : in  std_logic;
		clk_out		: in  std_logic;
		clk_out_resetn  : in  std_logic;	
		data_in		: in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		data_out	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
		strb_in		: in  std_logic;
		strb_out	: in  std_logic;
		drop_in		: in  std_logic;
		is_full_clk_in	: out std_logic
	);
end component fifo;

component control_register is
	generic (
		DATA_WIDTH : integer := 32
	);

	port (
		clk 		: in std_logic;
		clk_resetn 	: in std_logic;
		reg_input 	: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		reg_strb 	: in std_logic;
		rcv_en		: out std_logic;
		int_en		: out std_logic;
		dma_en		: out std_logic;
		resetp      	: out std_logic
	);
end component control_register;

component AXI_to_regs is
	generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 5
	);
	port (
		interrupt 		: out std_logic;
		interrupt_in    	: in  std_logic;       

		slv_reg0_rd		: in  std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg0_wr		: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg1_rd		: in  std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg1_wr		: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg2_rd		: in  std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg2_wr     	: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg3_rd		: in  std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg3_wr     	: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg4_rd		: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg4_wr		: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg5_rd		: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg5_wr		: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg6_rd		: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg6_wr    		: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg7_rd		: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg7_wr    		: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
        
		slv_reg0_rd_strb	: out std_logic;
		slv_reg1_rd_strb	: out std_logic;
		slv_reg2_rd_strb  	: out std_logic;
		slv_reg3_rd_strb   	: out std_logic;
		slv_reg4_rd_strb	: out std_logic;
		slv_reg5_rd_strb	: out std_logic;
		slv_reg6_rd_strb	: out std_logic;
		slv_reg7_rd_strb	: out std_logic;

		slv_reg0_wr_strb   	: out std_logic;
		slv_reg1_wr_strb   	: out std_logic;
		slv_reg2_wr_strb   	: out std_logic;
		slv_reg3_wr_strb   	: out std_logic;
		slv_reg4_wr_strb	: out std_logic;
		slv_reg5_wr_strb	: out std_logic;
		slv_reg6_wr_strb   	: out std_logic;
		slv_reg7_wr_strb   	: out std_logic;

		S_AXI_ACLK		: in  std_logic;
		S_AXI_ARESETN		: in  std_logic;
		S_AXI_AWADDR		: in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT		: in  std_logic_vector(2 downto 0);
		S_AXI_AWVALID		: in  std_logic;
		S_AXI_AWREADY		: out std_logic;
		S_AXI_WDATA		: in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB		: in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID		: in  std_logic;
		S_AXI_WREADY		: out std_logic;
		S_AXI_BRESP		: out std_logic_vector(1 downto 0);
		S_AXI_BVALID		: out std_logic;
		S_AXI_BREADY		: in  std_logic;
		S_AXI_ARADDR		: in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT		: in  std_logic_vector(2 downto 0);
		S_AXI_ARVALID		: in  std_logic;
		S_AXI_ARREADY		: out std_logic;
		S_AXI_RDATA		: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP		: out std_logic_vector(1 downto 0);
		S_AXI_RVALID		: out std_logic;
		S_AXI_RREADY		: in  std_logic
	);
end component;

component AXI_Master is
	generic (
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

		M_DATA_IN			: in std_logic_vector(C_M_AXI_DATA_WIDTH - 1 downto 0);
		M_DATA_OUT			: out std_logic_vector(C_M_AXI_DATA_WIDTH - 1 downto 0);
		M_TARGET_BASE_ADDR 		: in std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0);

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
		M_AXI_ARREADY	: in  std_logic;
		M_AXI_RID	: in  std_logic_vector(C_M_AXI_ID_WIDTH-1 downto 0);
		M_AXI_RDATA	: in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
		M_AXI_RRESP	: in  std_logic_vector(1 downto 0);
		M_AXI_RLAST	: in  std_logic;
		M_AXI_RUSER	: in  std_logic_vector(C_M_AXI_RUSER_WIDTH-1 downto 0);
		M_AXI_RVALID	: in  std_logic;
		M_AXI_RREADY	: out std_logic
	);
end component;

component  fsm_DMA_TX is
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
		AXI_RXN_STRB 		: in  std_logic;
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

component fsm_DMA_RX is
	port (
		clk			: in  std_logic;
		aresetn			: in  std_logic;
	
		DATA_IN 		: in  std_logic_vector(31 downto 0);
		DATA_OUT		: out std_logic_vector(31 downto 0);
		ADDR			: out std_logic_vector(31 downto 0);
		INIT_AXI_TXN		: out std_logic;
		AXI_TXN_DONE		: in  std_logic;
		AXI_TXN_STRB		: in  std_logic;
		AXI_TXN_IN_STRB		: out std_logic;
		INIT_AXI_RXN		: out std_logic;
		AXI_RXN_DONE 		: in  std_logic;
		AXI_RXN_STRB		: in  std_logic;
		BURST			: out std_logic_vector(7 downto 0);
		RX_DESC_ADDR		: in  std_logic_vector(31 downto 0);
		RX_DESC_ADDR_STRB 	: in  std_logic;
		RX_SIZE			: in  std_logic_vector(31 downto 0);
		RX_SIZE_STRB		: in  std_logic;
		RX_PRCSSD		: out std_logic_vector(31 downto 0);
		RX_PRCSSD_STRB		: in  std_logic;
		RX_PRCSSD_INT		: out std_logic;
		RX_WSTRB		: out std_logic_vector(3 downto 0);
		XGBE_PCKT_RCV		: in  std_logic;
		DMA_EN			: in  std_logic;
		RCV_EN			: in  std_logic;
		RX_PCKT_DATA		: in  std_logic_vector(31 downto 0);
		RX_PCKT_DATA_STRB	: out std_logic;
		RX_PCKT_CNT		: in  std_logic_vector(31 downto 0);
		RX_PCKT_CNT_STRB	: out std_logic	
	);
end component;

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

component fsm_axi_to_fifo is
port (
	clk 			: in std_logic;
	resetn 			: in std_logic;
	data_from_axi 		: in std_logic_vector(31 downto 0);
	data_from_axi_strb 	: in std_logic;
	data_to_fifo 		: out std_logic_vector(63 downto 0);
	data_to_fifo_strb 	: out std_logic;
	cnt_from_axi 		: in std_logic_vector(31 downto 0);
	cnt_from_axi_strb 	: in std_logic;
	cnt_to_fifo 		: out std_logic_vector(13 downto 0);
	cnt_to_fifo_strb 	: out std_logic;
	packet_strb 		: out std_logic
);
end component;

component fsm_fifo_to_mac is
	port (
		clk 		: in std_logic;
		rst 		: in std_logic;
		pkt_tx_data 	: out std_logic_vector(63 downto 0);
		pkt_tx_val 	: out std_logic;
		pkt_tx_sop 	: out std_logic;
		pkt_tx_eop 	: out std_logic;
		pkt_tx_mod 	: out std_logic_vector(2 downto 0);
		pkt_tx_full 	: in std_logic;
		packet_strb 	: in std_logic;
		fifo_data 	: in std_logic_vector(63 downto 0);
		fifo_cnt 	: in std_logic_vector(13 downto 0);
		fifo_data_strb 	: out std_logic;
		fifo_cnt_strb 	: out std_logic
	);
end component;

component fsm_mac_to_fifo is
	port (
		clk 		: in  std_logic;	
		rst 		: in  std_logic;
		en_rcv 		: in  std_logic;
		fifo_data 	: out std_logic_vector(63 downto 0);
		fifo_cnt 	: out std_logic_vector(13 downto 0);
	        fifo_cnt_strb 	: out std_logic;
	        fifo_strb 	: out std_logic;
	        fifo_drop 	: out std_logic;
		eop_strb 	: out std_logic;
		fifo_is_full	: in  std_logic;
	        pkt_rx_data 	: in  std_logic_vector(63 downto 0);
	        pkt_rx_ren 	: out std_logic;
	        pkt_rx_avail 	: in  std_logic;
	        pkt_rx_eop   	: in  std_logic;
	        pkt_rx_val   	: in  std_logic;
	        pkt_rx_sop   	: in  std_logic;
	        pkt_rx_mod   	: in  std_logic_vector(2 downto 0);
	        pkt_rx_err   	: in  std_logic
       );
end component;

component fsm_fifo_to_axi is
	port (
		clk	: in std_logic;
		resetn	: in std_logic;
	
		data_from_fifo		: in std_logic_vector(63 downto 0);
		data_from_fifo_strb	: out std_logic;
		data_to_axi		: out std_logic_vector(31 downto 0);
		data_to_axi_strb	: in std_logic;
	
		cnt_from_fifo		: in std_logic_vector(13 downto 0);
		cnt_from_fifo_strb	: out std_logic;
		cnt_to_axi		: out std_logic_vector(31 downto 0);
		cnt_to_axi_strb		: in std_logic
	);
end component;

component reset_con is
	port (
		clk		: in std_logic;
		resetn_1	: in std_logic;
		resetn_2	: in std_logic;
		out_resetn	: out std_logic
	);
end component reset_con;


	signal slv_reg0_rd_strb, slv_reg1_rd_strb, slv_reg2_rd_strb, slv_reg3_rd_strb : std_logic := '0';
	signal slv_reg0_wr_strb, slv_reg1_wr_strb, slv_reg2_wr_strb, slv_reg3_wr_strb : std_logic := '0';
	signal slv_reg4_rd_strb, slv_reg5_rd_strb, slv_reg6_rd_strb, slv_reg7_rd_strb : std_logic := '0';
	signal slv_reg4_wr_strb, slv_reg5_wr_strb, slv_reg6_wr_strb, slv_reg7_wr_strb : std_logic := '0';

	signal interrupt_axi_fifo, interrupt_fifo_mac : std_logic := '0';
	signal interrupt_mac_fifo, interrupt_fifo_counter : std_logic := '0';
	signal interrupt_rx_counter : std_logic := '0';
	signal interrupt_tx_prcssd  : std_logic := '0';
	signal interrupt_to_axi	    : std_logic := '0';
	signal interrupt_fsm_DMA_RX : std_logic := '0';
	
	signal rcv_en_100MHz, rcv_en_156_25MHz, resetp 	: std_logic := '0';
	signal int_en_100MHz			: std_logic := '0';
	signal dma_en_100MHz			: std_logic := '0';
	signal control_reg_100MHz_resetn 	: std_logic := '0';
	signal control_reg_156_25MHz_resetn 	: std_logic := '0';
	signal con_100MHz_resetn		: std_logic := '0';
	signal con_156_25MHz_resetn		: std_logic := '0'; 
	
	signal slv_reg0_rd	: std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg0_wr	: std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg1_rd	: std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg1_wr	: std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg2_rd	: std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg2_wr	: std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg3_rd	: std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg3_wr	: std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg4_rd	: std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg4_wr	: std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg5_rd	: std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg5_wr	: std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg6_rd	: std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg6_wr	: std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg7_rd	: std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg7_wr	: std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);

	signal axi_m_data_in 	: std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
	signal axi_m_data_out 	: std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
	signal axi_m_slave_addr : std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0);
	signal axi_m_init_txn, axi_m_done_txn, axi_m_strb_txn 	: std_logic := '0';
	signal axi_m_strb_txn_in 				: std_logic := '0';
	signal axi_m_init_rxn, axi_m_done_rxn, axi_m_strb_rxn 	: std_logic := '0';
	signal axi_m_burst	: std_logic_vector(7 downto 0);

	signal dma_tx_burst	: std_logic_vector(7 downto 0);
	signal dma_tx_data_out  : std_logic_vector(31 downto 0);
	signal dma_tx_data_in	: std_logic_vector(31 downto 0);
	signal dma_tx_addr	: std_logic_vector(31 downto 0);
	signal dma_tx_init_txn  : std_logic;
	signal dma_tx_init_rxn	: std_logic;
	signal dma_tx_txn_done  : std_logic;
	signal dma_tx_rxn_done  : std_logic;
	signal dma_tx_txn_strb	: std_logic;
	signal dma_tx_rxn_strb	: std_logic;

	signal dma_rx_burst	: std_logic_vector(7 downto 0);
	signal dma_rx_data_out  : std_logic_vector(31 downto 0);
	signal dma_rx_data_in	: std_logic_vector(31 downto 0);
	signal dma_rx_addr	: std_logic_vector(31 downto 0);
	signal dma_rx_init_txn  : std_logic;
	signal dma_rx_init_rxn	: std_logic;
	signal dma_rx_txn_done  : std_logic;
	signal dma_rx_rxn_done  : std_logic;
	signal dma_rx_txn_strb	: std_logic;
	signal dma_rx_rxn_strb	: std_logic;
	signal dma_rx_wstrb	: std_logic_vector(3 downto 0);

	signal data_dma_mux_tx, data_mux_fsm_tx  : std_logic_vector(31 downto 0);
	signal strb_data_dma_mux_tx, strb_data_mux_fsm_tx : std_logic;
	signal cnt_dma_mux_tx, cnt_mux_fsm_tx   : std_logic_vector(31 downto 0);
	signal strb_cnt_dma_mux_tx, strb_cnt_mux_fsm_tx : std_logic;

	signal strb_data_dma_mux_rx, strb_data_mux_fsm_rx : std_logic;
	signal strb_cnt_dma_mux_rx, strb_cnt_mux_fsm_rx : std_logic;

	signal data_axi_fifo, data_fifo_mac : std_logic_vector(63 downto 0);
	signal data_mac_fifo, data_fifo_axi : std_logic_vector(63 downto 0);
	signal cnt_axi_fifo, cnt_fifo_mac   : std_logic_vector(13 downto 0);
	signal cnt_mac_fifo, cnt_fifo_axi   : std_logic_vector(13 downto 0);
	signal strb_data_axi_fifo, strb_cnt_axi_fifo : std_logic := '0';
	signal strb_data_fifo_mac, strb_cnt_fifo_mac : std_logic := '0';
	signal strb_data_mac_fifo, strb_cnt_mac_fifo : std_logic := '0';
	signal strb_data_fifo_axi, strb_cnt_fifo_axi : std_logic := '0';

	signal fifo_drop : std_logic := '0';
	signal full_fifo_axi_mac, full_fifo_mac_axi : std_logic := '0';

	signal pkt_rx_avail, pkt_rx_eop, pkt_rx_err, pkt_rx_ren, pkt_rx_sop : std_logic := '0';
	signal pkt_rx_val, pkt_tx_eop, pkt_tx_full, pkt_tx_sop, pkt_tx_val : std_logic := '0';
	signal pkt_rx_data, pkt_tx_data: std_logic_vector(63 downto 0) := (others => '0');
	signal pkt_rx_mod, pkt_tx_mod : std_logic_vector(2 downto 0) := (others => '0');

begin
	--process resets not used AXI register.
   	process (s_axi_aclk) begin
		if (rising_edge(s_axi_aclk)) then
			if (s_axi_aresetn = '0') then
				slv_reg2_rd 	<= (others => '0');
				slv_reg5_rd 	<= (others => '0');
				slv_reg7_rd 	<= (others => '0');
				dma_tx_data_out <= (others => '0');
			end if;
		end if;
	end process;	

	interrupt_controller_0 : interrupt_controller
		port map (
			int_0 => interrupt_rx_counter,
			int_1 => interrupt_tx_prcssd,
			int_out => interrupt_to_axi
		);

	not_read_packet_counter : counter
		generic map ( REG_WIDTH => 32, INT_GEN_DELAY => 100000)
		port map (
			clk => s_axi_aclk,
			resetn => con_100MHz_resetn,
			incr => interrupt_fsm_DMA_RX,
			get_val => slv_reg3_rd_strb,
			int_en	=> int_en_100MHz,
			cnt_out => slv_reg3_rd,
			interrupt => interrupt_rx_counter
		);

	int_axi_mac : flag_over_clocks
		port map (
			clk_in => s_axi_aclk,
			clk_in_resetn => con_100MHz_resetn,
			clk_out => clk_156_25MHz,
			clk_out_resetn => con_156_25MHz_resetn,
			flag_in => interrupt_axi_fifo,
			flag_out => interrupt_fifo_mac
		);	 
 
	fifo_axi_mac_data : fifo	
		generic map (DATA_WIDTH => 64, DATA_HEIGHT => 10) 
		port map (  
			clk_in  => s_axi_aclk,
			clk_in_resetn => con_100MHz_resetn,
			clk_out => clk_156_25MHz,
			clk_out_resetn => con_156_25MHz_resetn,
			data_in => data_axi_fifo,
			data_out => data_fifo_mac,
			strb_in => strb_data_axi_fifo,
			strb_out => strb_data_fifo_mac,
			drop_in => '0',
			is_full_clk_in => full_fifo_axi_mac
		);

	fifo_axi_mac_cnt : fifo		
		generic map (DATA_WIDTH => 14, DATA_HEIGHT => 10)
		port map (
			clk_in	=> s_axi_aclk,
			clk_in_resetn => con_100MHz_resetn,
			clk_out => clk_156_25MHz,
			clk_out_resetn => con_156_25MHz_resetn,
			data_in => cnt_axi_fifo,
			data_out => cnt_fifo_mac,
			strb_in => strb_cnt_axi_fifo,
			strb_out => strb_cnt_fifo_mac,
			drop_in => '0',
			is_full_clk_in => open
		);

	int_mac_axi : flag_over_clocks
		port map (
			clk_in => clk_156_25MHz,
			clk_in_resetn => con_156_25MHz_resetn,
			clk_out => s_axi_aclk,
			clk_out_resetn => con_100MHz_resetn,
			flag_in => interrupt_mac_fifo,
			flag_out => interrupt_fifo_counter
		);	 

	fifo_mac_axi_data : fifo	
		generic map (DATA_WIDTH => 64, DATA_HEIGHT => 10)
		port map (
			clk_in  => clk_156_25MHz,
			clk_in_resetn => con_156_25MHz_resetn,
			clk_out => s_axi_aclk,
			clk_out_resetn	=> con_100MHz_resetn,
			data_in => data_mac_fifo,
			data_out => data_fifo_axi,
			strb_in => strb_data_mac_fifo,
			strb_out => strb_data_fifo_axi,
			drop_in => fifo_drop,
			is_full_clk_in => full_fifo_mac_axi
		);

	fifo_mac_axi_cnt : fifo		
		generic map (DATA_WIDTH => 14, DATA_HEIGHT => 10)
		port map (
			clk_in  => clk_156_25MHz,
			clk_in_resetn => con_156_25MHz_resetn,
			clk_out => s_axi_aclk,
			clk_out_resetn => con_100MHz_resetn,
			data_in => cnt_mac_fifo,
			data_out => cnt_fifo_axi,
			strb_in => strb_cnt_mac_fifo,
			strb_out => strb_cnt_fifo_axi,
			drop_in => '0',
			is_full_clk_in => open
		);

	fsm_axi_to_fifo_0 : fsm_axi_to_fifo
		port map (
			clk => s_axi_aclk,
			resetn => con_100MHz_resetn,
			data_from_axi => data_mux_fsm_tx,
			data_from_axi_strb => strb_data_mux_fsm_tx, 
			data_to_fifo => data_axi_fifo, 
			data_to_fifo_strb => strb_data_axi_fifo, 
			cnt_from_axi   => cnt_mux_fsm_tx,
			cnt_from_axi_strb => strb_cnt_mux_fsm_tx,
			cnt_to_fifo  => cnt_axi_fifo,
			cnt_to_fifo_strb => strb_cnt_axi_fifo,
			packet_strb => interrupt_axi_fifo
		);

	fsm_fifo_to_mac_0 : fsm_fifo_to_mac 
		port map (
			clk => clk_156_25MHz,
			rst => con_156_25MHz_resetn,
			pkt_tx_data => pkt_tx_data,
			pkt_tx_val => pkt_tx_val,
			pkt_tx_sop => pkt_tx_sop,
			pkt_tx_eop => pkt_tx_eop,
			pkt_tx_mod => pkt_tx_mod,
			pkt_tx_full => pkt_tx_full,
			packet_strb => interrupt_fifo_mac,
			fifo_data => data_fifo_mac,
			fifo_cnt => cnt_fifo_mac,
			fifo_data_strb => strb_data_fifo_mac,
			fifo_cnt_strb => strb_cnt_fifo_mac
		);

	fsm_mac_to_fifo_0 : fsm_mac_to_fifo
		port map (
			clk => clk_156_25MHz,
			rst => con_156_25MHz_resetn,
			en_rcv => rcv_en_156_25MHz,
			fifo_data => data_mac_fifo,
			fifo_cnt => cnt_mac_fifo,
			fifo_cnt_strb => strb_cnt_mac_fifo,
			fifo_strb => strb_data_mac_fifo,
			fifo_drop => fifo_drop,
			eop_strb => interrupt_mac_fifo,
			fifo_is_full => full_fifo_mac_axi,
			pkt_rx_data => pkt_rx_data,
			pkt_rx_ren => pkt_rx_ren,
			pkt_rx_avail => pkt_rx_avail,
			pkt_rx_eop => pkt_rx_eop,
			pkt_rx_val => pkt_rx_val,
			pkt_rx_sop => pkt_rx_sop,
			pkt_rx_mod => pkt_rx_mod,
			pkt_rx_err => pkt_rx_err
		);

	fsm_fifo_to_axi_0 : fsm_fifo_to_axi
		port map (
			clk => s_axi_aclk,
			resetn => con_100MHz_resetn,
			data_from_fifo => data_fifo_axi,
			data_from_fifo_strb => strb_data_fifo_axi,
			data_to_axi => slv_reg1_rd,
			data_to_axi_strb => strb_data_mux_fsm_rx,
			cnt_from_fifo => cnt_fifo_axi,
			cnt_from_fifo_strb => strb_cnt_fifo_axi,
			cnt_to_axi => slv_reg0_rd,
			cnt_to_axi_strb => strb_cnt_mux_fsm_rx
		);
	
	control_register_0 : control_register
	generic map (DATA_WIDTH => 32)
		port map (
			clk => s_axi_aclk,
			clk_resetn => s_axi_aresetn,
			reg_input => slv_reg2_wr,
			reg_strb => slv_reg2_wr_strb,
			rcv_en  => rcv_en_100MHz,
			int_en => int_en_100MHz,
			dma_en => dma_en_100MHz,
			resetp => resetp	
		);
		
	control_reg_100MHz_resetn <= not(resetp);

	reset_con_100MHz : reset_con
		port map (
			clk => s_axi_aclk,
			resetn_1 => control_reg_100MHz_resetn,
			resetn_2 => s_axi_aresetn,
			out_resetn => con_100MHz_resetn
		);

	softreset_intra_clk : flagn_over_clocks
		port map (
			clk_in => s_axi_aclk,
			clk_in_resetn => s_axi_aresetn,
			clk_out => clk_156_25MHz,
			clk_out_resetn => rst_clk_156_25MHz,
			flagn_in => con_100MHz_resetn,
			flagn_out => control_reg_156_25MHz_resetn
		);	

 	rcv_en_intra_clk : bit_over_clocks
		port map (
			clk_in => s_axi_aclk,
			clk_in_resetn => '1',
			clk_out => clk_156_25MHz,
			clk_out_resetn => '1',
			bit_in => rcv_en_100MHz,
			bit_out => rcv_en_156_25MHz
		);

	reset_con_156_25MHz : reset_con
		port map (
			clk => clk_156_25MHz,
			resetn_1 => rst_clk_156_25MHz,
			resetn_2 => control_reg_156_25MHz_resetn,
			out_resetn => con_156_25MHz_resetn
		);

	AXI_to_regs_0 : AXI_to_regs 
		generic map (
			C_S_AXI_DATA_WIDTH => C_AXI_DATA_WIDTH,
			C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH
		)
		port map (
			interrupt => interrupt,
			interrupt_in => interrupt_to_axi,

			slv_reg0_rd => slv_reg0_rd, 
			slv_reg0_wr => slv_reg0_wr,
			slv_reg1_rd => slv_reg1_rd, 
			slv_reg1_wr => slv_reg1_wr, 
			slv_reg2_rd => slv_reg2_rd,
			slv_reg2_wr => slv_reg2_wr, 
			slv_reg3_rd => slv_reg3_rd,
			slv_reg3_wr => slv_reg3_wr,
			slv_reg4_rd => slv_reg4_rd, 
			slv_reg4_wr => slv_reg4_wr,
			slv_reg5_rd => slv_reg5_rd, 
			slv_reg5_wr => slv_reg5_wr, 
			slv_reg6_rd => slv_reg6_rd,
			slv_reg6_wr => slv_reg6_wr, 
			slv_reg7_rd => slv_reg7_rd,
			slv_reg7_wr => slv_reg7_wr,

			slv_reg0_rd_strb => slv_reg0_rd_strb,
			slv_reg1_rd_strb => slv_reg1_rd_strb,
			slv_reg2_rd_strb => slv_reg2_rd_strb,
			slv_reg3_rd_strb => slv_reg3_rd_strb,
			slv_reg4_rd_strb => slv_reg4_rd_strb,
			slv_reg5_rd_strb => slv_reg5_rd_strb,
			slv_reg6_rd_strb => slv_reg6_rd_strb,
			slv_reg7_rd_strb => slv_reg7_rd_strb,

			slv_reg0_wr_strb => slv_reg0_wr_strb,
			slv_reg1_wr_strb => slv_reg1_wr_strb,
			slv_reg2_wr_strb => slv_reg2_wr_strb, 
			slv_reg3_wr_strb => slv_reg3_wr_strb,
			slv_reg4_wr_strb => slv_reg4_wr_strb,
			slv_reg5_wr_strb => slv_reg5_wr_strb,
			slv_reg6_wr_strb => slv_reg6_wr_strb, 
			slv_reg7_wr_strb => slv_reg7_wr_strb,

			S_AXI_ACLK => s_axi_aclk,
			S_AXI_ARESETN => s_axi_aresetn,
			S_AXI_AWADDR => s_axi_awaddr,
			S_AXI_AWPROT => s_axi_awprot,
			S_AXI_AWVALID => s_axi_awvalid,
			S_AXI_AWREADY => s_axi_awready,
			S_AXI_WDATA => s_axi_wdata,
			S_AXI_WSTRB => s_axi_wstrb,
			S_AXI_WVALID => s_axi_wvalid,
			S_AXI_WREADY => s_axi_wready,
			S_AXI_BRESP => s_axi_bresp,
			S_AXI_BVALID => s_axi_bvalid,
			S_AXI_BREADY => s_axi_bready,
			S_AXI_ARADDR => s_axi_araddr,
			S_AXI_ARPROT => s_axi_arprot,
			S_AXI_ARVALID => s_axi_arvalid,
			S_AXI_ARREADY => s_axi_arready,
			S_AXI_RDATA => s_axi_rdata,
			S_AXI_RRESP => s_axi_rresp,
			S_AXI_RVALID => s_axi_rvalid,
			S_AXI_RREADY => s_axi_rready
		);


	AXI_Master_0 : AXI_Master
		port map (
			M_DATA_IN		=> axi_m_data_in,
			M_DATA_OUT		=> axi_m_data_out,
			M_TARGET_BASE_ADDR 	=> axi_m_slave_addr,

			INIT_AXI_TXN	=> axi_m_init_txn,
			AXI_TXN_DONE	=> axi_m_done_txn,
			AXI_TXN_STRB	=> axi_m_strb_txn,
			AXI_TXN_IN_STRB => axi_m_strb_txn_in,
			INIT_AXI_RXN	=> axi_m_init_rxn,
			AXI_RXN_DONE	=> axi_m_done_rxn,
			AXI_RXN_STRB	=> axi_m_strb_rxn,
			BURST		=> axi_m_burst,

			M_AXI_ACLK	=> M_AXI_ACLK,
			M_AXI_ARESETN	=> M_AXI_ARESETN,
			M_AXI_AWID	=> M_AXI_AWID,
			M_AXI_AWADDR	=> M_AXI_AWADDR,
			M_AXI_AWLEN	=> M_AXI_AWLEN,
			M_AXI_AWSIZE	=> M_AXI_AWSIZE,
			M_AXI_AWBURST	=> M_AXI_AWBURST,
			M_AXI_AWLOCK	=> M_AXI_AWLOCK,
			M_AXI_AWCACHE	=> M_AXI_AWCACHE,
			M_AXI_AWPROT	=> M_AXI_AWPROT,
			M_AXI_AWQOS	=> M_AXI_AWQOS,
			M_AXI_AWUSER	=> M_AXI_AWUSER,
			M_AXI_AWVALID	=> M_AXI_AWVALID,	
			M_AXI_AWREADY	=> M_AXI_AWREADY,
			M_AXI_WDATA	=> M_AXI_WDATA,
			M_AXI_WSTRB	=> M_AXI_WSTRB,
			M_AXI_WLAST	=> M_AXI_WLAST,
			M_AXI_WUSER	=> M_AXI_WUSER,
			M_AXI_WVALID	=> M_AXI_WVALID,
			M_AXI_WREADY	=> M_AXI_WREADY,
			M_AXI_BID	=> M_AXI_BID,
			M_AXI_BRESP	=> M_AXI_BRESP,
			M_AXI_BUSER	=> M_AXI_BUSER,
			M_AXI_BVALID	=> M_AXI_BVALID,
			M_AXI_BREADY	=> M_AXI_BREADY,
			M_AXI_ARID	=> M_AXI_ARID,
			M_AXI_ARADDR	=> M_AXI_ARADDR,
			M_AXI_ARLEN	=> M_AXI_ARLEN,
			M_AXI_ARSIZE	=> M_AXI_ARSIZE,
			M_AXI_ARBURST	=> M_AXI_ARBURST,
			M_AXI_ARLOCK	=> M_AXI_ARLOCK,
			M_AXI_ARCACHE	=> M_AXI_ARCACHE,
			M_AXI_ARPROT	=> M_AXI_ARPROT,
			M_AXI_ARQOS	=> M_AXI_ARQOS,
			M_AXI_ARUSER	=> M_AXI_ARUSER,
			M_AXI_ARVALID	=> M_AXI_ARVALID,
			M_AXI_ARREADY	=> M_AXI_ARREADY,
			M_AXI_RID	=> M_AXI_RID,
			M_AXI_RDATA	=> M_AXI_RDATA,
			M_AXI_RRESP	=> M_AXI_RRESP,
			M_AXI_RLAST	=> M_AXI_RLAST,
			M_AXI_RUSER	=> M_AXI_RUSER,
			M_AXI_RVALID	=> M_AXI_RVALID,
			M_AXI_RREADY	=> M_AXI_RREADY
		);
	--TODO CLOCKS! s_axi_aclk and m_axi_aclk should be synchronized!!!!
	interconnect_AXI_M_DMA_0 : interconnect_AXI_M_DMA
		port map (
		clk 		=> s_axi_aclk,
		aresetn 	=> s_axi_aresetn,
		DATA_OUT_0 	=> dma_rx_data_out, 
		DATA_OUT_1 	=> dma_tx_data_out,
		DATA_TO_AXI 	=> axi_m_data_in,
		DATA_FROM_AXI 	=> axi_m_data_out,
		DATA_IN_0 	=> dma_rx_data_in,
		DATA_IN_1 	=> dma_tx_data_in,
		ADDR_0 		=> dma_rx_addr,
		ADDR_1 		=> dma_tx_addr,
		ADDR_TO_AXI 	=> axi_m_slave_addr,
		INIT_AXI_TXN 	=> axi_m_init_txn,
		INIT_AXI_RXN 	=> axi_m_init_rxn,
		AXI_TXN_DONE 	=> axi_m_done_txn,
		AXI_RXN_DONE 	=> axi_m_done_rxn,
		AXI_TXN_STRB    => axi_m_strb_txn,
		AXI_RXN_STRB    => axi_m_strb_rxn,
		INIT_AXI_TXN_0 	=> dma_rx_init_txn,
		AXI_TXN_DONE_0 	=> dma_rx_txn_done,
		INIT_AXI_RXN_0 	=> dma_rx_init_rxn,
		AXI_RXN_DONE_0 	=> dma_rx_rxn_done,
		INIT_AXI_TXN_1 	=> dma_tx_init_txn,
		AXI_TXN_DONE_1 	=> dma_tx_txn_done,
		INIT_AXI_RXN_1 	=> dma_tx_init_rxn,
		AXI_RXN_DONE_1 	=> dma_tx_rxn_done,
		AXI_RXN_STRB_0 	=> dma_rx_rxn_strb,
		AXI_TXN_STRB_0 	=> dma_rx_txn_strb,
		AXI_RXN_STRB_1 	=> dma_tx_rxn_strb,
		AXI_TXN_STRB_1	=> dma_tx_txn_strb,
		BRST_0		=> dma_rx_burst,
		BRST_1		=> dma_tx_burst,
		BRST_TO_AXI	=> axi_m_burst
	);


	fsm_DMA_TX_0 : fsm_DMA_TX
		port map (
			clk 			=> s_axi_aclk,
			aresetn 		=> s_axi_aresetn,
	
			DATA_IN 		=> dma_tx_data_in,
			ADDR 			=> dma_tx_addr,
			INIT_AXI_TXN 		=> dma_tx_init_txn,
			AXI_TXN_DONE 		=> dma_tx_txn_done,
			AXI_TXN_STRB		=> dma_tx_txn_strb,
			INIT_AXI_RXN 		=> dma_tx_init_rxn,
			AXI_RXN_DONE 		=> dma_tx_rxn_done,
			AXI_RXN_STRB		=> dma_tx_rxn_strb,
			BURST			=> dma_tx_burst,
			TX_DESC_ADDR	 	=> slv_reg4_wr,
			TX_DESC_ADDR_STRB	=> slv_reg4_wr_strb,
			TX_SIZE 		=> slv_reg5_wr,
			TX_SIZE_STRB 		=> slv_reg5_wr_strb,
			TX_INCR_STRB 		=> slv_reg7_wr_strb,
			TX_PRCSSD 		=> slv_reg6_rd,
			TX_PRCSSD_STRB 		=> slv_reg6_rd_strb,
			TX_PRCSSD_INT 		=> interrupt_tx_prcssd,
			DMA_EN 			=> dma_en_100MHz,
			TX_PCKT_DATA	 	=> data_dma_mux_tx,
			TX_PCKT_DATA_STRB 	=> strb_data_dma_mux_tx,
			TX_PCKT_CNT 		=> cnt_dma_mux_tx,
			TX_PCKT_CNT_STRB 	=> strb_cnt_dma_mux_tx
		);

	fsm_DMA_RX_0 : fsm_DMA_RX
		port map (
			clk 			=> s_axi_aclk,
			aresetn 		=> s_axi_aresetn,
			DATA_IN 		=> dma_rx_data_in,
			DATA_OUT	 	=> dma_rx_data_out,
			ADDR 			=> dma_rx_addr,
			INIT_AXI_TXN		=> dma_rx_init_txn,
			AXI_TXN_DONE 		=> dma_rx_txn_done,
			AXI_TXN_STRB 		=> dma_rx_txn_strb,
			AXI_TXN_IN_STRB		=> axi_m_strb_txn_in,
			INIT_AXI_RXN 		=> dma_rx_init_rxn,
			AXI_RXN_DONE 		=> dma_rx_rxn_done,
			AXI_RXN_STRB 		=> dma_rx_rxn_strb,
			BURST 			=> dma_rx_burst,
			RX_DESC_ADDR 		=> slv_reg6_wr,
			RX_DESC_ADDR_STRB 	=> slv_reg6_wr_strb,
			RX_SIZE 		=> slv_reg5_wr,
			RX_SIZE_STRB 		=> slv_reg5_wr_strb,
			RX_PRCSSD 		=> slv_reg4_rd,
			RX_PRCSSD_STRB 		=> slv_reg4_rd_strb,
			RX_PRCSSD_INT 		=> interrupt_fsm_DMA_RX,
			RX_WSTRB		=> dma_rx_wstrb,
			XGBE_PCKT_RCV 		=> interrupt_fifo_counter,
			DMA_EN			=> dma_en_100MHz,
			RCV_EN			=> rcv_en_100MHz,
			RX_PCKT_DATA		=> slv_reg1_rd, 
			RX_PCKT_DATA_STRB	=> strb_data_dma_mux_rx,
			RX_PCKT_CNT		=> slv_reg0_rd,
			RX_PCKT_CNT_STRB 	=> strb_cnt_dma_mux_rx
	);


	data_reg_or_dma_tx : MUX
		generic map (
			DATA_WIDTH => 32
		)
		port map (
			DIN_0 => slv_reg1_wr,
			DIN_1 => data_dma_mux_tx,
			DOUT => data_mux_fsm_tx,
			ADDR => dma_en_100MHz
		);

	strb_data_reg_or_dma_tx : MUX
		generic map (
			DATA_WIDTH => 1
		)
		port map (
			DIN_0(0) => slv_reg1_wr_strb,
			DIN_1(0) => strb_data_dma_mux_tx,
			DOUT(0) => strb_data_mux_fsm_tx,
			ADDR => dma_en_100MHz
		);

	cnt_reg_or_dma_tx : MUX
		generic map (
			DATA_WIDTH => 32
		)
		port map (
			DIN_0 => slv_reg0_wr,
			DIN_1 => cnt_dma_mux_tx,
			DOUT => cnt_mux_fsm_tx,
			ADDR => dma_en_100MHz
		);

	strb_cnt_reg_or_dma_tx : MUX
		generic map (
			DATA_WIDTH => 1
		)
		port map (
			DIN_0(0) => slv_reg0_wr_strb,
			DIN_1(0) => strb_cnt_dma_mux_tx,
			DOUT(0) => strb_cnt_mux_fsm_tx,
			ADDR => dma_en_100MHz
		);

	strb_data_reg_or_dma_rx : MUX
		generic map (
			DATA_WIDTH => 1
		)
		port map (
			DIN_0(0) => slv_reg1_rd_strb,
			DIN_1(0) => strb_data_dma_mux_rx,
			DOUT(0) => strb_data_mux_fsm_rx,
			ADDR => dma_en_100MHz
		);


	strb_cnt_reg_or_dma_rx : MUX
		generic map (
			DATA_WIDTH => 1
		)
		port map (
			DIN_0(0) => slv_reg0_rd_strb,
			DIN_1(0) => strb_cnt_dma_mux_rx,
			DOUT(0) => strb_cnt_mux_fsm_rx,
			ADDR => dma_en_100MHz
		);

	xge_mac_0 : xge_mac
		port map (
			clk_156m25 => clk_156_25MHz,
			clk_xgmii_rx => xgmii_rx_clk,
			clk_xgmii_tx => xgmii_tx_clk,
			pkt_rx_avail => pkt_rx_avail,
			pkt_rx_data => pkt_rx_data,
			pkt_rx_eop => pkt_rx_eop,
			pkt_rx_err => pkt_rx_err,
			pkt_rx_mod => pkt_rx_mod,
			pkt_rx_ren => pkt_rx_ren,
			pkt_rx_sop => pkt_rx_sop,
			pkt_rx_val => pkt_rx_val,
			pkt_tx_data => pkt_tx_data,
			pkt_tx_eop => pkt_tx_eop,
			pkt_tx_full => pkt_tx_full,
			pkt_tx_mod => pkt_tx_mod,
			pkt_tx_sop => pkt_tx_sop,
			pkt_tx_val => pkt_tx_val,
			reset_156m25_n => con_156_25MHz_resetn,
			reset_xgmii_rx_n => con_156_25MHz_resetn,
			reset_xgmii_tx_n => con_156_25MHz_resetn,
			wb_ack_o => open,
			wb_adr_i =>  (others => '0'),
			wb_clk_i => clk_20MHz,
			wb_cyc_i => '0',
			wb_dat_i => (others => '0'),
			wb_dat_o => open,
			wb_int_o => open,
			wb_rst_i => rst_clk_20MHz,
			wb_stb_i => '0',
			wb_we_i => '0',
			xgmii_rxc => xgmii_rxc,
			xgmii_rxd => xgmii_rxd,
			xgmii_txc => xgmii_txc,
			xgmii_txd => xgmii_txd
		);
	
end xgbe_arch;
