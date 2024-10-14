----------------------------------------------------------------------------------
-- Company: Robert Bosch GmbH
-- Engineer: Dr. Anatolii Tcai
-- 
-- Create Date: 04/06/2024 07:50:45 AM
-- Design Name: Sine Wave Wrapper
-- Module Name: sin_wrapper - Behavioral
-- Project Name: Private
-- Target Devices: 
-- Tool Versions: 
-- Description: A wrapper for the CORDIC sine-cosine generator to normalize the values to the fixed-point 
-- 
-- Dependencies: 
-- CORDIC.vhd
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity sin_wrapper is
    generic (width : integer := 32;
             frac  : integer := 16);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           signed_unsigned : in STD_LOGIC;
           angle  : in STD_LOGIC_VECTOR (width-1 downto 0);
           sine   : out STD_LOGIC_VECTOR (width-1 downto 0);
           cosine : out STD_LOGIC_VECTOR (width-1 downto 0));
end sin_wrapper;

architecture Behavioral of sin_wrapper is

------------------------------- DEFINE COMPONENTS --------------------------------
----------------------------------------------------------------------------------
component cordic is
    Port ( 	clk 	: in  STD_LOGIC;
			rst 	: in  STD_LOGIC;
			angle   : in  SIGNED(12 downto 0);
			sin 	: out SIGNED(11 downto 0);
			cos 	: out SIGNED(11 downto 0));
end component;
-------------------------------- DEFINE SIGNALS ----------------------------------
----------------------------------------------------------------------------------
signal sin_out : SIGNED(11 downto 0);
signal cos_out : SIGNED(11 downto 0);
signal clk_tb,rst_tb : std_logic;
--signal pi2_test : unsigned(15 downto 0) := to_unsigned(6434,16);   -- w16f10 (widht-16, frac-10)
--signal pi2_test : unsigned(15 downto 0) := to_unsigned(12868,width);    -- w16f11 (width-16, frac-11)
--signal pi2_test : signed(width-1 downto 0) := x"0064_7ae1";    -- w32f20
--signal pi2_test   : signed(width-1 downto 0) := x"0003_23d7_0a3d";  -- w40f31 00_0000_0000
signal pi2_fin    : signed(12 downto 0);
begin

-- width1 + width2 -1 - 9
-- width1+width2 - frac1+frac2

sine(frac+1 downto frac-10) <= std_logic_vector(sin_out);
cosine(frac+1 downto frac-10) <= std_logic_vector(cos_out);

sine(width-1 downto frac+2) <= (others=>'0') when sin_out(11) = '0' else
                               (others=>'1'); 
cosine(width-1 downto frac+2) <= (others=>'0') when cos_out(11) = '0' else
                               (others=>'1'); 

sine(frac-11 downto 0) <= (others=>'0');
cosine(frac-11 downto 0) <= (others=>'0');
 
----------------------------------------------------------------------------------
--rst_tb <= '1', '0' after 1 us;
--process
--begin
--    pi2_test <= pi2_test + to_signed(214748,width);
--    if pi2_test > x"03_23d7_0a3d" then  --01_921f_9f02
--        pi2_test <= pi2_test - x"03_23d7_0a3d";
--    end if;
    
--    wait for 1 ns;
--end process;
--process
--begin
--    clk_tb <= '1';
--    wait for 5 ns;
--    clk_tb <= '0';
--    wait for 5 ns;
--end process;
----------------------------------------------------------------------------------

CORDIC_INST_1: cordic port map
(
    clk => clk,
    rst => rst,
    angle => pi2_fin,
    sin => sin_out,
    cos => cos_out
);

process(rst,clk) is
constant width_scaler : integer := 12;
constant scaler : signed(width_scaler-1 downto 0) := to_signed(652,width_scaler);         -- 1/2*pi w10f10 652  1024
variable pi2_result : signed(width+width_scaler-1 downto 0);
variable step : integer range 0 to 5;
begin
    if rst = '1' then
        pi2_result := (others=>'0');
        pi2_fin <= (others=>'0');
        step := 0;
    elsif rising_edge(clk) then
        case step is
            when 0 => step := 1;
                pi2_result := signed(angle) * scaler;        -- w26f21 (f10+f11) >> 13;
            when 1 => step := 2;
--                pi2_fin <= pi2_result(width+width_scaler-(width-frac)-1 downto width+width_scaler-(width-frac)-13);
                pi2_fin <= pi2_result(width_scaler+frac-1 downto width_scaler+frac-13);
            when others => step := 0;
        end case;
    end if;
end process;

end Behavioral;