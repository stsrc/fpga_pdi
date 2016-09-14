--AXI tb from https://github.com/frobino/axi_custom_ip_tb/blob/master/led_controller_1.0/hdl/testbench.vhd

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity tb is
 
end tb;

architecture STRUCTURE of tb is
  component block_design_wrapper is
  port (
    clk_mac : in STD_LOGIC;
    interrupt : out STD_LOGIC;
    pkt_rx_avail : in STD_LOGIC;
    pkt_rx_data : in STD_LOGIC_VECTOR ( 63 downto 0 );
    pkt_rx_eop : in STD_LOGIC;
    pkt_rx_err : in STD_LOGIC;
    pkt_rx_mod : in STD_LOGIC_VECTOR ( 2 downto 0 );
    pkt_rx_ren : out STD_LOGIC;
    pkt_rx_sop : in STD_LOGIC;
    pkt_rx_val : in STD_LOGIC;
    pkt_tx_data : out STD_LOGIC_VECTOR ( 63 downto 0 );
    pkt_tx_eop : out STD_LOGIC;
    pkt_tx_full : in STD_LOGIC;
    pkt_tx_mod : out STD_LOGIC_VECTOR ( 2 downto 0 );
    pkt_tx_sop : out STD_LOGIC;
    pkt_tx_val : out STD_LOGIC;
    s00_axi_aclk : in STD_LOGIC;
    s00_axi_araddr : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s00_axi_aresetn : in STD_LOGIC;
    s00_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s00_axi_arready : out STD_LOGIC;
    s00_axi_arvalid : in STD_LOGIC;
    s00_axi_awaddr : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s00_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s00_axi_awready : out STD_LOGIC;
    s00_axi_awvalid : in STD_LOGIC;
    s00_axi_bready : in STD_LOGIC;
    s00_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s00_axi_bvalid : out STD_LOGIC;
    s00_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s00_axi_rready : in STD_LOGIC;
    s00_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s00_axi_rvalid : out STD_LOGIC;
    s00_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s00_axi_wready : out STD_LOGIC;
    s00_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s00_axi_wvalid : in STD_LOGIC
  );
end component block_design_wrapper;
  signal pkt_tx_eop, pkt_tx_sop, pkt_tx_val, pkt_tx_full : std_logic := '0';
  signal pkt_tx_data : std_logic_vector(63 downto 0) := (others => '0');
  signal pkt_tx_mod : std_logic_vector(2 downto 0) := (others => '0');
  signal clk_mac : std_logic := '0';
  signal interrupt, pkt_rx_avail, pkt_rx_eop, pkt_rx_err, pkt_rx_ren, pkt_rx_sop, pkt_rx_val : std_logic := '0';
  signal s00_axi_aclk, s00_axi_aresetn, s00_axi_arready, s00_axi_arvalid, s00_axi_awready, s00_axi_awvalid : std_logic := '0';
  signal s00_axi_bready, s00_axi_bvalid, s00_axi_rready, s00_axi_rvalid, s00_axi_wready, s00_axi_wvalid : std_logic := '0';
  signal pkt_rx_data : std_logic_vector(63 downto 0) := (others => '0');
  signal s00_axi_rdata, s00_axi_wdata : std_logic_vector(31 downto 0) := (others => '0');
  signal s00_axi_araddr, s00_axi_awaddr, s00_axi_wstrb : std_logic_vector(3 downto 0) := (others => '0');
  signal pkt_rx_mod, s00_axi_arprot, s00_axi_awprot : std_logic_vector(2 downto 0) := (others => '0');
  signal s00_axi_bresp, s00_axi_rresp : std_logic_vector(1 downto 0) := (others => '0');
  
  signal ReadIt, SendIt : std_logic := '0';
begin

block_design_i: component block_design_wrapper
     port map (
      clk_mac => clk_mac,
      interrupt => interrupt,
      pkt_rx_avail => pkt_rx_avail,
      pkt_rx_data(63 downto 0) => pkt_rx_data(63 downto 0),
      pkt_rx_eop => pkt_rx_eop,
      pkt_rx_err => pkt_rx_err,
      pkt_rx_mod(2 downto 0) => pkt_rx_mod(2 downto 0),
      pkt_rx_ren => pkt_rx_ren,
      pkt_rx_sop => pkt_rx_sop,
      pkt_rx_val => pkt_rx_val,
      pkt_tx_data(63 downto 0) => pkt_tx_data(63 downto 0),
      pkt_tx_eop => pkt_tx_eop,
      pkt_tx_full => pkt_tx_full,
      pkt_tx_mod(2 downto 0) => pkt_tx_mod(2 downto 0),
      pkt_tx_sop => pkt_tx_sop,
      pkt_tx_val => pkt_tx_val,
      s00_axi_aclk => s00_axi_aclk,
      s00_axi_araddr(3 downto 0) => s00_axi_araddr(3 downto 0),
      s00_axi_aresetn => s00_axi_aresetn,
      s00_axi_arprot(2 downto 0) => s00_axi_arprot(2 downto 0),
      s00_axi_arready => s00_axi_arready,
      s00_axi_arvalid => s00_axi_arvalid,
      s00_axi_awaddr(3 downto 0) => s00_axi_awaddr(3 downto 0),
      s00_axi_awprot(2 downto 0) => s00_axi_awprot(2 downto 0),
      s00_axi_awready => s00_axi_awready,
      s00_axi_awvalid => s00_axi_awvalid,
      s00_axi_bready => s00_axi_bready,
      s00_axi_bresp(1 downto 0) => s00_axi_bresp(1 downto 0),
      s00_axi_bvalid => s00_axi_bvalid,
      s00_axi_rdata(31 downto 0) => s00_axi_rdata(31 downto 0),
      s00_axi_rready => s00_axi_rready,
      s00_axi_rresp(1 downto 0) => s00_axi_rresp(1 downto 0),
      s00_axi_rvalid => s00_axi_rvalid,
      s00_axi_wdata(31 downto 0) => s00_axi_wdata(31 downto 0),
      s00_axi_wready => s00_axi_wready,
      s00_axi_wstrb(3 downto 0) => s00_axi_wstrb(3 downto 0),
      s00_axi_wvalid => s00_axi_wvalid
    );

    
process begin
    s00_axi_aclk <= '0';
    clk_mac <= '0';
    wait for 5 ns;
    s00_axi_aclk <= '1';
    clk_mac <= '1';
    wait for 5 ns;
end process;
 

send : PROCESS
 BEGIN
    S00_AXI_AWVALID<='0';
    S00_AXI_WVALID<='0';
    S00_AXI_BREADY<='0';
    loop
        wait until sendIt = '1';
        wait until S00_AXI_ACLK= '0';
            S00_AXI_AWVALID<='1';
            S00_AXI_WVALID<='1';
        wait until (S00_AXI_AWREADY and S00_AXI_WREADY) = '1';  --Client ready to read address/data        
            S00_AXI_BREADY<='1';
        wait until S00_AXI_BVALID = '1';  -- Write result valid
            assert S00_AXI_BRESP = "00" report "AXI data not written" severity failure;
            S00_AXI_AWVALID<='0';
            S00_AXI_WVALID<='0';
            S00_AXI_BREADY<='1';
        wait until S00_AXI_BVALID = '0';  -- All finished
            S00_AXI_BREADY<='0';
    end loop;
 END PROCESS send;

 read : PROCESS
  BEGIN
    S00_AXI_ARVALID<='0';
    S00_AXI_RREADY<='0';
     loop
         wait until readIt = '1';
         wait until S00_AXI_ACLK= '0';
             S00_AXI_ARVALID<='1';
            wait until (S00_AXI_RVALID) = '1';  --Client provided data (removed and S00_AXI_ARREADY???)
            S00_AXI_RREADY<='1';
            S00_AXI_ARVALID <= '0';
            assert S00_AXI_RRESP = "00" report "AXI data not written" severity failure;
            wait until (S00_AXI_RVALID) = '0';
            S00_AXI_RREADY<='0';
     end loop;
  END PROCESS read;
      
tb : process
begin
 
    S00_AXI_ARESETN <= '0';
    wait for 10 ns;
    S00_AXI_ARESETN <= '1';
    
    for i in 0 to 8 loop
	   S00_AXI_AWADDR<="0100";
        S00_AXI_WDATA<=x"fffffff0" or std_logic_vector(to_unsigned(i, 32));
        S00_AXI_WSTRB<=b"1111";
        sendIt<='1';                --Start AXI Write to Slave
        wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	    wait until S00_AXI_BVALID = '1';
	    wait until S00_AXI_BVALID = '0';  --AXI Write finished
        S00_AXI_WSTRB<=b"0000";

	    S00_AXI_AWADDR<="0100";
        S00_AXI_WDATA<=x"fffff0f0" or std_logic_vector(to_unsigned(i, 32));
        S00_AXI_WSTRB<=b"1111";
        sendIt<='1';                --Start AXI Write to Slave
        wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	   wait until S00_AXI_BVALID = '1';
	   wait until S00_AXI_BVALID = '0';  --AXI Write finished
        S00_AXI_WSTRB<=b"0000";
    end loop;

	S00_AXI_AWADDR<="0000";
    S00_AXI_WDATA<=x"00000041";
    S00_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	wait until S00_AXI_BVALID = '1';
	wait until S00_AXI_BVALID = '0';  --AXI Write finished
    S00_AXI_WSTRB<=b"0000";
    
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
    
    S00_AXI_ARADDR<="0000";
        readIt<='1';                --Start AXI Read from Slave
        wait for 1 ns; 
       readIt<='0';                --Clear "Start Read" Flag
    wait until S00_AXI_RREADY = '1';
    wait until S00_AXI_RREADY = '0';    --AXI_DATA should be equal to 17
        S00_AXI_ARADDR<="0100";
   for i in 0 to 5 loop
        readIt<='1';                --Start AXI Read from Slave
        wait for 1 ns; 
       readIt<='0';                --Clear "Start Read" Flag
    wait until S00_AXI_RREADY = '1';    --AXI_DATA should be equal to 10000000...
    wait until S00_AXI_RREADY = '0';
    end loop;

     wait; -- will wait forever     
end process tb;   
     
end STRUCTURE;
