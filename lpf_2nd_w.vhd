library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RLC_filter is
    generic (width : integer := 40;
             frac : integer := 31);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sync : in STD_LOGIC;
           
           sig_in  : in STD_LOGIC_VECTOR(width-1 downto 0);
           Ts      : in STD_LOGIC_VECTOR(width-1 downto 0);
           w       : in STD_LOGIC_VECTOR(width-1 downto 0);
           jeta       : in STD_LOGIC_VECTOR(width-1 downto 0);
           lpf_out : out STD_LOGIC_VECTOR (width-1 downto 0));
end RLC_filter;

architecture Behavioral of RLC_filter is
signal sync_sig : std_logic_vector(1 downto 0);
signal u, y_1, y_2, x_1, x_2 : signed(width-1 downto 0);
signal diff_1, diff_2 : signed(width-1 downto 0);
signal dx_1, dx_2, x1_R : signed(2*width-1 downto 0);

signal Ts_L, Ts_C : signed(width-1 downto 0);
signal ready : std_logic_vector(1 downto 0);
begin


LPF_CALC: process(clk,rst) is
variable step : integer range 0 to 10 := 0;
begin
    if rst = '1' then
        step := 10;
        sync_sig <= "00";
		
        x(i) <= (others =>'0');
        dx(i)   <= (others =>'0');
        diff(i) <= (others =>'0');
        
    elsif rising_edge(clk) then
        sync_sig(1) <= sync_sig(0);
        sync_sig(0) <= sync;
        if (sync_sig = b"01") then
            step := 0;
			lpf_out <= std_logic_vector(x(0));
        end if;
		
        case step is
            when 0 => step := 1;
            when 1 => step := 2;
				Ts_w <= signed(Ts)*signed(w);
            when 2 => step := 3;
				-- w*sig_in
				mul(0) <= signed(w) * signed(sig_in);
            when 3 => step := 4;
				-- x2 * jeta
				mul(1) <= signed(jeta)*x(1)(width+frac-1 downto frac);
            when 4 => step := 5;
				-- w*sig_in-x1;
				diff(0) <= mul(0)(width+frac-1 downto frac) - x(0)(width+frac-1 downto frac);
            when 5 => step := 6;
				dx(0) <= x(1)(width+frac-1 downto frac);
            when 6 => step := 7;
				-- w*sig_in-x1 - 2*jeta*x2
				dx(1) <= diff(0) - mul(1)(width+frac downto frac+1);
            when 7 => step := 8;
				x(0) <= x(0)(width+frac-1 downto frac) * Ts_w(width+frac-1 downto frac);
            when 8 => step := 9;
				x(1) <= x(1)(width+frac-1 downto frac) * Ts_w(width+frac-1 downto frac);
            when others => step := 9;
      end case;
    end if;
end process;

end Behavioral;

----- COPY COMPONENT DEFINITION -----
--component RLC_filter is
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

--RLC_INST_1: rlc_filter 
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
