library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo is

	port (
		rst		: in std_logic;
		clk_in		: in std_logic;
		clk_out		: in std_logic;	
		data_in		: in std_logic_vector(31 downto 0);
		data_out	: out std_logic_vector(31 downto 0);
		cnt_out		: out std_logic_vector(9 downto 0);
		strb_in		: in std_logic;
		strb_out	: in std_logic
	);
end fifo;

architecture fifo_arch of fifo is
shared variable data_head, data_tail : unsigned(9 downto 0) := (others => '0');
type mem_type is array (1023 downto 0) of std_logic_vector(31 downto 0);
shared variable mem : mem_type;
type cnt_type is array (1023 downto 0) of std_logic_vector(9 downto 0);
shared variable cnt : cnt_type;
shared variable cnt_temp, cnt_temp_rd : unsigned(9 downto 0) := (others => '0');
shared variable cnt_head, cnt_tail   : unsigned(9 downto 0) := (others => '0');

begin

	process (clk_in) begin
		if (clk_in'event and clk_in = '1') then
		    if (rst = '0') then
		      for i in 0 to 1023 loop
		        mem(i) := (others => '0');
		      end loop;
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

	process (clk_in) begin
		if (clk_in'event and clk_in = '1') then
		
		    if (rst = '0') then
		      for i in 0 to 1023 loop
		         cnt(i) := (others => '0');
		      end loop;
		      cnt_temp := (others => '0');
		      cnt_head := (others => '0');
		      
		    elsif (strb_in = '1') then
			
		      cnt_temp := cnt_temp + 1;
				
		    elsif (cnt_temp /= 0) then
			
		      cnt(to_integer(cnt_head)) := std_logic_vector(cnt_temp);
		      cnt_temp := (others => '0');
		      cnt_head := cnt_head + 1;
				
		    end if;
	         end if;
	end process;

	process (clk_out) begin
		if (clk_out'event and clk_out = '1') then
		
		    if (rst = '0') then
		      
		      cnt_temp_rd := (others => '0');
		      cnt_tail := (others => '0');
		      
		    elsif (strb_out = '1') then
			
		      cnt_temp_rd := cnt_temp_rd + 1;
				
		      if (cnt(to_integer(cnt_tail)) = std_logic_vector(cnt_temp_rd)) then
				
		        cnt_tail := cnt_tail + 1;
			cnt_temp_rd := (others => '0');
					
		      end if;		
						
	           end if;
			
		cnt_out <= std_logic_vector(cnt(to_integer(cnt_tail)));
			
		end if;
	end process;

end fifo_arch;
