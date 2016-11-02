library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interconnect_AXI_M_DMA is
	port (
		clk 		: in  std_logic;
		aresetn		: in  std_logic;

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

		INIT_AXI_TXN_0	: in  std_logic;
		AXI_TXN_DONE_0	: out std_logic;
		INIT_AXI_RXN_0	: in  std_logic;
		AXI_RXN_DONE_0 	: out std_logic;

		INIT_AXI_TXN_1	: in  std_logic;
		AXI_TXN_DONE_1	: out std_logic;
		INIT_AXI_RXN_1	: in  std_logic;
		AXI_RXN_DONE_1 	: out std_logic
	);
end interconnect_AXI_M_DMA;

architecture interconnect_AXI_M_DMA_arch of interconnect_AXI_M_DMA is

signal DATA_0_REG, DATA_1_REG : std_logic_vector(31 downto 0);
signal ADDR_0_REG, ADDR_1_REG : std_logic_vector(31 downto 0);
signal state : std_logic_vector(1 downto 0);
signal strb_0, rdwr_0, strb_1, rdwr_1 : std_logic;
begin

process(clk) begin
	if (rising_edge(clk)) then
		if (aresetn = '0') then
			DATA_0_REG <= (others => '0');
			DATA_1_REG <= (others => '0');
			ADDR_0_REG <= (others => '0');
			ADDR_1_REG <= (others => '0');

			DATA_TO_AXI <= (others => '0');
			ADDR_TO_AXI <= (others => '0');

			DATA_IN_0 <= (others => '0');
			DATA_IN_1 <= (others => '0');

			AXI_TXN_DONE_0 <= '0';
			AXI_RXN_DONE_0 <= '0';
			AXI_TXN_DONE_1 <= '0';
			AXI_RXN_DONE_1 <= '0';

			state <= (others => '0');

			strb_0 <= '0';
			strb_1 <= '0';
			rdwr_0 <= '0';
			rdwr_1 <= '0';

			INIT_AXI_TXN <= '0';
			INIT_AXI_RXN <= '0';

		else 	
			INIT_AXI_TXN <= '0';
			INIT_AXI_RXN <= '0';			
			AXI_TXN_DONE_0 <= '0';
			AXI_RXN_DONE_0 <= '0';
			AXI_TXN_DONE_1 <= '0';
			AXI_RXN_DONE_1 <= '0';

			if (INIT_AXI_TXN_0 = '1') then
				strb_0 <= '1';
				rdwr_0 <= '1';
				DATA_0_REG <= DATA_OUT_0;
				ADDR_0_REG <= ADDR_0; 
			end if;

			if (INIT_AXI_RXN_0 = '1') then
				strb_0 <= '1';
				rdwr_0 <= '0';
				DATA_0_REG <= (others => '0');
				ADDR_0_REG <= ADDR_0; 
			end if;

			if (INIT_AXI_TXN_1 = '1') then
				strb_1 <= '1';
				rdwr_1 <= '1';
				DATA_1_REG <= DATA_OUT_1;
				ADDR_1_REG <= ADDR_1; 
			end if;

			if (INIT_AXI_RXN_1 = '1') then
				strb_1 <= '1';
				rdwr_1 <= '0';
				DATA_1_REG <= (others => '0');
				ADDR_1_REG <= ADDR_1; 
			end if;

			case(state) is
			when "00" =>
				if (strb_0 = '1') then
					state <= "01";
					strb_0 <= '0';
					ADDR_TO_AXI <= ADDR_0_REG;
					DATA_TO_AXI <= DATA_0_REG;
					if (rdwr_0 = '0') then
						INIT_AXI_RXN <= '1';
					else
						INIT_AXI_TXN <= '1';
					end if;
				elsif (strb_1 = '1') then
					state <= "10";
					strb_1 <= '0';
					ADDR_TO_AXI <= ADDR_1_REG;
					DATA_TO_AXI <= DATA_1_REG;
					if (rdwr_1 = '1') then
						INIT_AXI_RXN <= '1';
					else
						INIT_AXI_TXN <= '1';
					end if;
				end if;	

			when "01" =>

				case (rdwr_0) is
				when '0' =>
					if (AXI_RXN_DONE = '1') then
						DATA_IN_0 <= DATA_FROM_AXI;
						AXI_RXN_DONE_0 <= '1';
						state <= "00";
					else
						state <= "01";
					end if;
				when '1' =>
					if (AXI_TXN_DONE = '1') then
						DATA_IN_0 <= DATA_FROM_AXI;
						AXI_TXN_DONE_0 <= '1';
						state <= "00";
					else
						state <= "01";
					end if;
				when others =>
					state <= "00";
				end case;

			when "10" =>

				case (rdwr_1) is
				when '0' =>
					if (AXI_RXN_DONE = '1') then
						DATA_IN_1 <= DATA_FROM_AXI;
						AXI_RXN_DONE_1 <= '1';
						state <= "00";
					else
						state <= "10";
					end if;
				when '1' =>
					if (AXI_TXN_DONE = '1') then
						DATA_IN_1 <= DATA_FROM_AXI;
						AXI_TXN_DONE_1 <= '1';
						state <= "00";
					else
						state <= "10";
					end if;
				when others =>
					state <= "00";
				end case;

			when others =>
				state <= (others => '0');
			end case;
		end if;	
	end if;			
end process;	
end interconnect_AXI_M_DMA_ARCH;
