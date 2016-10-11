-- Part of 10 gig eth design. Here is an ordinary AXI-XGMII converter.
-- BURST AXI, DMA not implemented yet. 
-- Data transmission: 
-- 1. Write packets to the AXI reg1.
-- 2. Write byte count to the AXI reg0. It starts packet transmission.
-- Data reception:
-- 1. Enable data reception by writing 2 to AXI reg2.
-- 2. Wait for interrupt == 1.
-- 3. Read bytes count from AXI reg0.
-- 4. Read packet from AXI reg1.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xgbe is 
	generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
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
		s_axi_wdata		: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		s_axi_wstrb		: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		s_axi_wvalid		: in std_logic;
		s_axi_wready		: out std_logic;
		s_axi_bresp		: out std_logic_vector(1 downto 0);
		s_axi_bvalid		: out std_logic;
		s_axi_bready		: in std_logic;
		s_axi_araddr		: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_arprot		: in std_logic_vector(2 downto 0);
		s_axi_arvalid		: in std_logic;
		s_axi_arready		: out std_logic;
		s_axi_rdata		: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		s_axi_rresp		: out std_logic_vector(1 downto 0);
		s_axi_rvalid		: out std_logic;
		s_axi_rready		: in std_logic;

		xgmii_rxc 		: in std_logic_vector(7 downto 0);
		xgmii_rxd 		: in std_logic_vector(63 downto 0);
		xgmii_txc 		: out std_logic_vector(7 downto 0);
		xgmii_txd 		: out std_logic_vector(63 downto 0);
		xgmii_tx_clk 		: in std_logic;
		xgmii_rx_clk 		: in std_logic
	);
end xgbe;

architecture xgbe_arch of xgbe is 

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
		resetp      : out std_logic
	);
end component control_register;

component AXI_to_regs is
	generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		interrupt : out std_logic;
		interrupt_in    : in std_logic;       

		slv_reg0_rd	: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg0_wr	: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg1_rd	: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg1_wr	: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg2_rd	: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg2_wr     : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg3_rd	: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg3_wr     : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
        
		slv_reg0_rd_strb   : out std_logic;
		slv_reg1_rd_strb   : out std_logic;
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
	packet_strb 		: out std_logic;
	fifo_is_full 		: in std_logic
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
	signal interrupt_axi_fifo, interrupt_fifo_mac : std_logic := '0';
	signal interrupt_mac_fifo, interrupt_fifo_counter : std_logic := '0';
	signal interrupt_counter_axi : std_logic := '0';
	
	signal rcv_en_100MHz, rcv_en_156_25MHz, resetp 	: std_logic := '0';
	signal control_reg_100MHz_resetn 	: std_logic := '0';
	signal control_reg_156_25MHz_resetn 	: std_logic := '0';
	signal con_100MHz_resetn		: std_logic := '0';
	signal con_156_25MHz_resetn		: std_logic := '0'; 
	
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
				slv_reg2_rd <= (others => '0');
			end if;
		end if;
	end process;	

	not_read_packet_counter : counter
		generic map ( REG_WIDTH => 32, INT_GEN_DELAY => 100)
		port map (
			clk => s_axi_aclk,
			resetn => con_100MHz_resetn,
			incr => interrupt_fifo_counter,
			get_val => slv_reg3_rd_strb,
			cnt_out => slv_reg3_rd,
			interrupt => interrupt_counter_axi
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
			data_from_axi => slv_reg1_wr,
			data_from_axi_strb => slv_reg1_wr_strb, 
			data_to_fifo => data_axi_fifo, 
			data_to_fifo_strb => strb_data_axi_fifo, 
			cnt_from_axi   => slv_reg0_wr,
			cnt_from_axi_strb => slv_reg0_wr_strb,
			cnt_to_fifo  => cnt_axi_fifo,
			cnt_to_fifo_strb => strb_cnt_axi_fifo,
			packet_strb => interrupt_axi_fifo,
			fifo_is_full => full_fifo_axi_mac
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
			data_to_axi_strb => slv_reg1_rd_strb,
			cnt_from_fifo => cnt_fifo_axi,
			cnt_from_fifo_strb => strb_cnt_fifo_axi,
			cnt_to_axi => slv_reg0_rd,
			cnt_to_axi_strb => slv_reg0_rd_strb
		);
	
	control_register_0 : control_register
	generic map (DATA_WIDTH => 32)
		port map (
			clk => s_axi_aclk,
			clk_resetn => s_axi_aresetn,
			reg_input => slv_reg2_wr,
			reg_strb => slv_reg2_wr_strb,
			rcv_en  => rcv_en_100MHz,
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
			C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
			C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH
		)
		port map (
			interrupt => interrupt,
			interrupt_in => interrupt_counter_axi,
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
