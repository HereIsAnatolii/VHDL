----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dr. Anatolii Tcai 
-- 
-- Create Date: 10/12/2024 02:40:06 PM
-- Design Name: 
-- Module Name: RL_filter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RL_filter is
    generic (width : integer := 32;
             frac : integer := 16);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sync : in STD_LOGIC;
           
           sig_in    : in STD_LOGIC_VECTOR(width-1 downto 0);
           Ts_over_L : in STD_LOGIC_VECTOR(width-1 downto 0);
           R         : in STD_LOGIC_VECTOR(width-1 downto 0);
           lpf_out   : out STD_LOGIC_VECTOR (width-1 downto 0));
end entity;

architecture Behavioral of RL_filter is
signal sync_sig : std_logic_vector(1 downto 0);
signal u, y_1, x_1 : signed(width-1 downto 0);
signal diff_1 : signed(width-1 downto 0);
signal dx_1, x1_R : signed(2*width-1 downto 0);

signal ready : std_logic_vector(1 downto 0);
begin

lpf_out <= std_logic_vector(y_1);

LPF_CALC: process(clk,rst) is
variable step : integer range 0 to 10 := 0;
begin
    if rst = '1' then
        step := 10;
        ready(0) <= '0';
        ready(1) <= '0';
        sync_sig <= "00";
        u   <= (others =>'0');
        x_1 <= (others =>'0');
        y_1   <= (others =>'0');
        
        dx_1   <= (others =>'0');
        diff_1 <= (others =>'0');
        
        x1_R <= (others =>'0');
    elsif rising_edge(clk) then
        sync_sig(1) <= sync_sig(0);
        sync_sig(0) <= sync;
        if (sync_sig(1) = '0' and sync_sig(0) = '1') then
            step := 0;
            u <= signed(sig_in);
            y_1 <= x_1;
        end if;
        case step is
            when 0 => step := 1;
             -- dx1 = (sig_in-x1*R)/L; 
                diff_1 <= u - x1_R(width+frac-1 downto frac);
                ready(0) <= '0';
            when 1 => step := 2;
             -- dx1 = (sig_in-x1*R)/L;
                dx_1 <= diff_1 * signed(Ts_over_L); 
            when 2 => step := 3;
                x_1 <= x_1 + dx_1(width+frac-1 downto frac);
            when 3 => step := 4;
                x1_R <= x_1 * signed(R);
            when 4 => step := 5;
                ready(0) <= '1';
            when others => step := 6;
      end case;
    end if;
end process;

end Behavioral;

----- COPY COMPONENT DEFINITION -----
--component RL_filter is
--    generic (width : integer := 40;
--             frac : integer := 31);
--    Port ( clk : in STD_LOGIC;
--           rst : in STD_LOGIC;
--           sync : in STD_LOGIC;
           
--           sig_in    : in STD_LOGIC_VECTOR(width-1 downto 0);
--           Ts_over_L : in STD_LOGIC_VECTOR(width-1 downto 0);
--           R         : in STD_LOGIC_VECTOR(width-1 downto 0);
--           lpf_out   : out STD_LOGIC_VECTOR (width-1 downto 0));
--end component;

--RL_INST_1: rl_filter 
--generic map (
--        width => 64, 
--        frac => 31)
--port map (
--        clk       =>,
--        rst       =>,
--        sync      =>,
        
--        sig_in    =>,
--        Ts_over_L =>,
--        R         =>,
--        lpf_out   =>,
--);