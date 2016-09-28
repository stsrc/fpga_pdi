library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity fsm_fifo_to_axi_tb is

end fsm_fifo_to_axi_tb;

architecture Behavioral of fsm_fifo_to_axi_tb is
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
end component fsm_fifo_to_axi;

signal clk, resetn, data_from_fifo_strb, data_to_axi_strb : std_logic := '0';
signal cnt_from_fifo_strb, cnt_to_axi_strb : std_logic := '0';
signal data_from_fifo : std_logic_vector(63 downto 0) := (others => '0');
signal data_to_axi, cnt_to_axi : std_logic_vector(31 downto 0) := (others => '0');
signal cnt_from_fifo : std_logic_vector(13 downto 0);

begin
fsm1 : fsm_fifo_to_axi 
	port map  (
		clk => clk, 
		resetn => resetn, 
		data_from_fifo => data_from_fifo, 
		data_from_fifo_strb => data_from_fifo_strb,
		data_to_axi => data_to_axi, 
		data_to_axi_strb => data_to_axi_strb, 
		cnt_from_fifo => cnt_from_fifo,
		cnt_from_fifo_strb => cnt_from_fifo_strb,
		cnt_to_axi => cnt_to_axi, 
		cnt_to_axi_strb => cnt_to_axi_strb
	);

process begin
clk <= '0';
wait for 5 ns;
clk <= '1';
wait for 5 ns;
end process;

process begin
cnt_from_fifo <= (others => '1');
resetn <= '0';
wait for 15 ns;
resetn <= '1';
data_from_fifo <= "1000000010000000100000001000000000000001000000010000000100000001";
wait for 10 ns; --fifo_strb = '0';
data_to_axi_strb <= '1';
cnt_to_axi_strb <= '1';
wait for 10 ns; --fifo_strb = '1';
wait for 10 ns; --fifo_strb = '0';
data_to_axi_strb <= '0';
cnt_to_axi_strb <= '0';
wait; --fifo_strb = '0';
end process;
end Behavioral;
