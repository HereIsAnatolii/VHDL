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

entity ab_abc is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           alpha : in STD_LOGIC_VECTOR (15 downto 0);
           
           a : out STD_LOGIC_VECTOR (15 downto 0);
           c : out STD_LOGIC_VECTOR (15 downto 0);
           b : out STD_LOGIC_VECTOR (15 downto 0);
           
           beta : in STD_LOGIC_VECTOR (15 downto 0));
end ab_abc;

architecture Behavioral of ab_abc is
signal alpha_temp, beta_sqrt_3,a_temp,b_temp,c_temp : signed(31 downto 0);
signal diff : signed(31 downto 0);
begin

a <= std_logic_vector(shift_left(a_temp,5)(31 downto 16));
b <= std_logic_vector(shift_left(b_temp,5)(31 downto 16));
c <= std_logic_vector(shift_left(-c_temp,5)(31 downto 16));
process (clk,rst) is
variable step : integer range 0 to 10;
constant sqrt_3 : signed(15 downto 0) := x"0DDB";    -- 3^0.5 in 2^11
begin
    if rst = '0' then
        step := 0;
    elsif rising_edge(clk) then
        case step is
            when 0 => step := 1;
                beta_sqrt_3 <= signed(beta)*sqrt_3;
            when 1 => step := 2;
                a_temp <= signed(alpha) * to_signed(2048,16);
            when 2 => step := 3;
                alpha_temp <= signed(alpha) * to_signed(1024,16);
            when 3 => step := 4;
                b_temp <= shift_right(beta_sqrt_3,1) - alpha_temp;
            when 4 => step := 5;
                c_temp <= shift_right(beta_sqrt_3,1) + alpha_temp;
            when others => step := 0;
      end case;

    end if;
end process;
end Behavioral;
