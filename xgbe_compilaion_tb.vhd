----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/01/2016 08:33:40 PM
-- Design Name: 
-- Module Name: xgbe_compilation_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity xgbe_compilation_tb is
--  Port ( );
end xgbe_compilation_tb;

architecture Behavioral of xgbe_compilation_tb is

component xgbe_compilation_wrapper is
  port (
    interrupt : out STD_LOGIC;
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
end component xgbe_compilation_wrapper;
  signal interrupt : std_logic := '0';
  signal s00_axi_aclk, s00_axi_aresetn, s00_axi_arready, s00_axi_arvalid, s00_axi_awready, s00_axi_awvalid : std_logic := '0';
  signal s00_axi_bready, s00_axi_bvalid, s00_axi_rready, s00_axi_rvalid, s00_axi_wready, s00_axi_wvalid : std_logic := '0';

  signal s00_axi_rdata, s00_axi_wdata : std_logic_vector(31 downto 0) := (others => '0');
  signal s00_axi_araddr, s00_axi_awaddr, s00_axi_wstrb : std_logic_vector(3 downto 0) := (others => '0');
  signal pkt_rx_mod, s00_axi_arprot, s00_axi_awprot : std_logic_vector(2 downto 0) := (others => '0');
  signal s00_axi_bresp, s00_axi_rresp : std_logic_vector(1 downto 0) := (others => '0');
  
  signal ReadIt, SendIt : std_logic := '0';
begin

xgbe_compilation_wrapper_1 : xgbe_compilation_wrapper port map
(
interrupt => interrupt,
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
wait for 5ns;
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

  process begin

    S00_AXI_ARESETN <= '0';
    wait for 10 ns;
    S00_AXI_ARESETN <= '1';

	S00_AXI_AWADDR<="1100";
    S00_AXI_WDATA<=x"00010010";
    S00_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	wait until S00_AXI_BVALID = '1';
	wait until S00_AXI_BVALID = '0';  --AXI Write finished
    S00_AXI_WSTRB<=b"0000";

	S00_AXI_AWADDR<="1100";
    S00_AXI_WDATA<=x"00000100";
    S00_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	wait until S00_AXI_BVALID = '1';
	wait until S00_AXI_BVALID = '0';  --AXI Write finished
    S00_AXI_WSTRB<=b"0000";

	S00_AXI_AWADDR<="1100";
    S00_AXI_WDATA<=x"88b50001";
    S00_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	wait until S00_AXI_BVALID = '1';
	wait until S00_AXI_BVALID = '0';  --AXI Write finished
    S00_AXI_WSTRB<=b"0000";

	S00_AXI_AWADDR<="1100";
    S00_AXI_WDATA<=x"94000002";
    S00_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	wait until S00_AXI_BVALID = '1';
	wait until S00_AXI_BVALID = '0';  --AXI Write finished
    S00_AXI_WSTRB<=b"0000";

	S00_AXI_AWADDR<="1100";
    S00_AXI_WDATA<=x"06070809";
    S00_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	wait until S00_AXI_BVALID = '1';
	wait until S00_AXI_BVALID = '0';  --AXI Write finished
    S00_AXI_WSTRB<=b"0000";

	S00_AXI_AWADDR<="1100";
    S00_AXI_WDATA<=x"02030405";
    S00_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	wait until S00_AXI_BVALID = '1';
	wait until S00_AXI_BVALID = '0';  --AXI Write finished
    S00_AXI_WSTRB<=b"0000";

	S00_AXI_AWADDR<="1100";
    S00_AXI_WDATA<=x"0e0f1011";
    S00_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	wait until S00_AXI_BVALID = '1';
	wait until S00_AXI_BVALID = '0';  --AXI Write finished
    S00_AXI_WSTRB<=b"0000";

	S00_AXI_AWADDR<="1100";
    S00_AXI_WDATA<=x"0a0b0c0d";
    S00_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	wait until S00_AXI_BVALID = '1';
	wait until S00_AXI_BVALID = '0';  --AXI Write finished
    S00_AXI_WSTRB<=b"0000";

	S00_AXI_AWADDR<="1100";
    S00_AXI_WDATA<=x"16171819";
    S00_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	wait until S00_AXI_BVALID = '1';
	wait until S00_AXI_BVALID = '0';  --AXI Write finished
    S00_AXI_WSTRB<=b"0000";


	S00_AXI_AWADDR<="1100";
    S00_AXI_WDATA<=x"12131415";
    S00_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	wait until S00_AXI_BVALID = '1';
	wait until S00_AXI_BVALID = '0';  --AXI Write finished
    S00_AXI_WSTRB<=b"0000";

	S00_AXI_AWADDR<="1100";
    S00_AXI_WDATA<=x"1e1f2021";
    S00_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	wait until S00_AXI_BVALID = '1';
	wait until S00_AXI_BVALID = '0';  --AXI Write finished
    S00_AXI_WSTRB<=b"0000";

	S00_AXI_AWADDR<="1100";
    S00_AXI_WDATA<=x"1a1b1c1d";
    S00_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	wait until S00_AXI_BVALID = '1';
	wait until S00_AXI_BVALID = '0';  --AXI Write finished
    S00_AXI_WSTRB<=b"0000";

	S00_AXI_AWADDR<="1100";
    S00_AXI_WDATA<=x"26272829";
    S00_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	wait until S00_AXI_BVALID = '1';
	wait until S00_AXI_BVALID = '0';  --AXI Write finished
    S00_AXI_WSTRB<=b"0000";

	S00_AXI_AWADDR<="1100";
    S00_AXI_WDATA<=x"22232425";
    S00_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	wait until S00_AXI_BVALID = '1';
	wait until S00_AXI_BVALID = '0';  --AXI Write finished
    S00_AXI_WSTRB<=b"0000";

	S00_AXI_AWADDR<="1100";
    S00_AXI_WDATA<=x"2e2f3031";
    S00_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	wait until S00_AXI_BVALID = '1';
	wait until S00_AXI_BVALID = '0';  --AXI Write finished
    S00_AXI_WSTRB<=b"0000";

	S00_AXI_AWADDR<="1100";
    S00_AXI_WDATA<=x"2a2b2c2d";
    S00_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	wait until S00_AXI_BVALID = '1';
	wait until S00_AXI_BVALID = '0';  --AXI Write finished
    S00_AXI_WSTRB<=b"0000";

	S00_AXI_AWADDR<="1000";
    S00_AXI_WDATA<=x"00000040";
    S00_AXI_WSTRB<=b"1111";
    sendIt<='1';                --Start AXI Write to Slave
    wait for 1 ns; sendIt<='0'; --Clear Start Send Flag
	wait until S00_AXI_BVALID = '1';
	wait until S00_AXI_BVALID = '0';  --AXI Write finished
    S00_AXI_WSTRB<=b"0000";

wait until interrupt = '1';

    S00_AXI_ARADDR<="0000";
        readIt<='1';                --Start AXI Read from Slave
        wait for 1 ns; 
       readIt<='0';                --Clear "Start Read" Flag
    wait until S00_AXI_RREADY = '1';
    wait until S00_AXI_RREADY = '0';    --AXI_DATA should be equal to 17
        S00_AXI_ARADDR<="0100";
   for i in 0 to 16 loop
        readIt<='1';                --Start AXI Read from Slave
        wait for 1 ns; 
       readIt<='0';                --Clear "Start Read" Flag
    wait until S00_AXI_RREADY = '1';    --AXI_DATA should be equal to 10000000...
    wait until S00_AXI_RREADY = '0';
    end loop;

     wait; -- will wait forever     

end process; 

end Behavioral;
