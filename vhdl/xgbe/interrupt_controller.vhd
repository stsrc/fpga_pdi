library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interrupt_controller is
port (
	clk : in std_logic;
	resetn : in std_logic;
	int_0 : in std_logic;
	int_1 : in std_logic;
	int_en : in std_logic;
	int_out : out std_logic
);
end interrupt_controller;

architecture interrupt_controller_arch of interrupt_controller is
begin
	process(clk) is
	begin
		if (rising_edge(clk)) then
			if (resetn = '0') then
				int_out <= '0';
			else
				if (int_en = '1') then
					int_out <= int_0 or int_1;
				else
					int_out <= '0';
				end if;
			end if;
		end if;
	end process;
end interrupt_controller_arch;
