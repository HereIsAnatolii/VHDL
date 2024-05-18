library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RLC_filter is
    generic (width : integer := 40;
             frac : integer := 31);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sync : in STD_LOGIC;
           
           sig_in : in STD_LOGIC_VECTOR(width-1 downto 0);
           Ts     : in STD_LOGIC_VECTOR(width-1 downto 0);
           L_div_Ts  : in STD_LOGIC_VECTOR(width-1 downto 0);
           C_div_Ts  : in STD_LOGIC_VECTOR(width-1 downto 0);
           R_div  : in STD_LOGIC_VECTOR(width-1 downto 0);
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

lpf_out <= std_logic_vector(y_2);

W2_CALC: process(clk,rst) is
variable step : integer range 0 to 5 := 0;
variable Ts_L_temp : signed(2*width-1 downto 0);
variable Ts_C_temp : signed(2*width-1 downto 0);
begin
    if rst = '1' then
        step := 0;
        Ts_L_temp := (others =>'0');
        Ts_C_temp := (others =>'0');
        Ts_L <= (others=>'0');
        Ts_C <= (others=>'0');
        ready(0) <= '0';
    elsif rising_edge(clk) then
        if (sync_sig(1) = '0' and sync_sig(0) = '1') then
            step := 0;
            ready(0) <= '0';
        end if;
        case step is
            when 0 => step := 1;
--                Ts_L_temp := signed(L_div_Ts)*signed(Ts);
                Ts_L <= signed(L_div_Ts);--Ts_L_temp(frac+width-1 downto frac);
            when 1 => step := 2;
--                Ts_C_temp := signed(C_div)*signed(Ts);
                Ts_C <= signed(C_div_Ts);--Ts_C_temp(width+frac-1 downto frac);
            when 2 => step := 3;
                ready(0) <= '1';
            when others => step := 5;
        end case;
    end if;
end process;

LPF_CALC: process(clk,rst) is
variable step : integer range 0 to 10 := 0;
begin
    if rst = '1' then
        step := 10;
        ready(1) <= '0';
        sync_sig <= "00";
        u   <= (others =>'0');
        x_1 <= (others =>'0');
        x_2 <= (others =>'0');
        y_1   <= (others =>'0');
        y_2   <= (others =>'0');
        
        dx_1   <= (others =>'0');
        dx_2   <= (others =>'0');
        diff_1 <= (others =>'0');
        diff_2 <= (others =>'0');
        
        x1_R <= (others =>'0');
    elsif rising_edge(clk) then
        sync_sig(1) <= sync_sig(0);
        sync_sig(0) <= sync;
        if (sync_sig(1) = '0' and sync_sig(0) = '1') then
            step := 0;
            ready(1) <= '0';
            u <= signed(sig_in);
            y_1 <= x_1;
        end if;
        case step is
            when 0 => 
                diff_2 <= u - x_1;
                if ready(0) = '1' then
                    step := 1;
                end if;
            when 1 => step := 2;
                dx_2 <= diff_2 * Ts_L;
            when 2 => step := 3;
                diff_1 <= x_2 - y_2; 
            when 3 => step := 4;
                dx_1 <= diff_1 * Ts_C;
            when 4 => step := 5;
                x_1 <= x_1 + dx_1(width+frac-1 downto frac);
            when 5 => step := 6;
                x_2 <= x_2 + dx_2(width+frac-1 downto frac);
            when 6 => step := 7;
                x1_R <= x_1 * signed(R_div);
            when 7 => step := 8;
                y_2 <= x1_R(width+frac-1 downto frac);
            when 8 => step := 9;
                ready(1) <= '1';
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
--           L_div  : in STD_LOGIC_VECTOR(width-1 downto 0);
--           C_div  : in STD_LOGIC_VECTOR(width-1 downto 0);
--           R_div  : in STD_LOGIC_VECTOR(width-1 downto 0);
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
--        L_div   =>,
--        C_div   =>,
--        R_div   =>,
--        lpf_out =>,
--);
