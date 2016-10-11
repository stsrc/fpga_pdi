library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reset_gen is
    Generic (
        delay : integer := 1;
        rst_pol : std_logic := '0'
    );
    Port ( clk : in STD_LOGIC;
           asynchr_rst : in std_logic;
           locked : in STD_LOGIC;
           rst_out_n : out STD_LOGIC;
           rst_out_p : out STD_LOGIC);
end reset_gen;

architecture Behavioral of reset_gen is
signal cnt, cnt_tmp : unsigned(31 downto 0) := (others => '0');
signal state, state_tmp : std_logic := '0';
begin
    process (clk, asynchr_rst) begin
        if (asynchr_rst = rst_pol) then
            state <= '1';
            cnt <= (others => '0'); 
        elsif (rising_edge(clk)) then
                cnt <= cnt_tmp;
                state <= state_tmp;
        end if;
    end process;
    
    process (cnt, state, locked) begin
    state_tmp <= '0';
    cnt_tmp <= (others => '0');
    rst_out_n <= '1';
    rst_out_p <= '0';
    
    if (state = '0') then
        if (locked = '0') then
            state_tmp <= '1';
            rst_out_n <= '0';
            rst_out_p <= '1';
        end if;
    else
        if (locked = '0') then
            state_tmp <= '1';
            rst_out_n <= '0';
            rst_out_p <= '1';
        else
            if (to_integer(cnt) < delay) then
                cnt_tmp <= cnt + 1;
                rst_out_n <= '0';
                rst_out_p <= '1';
                state_tmp <= '1'; 
            end if;
        end if;
    end if; 
    end process;

end Behavioral;
