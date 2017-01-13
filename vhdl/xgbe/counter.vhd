library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_2 is
	generic (
		REG_WIDTH : integer := 32;
		INT_GEN_DELAY : integer := 100
	);
	port (
		clk		: in std_logic;
		resetn		: in std_logic;
		incr   		: in std_logic;
		int_en		: in std_logic;
		get_val		: in std_logic;
		cnt_out		: out std_logic_vector(REG_WIDTH - 1 downto 0);
		interrupt   : out std_logic
	);
end counter_2;

architecture counter_arch of counter_2 is
	signal cnt : unsigned(REG_WIDTH - 1 downto 0);
	signal incr_state : std_logic := '0';
	signal int_en_last : std_logic;
begin
    	cnt_out <= std_logic_vector(cnt);
	
	process(clk) is
	begin
		if (rising_edge(clk)) then
			if (resetn = '0') then
				interrupt <= '0';
				cnt <= (others => '0');
			else
                		interrupt <= '0';
				int_en_last <= int_en;	
				if (get_val = '1') then
					if (incr_state = '1' and incr = '1') then
						cnt <= TO_UNSIGNED(2, REG_WIDTH);
						interrupt <= '1';
					elsif (incr_state = '1' or incr = '1') then
						cnt <= TO_UNSIGNED(1, REG_WIDTH);
						interrupt <= '1';
					else
						cnt <= (others => '0');
					end if;
					incr_state <= '0';
				else
					if (incr = '1') then
						cnt <= cnt + 1;
						incr_state <= '1';
						if (cnt = 0) then
						  interrupt <= '1';
						end if;
					else
						incr_state <= '0';
					end if;
				end if;		

				if (int_en_last = '0' and int_en ='1' and cnt /= 0) then
					interrupt <= '1';
				end if;
			end if;
		end if;
	end process;
end counter_arch;
