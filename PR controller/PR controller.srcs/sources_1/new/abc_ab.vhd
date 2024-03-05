----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/18/2024 12:03:18 AM
-- Design Name: 
-- Module Name: abc_ab - Behavioral
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

entity abc_ab is
    Port ( a : in STD_LOGIC_VECTOR (15 downto 0);
           b : in STD_LOGIC_VECTOR (15 downto 0);
           c : in STD_LOGIC_VECTOR (15 downto 0);
           
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           
           alpha : out STD_LOGIC_VECTOR (15 downto 0);
           beta  : out STD_LOGIC_VECTOR (15 downto 0));
end abc_ab;

architecture Behavioral of abc_ab is
signal beta_temp   : signed(31 downto 0);
signal diff   : signed(15 downto 0);
begin

process (clk,rst) is
variable step : integer range 0 to 10;
constant sqrt_1_3 : signed(15 downto 0) := x"24F3";    -- 1/3^0.5 in 2^14
begin
    if rst = '0' then
        step := 4;
        diff <= (others=>'0');
        beta_temp <= (others=>'0');
    elsif rising_edge(clk) then
        case step is
            when 0 => step := 1;
                diff <= signed(b) - signed(c); 
            when 1 => step := 2;
                beta_temp <= diff*sqrt_1_3;
            when 2 => step := 3;
                alpha <= a;
            when 3 => step := 4;
                beta <= std_logic_vector( shift_left(beta_temp,2)(31 downto 16) );
            when others => step := 0;
      end case;

    end if;
end process;

end Behavioral;
