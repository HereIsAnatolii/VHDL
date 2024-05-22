----------------------------------------------------------------------------------
-- Company: HereIsAnatolii
-- Engineer: Dr. Anatolii Tcai
-- 
-- Create Date: 04/06/2024 07:50:45 AM
-- Design Name: 12-bit CORDIC 
-- Module Name: sin_wrapper - Behavioral
-- Project Name: Private
-- Target Devices: 
-- Tool Versions: 
-- Description: A wrapper for the CORDIC sine-cosine generator to normalize the values to the fixed-point 
-- 
-- Dependencies: 
-- CORDIC.vhd
-- Revision:
-- Revision 0.00 - File Created
-- Revision 0.01 - Reset added 
-- Revision 0.10 - File modified, definition and initialization prototypes added 
-- Revision 0.20 - Inputs and outputs are converted into signed 
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cordic is
    Port ( 	clk 	: in STD_LOGIC;
			rst 	: in STD_LOGIC;
			angle   : in  SIGNED(12 downto 0);
			sin 	: out SIGNED(11 downto 0);
			cos 	: out SIGNED(11 downto 0));
end entity;

architecture Behavioral of cordic is
type LUT_TYPE   is array (0 to 11) of signed(12 downto 0);
constant ATAN : LUT_TYPE := 
(
	b"0010000000000",		-- ATAN(0)
	b"0001001011100",		-- ATAN(1)
	b"0000100111111",		-- ATAN(2)
	b"0000010100010",		-- ATAN(3)
	b"0000001010001",		-- ATAN(4)
	b"0000000101000",		-- ATAN(5)
	b"0000000010100",		-- ATAN(6)
	b"0000000001010",		-- ATAN(7)
	b"0000000000101",		-- ATAN(8)
	b"0000000000010",		-- ATAN(9)
	b"0000000000001",		-- ATAN(10)
	b"0000000000000"		-- ATAN(11)
);

signal quadrant : std_logic_vector(1 downto 0) := b"00";

type CORDIC is array (0 to 11) of signed(12 downto 0);
signal X,Y,Z : CORDIC := (others => (others=>'0'));
signal Xin : signed(11 downto 0) := b"010011011011";
signal Yin : signed(11 downto 0) := b"000000000000";
begin

quadrant <= std_logic_vector(angle(12 downto 11));

process(rst,clk)
begin
    if rst = '1' then
        X(0) <= (others => '0');
        Y(0) <= (others => '0');
        Z(0) <= (others => '0');
	elsif rising_edge(clk) then
		case quadrant is
			when b"00" | b"11" =>
				X(0) <= resize(signed(Xin),13);
				Y(0) <= resize(signed(Yin),13);
				Z(0) <= signed(angle);
			when b"01" =>
				X(0) <= 0-resize(signed(Yin),13);
				Y(0) <=   resize(signed(Xin),13);
				Z(0) <= b"00"&signed(angle(10 downto 0));
			when b"10" =>
				X(0) <=   resize(signed(Yin),13);
				Y(0) <= 0-resize(signed(Xin),13);
				Z(0) <= b"11"&signed(angle(10 downto 0));
            when others =>
                X(0) <= resize(signed(Xin),13);
                Y(0) <= resize(signed(Yin),13);
                Z(0) <= signed(angle);
		end case;
	end if;
end process;

gen: for i in 0 to 10 generate
	process(clk)
	begin
		if rising_edge(clk) then
			case Z(i)(12) is
				when '1' =>
					X(i+1) <= X(i) + shift_right(signed(Y(i)),i);
					Y(i+1) <= Y(i) - shift_right(signed(X(i)),i);
					Z(i+1) <= Z(i) + ATAN(i);
				when others =>
					X(i+1) <= X(i) - shift_right(signed(Y(i)),i);
					Y(i+1) <= Y(i) + shift_right(signed(X(i)),i);
					Z(i+1) <= Z(i) - ATAN(i);
				end case;
		end if;
	end process;
end generate gen;

cos <= X(11)(12 downto 1);
sin <= Y(11)(12 downto 1);

end Behavioral;


----------------------------- COMPONENT DEFINITION -------------------------------
----------------------------------------------------------------------------------
--component cordic is
--    Port ( 	clk 	: in STD_LOGIC;
--			rst 	: in STD_LOGIC;
--  		angle   : in  SIGNED(12 downto 0);
--			sin 	: out SIGNED(11 downto 0);
--			cos 	: out SIGNED(11 downto 0));
--end component;
------------------------------ INSTANCE DEFINITION -------------------------------
----------------------------------------------------------------------------------
--CORDIC_INST_1: cordic port map
--(
--    clk => ,
--    rst => ,
--    angle => ,
--    sin => ,
--    cos => open
--);
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
