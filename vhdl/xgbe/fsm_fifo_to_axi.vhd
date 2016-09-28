library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity fsm_fifo_to_axi is
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
end fsm_fifo_to_axi;

architecture Behavioral of fsm_fifo_to_axi is
   
signal state, state_tmp : std_logic := '0';

begin
	cnt_to_axi(31 downto 14) <= (others => '0');
	cnt_to_axi(13 downto 0) <= cnt_from_fifo;
	cnt_from_fifo_strb <= cnt_to_axi_strb;
	
	process(clk, resetn) begin
	if (rising_edge(clk)) then
		if (resetn = '0') then
			state <= '0'; 
		else
			state <= state_tmp;
		end if;
	end if;
	end process;
	
	process(state, data_to_axi_strb, data_from_fifo) begin
	state_tmp <= state;
	data_from_fifo_strb <= '0';
	data_to_axi <= (others => '0');
	case state is
	
	when '0' =>
		data_to_axi <= data_from_fifo(31 downto 0);
		if (data_to_axi_strb = '1') then
			state_tmp <= '1';
		end if;
		
	when '1' =>
		data_to_axi <= data_from_fifo(63 downto 32);
		if (data_to_axi_strb = '1') then
			data_from_fifo_strb <= '1';
			state_tmp <= '0';
		end if;
		
	when others =>
		state_tmp <= '0';
		
	end case;
	end process;
end Behavioral;
