----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/20/2024 10:23:46 PM
-- Design Name: 
-- Module Name: pwm - Behavioral
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

entity pwm is
    generic (width : integer := 32 );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           modulation : in STD_LOGIC_VECTOR(width-1 downto 0);
           car_lim   : in STD_LOGIC_VECTOR(width-1 downto 0);
           scale     : in STD_LOGIC_VECTOR(width-1 downto 0);
           carrier   : out STD_LOGIC_VECTOR(width-1 downto 0);
           pwm_out   : out STD_LOGIC_VECTOR(width-1 downto 0);
           sync_out  : out STD_LOGIC
           );
end pwm;

architecture Behavioral of pwm is
signal carrier_sig : signed(width-1 downto 0);
signal carrier_simple : signed(width-1 downto 0);
signal dir : std_logic;
signal cnt : signed(width-1 downto 0) := x"0000_0292";
begin

carrier <= std_logic_vector(carrier_sig);
carrier_sig <= carrier_simple when dir = '0' else
              -carrier_simple;
           
pwm_out <= scale when signed(modulation) > carrier_sig else
           std_logic_vector(-signed(scale));

sync_out <= dir;

process(clk,rst) is
begin
    if rst = '1' then
        carrier_simple <= (others=>'0');
        dir <= '0';
    elsif rising_edge(clk) then
        if carrier_simple >= (signed(car_lim)) then
            carrier_simple <= - signed(car_lim);
            dir <= not dir;
        else
            carrier_simple <= carrier_simple + cnt;
        end if;
    end if;
end process;

end Behavioral;
