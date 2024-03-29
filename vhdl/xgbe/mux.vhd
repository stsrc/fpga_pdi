library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MUX is 
	generic (
		DATA_WIDTH : integer := 32
	);
	port (
		DIN_0 	: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		DIN_1	: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		DOUT	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
		ADDR	: in std_logic
	);
end MUX;

architecture MUX_arch of MUX is
begin
	DOUT <= DIN_1 when (ADDR = '1') else DIN_0;
end MUX_arch;
