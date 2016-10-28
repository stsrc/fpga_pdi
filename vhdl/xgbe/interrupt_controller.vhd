library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interrupt_controller is
port (
	int_0 : in std_logic;
	int_1 : in std_logic;
	int_out : out std_logic
);
end interrupt_controller;

architecture interrupt_controller_arch of interrupt_controller is
begin
	int_out <= int_0 or int_1;
end interrupt_controller_arch;
