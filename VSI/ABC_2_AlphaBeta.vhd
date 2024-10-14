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

entity abc_2_alphabeta is
    generic (width : integer := 32;
             frac  : integer := 16);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           A : in STD_LOGIC_VECTOR (width-1 downto 0);
           B : in STD_LOGIC_VECTOR (width-1 downto 0);
           C : in STD_LOGIC_VECTOR (width-1 downto 0);
           
           alpha : out STD_LOGIC_VECTOR (width-1 downto 0);
           beta  : out STD_LOGIC_VECTOR (width-1 downto 0)
           );
end entity ;

architecture Behavioral of abc_2_alphabeta  is
signal beta_temp : signed(2*width-1 downto 0);
signal diff : signed(31 downto 0);
begin

alpha <= A;
beta  <= std_logic_vector( beta_temp(frac+width-1 downto frac));

-- alpha = A;
-- beta = (B-C)/sqrt(3);
process (clk,rst) is
variable step : integer range 0 to 10;
constant one_over_sqrt_3 : signed(width-1 downto 0) := x"0000_93CD";    -- 1/3^0.5 in 2^16
begin
    if rst = '1' then
        step := 0;
        diff <= (others=>'0');
        beta_temp <= (others=>'0');
    elsif rising_edge(clk) then
        case step is
            when 0 => step := 1;
                diff <= signed(B) - signed(C);
            when 1 => step := 2;
                beta_temp <= one_over_sqrt_3 * diff;
            when others => step := 0;
      end case;

    end if;
end process;
end Behavioral;
