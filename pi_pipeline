library IEEE;
library IEEE_proposed;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE_PROPOSED.FIXED_PKG.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Pi_pipeline is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sync     : in STD_LOGIC;
           
           Kp_ref   :  in ufixed (3 downto -16);
           KiTs_ref :  in ufixed (3 downto -16);
           Kaw_ref  :  in ufixed (3 downto -16);
           
           sig_ref  :  in sfixed (6 downto -32);
           pi_in    :  in sfixed (10 downto -32);
           pi_out   : out sfixed (14 downto -32));
end entity;

architecture Behavioral of Pi_pipeline is

signal Iterm : sfixed(16 downto -32) := (others=>'0');
signal errKi : sfixed(16 downto -32) := (others=>'0');
signal errKp : sfixed(16 downto -32) := (others=>'0');
signal PIsum, PIlim, AW, PIaw : sfixed(16 downto -32) := (others=>'0');
signal Iterm_aw, PIfin : sfixed(16 downto -32) := (others=>'0');
signal AW_flag : std_logic_vector(1 downto 0);

signal pi_calc : sfixed(14 downto -32) := (others=>'0');
signal pi_mes : sfixed(10 downto -32) := (others=>'0');
signal sig_err : sfixed(16 downto -32) := (others=>'0');
signal data_rdy : std_logic;
signal sync_sig : std_logic_vector(1 downto 0);

signal Kp   : sfixed(3 downto -16);
signal KiTs : sfixed(3 downto -16);
signal Kaw  : sfixed(3 downto -16);

-- PIPELINE VARIABLES --
signal err_ready, p_ready, i_ready, pi_ready : std_logic;
begin
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
pi_out <= pi_calc;
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------

-- SET KP, KI, KAW gains --
process(clk,rst) is
begin
    if rst = '1' then
        Kp <= to_sfixed(1,Kp);
        KiTs <= to_sfixed(1,KiTs);
        Kaw <= to_sfixed(1,Kaw);
    elsif rising_edge(clk) then
        Kp <=   sfixed(Kp_ref);
        KiTs <= sfixed(KiTs_ref);
        Kaw <=  sfixed(Kaw_ref);
    end if;
end process;

pi_mes <= pi_in;
-- MAIN SAMPLING + ERROR LOOP --
    process(clk,rst) is
    variable step : integer range 0 to 2 := 0;
    begin
        if rst = '1' then
        -- RESET ALL THE VALUES FOR THE CONTROL --
            sig_err <= (others=>'0');
            pi_calc <= (others=>'0');
            step := 0;
            
            sync_sig <= "00";
            err_ready <= '0';
        elsif rising_edge(clk) then
            sync_sig(0) <= sync;
            if (sync_sig(1) = '0' and sync_sig(0) = '1') then
            -- SAMPLING TIME HIT, UPDATE THE OUTPUT -- 
                step := 0;
                pi_calc <=  resize(arg=>PIfin,size_res=>pi_calc,overflow_style=>fixed_saturate,round_style=>fixed_round);
                err_ready <= '0';
            end if;
            case step is
            -- CALCULATE THE OUTPUT FOR THE NEXT SAMPLING HIT --
                when 0 => step := 1;
                    sig_err <= resize(arg=>sig_ref-pi_mes,size_res=>sig_err,overflow_style=>fixed_saturate,round_style=>fixed_round);
                when 1 => step := 2;
                    err_ready <= '1';
                when others => step := 2;
          end case;
          sync_sig(1) <= sync_sig(0);
        end if;
    end process;
    
------------------------------------------------------------------------------------------------------------------------------------------------------
-- P GAIN CALCULATION LOOP --
------------------------------------------------------------------------------------------------------------------------------------------------------
    process(clk,rst) is
    variable step : integer range 0 to 2 := 0;
    begin
        if rst = '1' then
        -- RESET ALL THE VALUES FOR THE CONTROL --
            errKp <= (others=>'0');
			p_ready <= '0';
            step := 0;
        elsif rising_edge(clk) then
            if(err_ready = '1') then
                case step is
                    when 0 => step := 1;
                        errKp <= resize(arg=>sig_err*Kp,size_res=>errKp,overflow_style=>fixed_saturate,round_style=>fixed_round);
                    when 1 => step := 2;
						p_ready <= '1';
                    when others => step := 2;
              end case;
            else
                step := 0;
				p_ready <= '0';
            end if;
        end if;
    end process;

------------------------------------------------------------------------------------------------------------------------------------------------------
-- I CALCULATION LOOP --
------------------------------------------------------------------------------------------------------------------------------------------------------
    process(clk,rst) is
    variable step : integer range 0 to 4 := 0;
    begin
        if rst = '1' then
        -- RESET ALL THE VALUES FOR THE CONTROL --
            errKi <= (others=>'0');
            Iterm <= (others=>'0');
            Iterm_aw <= (others=>'0');
            i_ready <= '0';
            step := 0;
        elsif rising_edge(clk) then
            if(err_ready = '1') then
                case step is
                    when 0 => step := 1;
                        errKi <= resize(arg=>sig_err*KiTs,size_res=>errKi,overflow_style=>fixed_saturate,round_style=>fixed_round);
                    when 1 => step := 2;
                        if AW_flag /= "00" then
                            Iterm_aw <= resize(arg=>errKi-AW,size_res=>Iterm_aw,overflow_style=>fixed_saturate,round_style=>fixed_round);
                        else
                            Iterm_aw <= resize(arg=>errKi,size_res=>Iterm_aw,overflow_style=>fixed_saturate,round_style=>fixed_round);
                        end if;
                    when 2 => step := 3;
                        Iterm <= resize(arg=>Iterm+Iterm_aw,size_res=>Iterm,overflow_style=>fixed_saturate,round_style=>fixed_round);
                    when 3 => step := 4;
                        i_ready <= '1';
                    when others => step := 4;
              end case;
            else
                step := 0;
                i_ready <= '0';
            end if;
        end if;
    end process;
    
------------------------------------------------------------------------------------------------------------------------------------------------------
-- PI SUM LOOP --
------------------------------------------------------------------------------------------------------------------------------------------------------
    process(clk,rst) is
    variable step : integer range 0 to 2 := 0;
    begin
        if rst = '1' then
        -- RESET ALL THE VALUES FOR THE CONTROL --
            PIsum <= (others=>'0');
            pi_ready <= '0';
            step := 0;
        elsif rising_edge(clk) then
            if(p_ready = '1' and i_ready = '1') then
                case step is
                    when 0 => step := 1;
                        PIsum <= resize(arg=>Iterm+errKp,size_res=>PIsum,overflow_style=>fixed_saturate,round_style=>fixed_round);
                    when 1 => step := 2;
                        pi_ready <= '1';
                    when others => step := 2;
              end case;
            else
                step := 0;
                pi_ready <= '0';
            end if;
        end if;
    end process;
    
------------------------------------------------------------------------------------------------------------------------------------------------------
-- Anti-Windup LOOP --
------------------------------------------------------------------------------------------------------------------------------------------------------
    process(clk,rst) is
    variable step : integer range 0 to 3 := 0;
    begin
        if rst = '1' then
        -- RESET ALL THE VALUES FOR THE CONTROL --
            PIfin <= (others => '0');
            PIlim <= to_sfixed(110,16,-32);
            PIaw <= (others => '0');
            AW_flag <= "00";
            AW <= (others => '0');
            step := 0;
        elsif rising_edge(clk) then
            if(pi_ready = '1') then
                case step is
                    when 0 => step := 1;                        
                        if PIsum > PIlim then
                            PIfin <= resize(arg=>PIlim,size_res=>PIfin,overflow_style=>fixed_saturate,round_style=>fixed_round);
                            AW_flag <= "01";
                        elsif PIsum <-PIlim then
                            PIfin <= resize(arg=>-PIlim,size_res=>PIfin,overflow_style=>fixed_saturate,round_style=>fixed_round);
                            AW_flag <= "10";
                        else
                            PIfin <= PIsum;
                            AW_flag <= "00";
                        end if;
                    when 1 => step := 2;
                        if AW_flag = "01" then
                            PIaw <= resize(arg=>(PIsum-PIlim),size_res=>PIaw,overflow_style=>fixed_saturate,round_style=>fixed_round);
                        elsif AW_flag = "10" then
                            PIaw <= resize(arg=>(PIlim+PIsum),size_res=>PIaw,overflow_style=>fixed_saturate,round_style=>fixed_round);
                        else
                            PIaw <= (others=>'0');
                        end if;
                    when 2 => step := 3;
                        if AW_flag /= "00" then
                            AW <= resize(arg=>PIaw*Kaw,size_res=>AW,overflow_style=>fixed_saturate,round_style=>fixed_round);
                        else
                            AW <= (others=>'0');
                        end if;
                    when others => step := 3;
              end case;
            else
                step := 0;
            end if;
        end if;
    end process;

end Behavioral;
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
-- DECLARATION --
--component PI_fixed is
--    generic (width : integer := 32);
--    Port ( clk : in STD_LOGIC;
--           rst : in STD_LOGIC;
--           sync    : in STD_LOGIC;
--           clr_iterm : in STD_LOGIC;
--           Kp_ref   :  in ufixed (3 downto -32);
--           KiTs_ref :  in ufixed (3 downto -32);
--           Kaw_ref  :  in ufixed (3 downto -32);
--           sig_ref :  in sfixed (6 downto -32);
--           pi_in   :  in sfixed (10 downto -32);
--           pi_out  : out sfixed (14 downto -32));
--end component;
-- INITIALIZATION --
--PI_FIXED_1: component pi_fixed
--generic map(width => 32)
--port map (
--    clk=>clk,
--    rst=>rst,
--    sync=>sync,
--    clk_iterm=>clr_iterm,
--    Kp_ref=>Kp_f,
--    KiTs_ref=>KiTs_f,
--    Kaw_ref =>Kaw_f,
--    sig_ref=>ref_val_f,
--    pi_in=>pi_in_f,
--    pi_out=>pi_out_f
--);
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
