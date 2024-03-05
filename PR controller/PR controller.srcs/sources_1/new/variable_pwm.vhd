----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/25/2024 07:32:24 PM
-- Design Name: 
-- Module Name: variable_pwm - Behavioral
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

entity variable_pwm is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           freq : in STD_LOGIC_VECTOR (15 downto 0);
           car : out STD_LOGIC_VECTOR (15 downto 0));
end variable_pwm;

architecture Behavioral of variable_pwm is
signal car_sig : unsigned(15 downto 0);
signal freq_un : unsigned(15 downto 0);
signal dir : std_logic;
begin

MAKE_REF: process(clk,rst) is
begin
    if rst = '0' then
        freq_un <= (others=>'0');
    elsif rising_edge(clk) then
        if signed(freq) < x"0000" then
            freq_un <= unsigned(- signed(freq) );
        else
            freq_un <= unsigned(freq);
        end if;
    end if;
end process;

MAKE_CAR: process(clk,rst) is
variable step : unsigned(15 downto 0);
begin
    if rst = '0' then
        car_sig <= (others=>'0');
        dir <= '0';
        step := x"0001";
    elsif rising_edge(clk) then
        if car_sig >= (15000-step) then
            dir <= '0';
            car_sig <= car_sig - step;
            step(5 downto 0) := freq_un(15 downto 10)+b"000001";
            step(15 downto 6) := (others=>'0');
        elsif car_sig <= (1+step) then
            dir <= '1';
            car_sig <= car_sig + step;
            step(5 downto 0) := freq_un(15 downto 10)+b"000001";
            step(15 downto 6) := (others=>'0');
        else
            if dir = '1' then
                car_sig <= car_sig + step;
            else
                car_sig <= car_sig - step;
            end if;
        end if;
    end if;
end process;
end Behavioral;
