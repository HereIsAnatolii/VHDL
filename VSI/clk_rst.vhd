----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/08/2024 06:30:32 PM
-- Design Name: 
-- Module Name: clk_rst - Behavioral
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

entity clk_rst is
    Port ( clk_100 : out STD_LOGIC;
           rst : out STD_LOGIC;
           samp: out STD_LOGIC;
           angle : out STD_LOGIC_VECTOR (31 downto 0));
end clk_rst;

architecture Behavioral of clk_rst is
signal clk_tb, rst_tb, samp_tb : std_logic;
signal angle_tb : signed(31 downto 0);
begin

rst_tb <= '1', '0' after 10 ns;

samp <= samp_tb;
clk_100 <= clk_tb;
rst <= rst_tb;
angle <= std_logic_vector(angle_tb);
-- 100 MHz
process
begin
    clk_tb <= '0';
    wait for 5 ns;
    clk_tb <= '1';
    wait for 5 ns;
end process;

-- 25 MHz
process
begin
    samp_tb <= '0';
    wait for 20 ns;
    samp_tb <= '1';
    wait for 20 ns;
end process;

-- angle
process(clk_tb,rst_tb) is
variable PI2 : signed(31 downto 0) := x"0006_487F";
variable cnt : integer;
begin
    if rst_tb = '1' then
        angle_tb <= (others => '0');
        cnt := 0;
    elsif rising_edge(clk_tb) then
        if cnt >= 4 then
            cnt := 0;
            if angle_tb >= PI2 then
                angle_tb <= (others => '0');
            else
                angle_tb <= angle_tb + to_signed(1,31);
            end if;
        else
            cnt := cnt + 1;
        end if;
    end if;
end process;
end Behavioral;
