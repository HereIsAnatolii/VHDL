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
    generic (width : integer := 16 );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           modulation : in STD_LOGIC_VECTOR(width-1 downto 0);
           scale   : in STD_LOGIC_VECTOR(width-1 downto 0);
           pwm_out : out STD_LOGIC_VECTOR(width-1 downto 0);
           sync    : out STD_LOGIC;
           pwm_3lvl   : out STD_LOGIC_VECTOR(1 downto 0)
           );
end pwm;

architecture Behavioral of pwm is
signal car_top : signed(width-1 downto 0);
signal car_bot : signed(width-1 downto 0);
signal sync_sig : std_logic;
begin

sync <= sync_sig;
process(clk,rst) is
variable dir : std_logic;
begin
    if rst = '0' then
        car_top <= (others=>'0');
        sync_sig <= '0';
        dir := '1';
    elsif rising_edge(clk) then
        if car_top > (signed(scale)-53) and dir = '1' then
            sync_sig <= not sync_sig;
            dir := '0';
        elsif car_top < to_signed(35,width) and dir = '0' then
            dir := '1';
        elsif dir = '1' then
            car_top <= car_top + x"0035";
        else
            car_top <= car_top - x"0035";
        end if;
        car_bot <= -car_top;
    end if;
end process;

process(clk,rst) is
begin
    if rst = '0' then
        pwm_out <= (others=>'0');
        pwm_3lvl <= b"00";
    elsif rising_edge(clk) then
        if signed(modulation) > car_top then
            pwm_out <= scale;   -- 16x6 400
            pwm_3lvl <= b"01";
        elsif signed(modulation) < car_bot then
            pwm_out <= std_logic_vector(- signed(scale));   -- 40x30 -400
            pwm_3lvl <= b"10";
        else
            pwm_out <= (others=>'0');
            pwm_3lvl <= b"00";
        end if;
    end if;
end process;

end Behavioral;
