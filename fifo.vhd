library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo is
	generic (
		DATA_WIDTH	: integer := 32;
		HEIGHT		: integer := 8192;
		HEIGHT_LOG_2	: integer := 13
	);
	port (
		rst		: in std_logic;	
		data_in		: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		data_out	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
		cnt_out		: out std_logic_vector(HEIGHT_LOG_2 - 1 downto 0);
		strb_in		: in std_logic;
		strb_out	: in std_logic;
		last_in		: in std_logic
	);
end fifo;

architecture fifo_arch of fifo is
	type data_array is array(0 to HEIGHT - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	type cnt_array is array(0 to HEIGHT - 1) of unsigned(HEIGHT_LOG_2 - 1 downto 0);
	signal data : data_array := (others => (others => '0'));
	signal cnt  : cnt_array  := (others => (others => '0')); 
	signal cnt_temp : unsigned(HEIGHT_LOG_2 - 1 downto 0) := (others => '0');
	signal data_head, data_tail : unsigned(HEIGHT_LOG_2 - 1 downto 0) := (others => '0');
	signal cnt_head, cnt_tail   : unsigned(HEIGHT_LOG_2 - 1 downto 0) := (others => '0');
	
begin
	
	cnt_out <= std_logic_vector(cnt(to_integer(cnt_tail)));
    data_out <= data(to_integer(data_tail));
    
	process (rst, strb_in, strb_out)
	begin
		if (rst = '0') then
			data_head <= (others => '0');
			data_tail <= (others => '0');
			cnt_head <= (others => '0');
			cnt_tail <= (others => '0');
			cnt_temp <= (others => '0');
			for i in 0 to HEIGHT - 1 loop
				cnt(i) <= (others => '0');
				data(i) <= (others => '0');
			end loop;
		else	
			data_head <= data_head;
			data_tail <= data_tail;
			cnt_head <= cnt_head;
			cnt_tail <= cnt_tail;
			cnt_temp <= cnt_temp;
			for i in 0 to HEIGHT - 1 loop
				cnt(i) <= cnt(i);
				data(i) <= data(i);
			end loop;

			if (strb_in = '1') then
				data(to_integer(data_head)) <= data_in;
				data_head <= data_head + 1;
				if (last_in = '1') then
					cnt(to_integer(cnt_head)) <= cnt_temp;
					cnt_head <= cnt_head + 1;
					cnt_temp <= (others => '0');
				else
					cnt_temp <= cnt_temp + 1;
				end if;
			end if;
		
			if (strb_out = '1') then
				data_tail <= data_tail + 1; 
				if (cnt(to_integer(cnt_tail)) = 0) then
			              cnt_tail <= cnt_tail + 1;
				else
			              cnt(to_integer(cnt_tail)) <= cnt(to_integer(cnt_tail)) - 1;               
			        end if;
          
		        end if;	
		end if;
	end process;
end fifo_arch;
