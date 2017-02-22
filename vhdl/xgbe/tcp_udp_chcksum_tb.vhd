library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb is
end tb;

architecture tb_arch of tb is

component chcksum is
port (
	clk		: in std_logic;
	resetn		: in std_logic;
	input_1		: in std_logic_vector(15 downto 0);
	input_2		: in std_logic_vector(15 downto 0);
	input_1_strb	: in std_logic;
	input_2_strb	: in std_logic;
	oe		: in std_logic;
	reset		: in std_logic;
	output		: out std_logic_vector(15 downto 0);
	output_strb	: out std_logic
);
end component;

signal clk, resetn, input_1_strb, input_2_strb, oe, reset, output_strb: std_logic := '0';
signal input_1, input_2, output: std_logic_vector(15 downto 0);

type daataa is array (natural range 0 to 15) of std_logic_vector(31 downto 0);

constant data_1 : daataa := (
0 => (X"45000030"),
1 => (X"44224000"),
2 => (X"80060000"),
3 => (X"8C7C19AC"),
4 => (X"AE241E2B"),
5 => (X"00000000"),
6 => (X"00000000"),
7 => (X"00000000"),
8 => (X"00000000"),
9 => (X"00000000"),
10 => (X"00000000"),
11 => (X"00000000"),
12 => (X"00000000"),
13 => (X"00000000"),
14 => (X"00000000"),
15 => (X"00000000"));

begin

chcksum_1 : chcksum
port map(
	clk => clk,
	resetn => resetn,
	input_1 => input_1,
	input_2 => input_2,
	input_1_strb => input_1_strb,
	input_2_strb => input_2_strb,
	oe => oe,
	reset => reset,
	output => output,
	output_strb => output_strb
);

process begin
clk <= '0';
wait for 5 ns;
clk <= '1';
wait for 5 ns;
end process;

process begin
resetn <= '0';
wait for 10 ns;
resetn <= '1';
wait;
end process;

process begin
    wait for 10 ns;
	for i in 0 to 15 loop
		if (i < 5) then
			input_1 <= data_1(i)(15 downto 0);
			input_2 <= data_1(i)(31 downto 16);
			input_1_strb <= '1';
			input_2_strb <= '1';
			reset <= '0';
		else
			input_1_strb <= '0';
			input_2_strb <= '0';
		end if;
		wait for 10 ns;
	end loop;
	oe <= '1';
	wait until output_strb = '1';
	assert unsigned(output) = X"442E" severity failure;
	oe <= '0';
	wait until output_strb = '0';
	assert unsigned(output) = 0;
	wait;
end process;
end tb_arch;
