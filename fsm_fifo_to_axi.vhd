----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/28/2016 07:05:50 PM
-- Design Name: 
-- Module Name: fsm_fifo_to_axi_rx - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fsm_fifo_to_axi is
    port (
    clk     : in std_logic;
    rst     : in std_logic;
    
    fifo_out : in std_logic_vector(63 downto 0);
    fifo_strb : out std_logic;
    axi_in   : out std_logic_vector(31 downto 0);
    axi_strb  : in std_logic;
    
    cnt_in : in std_logic_vector(13 downto 0);
    cnt_out : out std_logic_vector(31 downto 0);
    cnt_strb_in : in std_logic;
    cnt_strb_out : out std_logic
    );
end fsm_fifo_to_axi;

architecture Behavioral of fsm_fifo_to_axi is
   
signal state, state_tmp : std_logic := '0';

begin
    cnt_out(31 downto 14) <= (others => '0');
    cnt_out(13 downto 0) <= cnt_in;
    cnt_strb_out <= cnt_strb_in;
    
    process(clk, rst) begin
    if (rising_edge(clk)) then
        if (rst = '0') then
            state <= '0'; 
        else
            state <= state_tmp;
        end if;
    end if;
    end process;
    
    process(state, axi_strb, fifo_out) begin
    state_tmp <= state;
    fifo_strb <= '0';
    axi_in <= (others => '0');
    case state is
    
    when '0' =>
        axi_in <= fifo_out(31 downto 0);
        if (axi_strb = '1') then
            state_tmp <= '1';
        end if;
        
    when '1' =>
        axi_in <= fifo_out(63 downto 32);
        if (axi_strb = '1') then
            fifo_strb <= '1';
            state_tmp <= '0';
        end if;
        
    when others =>
        state_tmp <= '0';
        
    end case;
    end process;
end Behavioral;
