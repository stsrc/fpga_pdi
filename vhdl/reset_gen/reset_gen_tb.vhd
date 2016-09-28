library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb is
end tb;

architecture Behavioral of tb is
component reset_gen is
    Generic (
        delay : integer := 1;
        rst_pol : std_logic := '0'
    );
    Port ( clk : in STD_LOGIC;
           asynchr_rst : in STD_LOGIC;
           locked : in STD_LOGIC;
           rst_out_n : out STD_LOGIC;
           rst_out_p : out STD_LOGIC);
end component;
signal clk, asynchr_rst, locked, rst_out_n, rst_out_p : std_logic := '0';
begin
    reset_gen_0 : reset_gen 
    generic map (delay => 1, rst_pol => '1')
    port map (
        clk => clk,
        asynchr_rst => asynchr_rst,
        locked => locked,
        rst_out_n => rst_out_n,
        rst_out_p => rst_out_p
    );
    
    process begin
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
    end process;
    
    process begin
    asynchr_rst <= '1';
    locked <= '1';
    wait for 25 ns;
    asynchr_rst <= '0';
    wait for 20 ns;
    
    locked <= '0';
    wait for 30 ns;
    locked <= '1';
    wait for 30 ns;
    locked <= '0';
    wait for 100 ns;
    locked <= '1';
    wait for 10 ns;
    locked <= '0';
    wait for 20 ns;
    
    locked <= '1';
    wait for 20 ns;
    asynchr_rst <= '1';
    wait for 20 ns;
    asynchr_rst <= '0';
    wait;
    end process;
end Behavioral;
