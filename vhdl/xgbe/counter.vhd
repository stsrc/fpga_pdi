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

	signal cnt : unsigned(REG_WIDTH - 1 downto 0);
	signal int_gen_cnt  : unsigned(REG_WIDTH - 1 downto 0);
	signal incr_state : std_logic := '0';

begin
    
	cnt_out <= std_logic_vector(cnt);
	
	process(clk) is
	begin
		if (rising_edge(clk)) then
			if (resetn = '0') then
				int_gen_cnt <= (others => '0');
				interrupt <= '0';
				cnt <= (others => '0');
			else

				cnt <= cnt;

				if (get_val = '1') then
					if (incr_state = '1' and incr = '1') then
						cnt <= TO_UNSIGNED(2, REG_WIDTH);
					elsif (incr_state = '1' or incr = '1') then
						cnt <= TO_UNSIGNED(1, REG_WIDTH);
					else
						cnt <= (others => '0');
					end if;
					incr_state <= '0';
				else
					if (incr = '1') then
						cnt <= cnt + 1;
						incr_state <= '1';
					else
						incr_state <= '0';
					end if;
				end if;		
				
				interrupt <= '0';
				int_gen_cnt <= int_gen_cnt;
				if (incr = '1') then
					interrupt <= '1';
					int_gen_cnt <= (others => '0');
				elsif (to_integer(int_gen_cnt) > INT_GEN_DELAY) then
					interrupt <= '1';
					int_gen_cnt <= (others => '0');
				elsif (cnt /= 0) then
					int_gen_cnt <= int_gen_cnt + 1;
				end if;
			end if;
		end if;
end process;

end counter_arch;
