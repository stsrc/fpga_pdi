--AXI tb from https://github.com/frobino/axi_custom_ip_tb/blob/master/led_controller_1.0/hdl/testbench.vhd

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity tb is
 
end tb;

architecture STRUCTURE of tb is
	component AXI_to_regs is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
		interrupt : out std_logic;
	       
		slv_reg0_rd	: in std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg0_wr	: out std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg1_rd	: in std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg1_wr	: out std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg2_rd	: in std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg2_wr    : out std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg3_rd	: in std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg3_wr    : out std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
        
		slv_reg0_rd_strb   : out std_logic;
		slv_reg1_rd_strb  : out std_logic;
		slv_reg2_rd_strb   : out std_logic;
		slv_reg3_rd_strb   : out std_logic;
		slv_reg0_wr_strb   : out std_logic;
		slv_reg1_wr_strb   : out std_logic;
		slv_reg2_wr_strb   : out std_logic;
		slv_reg3_wr_strb   : out std_logic;

		interrupt_in    : in std_logic;

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
	end component;
  



  signal s00_axi_aclk, s00_axi_aresetn, s00_axi_arready, s00_axi_arvalid, s00_axi_awready, s00_axi_awvalid : std_logic := '0';
  signal s00_axi_bready, s00_axi_bvalid, s00_axi_rready, s00_axi_rvalid, s00_axi_wready, s00_axi_wvalid : std_logic := '0';
  signal s00_axi_rdata, s00_axi_wdata : std_logic_vector(31 downto 0) := (others => '0');
  signal s00_axi_araddr, s00_axi_awaddr, s00_axi_wstrb : std_logic_vector(3 downto 0) := (others => '0');
  signal s00_axi_arprot, s00_axi_awprot : std_logic_vector(2 downto 0) := (others => '0');
  signal s00_axi_bresp, s00_axi_rresp : std_logic_vector(1 downto 0) := (others => '0');
  
  signal ReadIt, SendIt : std_logic := '0';


	signal interrupt : std_logic := '0';

	signal slv_reg0_rd	: std_logic_vector(32 - 1 downto 0) := (others => '0');
	signal slv_reg0_wr	: std_logic_vector(32 - 1 downto 0) := (others => '0');
	signal slv_reg1_rd	: std_logic_vector(32 - 1 downto 0) := (others => '0');
	signal slv_reg1_wr	: std_logic_vector(32 - 1 downto 0) := (others => '0');
	signal slv_reg2_rd	: std_logic_vector(32 - 1 downto 0) := (others => '0');
	signal slv_reg2_wr     : std_logic_vector(32 - 1 downto 0) := (others => '0');
	signal slv_reg3_rd	: std_logic_vector(32 - 1 downto 0) := (others => '0');
	signal slv_reg3_wr     : std_logic_vector(32 - 1 downto 0) := (others => '0');
        
	signal slv_reg0_rd_strb   : std_logic := '0';
	signal slv_reg1_rd_strb   : std_logic := '0';
	signal slv_reg2_rd_strb   : std_logic := '0';
	signal slv_reg3_rd_strb   : std_logic := '0';
	signal slv_reg0_wr_strb   : std_logic := '0';
	signal slv_reg1_wr_strb   : std_logic := '0';
	signal slv_reg2_wr_strb   : std_logic := '0';
	signal slv_reg3_wr_strb   : std_logic := '0';
	signal interrupt_in    : std_logic := '0';

begin

axi_to_regs_1 : AXI_to_regs
generic map(C_S00_AXI_DATA_WIDTH => 32, C_S00_AXI_ADDR_WIDTH => 4)
port map (interrupt => interrupt, slv_reg0_rd => slv_reg0_rd, slv_reg0_wr => slv_reg0_wr,
	slv_reg1_rd => slv_reg1_rd, slv_reg1_wr => slv_reg1_wr, slv_reg2_rd => slv_reg2_rd,
	slv_reg2_wr => slv_reg2_wr, slv_reg3_rd => slv_reg3_rd, slv_reg3_wr => slv_reg3_wr,
	slv_reg0_rd_strb => slv_reg0_rd_strb, slv_reg1_rd_strb => slv_reg1_rd_strb,
	slv_reg2_rd_strb => slv_reg2_rd_strb, slv_reg3_rd_strb => slv_reg3_rd_strb,
	slv_reg0_wr_strb => slv_reg0_wr_strb, slv_reg1_wr_strb => slv_reg1_wr_strb,
	slv_reg2_wr_strb => slv_reg2_wr_strb, slv_reg3_wr_strb => slv_reg3_wr_strb,
	interrupt_in => interrupt_in, 
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
    wait for 5 ns;
    s00_axi_aclk <= '1';
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
	slv_reg0_rd <= std_logic_vector(to_unsigned(255, 32));
	slv_reg1_rd <= std_logic_vector(to_unsigned(511, 32));
    S00_AXI_ARESETN <= '0';
    wait for 10 ns;
    S00_AXI_ARESETN <= '1';
    
    for i in 0 to 8 loop
	   S00_AXI_AWADDR<="0100";
        S00_AXI_WDATA<=x"00000001";
        S00_AXI_WSTRB<=b"1111";
        sendIt<='1';                --Start AXI Write to Slave
        wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	    wait until S00_AXI_BVALID = '1';
	    wait until S00_AXI_BVALID = '0';  --AXI Write finished
        S00_AXI_WSTRB<=b"0000";

	    S00_AXI_AWADDR<="0100";
        S00_AXI_WDATA<=x"00000010";
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
