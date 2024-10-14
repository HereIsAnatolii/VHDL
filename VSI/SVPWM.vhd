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

entity SVPWM is
    generic (width : integer := 32;
             frac  : integer := 16);
    Port ( a : in STD_LOGIC_VECTOR (width-1 downto 0);
           b : in STD_LOGIC_VECTOR (width-1 downto 0);
           c : in STD_LOGIC_VECTOR (width-1 downto 0);
           
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           
           sa  : out STD_LOGIC_VECTOR (width-1 downto 0);
           sb  : out STD_LOGIC_VECTOR (width-1 downto 0);
           sc  : out STD_LOGIC_VECTOR (width-1 downto 0);
           
           cmv_out : out STD_LOGIC_VECTOR (width-1 downto 0));
end SVPWM;

architecture Behavioral of SVPWM is
signal maxx    : signed(width-1 downto 0);
signal minn    : signed(width-1 downto 0);
signal offset  : signed(width-1 downto 0);
signal sa_sig, sb_sig, sc_sig : signed(width-1 downto 0);
begin

maxx <= signed(a) when signed(a) > signed(b) and signed(a) > signed(c) else
        signed(b) when signed(b) > signed(a) and signed(b) > signed(c) else
        signed(c);
minn <= signed(a) when signed(a) < signed(b) and signed(a) < signed(c) else
        signed(b) when signed(b) < signed(a) and signed(b) < signed(c) else
        signed(c);

cmv_out <= std_logic_vector(offset);

sa <= std_logic_vector(sa_sig);
sb <= std_logic_vector(sb_sig);
sc <= std_logic_vector(sc_sig);

process(clk,rst) is
variable step : integer range 0 to 10;
variable maxmin : signed(width-1 downto 0);
--variable offset_scaled : signed(2*width-1 downto 0);
--constant val_1_3 : signed(width-1 downto 0) := x"0000_2AAB";    -- 1/3^0.5 in 2^14
begin
    if rst = '1' then
        step := 0;
        sa_sig <= (others=>'0');
        sb_sig <= (others=>'0');
        sc_sig <= (others=>'0');
    elsif rising_edge(clk) then
        case step is
            when 0 => step := 1;
                maxmin := maxx+minn;
            when 1 => step := 2;
                offset <= shift_right(maxmin,1);
            when 2 => step := 3;
                sa_sig <= signed(a)-offset;
            when 3 => step := 4;
                sb_sig <= signed(b)-offset;
            when 4 => step := 5;
                sc_sig <= signed(c)-offset;
            when others => step := 0;
        end case;
    end if;
end process;
end Behavioral;
