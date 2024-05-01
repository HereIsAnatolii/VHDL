----------------------------------------------------------------------------------
-- Company: HereIsAnatolii
-- Engineer: Dr. Anatolii Tcai
-- 
-- Create Date: 04/06/2024 07:50:45 AM
-- Design Name: PI controller with Antiwindup
-- Module Name: PI_controller
-- Project Name: Private
-- Target Devices: 
-- Tool Versions: 
-- Description: Fixed-point logic PI controller with antiwindup
-- 
-- Dependencies: 
-- no
-- Revision:
-- Revision 0.00 - File Created
-- Revision 0.01 - Reset added 
-- Revision 0.10 - File modified, definition and initialization prototypes added 
-- Revision 0.20 - Inputs and outputs are converted into signed 
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pi_aw is
    generic (width : integer := 40;
             frac  : integer := 31;
             d_size  : integer := 32);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sync : in STD_LOGIC;
           
           Kp_gain   : in STD_LOGIC_VECTOR (width-1 downto 0);
           KiTs_gain : in STD_LOGIC_VECTOR (width-1 downto 0);
           Kaw_gain  : in STD_LOGIC_VECTOR (width-1 downto 0);
           
           Lim_high : in STD_LOGIC_VECTOR (width-1 downto 0);
           Lim_low  : in STD_LOGIC_VECTOR (width-1 downto 0);
           sig_ref  : in STD_LOGIC_VECTOR (width-1 downto 0);
           sig_nref : in STD_LOGIC_VECTOR (width-1 downto 0);
           pi_in    : in STD_LOGIC_VECTOR (width-1 downto 0);
           pi_fixed : out STD_LOGIC_VECTOR (width-1 downto 0);
           duty_out : out SIGNED (d_size-1 downto 0));
end pi_aw;

architecture Behavioral of pi_aw is
signal pi_calc : std_logic_vector(width-1 downto 0);
signal sig_err : signed(width-1 downto 0);
signal product_P, product_I, product_aw : signed(2*width-1 downto 0);
signal norm,lim_h, lim_l : signed(2*width-1 downto 0);
signal sum_I, sum_I_AW : signed(2*width-1 downto 0);
signal sum_PI, pi_fin, aw : signed(width-1 downto 0);
signal data_rdy : std_logic;
signal sync_sig : std_logic_vector(1 downto 0);
signal Kp, KiTs, Kaw  : signed(width-1 downto 0);
signal feedback : signed(width-1 downto 0);

signal duty : signed(d_size-1 downto 0);
signal mul_duty : signed(width-1 downto 0);
begin

pi_fixed <= pi_calc;

process(clk,rst) is
variable step : integer range 0 to 14;
variable one :signed(width-1 downto 0);
begin
    if rst = '1' then
        sig_err <= (others=>'0');
        product_P <= (others=>'0');
        product_I <= (others=>'0');
        product_aw <= (others=>'0');
        sum_I <= (others=>'0');

        sum_PI <= (others=>'0');
        aw <= (others=>'0');
        pi_calc <= (others=>'0');
        data_rdy <= '0';
        feedback <= (others=>'0');
        
        lim_h <= (others => '0');
        lim_l <= (others => '0');
        lim_h(2*frac) <= '1';

        one := (others => '0');
        one(frac) := '1';
        
        Kp <= (others => '0');
        Kaw <= (others => '0');
        Kp(frac-1) <= '1';
        Kaw(frac-1) <= '1';
        KiTs  <= (others => '0');

        mul_duty <= to_signed(800,width);
        
        step := 0;
        sync_sig <= "00";
    elsif rising_edge(clk) then
        sync_sig(0) <= sync;
        if (sync_sig(1) = '0' and sync_sig(0) = '1') then
            step := 0;
            pi_calc  <= std_logic_vector(pi_fin);
            feedback <= signed(pi_in);
            duty_out <= duty;
        else
            Kp   <= signed(Kp_gain);
            KiTs <= signed(KiTs_gain);
            Kaw  <= signed(Kaw_gain);
        end if;
        case step is
            when 0 => step := 1;
                sig_err <= signed(sig_ref) - feedback;
                data_rdy <= '0';
            when 1 => step := 2;
                product_P <= sig_err*Kp;
            when 2 => step := 3;
                product_I <= sig_err*KiTs;
            when 3 => step := 4;
                sum_I_AW <= product_I + product_aw; 
            when 4 => step := 5;
                sum_I <= sum_I + sum_I_AW;
            when 5 => step := 6;
                sum_PI <= product_P(width+frac-1 downto frac) + sum_I(width+frac-1 downto frac);
            when 6 => step := 7;
                norm <= sum_PI*signed(sig_nref);
            when 7 => step := 8;
                lim_h <= signed(Lim_high)*one;
            when 8 => step := 9;
                lim_l <= signed(Lim_low)*one;
            when 9 => step := 10;
                if(norm > lim_h) then
                    pi_fin <= lim_h;
                    aw <= lim_h(width+frac-1 downto frac) - norm(width+frac-1 downto frac);
                elsif(norm < lim_l) then
                    pi_fin <= lim_l;
                    aw <= lim_l(width+frac-1 downto frac) - norm(width+frac-1 downto frac);
                else
                    pi_fin <= norm;
                    aw <= (others => '0');
                end if;
            when 10 => step := 11;
                product_aw <= aw*Kaw;
            when 11 => step := 12;
                duty <= pi_fin(width+frac-1 downto frac) * mul_duty;
            when 12 => step := 13;
                data_rdy <= '1';
            when others => step := 13;
      end case;
    end if;
end process;

end Behavioral;

----- COPY COMPONENT DEFINITION -----
--component pi_aw is
--    generic (width  : integer := 40;
--             frac   : integer := 31;
--             d_size : integer := 32);
--    Port ( clk : in STD_LOGIC;
--           rst : in STD_LOGIC;
--           sync : in STD_LOGIC;
           
--           Kp_gain : in STD_LOGIC_VECTOR (width-1 downto 0);
--           KiTs_gain : in STD_LOGIC_VECTOR (width-1 downto 0);
--           Kaw_gain : in STD_LOGIC_VECTOR (width-1 downto 0);
           
--           Lim_high : in STD_LOGIC_VECTOR (width-1 downto 0);
--           Lim_low  : in STD_LOGIC_VECTOR (width-1 downto 0);
           
--           sig_ref : in STD_LOGIC_VECTOR (width-1 downto 0);
--           sig_nref : in STD_LOGIC_VECTOR (width-1 downto 0);
--           pi_in : in STD_LOGIC_VECTOR (width-1 downto 0);
--           pi_out : out STD_LOGIC_VECTOR (width-1 downto 0));
--end component;
----- COPY ENTITY DEFINITION -----
