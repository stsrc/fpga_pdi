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
		C_s_axi_DATA_WIDTH	: integer	:= 32;
		C_s_axi_ADDR_WIDTH	: integer	:= 5
	);
	port (
		-- Users to add ports here
		interrupt : out std_logic;
	       
		slv_reg0_rd	: in std_logic_vector(C_s_axi_DATA_WIDTH - 1 downto 0);
		slv_reg0_wr	: out std_logic_vector(C_s_axi_DATA_WIDTH - 1 downto 0);
		slv_reg1_rd	: in std_logic_vector(C_s_axi_DATA_WIDTH - 1 downto 0);
		slv_reg1_wr	: out std_logic_vector(C_s_axi_DATA_WIDTH - 1 downto 0);
		slv_reg2_rd	: in std_logic_vector(C_s_axi_DATA_WIDTH - 1 downto 0);
		slv_reg2_wr    : out std_logic_vector(C_s_axi_DATA_WIDTH - 1 downto 0);
		slv_reg3_rd	: in std_logic_vector(C_s_axi_DATA_WIDTH - 1 downto 0);
		slv_reg3_wr    : out std_logic_vector(C_s_axi_DATA_WIDTH - 1 downto 0);
		slv_reg4_rd	: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg4_wr	: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg5_rd	: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg5_wr	: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg6_rd	: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg6_wr    	: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg7_rd	: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		slv_reg7_wr    	: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
        
		slv_reg0_rd_strb	: out std_logic;
		slv_reg1_rd_strb	: out std_logic;
		slv_reg2_rd_strb	: out std_logic;
		slv_reg3_rd_strb	: out std_logic;
		slv_reg4_rd_strb	: out std_logic;
		slv_reg5_rd_strb	: out std_logic;
		slv_reg6_rd_strb	: out std_logic;
		slv_reg7_rd_strb	: out std_logic;
		slv_reg0_wr_strb	: out std_logic;
		slv_reg1_wr_strb	: out std_logic;
		slv_reg2_wr_strb	: out std_logic;
		slv_reg3_wr_strb	: out std_logic;
		slv_reg4_wr_strb	: out std_logic;
		slv_reg5_wr_strb	: out std_logic;
		slv_reg6_wr_strb   	: out std_logic;
		slv_reg7_wr_strb   	: out std_logic;

		interrupt_in    : in std_logic;

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface s_axi
		s_axi_aclk	: in std_logic;
		s_axi_aresetn	: in std_logic;
		s_axi_awaddr	: in std_logic_vector(C_s_axi_ADDR_WIDTH-1 downto 0);
		s_axi_awprot	: in std_logic_vector(2 downto 0);
		s_axi_awvalid	: in std_logic;
		s_axi_awready	: out std_logic;
		s_axi_wdata	: in std_logic_vector(C_s_axi_DATA_WIDTH-1 downto 0);
		s_axi_wstrb	: in std_logic_vector((C_s_axi_DATA_WIDTH/8)-1 downto 0);
		s_axi_wvalid	: in std_logic;
		s_axi_wready	: out std_logic;
		s_axi_bresp	: out std_logic_vector(1 downto 0);
		s_axi_bvalid	: out std_logic;
		s_axi_bready	: in std_logic;
		s_axi_araddr	: in std_logic_vector(C_s_axi_ADDR_WIDTH-1 downto 0);
		s_axi_arprot	: in std_logic_vector(2 downto 0);
		s_axi_arvalid	: in std_logic;
		s_axi_arready	: out std_logic;
		s_axi_rdata	: out std_logic_vector(C_s_axi_DATA_WIDTH-1 downto 0);
		s_axi_rresp	: out std_logic_vector(1 downto 0);
		s_axi_rvalid	: out std_logic;
		s_axi_rready	: in std_logic
	);
	end component;
  



  signal s_axi_aclk, s_axi_aresetn, s_axi_arready, s_axi_arvalid, s_axi_awready, s_axi_awvalid : std_logic := '0';
  signal s_axi_bready, s_axi_bvalid, s_axi_rready, s_axi_rvalid, s_axi_wready, s_axi_wvalid : std_logic := '0';
  signal s_axi_rdata, s_axi_wdata : std_logic_vector(31 downto 0) := (others => '0');
  signal s_axi_araddr, s_axi_awaddr : std_logic_vector(4 downto 0) := (others => '0');
  signal s_axi_wstrb : std_logic_vector(3 downto 0) := (others => '0');
  signal s_axi_arprot, s_axi_awprot : std_logic_vector(2 downto 0) := (others => '0');
  signal s_axi_bresp, s_axi_rresp : std_logic_vector(1 downto 0) := (others => '0');
  
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
	signal slv_reg4_rd	: std_logic_vector(32 - 1 downto 0) := (others => '0');
	signal slv_reg4_wr	: std_logic_vector(32 - 1 downto 0) := (others => '0');
	signal slv_reg5_rd	: std_logic_vector(32 - 1 downto 0) := (others => '0');
	signal slv_reg5_wr	: std_logic_vector(32 - 1 downto 0) := (others => '0');
	signal slv_reg6_rd	: std_logic_vector(32 - 1 downto 0) := (others => '0');
	signal slv_reg6_wr     : std_logic_vector(32 - 1 downto 0) := (others => '0');
	signal slv_reg7_rd	: std_logic_vector(32 - 1 downto 0) := (others => '0');
	signal slv_reg7_wr     : std_logic_vector(32 - 1 downto 0) := (others => '0');
        
	signal slv_reg0_rd_strb   : std_logic := '0';
	signal slv_reg1_rd_strb   : std_logic := '0';
	signal slv_reg2_rd_strb   : std_logic := '0';
	signal slv_reg3_rd_strb   : std_logic := '0';
	signal slv_reg0_wr_strb   : std_logic := '0';
	signal slv_reg1_wr_strb   : std_logic := '0';
	signal slv_reg2_wr_strb   : std_logic := '0';
	signal slv_reg3_wr_strb   : std_logic := '0';
	signal slv_reg4_rd_strb   : std_logic := '0';
	signal slv_reg5_rd_strb   : std_logic := '0';
	signal slv_reg6_rd_strb   : std_logic := '0';
	signal slv_reg7_rd_strb   : std_logic := '0';
	signal slv_reg4_wr_strb   : std_logic := '0';
	signal slv_reg5_wr_strb   : std_logic := '0';
	signal slv_reg6_wr_strb   : std_logic := '0';
	signal slv_reg7_wr_strb   : std_logic := '0';
	signal interrupt_in    : std_logic := '0';

begin

axi_to_regs_1 : AXI_to_regs
generic map(C_s_axi_DATA_WIDTH => 32, C_s_axi_ADDR_WIDTH => 5)
port map (interrupt => interrupt, 
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

	interrupt_in 	=> interrupt_in, 
	s_axi_aclk 	=> s_axi_aclk,
	s_axi_araddr 	=> s_axi_araddr,
	s_axi_aresetn 	=> s_axi_aresetn,
	s_axi_arprot 	=> s_axi_arprot,
	s_axi_arready 	=> s_axi_arready,
	s_axi_arvalid 	=> s_axi_arvalid,
	s_axi_awaddr 	=> s_axi_awaddr,
	s_axi_awprot 	=> s_axi_awprot,
	s_axi_awready 	=> s_axi_awready,
	s_axi_awvalid 	=> s_axi_awvalid,
	s_axi_bready 	=> s_axi_bready,
	s_axi_bresp 	=> s_axi_bresp,
	s_axi_bvalid 	=> s_axi_bvalid,
	s_axi_rdata 	=> s_axi_rdata,
	s_axi_rready 	=> s_axi_rready,
	s_axi_rresp	=> s_axi_rresp,
	s_axi_rvalid 	=> s_axi_rvalid,
	s_axi_wdata	=> s_axi_wdata,
	s_axi_wready 	=> s_axi_wready,
	s_axi_wstrb	=> s_axi_wstrb,
	s_axi_wvalid 	=> s_axi_wvalid
);
process begin
    s_axi_aclk <= '0';
    wait for 5 ns;
    s_axi_aclk <= '1';
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
	slv_reg0_rd <= std_logic_vector(to_unsigned(255, 32));
	slv_reg1_rd <= std_logic_vector(to_unsigned(511, 32));
    s_axi_aresetn <= '0';
    wait for 10 ns;
    s_axi_aresetn <= '1';
    
    for i in 0 to 8 loop
	   s_axi_awaddr<="00100";
        s_axi_wdata<=x"00000001";
        s_axi_wstrb<=b"1111";
        sendit<='1';                --start axi write to slave
        wait for 1 ns; sendit<='0'; --clear start send flag
	    wait until s_axi_bvalid = '1';
	    wait until s_axi_bvalid = '0';  --axi write finished
        s_axi_wstrb<=b"0000";

	    s_axi_awaddr<="00100";
        s_axi_wdata<=x"00000010";
        s_axi_wstrb<=b"1111";
        sendit<='1';                --start axi write to slave
        wait for 1 ns; sendit<='0'; --clear start send flag
	   wait until s_axi_bvalid = '1';
	   wait until s_axi_bvalid = '0';  --axi write finished
        s_axi_wstrb<=b"0000";
    end loop;

	s_axi_awaddr<="00000";
    s_axi_wdata<=x"00000041";
    s_axi_wstrb<=b"1111";
    sendit<='1';                --start axi write to slave
    wait for 1 ns; sendit<='0'; --clear start send flag
	wait until s_axi_bvalid = '1';
	wait until s_axi_bvalid = '0';  --axi write finished
    s_axi_wstrb<=b"0000";
    
    wait for 200 ns;
        
    s_axi_araddr<="00000";
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
