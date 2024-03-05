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

entity cmv is
    Port ( a : in STD_LOGIC_VECTOR (15 downto 0);
           b : in STD_LOGIC_VECTOR (15 downto 0);
           c : in STD_LOGIC_VECTOR (15 downto 0);
           
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           
           cmv_out : out STD_LOGIC_VECTOR (15 downto 0));
end cmv;

architecture Behavioral of cmv is
signal sum_1   : signed(15 downto 0);
signal sum_2   : signed(15 downto 0);
signal cmv_temp   : signed(31 downto 0);
begin

process (clk,rst) is
variable step : integer range 0 to 10;
constant val_1_3 : signed(15 downto 0) := x"1555";    -- 1/3^0.5 in 2^14
begin
    if rst = '0' then
        step := 0;
        sum_1 <= (others=>'0');
        sum_2 <= (others=>'0');
    elsif rising_edge(clk) then
        case step is
            when 0 => step := 1;
                sum_1 <= signed(a) + signed(b); 
            when 1 => step := 2;
                sum_2 <= signed(c) + sum_1;
            when 2 => step := 3;
                cmv_temp <= sum_2 * val_1_3;
            when 3 => step := 4;
                cmv_out <= std_logic_vector(cmv_temp(31 downto 16) );
            when others => step := 0;
      end case;

    end if;
end process;

end Behavioral;
