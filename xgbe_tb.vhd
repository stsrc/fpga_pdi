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
begin
	generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
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
end component xgbe;

  signal pkt_tx_eop, pkt_tx_sop, pkt_tx_val, pkt_tx_full : std_logic := '0';
  signal pkt_tx_data : std_logic_vector(63 downto 0) := (others => '0');
  signal pkt_tx_mod : std_logic_vector(2 downto 0) := (others => '0');
  signal clk_156_25MHz, rst_clk_156_25MHz : std_logic := '0';
  signal interrupt, pkt_rx_avail, pkt_rx_eop, pkt_rx_err, pkt_rx_ren, pkt_rx_sop, pkt_rx_val : std_logic := '0';
  signal s_axi_aclk, s_axi_aresetn, s_axi_arready, s_axi_arvalid, s_axi_awready, s_axi_awvalid : std_logic := '0';
  signal s_axi_bready, s_axi_bvalid, s_axi_rready, s_axi_rvalid, s_axi_wready, s_axi_wvalid : std_logic := '0';
  signal pkt_rx_data : std_logic_vector(63 downto 0) := (others => '0');
  signal s_axi_rdata, s_axi_wdata : std_logic_vector(31 downto 0) := (others => '0');
  signal s_axi_araddr, s_axi_awaddr, s_axi_wstrb : std_logic_vector(3 downto 0) := (others => '0');
  signal pkt_rx_mod, s_axi_arprot, s_axi_awprot : std_logic_vector(2 downto 0) := (others => '0');
  signal s_axi_bresp, s_axi_rresp : std_logic_vector(1 downto 0) := (others => '0');
  
  signal ReadIt, SendIt : std_logic := '0';
begin

block_design_i: xgbe
     port map (
      clk_156_25MHz => clk_156_25MHz,
      rst_clk_156_25MHz => rst_clk_156_25MHz,
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
      s_axi_wvalid => s_axi_wvalid


      pkt_tx_data(63 downto 0) => pkt_tx_data(63 downto 0),
      pkt_tx_eop => pkt_tx_eop,
      pkt_tx_full => pkt_tx_full,
      pkt_tx_mod(2 downto 0) => pkt_tx_mod(2 downto 0),
      pkt_tx_sop => pkt_tx_sop,
      pkt_tx_val => pkt_tx_val,
      pkt_rx_avail => pkt_rx_avail,
      pkt_rx_data(63 downto 0) => pkt_rx_data(63 downto 0),
      pkt_rx_eop => pkt_rx_eop,
      pkt_rx_err => pkt_rx_err,
      pkt_rx_mod(2 downto 0) => pkt_rx_mod(2 downto 0),
      pkt_rx_ren => pkt_rx_ren,
      pkt_rx_sop => pkt_rx_sop,
      pkt_rx_val => pkt_rx_val,

    );

    
process begin
    s_axi_aclk <= '0';
    clk_mac <= '0';
    wait for 5 ns;
    s_axi_aclk <= '1';
    clk_mac <= '1';
    wait for 5 ns;
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
      
tb : process
begin
 
    s_axi_aresetn <= '0';
    wait for 10 ns;
    s_axi_aresetn <= '1';
    
    for i in 0 to 8 loop
	   s_axi_awaddr<="0100";
        s_axi_wdata<=x"fffffff0" or std_logic_vector(to_unsigned(i, 32));
        s_axi_wstrb<=b"1111";
        sendit<='1';                --start axi write to slave
        wait for 1 ns; sendit<='0'; --clear start send flag
	    wait until s_axi_bvalid = '1';
	    wait until s_axi_bvalid = '0';  --axi write finished
        s_axi_wstrb<=b"0000";

	    s_axi_awaddr<="0100";
        s_axi_wdata<=x"fffff0f0" or std_logic_vector(to_unsigned(i, 32));
        s_axi_wstrb<=b"1111";
        sendit<='1';                --start axi write to slave
        wait for 1 ns; sendit<='0'; --clear start send flag
	   wait until s_axi_bvalid = '1';
	   wait until s_axi_bvalid = '0';  --axi write finished
        s_axi_wstrb<=b"0000";
    end loop;

	s_axi_awaddr<="0000";
    s_axi_wdata<=x"00000041";
    s_axi_wstrb<=b"1111";
    sendit<='1';                --start axi write to slave
    wait for 1 ns; sendit<='0'; --clear start send flag
	wait until s_axi_bvalid = '1';
	wait until s_axi_bvalid = '0';  --axi write finished
    s_axi_wstrb<=b"0000";
    
    wait for 200 ns;
    
    pkt_rx_avail <= '1';
    wait for 10 ns;
    pkt_rx_sop <= '1';
    pkt_rx_val <= '1';
    pkt_rx_data <= "1000000010000000100000001000000000000001000000010000000100000001";
    wait for 10 ns;
    pkt_rx_sop <= '0';
    pkt_rx_data <= "1100000011000000110000001100000000000011000000110000001100000011";
    wait for 10 ns;
    pkt_rx_eop <= '1';
    pkt_rx_data <= "1110000011100000111000001110000000000111000001110000011100000111";
    pkt_rx_mod <= std_logic_vector(to_unsigned(1, 3));
    wait for 10 ns;
    pkt_rx_eop <= '0';
    pkt_rx_val <= '0';
    pkt_rx_avail <= '0';
    wait for 10 ns; 
    
    wait until interrupt = '1';
    
    s_axi_araddr<="0000";
        readit<='1';                --start axi read from slave
        wait for 1 ns; 
       readit<='0';                --clear "start read" flag
    wait until s_axi_rready = '1';
    wait until s_axi_rready = '0';    --axi_data should be equal to 17
        s_axi_araddr<="0100";
   for i in 0 to 5 loop
        readit<='1';                --start axi read from slave
        wait for 1 ns; 
       readit<='0';                --clear "start read" flag
    wait until s_axi_rready = '1';    --axi_data should be equal to 10000000...
    wait until s_axi_rready = '0';
    end loop;

     wait; -- will wait forever     
end process tb;   
     
end structure;
