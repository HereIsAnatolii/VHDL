----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/16/2024 11:50:50 AM
-- Design Name: 
-- Module Name: ab_abc - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alphabeta_2_abc is
    generic (width : integer := 32;
             frac  : integer := 16);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           alpha : in STD_LOGIC_VECTOR (width-1 downto 0);
           beta : in STD_LOGIC_VECTOR (width-1 downto 0);
           
           a : out STD_LOGIC_VECTOR (width-1 downto 0);
           b : out STD_LOGIC_VECTOR (width-1 downto 0);
           c : out STD_LOGIC_VECTOR (width-1 downto 0)
           );
end alphabeta_2_abc ;

architecture Behavioral of alphabeta_2_abc  is
signal alpha_temp, beta_sqrt_3,a_temp,b_temp,c_temp : signed(2*width-1 downto 0);
signal diff : signed(31 downto 0);
begin

a <= std_logic_vector(a_temp(frac+width-1 downto frac));
b <= std_logic_vector(b_temp(frac+width-1 downto frac));
c <= std_logic_vector(c_temp(frac+width-1 downto frac));

-- A = alpha
-- B = (beta*sqrt(3) - alpha)/2;
-- C = (- beta*sqrt(3) - alpha/2);
process (clk,rst) is
variable step : integer range 0 to 10;
constant one : signed(width-1 downto 0) := x"0001_0000";
constant sqrt_3 : signed(width-1 downto 0) := x"0001_BB68";    -- 3^0.5 in 2^16
begin
    if rst = '1' then
        step := 0;
        a_temp <= (others => '0');
        b_temp <= (others => '0');
        c_temp <= (others => '0');
    elsif rising_edge(clk) then
        case step is
            when 0 => step := 1;
                beta_sqrt_3 <= signed(beta)*sqrt_3;
            when 1 => step := 2;
                a_temp <= signed(alpha) * one;
            when 2 => step := 3;
                b_temp <= shift_right(beta_sqrt_3,1) - shift_right(a_temp,1);
            when 3 => step := 4;
                c_temp <=-shift_right(beta_sqrt_3,1) - shift_right(a_temp,1 );
            when 4 => step := 5;
            when others => step := 0;
      end case;

    end if;
end process;
end Behavioral;
