----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity delta_sigma is
	Generic (width : integer := 32);
    Port ( in_sig : in STD_LOGIC_VECTOR (width-1 downto 0);
           out_sig : out STD_LOGIC;
           clk : in STD_LOGIC;
           rst : in STD_LOGIC);
end delta_sigma;

architecture Behavioral of delta_sigma is
signal max : signed(width-1 downto 0) := (others=>'1');

signal first_difference  : signed(width-1 downto 0) := (others=>'0');
signal adder_latched_1   : signed(width-1 downto 0) := (others=>'0'); 
signal bitstream         : std_logic := '0';
begin

max(width-1 downto width-2) <= b"00";
out_sig <= bitstream;

first_difference <= adder_latched_1 + max + signed(in_sig) when bitstream = '0' else
                    adder_latched_1 - max + signed(in_sig) ;
                    
bitstream <= '1' when adder_latched_1 > 0 else 
             '0';

process(clk,rst) is
begin
    if rst = '0' then
        adder_latched_1 <= (others =>'0');
    elsif rising_edge(clk) then
        adder_latched_1 <= first_difference;
    end if;
end process;
end Behavioral;
