library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity chcksum is
port (
	clk		: in std_logic;
	resetn		: in std_logic;
	input_1		: in std_logic_vector(15 downto 0);
	input_2		: in std_logic_vector(15 downto 0);
	input_1_strb	: in std_logic;
	input_2_strb	: in std_logic;
	oe		: in std_logic;
	reset		: in std_logic;
	output		: out std_logic_vector(15 downto 0);
	output_strb	: out std_logic
);
end chcksum;

architecture chcksum_arch of chcksum is
shared variable cnt : unsigned(16 downto 0);
signal output_strb_reg : std_logic;

begin

output_strb <= output_strb_reg;

process (clk) begin
	if (rising_edge(clk)) then
		if (resetn = '0' or reset = '1' or output_strb_reg = '1') then
			cnt := (others => '0');
			output 		<= (others => '0');
			output_strb_reg <= '0';
		else
			
			if (input_1_strb = '1') then
				cnt := unsigned(input_1) + cnt;
			
				if (cnt > 2**16 - 1) then
					cnt := cnt - 2**16;
					cnt := cnt + 1;
				end if;
			end if;
		
			if (input_2_strb = '1') then
				cnt := unsigned(input_2) + cnt;
		
				if (cnt > 2**16 - 1) then
					cnt := cnt - 2**16;
					cnt := cnt + 1;
				end if;
			end if;
			
			if (oe = '1') then
				cnt := not(cnt);
				output <= std_logic_vector(cnt(15 downto 0));
				output_strb_reg <= '1';
			end if;
		end if;
	end if;
end process;
end chcksum_arch;
