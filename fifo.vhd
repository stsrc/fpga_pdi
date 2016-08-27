library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo is
	generic (
		DATA_WIDTH : integer := 32;
		DATA_HEIGHT : integer := 10
	);
	port (
		rst		: in std_logic;
		clk_in		: in std_logic;
		clk_out		: in std_logic;	
		data_in		: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		data_out	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
		strb_in		: in std_logic;
		strb_out	: in std_logic
	);
end fifo;

architecture fifo_arch of fifo is
shared variable data_head, data_tail : unsigned(DATA_HEIGHT - 1 downto 0) := (others => '0');
type mem_type is array (2**DATA_HEIGHT - 1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
shared variable mem : mem_type;

begin

	process (clk_in) begin
		if (clk_in'event and clk_in = '1') then
		    if (rst = '0') then
		      data_head := (others => '0');
		    elsif (strb_in = '1') then
		      mem(to_integer(data_head)) := data_in;
		      data_head := data_head + 1;
		    end if;
		end if;
	end process;

	process (clk_out) begin
		if (clk_out'event and clk_out = '1') then
		    if (rst = '0') then
		        data_tail := (others => '0');
		    elsif (strb_out = '1') then
			data_tail := data_tail + 1;
		    end if;
		    data_out <= mem(to_integer(data_tail));
		end if;
	end process;

end fifo_arch;
