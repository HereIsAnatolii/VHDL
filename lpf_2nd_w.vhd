library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LPF_2nd_w is
    generic (width : integer := 40;
             frac : integer := 31);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sync : in STD_LOGIC;
           
           sig_in  : in STD_LOGIC_VECTOR(width-1 downto 0);
           w       : in STD_LOGIC_VECTOR(15 downto 0);
           jeta       : in STD_LOGIC_VECTOR(width-1 downto 0);
           Ts      : in STD_LOGIC_VECTOR(width-1 downto 0);
           lpf_out : out STD_LOGIC_VECTOR (width-1 downto 0));
end LPF_2nd_w;

architecture Behavioral of LPF_2nd_w is
type small_array is array(0 to 4) of signed(width-1 downto 0);
type big_array   is array(0 to 4) of signed(2*width-1 downto 0);
signal dx : small_array;
signal x, mul : big_array;
signal diff : signed(width-1 downto 0);
signal w_sig: signed(width-1 downto 0);
signal Ts_w : signed(2*width-1 downto 0);

begin

w_sig(width-1 downto 16) <= (others=>'0');
w_sig(15 downto 0) <= signed(w);
W_CALC: process(clk,rst) is
variable sync_sig : std_logic_vector(1 downto 0);
begin
    if rst = '1' then
        Ts_w <= signed(Ts )* w_sig;
    elsif rising_edge(clk) then
        sync_sig(1) := sync_sig(0);
        sync_sig(0) := sync;
        if (sync_sig = b"01") then
            Ts_w <= signed(Ts )* w_sig;
        end if;
    end if; 
end process;
 
LPF_CALC: process(clk,rst) is
variable step : integer range 0 to 10 := 0;
variable sync_sig : std_logic_vector(1 downto 0);
begin
    if rst = '1' then
        step := 10;
        sync_sig := "00";
		
		diff <= (others=>'0');
		
        for i in small_array'range loop
			x(i) <= (others =>'0');
			dx(i)   <= (others =>'0');
			mul(i) <= (others =>'0');
        end loop;
        lpf_out <= (others => '0');
    elsif rising_edge(clk) then
        sync_sig(1) := sync_sig(0);
        sync_sig(0) := sync;
        if (sync_sig = b"01") then
            step := 0;
			lpf_out <= std_logic_vector(x(0)(width+frac-1 downto frac));
        end if;
		
        case step is
            when 0 => step := 1;
				-- w*sig_in
				mul(0) <= signed(sig_in) * w_sig;
            when 1 => step := 2;
				-- x2 * jeta
				mul(1) <= signed(jeta)*x(1)(width+frac-1 downto frac);
            when 2 => step := 3;
				-- w*sig_in-x1;
				diff <= mul(0)(width-1 downto 0) - x(0)(width+frac-1 downto frac);
            when 3 => step := 4;
				dx(0) <= x(1)(width+frac-1 downto frac);
            when 4 => step := 5;
				-- w*sig_in-x1 - 2*jeta*x2
				dx(1) <= diff - mul(1)(width+frac-2 downto frac-1);
            when 5 => step := 6;
				mul(2) <= dx(0) * Ts_w(width-1 downto 0);
            when 6 => step := 7;
				mul(3) <= dx(1) * Ts_w(width-1 downto 0);
            when 7 => step := 8;
                x(0) <= x(0) + mul(2);
            when 8 => step := 9;
                x(1) <= x(1) + mul(3);
            when others => step := 9;
      end case;
    end if;
end process;

end Behavioral;

----- COPY COMPONENT DEFINITION -----
--component LPF_2nd_w is
--    generic (width : integer := 40;
--             frac : integer := 31);
--    Port ( clk : in STD_LOGIC;
--           rst : in STD_LOGIC;
--           sync : in STD_LOGIC;
           
--           sig_in : in STD_LOGIC_VECTOR(width-1 downto 0);
--           Ts     : in STD_LOGIC_VECTOR(width-1 downto 0);
--           w  : in STD_LOGIC_VECTOR(width-1 downto 0);
--           jeta  : in STD_LOGIC_VECTOR(width-1 downto 0);
--           lpf_out : out STD_LOGIC_VECTOR (width-1 downto 0));
--end component;

--LPF_2nd_w_INST_1: LPF_2nd_w 
--generic map (
--        width => 64, 
--        frac => 31)
--port map (
--        clk     =>,
--        rst     =>,
--        sync    =>,
        
--        sig_in  =>,
--        Ts      =>,
--        w   =>,
--        jeta   =>,
--        lpf_out =>,
--);
