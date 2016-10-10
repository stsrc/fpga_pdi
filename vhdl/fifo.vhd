-- fifo was written with help of RAM example found in FADE ethernet protocol.
-- project can be found here: www.opencores.org/project,fade_ether_protocol
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- *_in ports mean that it is for input data and control pins.
-- *_out as expected, it is to output data from fifo.
entity fifo is
	generic (
		DATA_WIDTH : integer := 64;
		DATA_HEIGHT : integer := 10
	);
	port (
		clk_in		: in std_logic;
		clk_in_resetn	: in std_logic;
		clk_out		: in std_logic;	
		clk_out_resetn  : in std_logic;
		data_in		: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		data_out	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
		strb_in		: in std_logic;
		strb_out	: in std_logic;
		drop_in		: in std_logic;
		is_full_clk_in	: out std_logic
	);
end fifo;

architecture fifo_arch of fifo is

signal head, head_tmp, tail : unsigned(DATA_HEIGHT - 1 downto 0) := (others => '0'); 
signal tail_gray, tail_in_bin: unsigned(DATA_HEIGHT - 1 downto 0) := (others => '0');
signal tail_in_0, tail_in_1 : unsigned(DATA_HEIGHT - 1 downto 0) := (others => '0'); 

type mem_type is array (2**DATA_HEIGHT - 1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
signal mem : mem_type;

begin
	
	process (clk_in) begin
		if (clk_in'event and clk_in = '1') then
			if (clk_in_resetn = '0') then
				head 	<= (others => '0');
				head_tmp  <= (others => '0');
				tail_in_0 <= (others => '0');
				tail_in_1 <= (others => '0');
				is_full_clk_in <= '0';
			else
				is_full_clk_in <= '0';	      
				tail_in_1 <= tail_in_0;
				tail_in_0 <= tail_gray;
				--Gray to BIN convertion.
				tail_in_bin(DATA_HEIGHT - 1) <= tail_in_1(DATA_HEIGHT - 1);
				for i in DATA_HEIGHT - 2 downto 0 loop
					tail_in_bin(i) <= tail_in_bin(i + 1) xor tail_in_1(i);
				end loop;
				--End of convertion

				if(head = tail_in_bin - 1) then
					is_full_clk_in <= '1';
					head <= head_tmp;
				elsif (strb_in = '1' and drop_in = '0') then
					mem(to_integer(head)) <= data_in;
					head <= head + 1;
				elsif (strb_in = '1' and drop_in = '1') then
					head <= head_tmp;
				else
					--TODO: fsm_axi_to_mac will fail because of this line.
					--when is_full_clk_in = 1 happend.
					head_tmp <= head; 
				end if;
			end if;
		end if;
	end process;
	
	process (clk_out) begin
		if (clk_out'event and clk_out = '1') then
			if (clk_out_resetn = '0') then
				tail <= (others => '0');   
			else
				if (strb_out = '1') then
		        		tail <= tail + 1;
					--Binary to gray conversion
					tail_gray <= tail xor ("0" & tail(DATA_HEIGHT - 1 downto 1));
					--End of BTG conversion
				end if;
			end if;
		end if;
	end process;
	
	data_out <= mem(to_integer(tail));

end fifo_arch;
