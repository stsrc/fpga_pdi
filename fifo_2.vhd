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
signal cnt_temp, cnt_temp_rd : unsigned(9 downto 0) := (others => '0');
signal data_head, data_tail : unsigned(9 downto 0) := (others => '0');
signal cnt_head, cnt_tail   : unsigned(9 downto 0) := (others => '0');
signal cnt_out_s : std_logic_vector(9 downto 0) := (others => '0');
signal cnt_strb, cnt_strb_rd : std_logic := '0';
	
component dp_ram_scl is
  generic (
    DATA_WIDTH : integer := 32;
    ADDR_WIDTH : integer := 10
    );
  port (
    -- Port A
    clk_a  : in  std_logic;
    we_a   : in  std_logic;
    addr_a : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    data_a : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    q_a    : out std_logic_vector(DATA_WIDTH-1 downto 0);

    -- Port B
    clk_b  : in  std_logic;
    we_b   : in  std_logic;
    addr_b : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    data_b : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    q_b    : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end component;

begin
	cnt_out <= std_logic_vector(cnt_out_s);

	data : dp_ram_scl generic map (DATA_WIDTH => 32, ADDR_WIDTH => 10)
	port map (clk_a => clk_in, we_a => strb_in, addr_a => std_logic_vector(data_head),
	data_a => data_in, q_a => open, clk_b => clk_out, we_b => '0',
	addr_b => std_logic_vector(data_tail), data_b => (others => '0'), q_b => data_out);

	process (clk_in) begin
		if (clk_in'event and clk_in = '1') then
			if (strb_in = '1') then
				data_head <= data_head + 1;
			end if;
		end if;
	end process;

	process (clk_out) begin
		if (clk_out'event and clk_out = '1') then
			if (strb_out = '1') then
				data_tail <= data_tail + 1;
			end if;
		end if;
	end process;

	cnt : dp_ram_scl generic map (DATA_WIDTH => 10, ADDR_WIDTH => 10)
	port map (clk_a => clk_in, we_a => cnt_strb, addr_a => std_logic_vector(cnt_head),
	data_a => std_logic_vector(cnt_temp), q_a => open, clk_b => clk_out, we_b => cnt_strb_rd, 
	addr_b => std_logic_vector(cnt_tail), data_b => std_logic_vector(cnt_temp_rd), q_b => cnt_out_s);

	process (clk_in) begin
		if (clk_in'event and clk_in = '1') then
			if (strb_in = '1') then
				cnt_temp <= cnt_temp + 1;
				cnt_strb <= '1';
			else
			    if (cnt_temp /= 0) then
			    cnt_head <= cnt_head + 1;
			    end if;
			    cnt_temp <= (others => '0');
                cnt_strb <= '0';
	
			end if;
		end if;	
	end process;

	process (clk_out) begin
		if (clk_out'event and clk_out = '1') then
			if (strb_out = '1') then
				if (unsigned(cnt_out_s) = 1) then
					cnt_tail <= cnt_tail + 1;
					cnt_strb_rd <= '0';
					cnt_temp_rd <= (others => '0');
				else
					cnt_temp_rd <= unsigned(cnt_out_s) - 1;
					cnt_strb_rd <= '1';
				end if;		
			end if;
		end if;
	end process;
end fifo_arch;
