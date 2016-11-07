library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interconnect_AXI_M_DMA is
	port (
		clk 		: in  std_logic;
		aresetn		: in  std_logic;

		BRST_0		: in std_logic_vector(7 downto 0);
		BRST_1		: in std_logic_vector(7 downto 0);
		BRST_TO_AXI	: out std_logic_vector(7 downto 0);

		DATA_OUT_0 	: in  std_logic_vector(31 downto 0);
		DATA_OUT_1 	: in  std_logic_vector(31 downto 0);
		DATA_TO_AXI  	: out std_logic_vector(31 downto 0);

		DATA_FROM_AXI	: in  std_logic_vector(31 downto 0);
		DATA_IN_0	: out std_logic_vector(31 downto 0);
		DATA_IN_1	: out std_logic_vector(31 downto 0);

		ADDR_0 		: in  std_logic_vector(31 downto 0);
		ADDR_1 		: in  std_logic_vector(31 downto 0);
		ADDR_TO_AXI  	: out std_logic_vector(31 downto 0);

		INIT_AXI_TXN	: out std_logic;
		INIT_AXI_RXN	: out std_logic;
		AXI_TXN_DONE	: in std_logic;
		AXI_RXN_DONE	: in std_logic;
		AXI_TXN_STRB	: in std_logic;
		AXI_RXN_STRB	: in std_logic;

		INIT_AXI_TXN_0	: in  std_logic;
		AXI_TXN_DONE_0	: out std_logic;
		AXI_TXN_STRB_0	: out std_logic;
		INIT_AXI_RXN_0	: in  std_logic;
		AXI_RXN_DONE_0 	: out std_logic;
		AXI_RXN_STRB_0	: out std_logic;

		INIT_AXI_TXN_1	: in  std_logic;
		AXI_TXN_DONE_1	: out std_logic;
		AXI_TXN_STRB_1	: out std_logic;
		INIT_AXI_RXN_1	: in  std_logic;
		AXI_RXN_DONE_1 	: out std_logic;
		AXI_RXN_STRB_1	: out std_logic
	);
end interconnect_AXI_M_DMA;

architecture interconnect_AXI_M_DMA_arch of interconnect_AXI_M_DMA is
signal dir : std_logic;
signal state : std_logic_vector(1 downto 0);
signal pending_0, pending_1 : std_logic;
signal rdwr_0, rdwr_1 : std_logic;

begin
process(clk) begin
	if (rising_edge(clk)) then
		if (aresetn = '0') then
			dir 		<= '0';
			pending_0 	<= '0';
			rdwr_0		<= '0';
			rdwr_1		<= '0';
			pending_1 	<= '0';
			state <= (others => '0');
			INIT_AXI_RXN   <= '0';
			INIT_AXI_TXN   <= '0';
			AXI_TXN_DONE_0 <= '0';
			AXI_RXN_DONE_0 <= '0';
			AXI_TXN_DONE_1 <= '0';
			AXI_RXN_DONE_1 <= '0';
		else

			INIT_AXI_RXN   <= '0';
			INIT_AXI_TXN   <= '0';
			AXI_TXN_DONE_0 <= '0';
			AXI_RXN_DONE_0 <= '0';
			AXI_TXN_DONE_1 <= '0';
			AXI_RXN_DONE_1 <= '0';

			if (INIT_AXI_RXN_0 = '1') then
				pending_0 	<= '1';
				rdwr_0 		<= '0';
			elsif (INIT_AXI_TXN_0 = '1') then
				pending_0 	<= '1';
				rdwr_0 		<= '1';
			end if;

			if (INIT_AXI_RXN_1 = '1') then
				pending_1 	<= '1';
				rdwr_1 		<= '0';
			elsif (INIT_AXI_TXN_1 = '1') then
				pending_1 	<= '1';
				rdwr_1 		<= '1';
			end if;
	
			case (to_integer(unsigned(state))) is
			when 0 =>
				if (pending_0 = '1') then
					dir 		<= '0';
					pending_0 	<= '0';
					state 		<= "01";
					if (rdwr_0 = '0') then
						INIT_AXI_RXN <= '1';
					else
						INIT_AXI_TXN <= '1';
					end if;
				elsif (pending_1 = '1') then
					dir 		<= '1';
					pending_1	<= '0';
					state		<= "10";
					if (rdwr_1 = '0') then
						INIT_AXI_RXN <= '1';
					else
						INIT_AXI_TXN <= '1';
					end if;
				end if;
			when 1 =>
				state <= "01";
				if (AXI_RXN_DONE = '1') then
					AXI_RXN_DONE_0 <= '1';
					state <= "00";
				elsif (AXI_TXN_DONE = '1') then
					AXI_TXN_DONE_0 <= '1';
					state <= "00";
				end if;
			when 2 =>
				state <= "10";
				if (AXI_RXN_DONE = '1') then
					AXI_RXN_DONE_1 <= '1';
					state <= "00";
				elsif (AXI_TXN_DONE = '1') then
					AXI_TXN_DONE_1 <= '1';
					state <= "00";
				end if;
			when others =>
			end case;
		end if;	
	end if;			
end process;

process(dir, ADDR_0, ADDR_1) begin
	if (dir = '0') then
		ADDR_TO_AXI <= ADDR_0;
	else
		ADDR_TO_AXI <= ADDR_1;
	end if;
end process;

 process(dir, BRST_0, BRST_1) begin
	if (dir = '0') then
		BRST_TO_AXI <= BRST_0;
	else
		BRST_TO_AXI <= BRST_1;
	end if;
end process; 

process(dir, DATA_OUT_0, DATA_OUT_1) begin
	if (dir = '0') then
		DATA_TO_AXI <= DATA_OUT_0;
	else
		DATA_TO_AXI <= DATA_OUT_1;
	end if;	
end process;

process(dir, DATA_FROM_AXI) begin
	DATA_IN_0 <= (others => '0');
	DATA_IN_1 <= (others => '0');
	if (dir = '0') then
		DATA_IN_0 <= DATA_FROM_AXI;
	else
		DATA_IN_1 <= DATA_FROM_AXI;
	end if;	
end process;

process(dir, AXI_TXN_STRB) begin
	AXI_TXN_STRB_0 <= '0';
	AXI_TXN_STRB_1 <= '0';

	if (dir = '0') then
		AXI_TXN_STRB_0 <= AXI_TXN_STRB;
	else
		AXI_TXN_STRB_1 <= AXI_TXN_STRB;
	end if;	
end process;

process(dir, AXI_RXN_STRB) begin
	AXI_RXN_STRB_0 <= '0';
	AXI_RXN_STRB_1 <= '0';

	if (dir = '0') then
		AXI_RXN_STRB_0 <= AXI_RXN_STRB;
	else
		AXI_RXN_STRB_1 <= AXI_RXN_STRB;
	end if;	
end process;
end interconnect_AXI_M_DMA_ARCH;
