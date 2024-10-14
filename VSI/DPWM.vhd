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
    generic (width : integer := 32;
             frac  : integer := 16);
    Port ( a : in STD_LOGIC_VECTOR (width-1 downto 0);
           b : in STD_LOGIC_VECTOR (width-1 downto 0);
           c : in STD_LOGIC_VECTOR (width-1 downto 0);
           
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           
           da  : out STD_LOGIC_VECTOR (width-1 downto 0);
           db  : out STD_LOGIC_VECTOR (width-1 downto 0);
           dc  : out STD_LOGIC_VECTOR (width-1 downto 0);
           
           cmv_out : out STD_LOGIC_VECTOR (width-1 downto 0));
end DPWM;

architecture Behavioral of DPWM is
signal maxx    : signed(width-1 downto 0);
signal minn    : signed(width-1 downto 0);
signal offset  : signed(width-1 downto 0);
signal da_sig, db_sig, dc_sig : signed(width-1 downto 0);
begin

maxx <= signed(a) when signed(a) > signed(b) and signed(a) > signed(c) else
        signed(b) when signed(b) > signed(a) and signed(b) > signed(c) else
        signed(c);
minn <= signed(a) when signed(a) < signed(b) and signed(a) < signed(c) else
        signed(b) when signed(b) < signed(a) and signed(b) < signed(c) else
        signed(c);

cmv_out <= std_logic_vector(offset);



process(clk,rst) is
variable step : integer range 0 to 10;
variable one : signed(width-1 downto 0);
variable maxmin : signed(width-1 downto 0);
--variable offset_scaled : signed(2*width-1 downto 0);
--constant val_1_3 : signed(width-1 downto 0) := x"0000_2AAB";    -- 1/3^0.5 in 2^14
begin
    if rst = '1' then
        step := 0;
        one := (others => '0');
        one(frac downto frac) := b"1";
        da_sig <= (others=>'0');
        db_sig <= (others=>'0');
        dc_sig <= (others=>'0');
    elsif rising_edge(clk) then
        case step is
            when 0 => step := 1;
                maxmin := maxx+minn;
            when 1 => step := 2;
                if maxmin > 0 then
                    offset <= one - maxx;
                else
                    offset <=-one - minn;
                end if;
            when 2 => step := 3;
                da_sig <= signed(a)+offset;
            when 3 => step := 4;
                db_sig <= signed(b)+offset;
            when 4 => step := 5;
                dc_sig <= signed(c)+offset;
            when 5 => step := 6;
                if da_sig > one - to_signed(100,width) then
                    da <= std_logic_vector(one + to_signed(1000,width));
                elsif da_sig < to_signed(100,width) - one then
                    da <= std_logic_vector(- one - to_signed(1000,width));
                else
                    da <= std_logic_vector(da_sig);
                end if;
                
                if db_sig > one - to_signed(100,width) then
                    db <= std_logic_vector(one + to_signed(1000,width));
                elsif db_sig < to_signed(100,width) - one then
                    db <= std_logic_vector(- one - to_signed(1000,width));
                else
                    db <= std_logic_vector(db_sig);
                end if;
                
                if dc_sig > one - to_signed(100,width) then
                    dc <= std_logic_vector(one + to_signed(1000,width));
                elsif dc_sig < to_signed(100,width) - one then
                    dc <= std_logic_vector(- one - to_signed(1000,width));
                else
                    dc <= std_logic_vector(dc_sig);
                end if;
                
            when others => step := 0;
        end case;
    end if;
end process;
end Behavioral;
