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
	generic (
		C_AXI_DATA_WIDTH	: integer 	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 5;
		C_M_AXI_ADDR_WIDTH	: integer	:= 32
	);
	port (
		clk_156_25MHz	: in std_logic;
		rst_clk_156_25MHz : in std_logic;
		clk_20MHz	: in std_logic;
		rst_clk_20MHz	: in std_logic;

		interrupt	: out std_logic;

		s_axi_aclk	: in std_logic;
		s_axi_aresetn	: in std_logic;
		s_axi_awaddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_awprot	: in std_logic_vector(2 downto 0);
		s_axi_awvalid	: in std_logic;
		s_axi_awready	: out std_logic;
		s_axi_wdata	: in std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
		s_axi_wstrb	: in std_logic_vector((C_AXI_DATA_WIDTH/8)-1 downto 0);
		s_axi_wvalid	: in std_logic;
		s_axi_wready	: out std_logic;
		s_axi_bresp	: out std_logic_vector(1 downto 0);
		s_axi_bvalid	: out std_logic;
		s_axi_bready	: in std_logic;
		s_axi_araddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_arprot	: in std_logic_vector(2 downto 0);
		s_axi_arvalid	: in std_logic;
		s_axi_arready	: out std_logic;
		s_axi_rdata	: out std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
		s_axi_rresp	: out std_logic_vector(1 downto 0);
		s_axi_rvalid	: out std_logic;
		s_axi_rready	: in std_logic;

		m_axi_aclk		: in std_logic;
		m_axi_aresetn		: in std_logic;
		m_axi_awaddr		: out std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0);
		m_axi_awprot		: out std_logic_vector(2 downto 0);
		m_axi_awvalid		: out std_logic;
		m_axi_awready		: in std_logic;
		m_axi_wdata		: out std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
		m_axi_wstrb		: out std_logic_vector(C_AXI_DATA_WIDTH/8 - 1 downto 0);
		m_axi_wvalid		: out std_logic;
		m_axi_wready		: in std_logic;
		m_axi_bresp		: in std_logic_vector(1 downto 0);
		m_axi_bvalid		: in std_logic;
		m_axi_bready		: out std_logic;
		m_axi_araddr		: out std_logic_vector(C_M_AXI_ADDR_WIDTH - 1 downto 0);
		m_axi_arprot		: out std_logic_vector(2 downto 0);
		m_axi_arvalid		: out std_logic;
		m_axi_arready		: in std_logic;
		m_axi_rdata		: in std_logic_vector(C_AXI_DATA_WIDTH - 1 downto 0);
		m_axi_rresp		: in std_logic_vector(1 downto 0);
		m_axi_rvalid		: in std_logic;
		m_axi_rready		: out std_logic;

		xgmii_rxc : in STD_LOGIC_VECTOR (7 downto 0);
		xgmii_rxd : in STD_LOGIC_VECTOR (63 downto 0);
		xgmii_txc : out STD_LOGIC_VECTOR (7 downto 0);
		xgmii_txd : out STD_LOGIC_VECTOR (63 downto 0);
		xgmii_tx_clk : in std_logic;
		xgmii_rx_clk : in std_logic			
	);
end component xgbe;

  signal xgmii_tx_clk, xgmii_rx_clk : std_logic := '0';
  signal clk_156_25MHz, clk_20MHz, rst_clk_156_25MHz, rst_clk_20MHz : std_logic := '0';
  signal interrupt : std_logic := '0';
  signal s_axi_aclk, s_axi_aresetn, s_axi_arready, s_axi_arvalid, s_axi_awready, s_axi_awvalid : std_logic := '0';
  signal s_axi_bready, s_axi_bvalid, s_axi_rready, s_axi_rvalid, s_axi_wready, s_axi_wvalid : std_logic := '0';
  signal s_axi_rdata, s_axi_wdata : std_logic_vector(31 downto 0) := (others => '0');
  signal s_axi_wstrb : std_logic_vector(3 downto 0) := (others => '0');
  signal s_axi_araddr, s_axi_awaddr : std_logic_vector(4 downto 0) := (others => '0');
  signal s_axi_arprot, s_axi_awprot : std_logic_vector(2 downto 0) := (others => '0');
  signal s_axi_bresp, s_axi_rresp : std_logic_vector(1 downto 0) := (others => '0');

  signal m_axi_aclk, m_axi_aresetn, m_axi_arready, m_axi_arvalid, m_axi_awready, m_axi_awvalid : std_logic := '0';
  signal m_axi_bready, m_axi_bvalid, m_axi_rready, m_axi_rvalid, m_axi_wready, m_axi_wvalid : std_logic := '0';
  signal m_axi_rdata, m_axi_wdata : std_logic_vector(31 downto 0) := (others => '0');
  signal m_axi_wstrb : std_logic_vector(3 downto 0) := (others => '0');
  signal m_axi_araddr, m_axi_awaddr : std_logic_vector(31 downto 0) := (others => '0');
  signal m_axi_arprot, m_axi_awprot : std_logic_vector(2 downto 0) := (others => '0');
  signal m_axi_bresp, m_axi_rresp : std_logic_vector(1 downto 0) := (others => '0');
  
  signal xgmii_rxd, xgmii_txd : std_logic_vector(63 downto 0) := (others => '0');
  signal xgmii_rxc, xgmii_txc : std_logic_vector(7 downto 0) := (others => '0');

  signal ReadIt, SendIt : std_logic := '0';
  shared variable cnt : integer := 0;

  signal TO_READ : std_logic_vector(31 downto 0) := (others => '0');

begin

block_design_i: xgbe
     port map (
       clk_156_25MHz => clk_156_25MHz,
       rst_clk_156_25MHz => rst_clk_156_25MHz,
	   clk_20MHz => clk_20MHz,
	   rst_clk_20MHz => rst_clk_20MHz,

      interrupt => interrupt,

      s_axi_aclk => s_axi_aclk,
      s_axi_araddr => s_axi_araddr,
      s_axi_aresetn => s_axi_aresetn,
      s_axi_arprot(2 downto 0) => s_axi_arprot(2 downto 0),
      s_axi_arready => s_axi_arready,
      s_axi_arvalid => s_axi_arvalid,
      s_axi_awaddr => s_axi_awaddr,
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
      s_axi_wvalid => s_axi_wvalid,

      m_axi_aclk => m_axi_aclk,
      m_axi_araddr => m_axi_araddr,
      m_axi_aresetn => m_axi_aresetn,
      m_axi_arprot(2 downto 0) => m_axi_arprot(2 downto 0),
      m_axi_arready => m_axi_arready,
      m_axi_arvalid => m_axi_arvalid,
      m_axi_awaddr => m_axi_awaddr,
      m_axi_awprot(2 downto 0) => m_axi_awprot(2 downto 0),
      m_axi_awready => m_axi_awready,
      m_axi_awvalid => m_axi_awvalid,
      m_axi_bready => m_axi_bready,
      m_axi_bresp(1 downto 0) => m_axi_bresp(1 downto 0),
      m_axi_bvalid => m_axi_bvalid,
      m_axi_rdata(31 downto 0) => m_axi_rdata(31 downto 0),
      m_axi_rready => m_axi_rready,
      m_axi_rresp(1 downto 0) => m_axi_rresp(1 downto 0),
      m_axi_rvalid => m_axi_rvalid,
      m_axi_wdata(31 downto 0) => m_axi_wdata(31 downto 0),
      m_axi_wready => m_axi_wready,
      m_axi_wstrb(3 downto 0) => m_axi_wstrb(3 downto 0),
      m_axi_wvalid => m_axi_wvalid,

      xgmii_rxd => xgmii_rxd,
      xgmii_txd => xgmii_txd,
      xgmii_rxc => xgmii_rxc,
      xgmii_txc => xgmii_txc,
      xgmii_tx_clk => xgmii_tx_clk,
      xgmii_rx_clk => xgmii_rx_clk
);

process begin
	wait for 1 ns;
	while true loop
		xgmii_tx_clk <= '0';
		wait for 3.2 ns;
		xgmii_tx_clk <= '1';
		wait for 3.2 ns;
	end loop;
end process;

process begin
	wait for 1.3 ns;
	while true loop
		xgmii_rx_clk <= '1';
		wait for 3.2 ns;
		xgmii_rx_clk <= '0';
		wait for 3.2 ns;
	end loop;
end process;

process begin
    s_axi_aclk <= '0';
	m_axi_aclk <= '0';
    wait for 5 ns;
    s_axi_aclk <= '1';
	m_axi_aclk <= '1';
    wait for 5 ns;
end process;
 
process begin
	clk_156_25MHz <= '1';
	wait for 3.2 ns;
	clk_156_25MHz <= '0';
	wait for 3.2 ns;
end process;

process begin
	clk_20MHz <= '1';
	wait for 25 ns;
	clk_20MHz <= '0';
	wait for 25 ns;
end process;

process begin
	s_axi_aresetn <= '0';
	m_axi_aresetn <= '0';
	rst_clk_156_25MHz <= '0';
	rst_clk_20MHz <= '0';
	wait for 6.4 ns;
	rst_clk_156_25MHz <= '1';
	wait for 3.6 ns;
	m_axi_aresetn <= '1';
	s_axi_aresetn <= '1';
	wait for 40 ns;
	rst_clk_20MHz <= '1';
	wait;
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
     
m_write : process
begin
	loop
		wait until m_axi_awvalid = '1';
		wait until m_axi_wvalid = '1';
		wait until m_axi_awready = '1';
		wait until m_axi_wready = '1';
		wait for 10 ns;
		m_axi_bvalid <= '1';
		wait for 10 ns;
		m_axi_bready <= '1';
		wait for 10 ns;
		m_axi_bvalid <= '0';
		m_axi_bready <= '0';
	end loop;
end process m_write;

m_read : process
begin
	wait until m_axi_arvalid = '1';
	wait for 1 ns;
	m_axi_arready <= '1';
	wait for 10 ns;
	m_axi_arready <= '0';
	m_axi_rdata <= TO_READ;
	m_axi_rvalid <= '1';
	wait until m_axi_rready <= '1';
	wait for 10 ns;
	m_axi_rvalid <= '0';
end process m_read;
 
process
	variable to_add : integer := 0;
begin
	wait until rst_clk_20MHz = '1';
	wait for 30 ns;
 	s_axi_awaddr<="01000";
	s_axi_wdata<=x"00000001";
	s_axi_wstrb<=b"1111";
	sendit<='1';                --start axi write to slave
	wait for 1 ns; 
	sendit<='0'; --clear start send flag
	wait until s_axi_bvalid = '1';
	wait until s_axi_bvalid = '0';  --axi write finished
	s_axi_wstrb<=b"0000";

	wait for 100 ns;
    
 	s_axi_awaddr<="01000";
	s_axi_wdata<=x"00000006";
	s_axi_wstrb<=b"1111";
	sendit<='1';                --start axi write to slave
	wait for 1 ns; 
	sendit<='0'; --clear start send flag
	wait until s_axi_bvalid = '1';
	wait until s_axi_bvalid = '0';  --axi write finished
	s_axi_wstrb<=b"0000";


 	s_axi_awaddr<="01000";
	s_axi_wdata<=x"00000006";
	s_axi_wstrb<=b"1111";
	sendit<='1';                --start axi write to slave
	wait for 1 ns; 
	sendit<='0'; --clear start send flag
	wait until s_axi_bvalid = '1';
	wait until s_axi_bvalid = '0';  --axi write finished
	s_axi_wstrb<=b"0000";

	--Write TX descriptor ring start address. 64.
 	s_axi_awaddr<="10000";
	s_axi_wdata<=x"00000040";
	s_axi_wstrb<=b"1111";
	sendit<='1';                --start axi write to slave
	wait for 1 ns; 
	sendit<='0'; --clear start send flag
	wait until s_axi_bvalid = '1';
	wait until s_axi_bvalid = '0';  --axi write finished
	s_axi_wstrb<=b"0000";
	
	--Write TX descriptor ring size in bytes. 64, (8 descriptors).
 	s_axi_awaddr<="10100";
	s_axi_wdata<=x"00000040";
	s_axi_wstrb<=b"1111";
	sendit<='1';                --start axi write to slave
	wait for 1 ns; 
	sendit<='0'; --clear start send flag
	wait until s_axi_bvalid = '1';
	wait until s_axi_bvalid = '0';  --axi write finished
	s_axi_wstrb<=b"0000";

	--Enable DMA, interrupt and data reception.
 	s_axi_awaddr<="01000";
	s_axi_wdata<=x"0000000E";
	s_axi_wstrb<=b"1111";
	sendit<='1';                --start axi write to slave
	wait for 1 ns; 
	sendit<='0'; --clear start send flag
	wait until s_axi_bvalid = '1';
	wait until s_axi_bvalid = '0';  --axi write finished
	s_axi_wstrb<=b"0000";
	while (true) loop
		for i in 0 to 7 loop
			--Trigger byte transmission.
		 	s_axi_awaddr<="11100";
			s_axi_wdata<=x"FFFFFFFF";
			s_axi_wstrb<=b"1111";
			sendit<='1';                --start axi write to slave
			wait for 1 ns; 
			sendit<='0'; --clear start send flag
			wait until s_axi_bvalid = '1';
			wait until s_axi_bvalid = '0';  --axi write finished
			s_axi_wstrb<=b"0000";
			
			--Packet size
			wait until m_axi_arvalid = '1';
			TO_READ <= std_logic_vector(to_unsigned(56 + i, 32));
			wait until m_axi_rready = '1';
			wait until m_axi_rready = '0';

			--Packet address
			wait until m_axi_arvalid = '1';
			TO_READ <= std_logic_vector(to_unsigned(1024 + 128 * i + 2, 32));
			wait until m_axi_rready = '1';
			wait until m_axi_rready = '0';	
			
			if (i >= 1 and i <= 4) then
				to_add := 1;
			elsif (i >= 5 and i <= 8) then
				to_add := 2;
			else
				to_add := 0;
			end if;

			for j in 0 to 14 + to_add loop
				wait until m_axi_arvalid = '1';
				TO_READ <= std_logic_vector(to_unsigned(16#00010000# 
									+ j * 16#00010001#
									+ i * 16#10001000#, 32));
				wait until m_axi_rready = '1';
				wait until m_axi_rready = '0';			
			end loop;
			if (i = 3) then	
				--Read used descriptors count.
				wait for 40 ns;
	 			s_axi_araddr<="11000";	
				readit<='1';
				wait for 1 ns; 
				readit<='0'; 
				wait until s_axi_rready = '1';
				wait until s_axi_rready = '0';
			end if;
		end loop;
		wait for 200 ns; 
		--Read used descriptors count.
	 	s_axi_araddr<="11000";	
		readit<='1';
		wait for 1 ns; 
		readit<='0'; 
		wait until s_axi_rready = '1';
		wait until s_axi_rready = '0';
	end loop;
end process;
 
end structure;
