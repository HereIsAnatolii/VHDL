----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/30/2021 01:01:29 AM
-- Design Name: 
-- Module Name: slow_sync - Behavioral
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

entity slow_sync is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sync_lpf : out STD_LOGIC;
           sync_sec : out STD_LOGIC);
end slow_sync;

architecture Behavioral of slow_sync is
signal clk_sig, clk_sync : std_logic; 
signal step : unsigned(15 downto 0) := to_unsigned(1214,16);
begin
sync_sec <= clk_sig;
sync_lpf <= clk_sync;
process(clk,rst)
variable cnt : integer range 0 to 10000;
begin
if rst = '0' then
    cnt := 0;
    clk_sig <= '0';
elsif rising_edge(clk) then
    if cnt >= to_integer(step) then
        cnt := 0;
        clk_sig <= not clk_sig;
    else
        cnt := cnt + 1;
    end if;
end if;
end process;

process(clk,rst)
variable cnt : integer range 0 to 100;
begin
if rst = '0' then
    cnt := 0;
    clk_sync <= '0';
elsif rising_edge(clk) then
    if cnt >= 9 then
        cnt := 0;
        clk_sync <= not clk_sync;
    else
        cnt := cnt + 1;
    end if;
end if;
end process;

end Behavioral;
