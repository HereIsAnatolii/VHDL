----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PR_Control is
  generic (width : integer := 40;
           frac  : integer := 31);
  Port (clk       : in  STD_LOGIC;
        local_rst : in STD_LOGIC;
        sync      : in STD_LOGIC;
        clk_out   : out STD_LOGIC;
        ref_in    : in  STD_LOGIC_VECTOR(width-1 downto 0);
        sig_in    : in  STD_LOGIC_VECTOR(width-1 downto 0);
        sig_out   : out STD_LOGIC_VECTOR(width-1 downto 0)
   );
end PR_Control;

architecture Behavioral of PR_Control is

signal sig_calc : signed(width-1 downto 0);
signal err, diff, tsamp : signed(width-1 downto 0);
signal iterm_1, iterm_2 : signed(width-1 downto 0);
signal product_iterm : signed(2*width-1 downto 0);
signal sum, sum_shift : signed(2*width-1 downto 0);

signal diff_samp : signed(width-1 downto 0);
signal Ts_ww : signed(width-1 downto 0);
signal Pgain, Rgain : signed(2*width-1 downto 0);
signal Kp, Kr: signed(width-1 downto 0);
signal norm : signed(2*width-1 downto 0);
signal sync_sig : std_logic_vector(1 downto 0);
begin

sig_out <= std_logic_vector(sig_calc);

process(clk,local_rst) is
variable step : integer range 0 to 15 := 0;

begin
    if local_rst = '0' then
--        err <= (others=>'0');S
        iterm_1 <= (others=>'0');
        iterm_2 <= (others=>'0');
        
        diff <= (others=>'0');
        
        sig_calc <= (others =>'0');
        Tsamp(15 downto 0) <= x"53E3";   -- 50 kHz => 20 usec * 2^30 => 21474.83648 => 21475
        Tsamp(width-1 downto 16) <= (others=>'0');
        Ts_ww(15 downto 0) <= x"A596";--x"A596";    -- 50 kHz => (20 usec)^2 * (314.159)^2 * 2^30 => 42389.55651719244 => 42390
        Ts_ww(width-1 downto 16) <= (others=>'0');
        
        Kp(31 downto 0) <= x"8000_0000";        -- 2*2^30  => 0x8000_0000
        Kp(width-1 downto 32) <= (others=>'0');
        Kr(35 downto 0) <= x"3_C000_0000";      -- 15*2^30 => 0x3_C000_0000
        Kr(width-1 downto 36) <= (others=>'0');
        
        step := 10;
        sync_sig <= "00";
    elsif rising_edge(clk) then                                                                                                                                                                                 
        sync_sig(0) <= sync;
        if (sync_sig(1) = '0' and sync_sig(0) = '1') then
            step := 0;
            sig_calc <= sum_shift(2*width-1 downto width);    -- sum_shift
        end if;
        case step is
            when 0 => step := 1;
                err <= signed(ref_in) - signed(sig_in);     -- Create signal error
            when 1 => step := 2;
                diff <= err - iterm_2;                      -- second integral difference
            when 2 => step := 3;
                iterm_1 <= iterm_1 + diff;                  -- first integration
            when 3 => step := 4;
                product_iterm <= iterm_1 * Ts_ww;           -- Scaling to the frequency
            when 4 => step := 5;
                iterm_2 <= shift_left(product_iterm,width-frac)(2*width-1 downto width);    -- Integrate
            when 5 => step := 6;
                Rgain <= Kr*iterm_1;                        -- Resonant gain calculation
            when 6 => step := 7;
                Pgain <= Kp*err;                            -- Proportional gain calculation
            when 7 => step := 8;
                sum <= Pgain + Rgain;
            when 8 => step := 9;
                sum_shift <= shift_left(sum,width-frac);
            when 9 => step := 10;
--                norm <= sum_shift(2*width-1 downto width) * to_signed(50,width);
            when others => step := 10;
      end case;
    end if;
end process;

--SYNC_TO_CLK: process(local_rst,clk) is
--variable sync : std_logic_vector(2 downto 0);
--begin
--    if local_rst = '0' then
--        sig_out <= (others => '0');
--        sync := (others => '0');
--    elsif rising_edge(clk) then
--        sync(0) := data_rdy;
--        sync(1) := sync(0);
--        sync(2) := sync(1);
--        if sync(2) /= sync(1) then
--            sig_out <= std_logic_vector(y0);
--        end if;
--    end if;
--end process;
            
end Behavioral;
