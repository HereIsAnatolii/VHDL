library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cordic is
    Generic ( width : integer := 12 
    );
    Port ( 	clk 	: in STD_LOGIC;
			rst 	: in STD_LOGIC;
			max     : in STD_LOGIC_VECTOR(11 downto 0);
			sin 	: out STD_LOGIC_VECTOR(15 downto 0);
			sin_un  : out STD_LOGIC_VECTOR(15 downto 0);
			cos 	: out STD_LOGIC_VECTOR(15 downto 0));
end entity;

architecture Behavioral of cordic is
type LUT_TYPE   is array (0 to 11) of signed(12 downto 0);
constant ATAN : LUT_TYPE := 
(
	b"0010000000000",		-- ATAN(0)
	b"0001001011100",		-- ATAN(1)1100011101
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

signal angle : signed(width downto 0) := (others => '0');
signal quadrant : std_logic_vector(1 downto 0) := b"00";

type CORDIC is array (0 to 11) of signed(width downto 0);
signal X,Y,Z : CORDIC := (others => (others=>'0'));
signal Xin : signed(width-1 downto 0);  -- 0100_1110_0001
signal Yin : signed(width-1 downto 0);
begin

quadrant <= std_logic_vector(angle(12 downto 11));

process(clk,rst)
begin
    if rst = '0' then
        Xin <= b"0100_1110_0001";
        Yin <= (others=>'0');
	elsif rising_edge(clk) then
	   if angle <= b"0000000001010" then
    	   Xin <= signed(max);
       end if;
		case quadrant is
			when b"00" | b"11" =>
				X(0) <= resize(signed(Xin),width+1);
				Y(0) <= resize(signed(Yin),width+1);
				Z(0) <= angle;
			when b"01" =>
				X(0) <= 0-resize(signed(Yin),width+1);
				Y(0) <=   resize(signed(Xin),width+1);
				Z(0) <= b"00"&angle(10 downto 0);
			when b"10" =>
				X(0) <=   resize(signed(Yin),width+1);
				Y(0) <= 0-resize(signed(Xin),width+1);
				Z(0) <= b"11"&angle(10 downto 0);
            when others =>
                X(0) <= resize(signed(Xin),width+1);
                Y(0) <= resize(signed(Yin),width+1);
                Z(0) <= angle;
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

process(clk)
begin 
	if rising_edge(clk) then
		angle <= angle + b"0000000001010";
	end if;
end process;

cos(15 downto 3) <= std_logic_vector(X(11));
sin(15 downto 3) <= std_logic_vector(Y(11));
cos(2 downto 0) <= (others=>'0');
sin(2 downto 0) <= (others=>'0');

sin_un <= std_logic_vector(Y(11)&b"000"+x"7FFF");
end Behavioral;
