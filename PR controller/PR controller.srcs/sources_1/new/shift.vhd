----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/28/2024 08:20:26 AM
-- Design Name: 
-- Module Name: shift - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity shift is
Generic (width_in  : integer := 16;
         width_out : integer := 16;
         shift : integer := 2 );
Port (
        clk : in std_logic;
        rst : in std_logic;
        sig_in : in  std_logic_vector(width_in-1 downto 0);
        sig_out: out std_logic_vector(width_out-1 downto 0)
 );
end shift;

architecture Behavioral of shift is
signal sig_si  : signed(width_in-1 downto 0);
signal sig_res, sig_shift : signed(width_out-1 downto 0);
begin


process(clk,rst) is
variable step : integer range 0 to 15 := 0;
begin
    if rst = '0' then
        sig_si <= (others=>'0');
    elsif rising_edge(clk) then
        case step is
            when 0 => step := 1;
                sig_si <= signed(sig_in);
            when 1 => step := 2;
                sig_shift <= shift_left(sig_si,shift);
--                if width_in > width_out then
--                    sig_res <= resize(sig_si,width_out);
--                else
--                    sig_res(width_out-1 downto width_out-width_in) <= sig_si;
--                end if;
            when 2 => step := 3;
                sig_out <= std_logic_vector( sig_shift );
--                sig_shift <= shift_left(sig_res,shift);
            when others => step := 0;
        end case;
    end if;
end process;

end Behavioral;
