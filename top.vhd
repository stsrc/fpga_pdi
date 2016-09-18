library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is 
begin
	generic (
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		clk_156_25MHz	: in std_logic;
		rst_clk_156_25MHz : in std_logic;
		interrupt	: out std_logic;

		s_axi_aclk	: in std_logic;
		s_axi_aresetn	: in std_logic;
		s_axi_awaddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_awprot	: in std_logic_vector(2 downto 0);
		s_axi_awvalid	: in std_logic;
		s_axi_awready	: out std_logic;
		s_axi_wdata	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		s_axi_wstrb	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		s_axi_wvalid	: in std_logic;
		s_axi_wready	: out std_logic;
		s_axi_bresp	: out std_logic_vector(1 downto 0);
		s_axi_bvalid	: out std_logic;
		s_axi_bready	: in std_logic;
		s_axi_araddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_arprot	: in std_logic_vector(2 downto 0);
		s_axi_arvalid	: in std_logic;
		s_axi_arready	: out std_logic;
		s_axi_rdata	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		s_axi_rresp	: out std_logic_vector(1 downto 0);
		s_axi_rvalid	: out std_logic;
		s_axi_rready	: in std_logic

		pkt_tx_data : out std_logic_vector(63 downto 0);
		pkt_tx_val : out std_logic;
		pkt_tx_sop : out std_logic;
		pkt_tx_eop : out std_logic;
		pkt_tx_mod : out std_logic_vector(2 downto 0);
		pkt_tx_full : in std_logic;
	        pkt_rx_data  : in  std_logic_vector(63 downto 0);
	        pkt_rx_ren   : out std_logic;
	        pkt_rx_avail : in  std_logic;
	        pkt_rx_eop   : in  std_logic;
	        pkt_rx_val   : in  std_logic;
	        pkt_rx_sop   : in  std_logic;
	        pkt_rx_mod   : in  std_logic_vector(2 downto 0);
	        pkt_rx_err   : in  std_logic
	);
end top;

architecture top_arch of top is 

component fifo is
	generic (
		DATA_WIDTH : integer := 64;
		DATA_HEIGHT : integer := 10
	);
	port (
		rst		: in std_logic;
		clk_in		: in std_logic;
		clk_out		: in std_logic;	
		data_in		: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		data_out	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
		strb_in		: in std_logic;
		strb_out	: in std_logic;
		drop_in		: in std_logic;
		interrupt_in	: in std_logic;
		interrupt_out	: out std_logic
	);
end component fifo;

component AXI_to_regs is
	generic (
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
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

component fsm_axi_to_fifo is
	port (
		clk : in std_logic;
		rst : in std_logic;
		axi_strb    : in std_logic;
		axi_data : in std_logic_vector(31 downto 0);
		fifo_data : out std_logic_vector(63 downto 0);
		fifo_strb : out std_logic;

		cnt_axi : in std_logic_vector(31 downto 0);
		cnt_fifo : out std_logic_vector(13 downto 0);
		cnt_axi_strb : in std_logic;
		packet_strb : out std_logic;
		cnt_fifo_strb : out std_logic
	);
end component;

component fsm_fifo_to_mac is
	port (
		clk : in std_logic;
		rst : in std_logic;
		pkt_tx_data : out std_logic_vector(63 downto 0);
		pkt_tx_val : out std_logic;
		pkt_tx_sop : out std_logic;
		pkt_tx_eop : out std_logic;
		pkt_tx_mod : out std_logic_vector(2 downto 0);
		pkt_tx_full : in std_logic;
	
		packet_strb : in std_logic;
		fifo_data : in std_logic_vector(63 downto 0);
		fifo_cnt : in std_logic_vector(13 downto 0);
		fifo_data_strb : out std_logic;
		fifo_cnt_strb : out std_logic
	);
end component;

component fsm is
	port (
		clk          : in  std_logic;	
		rst          : in  std_logic;
		fifo_data     : out std_logic_vector(63 downto 0);
		fifo_cnt      : out std_logic_vector(13 downto 0);
	        fifo_cnt_strb : out std_logic;
	        fifo_strb    : out std_logic;
	        fifo_drop    : out std_logic;
		eop_strb     : out std_logic;
	        pkt_rx_data  : in  std_logic_vector(63 downto 0);
	        pkt_rx_ren   : out std_logic;
	        pkt_rx_avail : in  std_logic;
	        pkt_rx_eop   : in  std_logic;
	        pkt_rx_val   : in  std_logic;
	        pkt_rx_sop   : in  std_logic;
	        pkt_rx_mod   : in  std_logic_vector(2 downto 0);
	        pkt_rx_err   : in  std_logic
       );
end component;

component fsm_fifo_to_axi_rx is
	port (
		clk     : in std_logic;
		rst     : in std_logic;
    
		fifo_out : in std_logic_vector(63 downto 0);
		fifo_strb : out std_logic;
		axi_in   : out std_logic_vector(31 downto 0);
		axi_strb  : in std_logic;
    
		cnt_in : in std_logic_vector(13 downto 0);
		cnt_out : out std_logic_vector(31 downto 0);
		cnt_strb_in : in std_logic;
		cnt_strb_out : out std_logic
	);
end component;
	signal slv_reg0_rd_strb, slv_reg1_rd_strb, slv_reg2_rd_strb, slv_reg3_rd_strb : std_logic := '0';
	signal slv_reg0_wr_strb, slv_reg1_wr_strb, slv_reg2_wr_strb, slv_reg3_wr_strb : std_logic := '0';
	signal interrupt_axi_fifo, interrupt_fifo_mac : std_logic := '0';
	signal interrupt_mac_fifo, interrupt_fifo_axi : std_logic := '0';
	
	signal slv_reg0_rd	: std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg0_wr	: std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg1_rd	: std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg1_wr	: std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg2_rd	: std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg2_wr	: std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg3_rd	: std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
	signal slv_reg3_wr	: std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
	
	signal data_axi_fifo, data_fifo_mac : std_logic_vector(63 downto 0);
	signal data_mac_fifo, data_fifo_axi : std_logic_vector(63 downto 0);
	signal cnt_axi_fifo, cnt_fifo_mac : std_logic_vector(13 downto 0);
	signal cnt_mac_fifo, cnt_fifo_axi : std_logic_vector(13 downto 0);
	signal strb_data_axi_fifo, strb_cnt_axi_fifo : std_logic := '0';
	signal strb_data_fifo_mac, strb_cnt_fifo_mac : std_logic := '0';
	signal strb_data_mac_fifo, strb_cnt_mac_fifo : std_logic := '0';
	signal strb_data_fifo_axi, strb_cnt_fifo_axi : std_logic := '0';

	signal fifo_drop : std_logic := '0';

begin
	fifo_axi_mac_data : fifo	generic map (DATA_WIDTH => 64, DATA_HEIGHT => 10) 
					port map (
					rst     => s_axi_aresetn,  
					clk_in  => s_axi_aclk,
					clk_out => clk_156_25MHz,
					data_in => data_axi_fifo,
					data_out => data_fifo_mac,
					strb_in => strb_data_axi_fifo,
					strb_out => strb_data_fifo_mac,
					drop_in => '0',
					interrupt_in => interrupt_axi_fifo,
					interrupt_out => interrupt_fifo_mac
				);
	fifo_axi_mac_cnt : fifo		generic map (DATA_WIDTH = 14, DATA_HEIGHT => 10)
					port map (
					rst	=> s_axi_aresetn,
					clk_in	=> s_axi_aclk,
					clk_out => clk_156_25MHz,
					data_in => cnt_axi_fifo,
					data_out => cnt_fifo_mac,
					strb_in => strb_cnt_axi_fifo,
					strb_out => strb_cnt_fifo_mac,
					drop_in => '0',
					interrupt_in => '0',
					interrupt_out => open
				);

	fifo_mac_axi_data : fifo	generic map (DATA_WIDTH => 64, DATA_HEIGHT => 10)
					port map (
					rst	=> s_axi_aresetn,
					clk_in  => s_axi_aclk,
					clk_out => clk_156_25MHz,
					data_in => data_mac_fifo,
					data_out => data_fifo_axi,
					strb_in => strb_data_mac_fifo,
					strb_out => strb_data_fifo_axi,
					drop_in => fifo_drop,
					interrupt_in => interrupt_mac_fifo,
					interrupt_out => interrupt_fifo_axi
				);

	fifo_mac_axi_cnt : fifo		generic map (DATA_WIDTH => 14, DATA_HEIGHT => 10)
					port map (
					rst	=> s_axi_aresetn,
					clk_in  => s_axi_aclk,
					clk_out => clk_156_25MHz,
					data_in => cnt_mac_fifo,
					data_out => cnt_fifo_axi,
					strb_in => strb_cnt_mac_fifo,
					strb_out => strb_cnt_fifo_axi,
					drop_in => '0',
					interrupt_in => '0',
					interrupt_out => open
				);

	fsm_axi_to_fifo_0 : fsm_axi_to_fifo
					port map (
					clk => s_axi_aclk,
					rst => s_axi_aresetn,
					axi_strb => slv_reg1_wr_strb, 
					axi_data => slv_reg1_wr,
					fifo_data => data_axi_fifo, 
					fifo_strb => strb_data_axi_fifo, 
					cnt_axi   => slv_reg0_wr,
					cnt_fifo  => cnt_axi_fifo,
					cnt_axi_strb => slv_reg0_wr_strb,
					packet_strtb => interrupt_axi_fifo,
					cnt_fifo_strb => strb_cnt_axi_fifo
				);

	fsm_fifo_to_mac_0 : fsm_fifo_to_mac 
					port map (
					clk => clk_156_25MHz,
					rst => rst_clk_156_25MHz,
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

	fsm_mac_to_fifo_0 : fsm 
					port map (
					clk => clk_156_25MHz,
					rst => rst_clk_156_25MHz,
					fifo_data => data_mac_fifo,
					fifo_cnt => cnt_mac_fifo,
					fifo_cnt_strb => strb_cnt_mac_fifo,
					fifo_strb => strb_data_mac_fifo,
					fifo_drop => fifo_drop,
					eop_strb => interrupt_mac_fifo,
					pkt_rx_data => pkt_rx_data,
					pkt_rx_ren => pkt_rx_ren,
					pkt_rx_avail => pkt_rx_avail,
					pkt_rx_eop => pkt_rx_eop,
					pkt_rx_val => pkt_rx_val,
					pkt_rx_sop => pkt_rx_sop,
					pkt_rx_mod => pkt_rx_mod,
					pkt_rx_err => pkt_rx_err
				);

	fsm_fifo_to_axi_0 : fsm_fifo_to_axi_rx
					port map (
					clk => s_axi_aclk,
					rst => s_axi_aresetn,
					fifo_out => data_fifo_axi,
					fifo_strb => strb_data_fifo_axi,
					axi_in => slv_reg1_rd,
					axi_strb => slv_reg1_rd_strb,
					cnt_in => cnt_fifo_axi,
					cnt_out => slv_reg0_rd,
					cnt_strb_in => strb_cnt_fifo_axi,
					cnt_strb_out => slv_reg0_rd_strb
				);

end arch_top;
