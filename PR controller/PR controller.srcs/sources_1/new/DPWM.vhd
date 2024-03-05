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

entity DPWM is
    Port ( a : in STD_LOGIC_VECTOR (15 downto 0);
           b : in STD_LOGIC_VECTOR (15 downto 0);
           c : in STD_LOGIC_VECTOR (15 downto 0);
           
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           
           da  : out STD_LOGIC_VECTOR (15 downto 0);
           db  : out STD_LOGIC_VECTOR (15 downto 0);
           dc  : out STD_LOGIC_VECTOR (15 downto 0);
           
           cmv_out : out STD_LOGIC_VECTOR (15 downto 0));
end DPWM;

architecture Behavioral of DPWM is
signal maxx    : signed(15 downto 0);
signal minn    : signed(15 downto 0);
signal offset : signed(15 downto 0);
begin

maxx <= signed(a) when signed(a) > signed(b) and signed(a) > signed(c) else
        signed(b) when signed(b) > signed(a) and signed(b) > signed(c) else
        signed(c);
minn <= signed(a) when signed(a) < signed(b) and signed(a) < signed(c) else
        signed(b) when signed(b) < signed(a) and signed(b) < signed(c) else
        signed(c);

offset <= to_signed(16384,16)-maxx when maxx+minn > 0 else
          to_signed(-16384,16)-minn;
          
cmv_out <= std_logic_vector(offset);

process(clk,rst) is
variable step : integer range 0 to 10;
variable offset_scaled : signed(31 downto 0);
constant val_1_3 : signed(15 downto 0) := x"2AAB";    -- 1/3^0.5 in 2^14
begin
    if rst = '0' then
        step := 0;
        da <= (others=>'0');
        db <= (others=>'0');
        dc <= (others=>'0');
    elsif rising_edge(clk) then
        case step is
            when 0 => step := 1;
                offset_scaled := offset * val_1_3;
            when 1 => step := 2;
                da <= std_logic_vector(signed(a)+offset);
            when 2 => step := 3;
                db <= std_logic_vector(signed(b)+offset);
            when 3 => step := 4;
                dc <= std_logic_vector(signed(c)+offset);
            when others => step := 0;
        end case;
    end if;
end process;
end Behavioral;
