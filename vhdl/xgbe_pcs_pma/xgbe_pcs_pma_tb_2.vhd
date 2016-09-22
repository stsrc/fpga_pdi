library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity xgbe_pcs_pma_tb is
end xgbe_pcs_pma_tb;

architecture xgbe_pcs_pma_tb_arch of xgbe_pcs_pma_tb is

component xgbe_pcs_pma is
	port (
		clk_156_25MHz		: in std_logic;
		rst_clk_156_25MHz 	: in std_logic;
		clk_20MHz		: in std_logic;
		rst_clk_20MHz		: in std_logic;

		interrupt		: out std_logic;

		s_axi_aclk		: in std_logic;
		s_axi_aresetn		: in std_logic;
		s_axi_awaddr		: in std_logic_vector(3 downto 0);
		s_axi_awprot		: in std_logic_vector(2 downto 0);
		s_axi_awvalid		: in std_logic;
		s_axi_awready		: out std_logic;
		s_axi_wdata		: in std_logic_vector(31 downto 0);
		s_axi_wstrb		: in std_logic_vector(3 downto 0);
		s_axi_wvalid		: in std_logic;
		s_axi_wready		: out std_logic;
		s_axi_bresp		: out std_logic_vector(1 downto 0);
		s_axi_bvalid		: out std_logic;
		s_axi_bready		: in std_logic;
		s_axi_araddr		: in std_logic_vector(3 downto 0);
		s_axi_arprot		: in std_logic_vector(2 downto 0);
		s_axi_arvalid		: in std_logic;
		s_axi_arready		: out std_logic;
		s_axi_rdata		: out std_logic_vector(31 downto 0);
		s_axi_rresp		: out std_logic_vector(1 downto 0);
		s_axi_rvalid		: out std_logic;
		s_axi_rready		: in std_logic;
		rxp 			: in std_logic;
		rxn 			: in std_logic;
		txp 			: out std_logic;
		txn 			: out std_logic;
		coreclk_out		: out std_logic;
		core_status		: out std_logic_vector(7 downto 0);
		sim_speedup_control	: in std_logic;
		reset			: in std_logic;
		resetdone		: out std_logic
	);
end component;


  signal coreclk_out : std_logic := '0';
  signal core_status : std_logic_vector(7 downto 0) := (others => '0');
  signal sim_speedup_control, reset, resetdone : std_logic := '0';

  signal clk_156_25MHz, clk_20MHz, rst_clk_156_25MHz, rst_clk_20MHz : std_logic := '0';
  signal interrupt : std_logic := '0';
  signal s_axi_aclk, s_axi_aresetn, s_axi_arready, s_axi_arvalid, s_axi_awready, s_axi_awvalid : std_logic := '0';
  signal s_axi_bready, s_axi_bvalid, s_axi_rready, s_axi_rvalid, s_axi_wready, s_axi_wvalid : std_logic := '0';
  signal s_axi_rdata, s_axi_wdata : std_logic_vector(31 downto 0) := (others => '0');
  signal s_axi_araddr, s_axi_awaddr, s_axi_wstrb : std_logic_vector(3 downto 0) := (others => '0');
  signal s_axi_arprot, s_axi_awprot : std_logic_vector(2 downto 0) := (others => '0');
  signal s_axi_bresp, s_axi_rresp : std_logic_vector(1 downto 0) := (others => '0');



  signal coreclk_out_2 : std_logic := '0';
  signal core_status_2 : std_logic_vector(7 downto 0) := (others => '0');
  signal sim_speedup_control_2, reset_2, resetdone_2 : std_logic := '0';

  signal clk_156_25MHz_2, clk_20MHz_2, rst_clk_156_25MHz_2, rst_clk_20MHz_2 : std_logic := '0';
  signal interrupt_2 : std_logic := '0';
  signal s_axi_aclk_2, s_axi_aresetn_2, s_axi_arready_2, s_axi_arvalid_2, s_axi_awready_2, s_axi_awvalid_2 : std_logic := '0';
  signal s_axi_bready_2, s_axi_bvalid_2, s_axi_rready_2, s_axi_rvalid_2, s_axi_wready_2, s_axi_wvalid_2 : std_logic := '0';
  signal s_axi_rdata_2, s_axi_wdata_2 : std_logic_vector(31 downto 0) := (others => '0');
  signal s_axi_araddr_2, s_axi_awaddr_2, s_axi_wstrb_2 : std_logic_vector(3 downto 0) := (others => '0');
  signal s_axi_arprot_2, s_axi_awprot_2 : std_logic_vector(2 downto 0) := (others => '0');
  signal s_axi_bresp_2, s_axi_rresp_2 : std_logic_vector(1 downto 0) := (others => '0');


  signal rxp, rxn, txp, txn : std_logic := '0';
  signal rxp_2, rxn_2, txp_2, txn_2 : std_logic := '0';

  signal ReadIt, SendIt : std_logic := '0';
  signal ReadIt_2, SendIt_2 : std_logic := '0';

  constant BITPERIOD : time := 98 ps;
  constant PERIODCORECLK : time := 66*98 ps; 


begin
	xgbe_pcs_pma_0 : xgbe_pcs_pma
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
		rxp => rxp,
		rxn => rxn,
		txp => txp,
		txn => txn,
		coreclk_out => coreclk_out,
		core_status => core_status,
		sim_speedup_control => sim_speedup_control,
		reset => reset,
		resetdone => resetdone
	);

	xgbe_pcs_pma_1 : xgbe_pcs_pma
	port map (
		clk_156_25MHz => clk_156_25MHz_2,
		rst_clk_156_25MHz => rst_clk_156_25MHz_2,
		clk_20MHz => clk_20MHz_2,
		rst_clk_20MHz => rst_clk_20MHz_2,
		interrupt => interrupt_2,
		s_axi_aclk => s_axi_aclk_2,
      		s_axi_araddr(3 downto 0) => s_axi_araddr_2(3 downto 0),
      		s_axi_aresetn => s_axi_aresetn_2,
		s_axi_arprot(2 downto 0) => s_axi_arprot_2(2 downto 0),
		s_axi_arready => s_axi_arready_2,
		s_axi_arvalid => s_axi_arvalid_2,
		s_axi_awaddr(3 downto 0) => s_axi_awaddr_2(3 downto 0),
		s_axi_awprot(2 downto 0) => s_axi_awprot_2(2 downto 0),
		s_axi_awready => s_axi_awready_2,
		s_axi_awvalid => s_axi_awvalid_2,
		s_axi_bready => s_axi_bready_2,
		s_axi_bresp(1 downto 0) => s_axi_bresp_2(1 downto 0),
		s_axi_bvalid => s_axi_bvalid_2,
		s_axi_rdata(31 downto 0) => s_axi_rdata_2(31 downto 0),
		s_axi_rready => s_axi_rready_2,
		s_axi_rresp(1 downto 0) => s_axi_rresp_2(1 downto 0),
		s_axi_rvalid => s_axi_rvalid_2,
		s_axi_wdata(31 downto 0) => s_axi_wdata_2(31 downto 0),
		s_axi_wready => s_axi_wready_2,
		s_axi_wstrb(3 downto 0) => s_axi_wstrb_2(3 downto 0),
		s_axi_wvalid => s_axi_wvalid_2,
		rxp => rxp_2,
		rxn => rxn_2,
		txp => txp_2,
		txn => txn_2,
		coreclk_out => coreclk_out_2,
		core_status => core_status_2,
		sim_speedup_control => sim_speedup_control_2,
		reset => reset_2,
		resetdone => resetdone_2
	);

  -- Generate the resets.
  reset_proc : process
  begin
    reset <= '0';
    rst_clk_156_25MHz <= '1';
    rst_clk_20MHz <= '1';
    s_axi_aresetn <= '1';
    reset_2 <= '0';
    rst_clk_156_25MHz_2 <= '1';
    rst_clk_20MHz_2 <= '1';
    s_axi_aresetn_2 <= '1';
    wait for 100 ns;
    reset <= '1';
    rst_clk_156_25MHz <= '0';
    rst_clk_20MHz <= '0';
    s_axi_aresetn <= '0';
    reset_2 <= '1';
    rst_clk_156_25MHz_2 <= '0';
    rst_clk_20MHz_2 <= '0';
    s_axi_aresetn_2 <= '0';
    wait for 100 ns;
    reset <= '0';
    rst_clk_156_25MHz <= '1';
    rst_clk_20MHz <= '1';
    s_axi_aresetn <= '1';
    reset_2 <= '0';
    rst_clk_156_25MHz_2 <= '1';
    rst_clk_20MHz_2 <= '1';
    s_axi_aresetn_2 <= '1';
    wait until coreclk_out = '1';
    sim_speedup_control <= '1';
    sim_speedup_control_2 <= '1';
    wait;
  end process reset_proc;

  -- Generate the 156.25MHz
  gen_refclk : process
  begin
    clk_156_25MHz <= '0';
    wait for PERIODCORECLK/2;
    clk_156_25MHz <= '1';
    wait for PERIODCORECLK/2;
  end process gen_refclk;

   clk_156_25MHz_2 <= clk_156_25MHz;

  --generate s_axi_aclk
  gen_s_axi_aclk : process
  begin
	s_axi_aclk <= '0';
	wait for 5 ns;
	s_axi_aclk <= '1';
	wait for 5 ns;
  end process gen_s_axi_aclk;
	s_axi_aclk_2 <= s_axi_aclk;

  gen_20MHz : process
  begin
	clk_20MHz <= '0';
	wait for 25 ns;
	clk_20MHz <= '1';
	wait for 25 ns;
  end process gen_20MHz;
  
	clk_20MHz_2 <= clk_20MHz;
	
  -- Serialize the RX stimulus
  rxn <= not(rxp);
  rxn_2 <= not(rxp_2);

  rxp_2 <= txp;
  rxp <= txp_2;

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

send_2 : process
 begin
    s_axi_awvalid_2<='0';
    s_axi_wvalid_2<='0';
    s_axi_bready_2<='0';
    loop
        wait until sendit_2 = '1';
        wait until s_axi_aclk_2= '0';
            s_axi_awvalid_2<='1';
            s_axi_wvalid_2<='1';
        wait until (s_axi_awready_2 and s_axi_wready_2) = '1';  --client ready to read address/data        
            s_axi_bready_2<='1';
        wait until s_axi_bvalid_2 = '1';  -- write result valid
            assert s_axi_bresp_2 = "00" report "axi data not written" severity failure;
            s_axi_awvalid_2<='0';
            s_axi_wvalid_2<='0';
            s_axi_bready_2<='1';
        wait until s_axi_bvalid_2 = '0';  -- all finished
            s_axi_bready_2<='0';
    end loop;
 end process send_2;

 read_2 : process
  begin
    s_axi_arvalid_2<='0';
    s_axi_rready_2<='0';
     loop
         wait until readit_2 = '1';
         wait until s_axi_aclk_2= '0';
             s_axi_arvalid_2<='1';
            wait until (s_axi_rvalid_2) = '1';  --client provided data (removed and s_axi_arready???)
            s_axi_rready_2<='1';
            s_axi_arvalid_2 <= '0';
            assert s_axi_rresp_2 = "00" report "axi data not written" severity failure;
            wait until (s_axi_rvalid_2) = '0';
            s_axi_rready_2<='0';
     end loop;
  end process read_2;


	working_process : process
	begin
		wait until core_status(0) = '1';

	for j in 0 to 9 loop
                s_axi_awaddr<="0100";
                    s_axi_wdata<=x"00000100";
                    s_axi_wstrb<=b"1111";
                     sendit<='1';                --start axi write to slave
                    wait for 1 ns; 
                    sendit<='0'; --clear start send flag
                wait until s_axi_bvalid = '1';
                wait until s_axi_bvalid = '0';  --axi write finished
                       s_axi_wstrb<=b"0000";
        
                s_axi_awaddr<="0100";
                s_axi_wdata<=x"00010010";
                s_axi_wstrb<=b"1111";
                sendit<='1';                --start axi write to slave
                wait for 1 ns; 
                sendit<='0'; --clear start send flag
               wait until s_axi_bvalid = '1';
               wait until s_axi_bvalid = '0';  --axi write finished
                s_axi_wstrb<=b"0000";  
        
               s_axi_awaddr<="0100";
                s_axi_wdata<=x"94000002";
                s_axi_wstrb<=b"1111";
                sendit<='1';                --start axi write to slave
                wait for 1 ns; 
                sendit<='0'; --clear start send flag
                wait until s_axi_bvalid = '1';
                wait until s_axi_bvalid = '0';  --axi write finished
                s_axi_wstrb<=b"0000";
        
                s_axi_awaddr<="0100";
                s_axi_wdata<=x"88b50001";
                s_axi_wstrb<=b"1111";
                sendit<='1';                --start axi write to slave
                wait for 1 ns; 
                sendit<='0'; --clear start send flag
               wait until s_axi_bvalid = '1';
               wait until s_axi_bvalid = '0';  --axi write finished
                s_axi_wstrb<=b"0000";
             
            for i in 0 to 7 loop
               s_axi_awaddr<="0100";
                s_axi_wdata<=x"ffffff00" or std_logic_vector(to_unsigned(i, 32) + to_unsigned(j, 32));
                s_axi_wstrb<=b"1111";
                sendit<='1';                --start axi write to slave
                wait for 1 ns; 
                sendit<='0'; --clear start send flag
                wait until s_axi_bvalid = '1';
                wait until s_axi_bvalid = '0';  --axi write finished
                s_axi_wstrb<=b"0000";
        
                s_axi_awaddr<="0100";
                s_axi_wdata<=x"f0000000" or std_logic_vector(to_unsigned(i, 32) + to_unsigned(j,32));
                s_axi_wstrb<=b"1111";
                sendit<='1';                --start axi write to slave
                wait for 1 ns; 
                sendit<='0'; --clear start send flag
               wait until s_axi_bvalid = '1';
               wait until s_axi_bvalid = '0';  --axi write finished
                s_axi_wstrb<=b"0000";
            end loop;
        
            s_axi_awaddr<="0000";
            s_axi_wdata<=x"00000040";
            s_axi_wstrb<=b"1111";
            sendit<='1';                --start axi write to slave
            wait for 1 ns; 
            sendit<='0'; --clear start send flag
            wait until s_axi_bvalid = '1';
            wait until s_axi_bvalid = '0';  --axi write finished
            s_axi_wstrb<=b"0000";
            
            wait until interrupt_2 = '1';
            
            s_axi_araddr_2<="0000";
                readit_2<='1';                --start axi read from slave
                wait for 1 ns; 
               readit_2<='0';                --clear "start read" flag
            wait until s_axi_rready_2 = '1';
            wait until s_axi_rready_2 = '0';    --axi_data should be equal to 17
            
                s_axi_araddr_2<="0100";    
           for i in 0 to 15 loop
                readit_2<='1';                --start axi read from slave
                wait for 1 ns; 
               readit_2<='0';                --clear "start read" flag
            wait until s_axi_rready_2 = '1';    --axi_data should be equal to 10000000...
            wait until s_axi_rready_2 = '0';
            end loop;
            end loop; 
    end process;


end xgbe_pcs_pma_tb_arch;
