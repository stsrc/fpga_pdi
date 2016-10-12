library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm_mac_to_fifo is 
	port (
        	clk		: in  std_logic;
	        rst		: in  std_logic;
		-- Enable data reception. Signal is used to prevent from
		-- saving packets when MicroBlaze is not ready yet for 
		-- reception.  
		en_rcv		: in  std_logic;
		-- Output to the FIFO
	        fifo_data	: out std_logic_vector(63 downto 0);
	        fifo_cnt	: out std_logic_vector(13 downto 0);
	        fifo_cnt_strb	: out std_logic;
        	fifo_strb	: out std_logic;
	        fifo_drop	: out std_logic;
		-- End of packet reception pin strobe. It signals that
		-- MB may now get packet.
	        eop_strb	: out std_logic;
		fifo_is_full	: in  std_logic;
		-- xge_mac related ports
        	pkt_rx_data	: in  std_logic_vector(63 downto 0);
	        pkt_rx_ren	: out std_logic;
	        pkt_rx_avail	: in  std_logic;
	        pkt_rx_eop	: in  std_logic;
	        pkt_rx_val	: in  std_logic;
	        pkt_rx_sop	: in  std_logic;
	        pkt_rx_mod	: in  std_logic_vector(2 downto 0);
	        pkt_rx_err	: in  std_logic
       );
end fsm_mac_to_fifo;

architecture Behavioral of fsm_mac_to_fifo is

	signal state, tmp_state : unsigned(1 downto 0) := (others => '0');
	signal cnt, cnt_temp : unsigned(13 downto 0) := (others => '0');
  	signal pkt_rx_data_s : std_logic_vector(63 downto 0) := (others => '0');

	procedure MOD_VAL (
			signal cnt : in unsigned(13 downto 0);
			signal cnt_temp : out unsigned(13 downto 0);
			signal pkt_rx_data : in std_logic_vector(63 downto 0);
			signal pkt_rx_data_s : out std_logic_vector(63 downto 0);
			signal pkt_rx_mod : in std_logic_vector(2 downto 0))
	is 
	begin
		case pkt_rx_mod is
		when "000" =>
                pkt_rx_data_s <= pkt_rx_data;
                cnt_temp <= cnt + 8;
            when "001" =>
                pkt_rx_data_s(63 downto 8) <= (others => '0');
                pkt_rx_data_s(7 downto 0) <= pkt_rx_data(7 downto 0);
                cnt_temp <= cnt + 1;
            when "010" =>
                pkt_rx_data_s(63 downto 16) <= (others => '0');
                pkt_rx_data_s(15 downto 0) <= pkt_rx_data(15 downto 0);
                cnt_temp <= cnt + 2;
            when "011" =>
                pkt_rx_data_s(63 downto 24) <= (others => '0');
                pkt_rx_data_s(23 downto 0) <= pkt_rx_data(23 downto 0);
                cnt_temp <= cnt + 3;
            when "100" =>
                pkt_rx_data_s(63 downto 32) <= (others => '0');
                pkt_rx_data_s(31 downto 0) <= pkt_rx_data(31 downto 0);
                cnt_temp <= cnt + 4;
            when "101" =>
                pkt_rx_data_s(63 downto 40) <= (others => '0');
                pkt_rx_data_s(39 downto 0) <= pkt_rx_data(39 downto 0);
                cnt_temp <= cnt + 5;
            when "110" =>
                pkt_rx_data_s(63 downto 48) <= (others => '0');
                pkt_rx_data_s(47 downto 0) <= pkt_rx_data(47 downto 0);
                cnt_temp <= cnt + 6;
            when "111" =>
                pkt_rx_data_s(63 downto 56) <= (others => '0');
                pkt_rx_data_s(55 downto 0) <= pkt_rx_data(55 downto 0);
                cnt_temp <= cnt + 7;
            when others =>
                pkt_rx_data_s <= (others => '0');
            end case;
	end MOD_VAL;

begin

fifo_data <= pkt_rx_data_s;
fifo_cnt <= std_logic_vector(cnt);
    
	process(clk) is
	begin
	if (rising_edge(clk)) then
		if (rst = '0') then
			state <= (others => '0');
			cnt <= (others => '0');
		else
        		state <= tmp_state;
			cnt <= cnt_temp;
		end if;
	end if;
	end process;
    
	process(state, cnt, en_rcv, pkt_rx_mod, pkt_rx_avail, pkt_rx_val, 
		pkt_rx_eop, pkt_rx_data, pkt_rx_err, fifo_is_full) begin

	tmp_state <= "00";
	pkt_rx_ren <= '0';
	fifo_strb <= '0';
	eop_strb <= '0';
	pkt_rx_data_s <= (others => '0');
	cnt_temp <= (others => '0');
	fifo_cnt_strb <= '0';
	fifo_drop <= '0';

	case state is
	when "00" =>

	if (pkt_rx_avail = '1' and en_rcv = '1') then
		pkt_rx_ren <= '1';
		tmp_state <= "01";
	end if;

	when "01" =>
	if (fifo_is_full = '1') then
		if ((pkt_rx_eop = '1' and pkt_rx_val = '1') or pkt_rx_err = '1') then
			tmp_state <= "00";
		else
			tmp_state <= "11";
			pkt_rx_ren <= '1';
		end if;
	elsif (pkt_rx_err = '1') then
		tmp_state <= "00";
		fifo_strb <= '1';
		fifo_drop <= '1';
	elsif (pkt_rx_val = '0') then
		tmp_state <= "01";
		cnt_temp <= cnt;
		pkt_rx_ren <= '1'; --IS IT OK?
	elsif (pkt_rx_val = '1' and pkt_rx_eop = '0') then
		tmp_state <= "01";
		pkt_rx_ren <= '1';
		fifo_strb <= '1';
		pkt_rx_data_s <= pkt_rx_data;
		cnt_temp <= cnt + 8;
	elsif (pkt_rx_val = '1' and pkt_rx_eop = '1') then
		tmp_state <= "10";
		fifo_strb <= '1';
		MOD_VAL(cnt, cnt_temp, pkt_rx_data, pkt_rx_data_s, pkt_rx_mod);
	end if;

	when "10" =>
	if (fifo_is_full = '0') then
		eop_strb <= '1';
		fifo_cnt_strb <= '1';
	end if;
	when "11" =>
	if (pkt_rx_eop = '0' or pkt_rx_val = '0') then
		pkt_rx_ren <= '1';
		tmp_state <= "11";		
	end if;	
	when others =>
		tmp_state <= "00";
	end case;

end process;

end Behavioral;
