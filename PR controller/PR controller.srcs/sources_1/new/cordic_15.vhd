library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cordic_15 is
    Port ( 	clk 	: in STD_LOGIC;
			rst 	: in STD_LOGIC;
			sin 	: out STD_LOGIC_VECTOR(15 downto 0);
			cos 	: out STD_LOGIC_VECTOR(15 downto 0));
end entity;

architecture Behavioral of cordic_15 is
type LUT_TYPE   is array (0 to 15) of signed(16 downto 0);
constant ATAN : LUT_TYPE := 
(
	b"00011101101011001",		-- ATAN(0)
	b"00001111101011100",		-- ATAN(1)1100011101
	b"00000111111101011",		-- ATAN(2)
	b"00000011111111110",		-- ATAN(3)
	b"00000010000000000",		-- ATAN(4)
	b"00000001000000000",		-- ATAN(5)
	b"00000000100000000",		-- ATAN(6)
	b"00000000010000000",		-- ATAN(7)
	b"00000000001000000",		-- ATAN(8)
	b"00000000000100000",		-- ATAN(9)
	b"00000000000010000",		-- ATAN(10)
	b"00000000000001000",		-- ATAN(11)
	b"00000000000000100",		-- ATAN(9)
	b"00000000000000010",		-- ATAN(10)
	b"00000000000000001",		-- ATAN(11)
	b"00000000000000000"		-- ATAN(11)
);

signal angle : signed(16 downto 0) := (others => '0');
signal quadrant : std_logic_vector(1 downto 0) := b"00";

type CORDIC is array (0 to 15) of signed(16 downto 0);
signal X,Y,Z : CORDIC := (others => (others=>'0'));
signal Xin : signed(15 downto 0);  -- 0100_1110_0001
signal Yin : signed(15 downto 0);
begin

quadrant <= std_logic_vector(angle(16 downto 15));

process(clk,rst)
begin
    if rst = '0' then
        Xin <= b"00100_1110_0001_000";
        Yin <= (others=>'0');
	elsif rising_edge(clk) then
		case quadrant is
			when b"00" | b"11" =>
				X(0) <= resize(signed(Xin),17);
				Y(0) <= resize(signed(Yin),17);
				Z(0) <= angle;
			when b"01" =>
				X(0) <= 0-resize(signed(Yin),17);
				Y(0) <=   resize(signed(Xin),17);
				Z(0) <= b"00"&angle(14 downto 0);
			when b"10" =>
				X(0) <=   resize(signed(Yin),17);
				Y(0) <= 0-resize(signed(Xin),17);
				Z(0) <= b"11"&angle(14 downto 0);
            when others =>
                X(0) <= resize(signed(Xin),17);
                Y(0) <= resize(signed(Yin),17);
                Z(0) <= angle;
		end case;
	end if;
end process;

gen: for i in 0 to 14 generate
	process(clk)
	begin
		if rising_edge(clk) then
			case Z(i)(16) is
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

process(clk)
begin 
	if rising_edge(clk) then
		angle <= angle + b"0_0000_0000_0000_0001";
	end if;
end process;

cos <= std_logic_vector(resize(X(15),16));
sin <= std_logic_vector(resize(Y(15),16));

end Behavioral;
