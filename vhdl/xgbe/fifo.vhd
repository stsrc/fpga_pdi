library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo is
	generic (
		DATA_WIDTH : integer := 64;
		DATA_HEIGHT : integer := 10
	);
	port (
		rst		: in std_logic;
		clk_in		: in std_logic;
		clk_out		: in std_logic;	
		data_in		: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		data_out	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
		strb_in		: in std_logic;
		strb_out	: in std_logic;
		drop_in		: in std_logic;
		interrupt_in	: in std_logic;
		interrupt_out	: out std_logic
	);
end fifo;

architecture fifo_arch of fifo is
shared variable head, head_tmp, tail : unsigned(DATA_HEIGHT - 1 downto 0) := (others => '0'); 
signal int_reg_in, int_tmp_in, int_reg_out, int_tmp_out: std_logic := '0';
type mem_type is array (2**DATA_HEIGHT - 1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
shared variable mem : mem_type;

begin

	
	process (clk_in) begin
		if (clk_in'event and clk_in = '1') then
		    if (rst = '0') then
		      head := (others => '0');
		      head_tmp := (others => '0');
		      int_reg_in <= '0';
		    else
		      int_reg_in <= int_tmp_in;		      
		      if (strb_in = '1' and drop_in = '0') then
		        mem(to_integer(head)) := data_in;
		        head := head + 1;
		      elsif (strb_in = '1' and drop_in = '1') then
		        head := head_tmp;
		      else
		        head_tmp := head; 
		      end if;
		    end if;
		end if;
	end process;
	
	process (clk_out) begin
		if (clk_out'event and clk_out = '1') then
		    if (rst = '0') then
		        tail := (others => '0');   
		        int_reg_out <= '0';
		    else
		      int_reg_out <= int_tmp_out;
		      if (strb_out = '1') then
		        tail := tail + 1;
		      end if;
		    end if;
		     data_out <= mem(to_integer(tail)); 
		end if;
	end process;
	

    interrupt_out <= int_reg_out;
    
    process(int_reg_in, int_reg_out, interrupt_in) begin
    
        int_tmp_in <= int_reg_in;
        int_tmp_out <= int_reg_out;
        
        if (interrupt_in = '1') then
            int_tmp_in <= '1';
        end if;
        
        if (int_reg_in = '1') then
            int_tmp_out <= '1';
        end if;
        
        if (int_reg_out = '1') then
            int_tmp_in <= '0';
            int_tmp_out <= '0';
       end if;
       
    end process;
end fifo_arch;
