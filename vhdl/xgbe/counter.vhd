library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
	generic (
		REG_WIDTH : integer := 32;
		INT_GEN_DELAY : integer := 100
	);
	port (
		clk		: in std_logic;
		resetn		: in std_logic;
		incr   		: in std_logic;
		get_val		: in std_logic;
		cnt_out		: out std_logic_vector(REG_WIDTH - 1 downto 0);
		interrupt   : out std_logic
	);
end counter;

architecture counter_arch of counter is
	--cnt - packet count
	signal cnt, cnt_tmp : unsigned(REG_WIDTH - 1 downto 0);
	signal int_gen_cnt, int_gen_cnt_tmp  : unsigned(REG_WIDTH - 1 downto 0);
	signal int_state  : std_logic := '0';
begin
    
	cnt_out <= std_logic_vector(cnt);

	process(clk) is
	begin
		if (rising_edge(clk)) then
			if (resetn = '0') then
				cnt <= (others => '0');
				int_gen_cnt <= (others => '0');
			else
				cnt <= cnt_tmp;
				int_gen_cnt <= int_gen_cnt_tmp;
			end if;
		end if;
	end process;

	process (cnt, incr, get_val) is
	begin
		cnt_tmp <= cnt;
		if (get_val = '1') then
			if (incr = '1') then
				cnt_tmp <= to_unsigned(1, REG_WIDTH);
			else
				cnt_tmp <= (others => '0');
			end if;
		else
			if (incr = '1') then
				cnt_tmp <= cnt + 1;
			end if;
		end if;
	end process;
	
	process (int_gen_cnt, cnt, incr) is
	begin 
	       interrupt <= '0';
	       int_gen_cnt_tmp <= int_gen_cnt;
	       if (incr = '1') then
	           interrupt <= '1';
	           int_gen_cnt_tmp <= (others => '0');
	       elsif (int_gen_cnt > to_unsigned(INT_GEN_DELAY, REG_WIDTH)) then
	           interrupt <= '1';
	           int_gen_cnt_tmp <= (others => '0');
	       elsif (cnt /= 0) then
		   int_gen_cnt_tmp <= int_gen_cnt + 1;
	       end if;
	end process;
end counter_arch;
