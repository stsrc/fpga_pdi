--Control register.
--bit 0: reset bit - set to 1 to reset xgbe logic.
--bit 1: receive enable bit - set to 1 to enable data reception.
--bit 2: interrupt enable bit - set to 1 to enable interrupt generation.
--bit 3: DMA enable bit - set to 1 to enable DMA.
--reset - reserved.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_register is
	generic (
		DATA_WIDTH : integer := 32
	);

	port (
		clk 		: in std_logic;
		clk_resetn 	: in std_logic;
		reg_input 	: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		reg_strb 	: in std_logic;
		rcv_en		: out std_logic;
		int_en		: out std_logic;
		dma_en		: out std_logic;
		resetp		: out std_logic
	);
end control_register;

architecture control_register_arch of control_register is
signal reg, reg_tmp : std_logic_vector(DATA_WIDTH - 1 downto 0);
begin

	dma_en <= reg(3);
	int_en <= reg(2);
	rcv_en <= reg(1);
	resetp <= reg(0);

	process (clk) begin
		if (rising_edge(clk)) then
			if (clk_resetn = '0') then
				reg <= (others => '0');
			else
				reg <= reg_tmp;
			end if;
		end if;
	end process;

	process (reg_input, reg, reg_strb) begin
		reg_tmp <= reg;
		if (reg_strb = '1') then
			reg_tmp <= reg_input;
		else
			reg_tmp <= reg;
		end if;	
	end process;

end control_register_arch;
