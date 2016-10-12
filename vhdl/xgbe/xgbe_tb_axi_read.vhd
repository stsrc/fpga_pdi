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
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
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
		s_axi_rready	: in std_logic;
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
  signal s_axi_araddr, s_axi_awaddr, s_axi_wstrb : std_logic_vector(3 downto 0) := (others => '0');
  signal s_axi_arprot, s_axi_awprot : std_logic_vector(2 downto 0) := (others => '0');
  signal s_axi_bresp, s_axi_rresp : std_logic_vector(1 downto 0) := (others => '0');
  
  signal xgmii_rxd, xgmii_txd : std_logic_vector(63 downto 0) := (others => '0');
  signal xgmii_rxc, xgmii_txc : std_logic_vector(7 downto 0) := (others => '0');

  signal ReadIt, SendIt : std_logic := '0';
	shared variable packet_cnt : integer := 0;
	shared variable bytes_cnt  : integer := 0;
	shared variable read_cnt   : integer := 0;


	type column_typ is record
                       d : std_logic_vector(63 downto 0);
                       c : std_logic_vector(7 downto 0);
                     end record;

	type column_array_typ is array (natural range <>) of column_typ;

	type frame_typ is record
                      stim : column_array_typ(0 to 31);
                      length : integer;
                    end record;

	type frame_typ_array is array (natural range 0 to 3) of frame_typ;

	constant frame_data : frame_typ_array := (
	
	0 => (
	stim => (
	0 => ( d => X"555555fb07070707", c => "00011111"),
	1 => ( d => X"00000000d5555555", c => X"00"),
	2 => ( d => X"0000000000000000", c => X"00"),
	3 => ( d => X"0000000000000000", c => X"00"),
	4 => ( d => X"0000000000000000", c => X"00"),
	5 => ( d => X"0000000000000000", c => X"00"),
	6 => ( d => X"0000000000000000", c => X"00"),
	7 => ( d => X"0000000000000000", c => X"00"),
	8 => ( d => X"0000000000000000", c => X"00"),
	9 => ( d => X"758d633600000000", c => X"00"),
	10 => ( d => X"07070707070707fd", c => X"FF"),
	11 => ( d => X"0707070707070707", c => X"FF"),
	12 => ( d => X"0707070707070707", c => X"FF"),
	13 => ( d => X"0707070707070707", c => X"FF"),
	14 => ( d => X"0707070707070707", c => X"FF"),
	15 => ( d => X"0707070707070707", c => X"FF"),
	16 => ( d => X"0707070707070707", c => X"FF"),
	17 => ( d => X"0707070707070707", c => X"FF"),
	18 => ( d => X"0707070707070707", c => X"FF"),
	19 => ( d => X"0707070707070707", c => X"FF"),
	20 => ( d => X"0707070707070707", c => X"FF"),
	21 => ( d => X"0707070707070707", c => X"FF"),
	22 => ( d => X"0707070707070707", c => X"FF"),
	23 => ( d => X"0707070707070707", c => X"FF"),
	24 => ( d => X"0707070707070707", c => X"FF"),
	25 => ( d => X"0707070707070707", c => X"FF"),
	26 => ( d => X"0707070707070707", c => X"FF"),
	27 => ( d => X"0707070707070707", c => X"FF"),
	28 => ( d => X"0707070707070707", c => X"FF"),
	29 => ( d => X"0707070707070707", c => X"FF"),
	30 => ( d => X"0707070707070707", c => X"FF"),
	31 => ( d => X"0707070707070707", c => X"FF")),
	length => 11),
	1 => (
	stim => (
	0 => ( d => X"555555fb07070707", c => "00011111"),
	1 => ( d => X"ffffffffd5555555", c => X"00"),
	2 => ( d => X"ffffffffffffffff", c => X"00"),
	3 => ( d => X"ffffffffffffffff", c => X"00"),
	4 => ( d => X"ffffffffffffffff", c => X"00"),
	5 => ( d => X"ffffffffffffffff", c => X"00"),
	6 => ( d => X"ffffffffffffffff", c => X"00"),
	7 => ( d => X"ffffffffffffffff", c => X"00"),
	8 => ( d => X"ffffffffffffffff", c => X"00"),
	9 => ( d => X"BB3B15ffffffffff", c => X"00"),
	10 => ( d => X"070707070707fdD4", c => "11111110"),
	11 => ( d => X"0707070707070707", c => X"FF"),
	12 => ( d => X"0707070707070707", c => X"FF"),
	13 => ( d => X"0707070707070707", c => X"FF"),
	14 => ( d => X"0707070707070707", c => X"FF"),
	15 => ( d => X"0707070707070707", c => X"FF"),
	16 => ( d => X"0707070707070707", c => X"FF"),
	17 => ( d => X"0707070707070707", c => X"FF"),
	18 => ( d => X"0707070707070707", c => X"FF"),
	19 => ( d => X"0707070707070707", c => X"FF"),
	20 => ( d => X"0707070707070707", c => X"FF"),
	21 => ( d => X"0707070707070707", c => X"FF"),
	22 => ( d => X"0707070707070707", c => X"FF"),
	23 => ( d => X"0707070707070707", c => X"FF"),
	24 => ( d => X"0707070707070707", c => X"FF"),
	25 => ( d => X"0707070707070707", c => X"FF"),
	26 => ( d => X"0707070707070707", c => X"FF"),
	27 => ( d => X"0707070707070707", c => X"FF"),
	28 => ( d => X"0707070707070707", c => X"FF"),
	29 => ( d => X"0707070707070707", c => X"FF"),
	30 => ( d => X"0707070707070707", c => X"FF"),
	31 => ( d => X"0707070707070707", c => X"FF")),
	length => 11),
	2 => (
	stim => (
	0 => ( d => X"555555fb07070707", c => "00011111"),
	1 => ( d => X"ffffffffd5555555", c => X"00"),
	2 => ( d => X"ffffffffffffffff", c => X"00"),
	3 => ( d => X"ffffffffffffffff", c => X"00"),
	4 => ( d => X"ffffffffffffffff", c => X"00"),
	5 => ( d => X"ffffffffffffffff", c => X"00"),
	6 => ( d => X"ffffffffffffffff", c => X"00"),
	7 => ( d => X"ffffffffffffffff", c => X"00"),
	8 => ( d => X"ffffffffffffffff", c => X"00"),
	9 => ( d => X"fd6E14FE90ffffff", c => "10000000"),
	10 => ( d => X"0707070707070707", c => X"FF"),
	11 => ( d => X"0707070707070707", c => X"FF"),
	12 => ( d => X"0707070707070707", c => X"FF"),
	13 => ( d => X"0707070707070707", c => X"FF"),
	14 => ( d => X"0707070707070707", c => X"FF"),
	15 => ( d => X"0707070707070707", c => X"FF"),
	16 => ( d => X"0707070707070707", c => X"FF"),
	17 => ( d => X"0707070707070707", c => X"FF"),
	18 => ( d => X"0707070707070707", c => X"FF"),
	19 => ( d => X"0707070707070707", c => X"FF"),
	20 => ( d => X"0707070707070707", c => X"FF"),
	21 => ( d => X"0707070707070707", c => X"FF"),
	22 => ( d => X"0707070707070707", c => X"FF"),
	23 => ( d => X"0707070707070707", c => X"FF"),
	24 => ( d => X"0707070707070707", c => X"FF"),
	25 => ( d => X"0707070707070707", c => X"FF"),
	26 => ( d => X"0707070707070707", c => X"FF"),
	27 => ( d => X"0707070707070707", c => X"FF"),
	28 => ( d => X"0707070707070707", c => X"FF"),
	29 => ( d => X"0707070707070707", c => X"FF"),
	30 => ( d => X"0707070707070707", c => X"FF"),
	31 => ( d => X"0707070707070707", c => X"FF")),
	length => 10),
	3 => (
	stim => (
	0 => ( d => X"555555fb07070707", c => "00011111"),
	1 => ( d => X"f0f0f0f0d5555555", c => X"00"),
	2 => ( d => X"f0f0f0f0f0f0f0f0", c => X"00"),
	3 => ( d => X"f0f0f0f0f0f0f0f0", c => X"00"),
	4 => ( d => X"f0f0f0f0f0f0f0f0", c => X"00"),
	5 => ( d => X"f0f0f0f0f0f0f0f0", c => X"00"),
	6 => ( d => X"f0f0f0f0f0f0f0f0", c => X"00"),
	7 => ( d => X"f0f0f0f0f0f0f0f0", c => X"00"),
	8 => ( d => X"f0f0f0f0f0f0f0f0", c => X"00"),
	9 => ( d => X"E97357f0f0f0f0f0", c => X"00"),
	10 => ( d => X"070707070707fdD8", c => "11111110"),
	11 => ( d => X"0707070707070707", c => X"FF"),
	12 => ( d => X"0707070707070707", c => X"FF"),
	13 => ( d => X"0707070707070707", c => X"FF"),
	14 => ( d => X"0707070707070707", c => X"FF"),
	15 => ( d => X"0707070707070707", c => X"FF"),
	16 => ( d => X"0707070707070707", c => X"FF"),
	17 => ( d => X"0707070707070707", c => X"FF"),
	18 => ( d => X"0707070707070707", c => X"FF"),
	19 => ( d => X"0707070707070707", c => X"FF"),
	20 => ( d => X"0707070707070707", c => X"FF"),
	21 => ( d => X"0707070707070707", c => X"FF"),
	22 => ( d => X"0707070707070707", c => X"FF"),
	23 => ( d => X"0707070707070707", c => X"FF"),
	24 => ( d => X"0707070707070707", c => X"FF"),
	25 => ( d => X"0707070707070707", c => X"FF"),
	26 => ( d => X"0707070707070707", c => X"FF"),
	27 => ( d => X"0707070707070707", c => X"FF"),
	28 => ( d => X"0707070707070707", c => X"FF"),
	29 => ( d => X"0707070707070707", c => X"FF"),
	30 => ( d => X"0707070707070707", c => X"FF"),
	31 => ( d => X"0707070707070707", c => X"FF")),
	length => 11));

begin

block_design_i: xgbe
     port map (
       clk_156_25MHz => clk_156_25MHz,
       rst_clk_156_25MHz => rst_clk_156_25MHz,
	   clk_20MHz => clk_20MHz,
	   rst_clk_20MHz => rst_clk_20MHz,

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
      s_axi_wvalid => s_axi_wvalid,
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
    wait for 5 ns;
    s_axi_aclk <= '1';
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
	rst_clk_156_25MHz <= '0';
	rst_clk_20MHz <= '0';
	wait for 6.4 ns;
	rst_clk_156_25MHz <= '1';
	wait for 3.6 ns;
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
      
process
begin
	wait until rst_clk_20MHz = '1';
	wait for 30 ns;
 	s_axi_awaddr<="1000";
	s_axi_wdata<=x"00000001";
	s_axi_wstrb<=b"1111";
	sendit<='1';                --start axi write to slave
	wait for 1 ns; 
	sendit<='0'; --clear start send flag
	wait until s_axi_bvalid = '1';
	wait until s_axi_bvalid = '0';  --axi write finished
	s_axi_wstrb<=b"0000";

	wait for 100 ns;
    
 	s_axi_awaddr<="1000";
	s_axi_wdata<=x"00000002";
	s_axi_wstrb<=b"1111";
	sendit<='1';                --start axi write to slave
	wait for 1 ns; 
	sendit<='0'; --clear start send flag
	wait until s_axi_bvalid = '1';
	wait until s_axi_bvalid = '0';  --axi write finished
	s_axi_wstrb<=b"0000";
	wait;
end process;

process begin
	for i in 0 to 3 loop	
		xgmii_rxd <= x"0707070707070707";
		xgmii_rxc <= x"ff";
		wait until rising_edge(clk_156_25MHz);

		for j in 0 to frame_data(i).length - 1 loop
			xgmii_rxd <= frame_data(i).stim(j).d;
			xgmii_rxc <= frame_data(i).stim(j).c;
			wait until rising_edge(clk_156_25MHz);
		end loop;
	end loop;	
end process;


process begin
	wait until interrupt = '1';
	s_axi_araddr<="1100";
	readit<='1';               
	wait for 1 ns; 
	readit<='0';
	wait until s_axi_rready = '1';
	wait until s_axi_rready = '0';
	packet_cnt := to_integer(unsigned(s_axi_rdata));
	
        assert packet_cnt /= 0 report "packet_cnt = 0" severity failure;

		for k in 0 to packet_cnt - 1 loop
		s_axi_araddr<="0000";
		readit<='1';
		wait for 1 ns; 
		readit<='0';
		wait until s_axi_rready = '1';
		wait until s_axi_rready = '0';
  		bytes_cnt := to_integer(unsigned(s_axi_rdata));

		if (bytes_cnt = 64) then
			read_cnt := 15;
		elsif (bytes_cnt = 63) then
			read_cnt := 15;
		elsif (bytes_cnt = 65) then
			read_cnt := 17;
		else
			read_cnt := 0;
		end if;
 
		-- read those packets
		s_axi_araddr<="0100";    
		for i in 0 to read_cnt loop
			readit<='1';
			wait for 1 ns; 
			readit<='0';
			wait until s_axi_rready = '1';
			wait until s_axi_rready = '0';
		end loop; 
	end loop;
end process tb;   
     
end structure;
