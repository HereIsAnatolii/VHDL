----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dr. Anatolii Tcai 
-- 
-- Create Date: 10/12/2024 02:40:06 PM
-- Design Name: 
-- Module Name: RL_filter - Behavioral
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

entity albe_2_dq is
    generic (width : integer := 32;
             frac : integer := 16);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           
           alpha_in   : in STD_LOGIC_VECTOR(width-1 downto 0);
           beta_in    : in STD_LOGIC_VECTOR(width-1 downto 0);
           angle      : in STD_LOGIC_VECTOR(width-1 downto 0);
           d_out      : out STD_LOGIC_VECTOR (width-1 downto 0);
           q_out      : out STD_LOGIC_VECTOR (width-1 downto 0));
end entity;

architecture Behavioral of albe_2_dq  is

component sin_wrapper is
    generic (width : integer := 32;
             frac  : integer := 16);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           signed_unsigned : in STD_LOGIC;
           angle  : in STD_LOGIC_VECTOR (width-1 downto 0);
           sine   : out STD_LOGIC_VECTOR (width-1 downto 0);
           cosine : out STD_LOGIC_VECTOR (width-1 downto 0));
end component;

-- Define an array type with 2 elements of signed type
type signed_array_t is array (0 to 1) of signed(2*width-1 downto 0);  -- 8-bit signed elements

-- Define signals
signal clk_sig, rst_sig : std_logic; 
signal angle_sig, sin_sig, cos_sig : std_logic_vector(width-1 downto 0); 
signal d_mul, q_mul :signed_array_t;
signal d_sig, q_sig : signed(2*width-1 downto 0);  
begin

clk_sig <= clk;
rst_sig <= rst;
angle_sig <= angle;
SIN_COS_INST: sin_wrapper port map
    (
        clk => clk_sig,
        rst => rst_sig,
        signed_unsigned => '0',
        angle  => angle_sig,
        sine   => sin_sig,
        cosine => cos_sig
    );

process(clk_sig,rst_sig) is
variable step : integer range 0 to 10 := 0;
begin
    if rst_sig = '1' then
        step := 0;
        d_sig <= (others => '0');
        q_sig  <= (others => '0');
    elsif rising_edge(clk_sig) then
--DQ-AB Transformation
--	d = alpha*cos_sig + beta*sin_sig;
--	q =-alpha*sin_sig + beta*cos_sig;
        case step is
            when 0 => step := 1;
                d_out <= std_logic_vector( d_sig(width+frac-1 downto frac) );
                q_out <= std_logic_vector( q_sig(width+frac-1 downto frac) );
            when 1 => step := 2;
                d_mul(0) <= signed(cos_sig)*signed(alpha_in);
            when 2 => step := 3;
                d_mul(1) <= signed(sin_sig)*signed(beta_in);
            when 3 => step := 4;
                q_mul(0) <=- signed(sin_sig)*signed(alpha_in);
            when 4 => step := 5;
                q_mul(1) <=  signed(cos_sig)*signed(beta_in);
            when 5 => step := 6;
                d_sig <= d_mul(0) + d_mul(1);
            when 6 => step := 7;
                q_sig <= q_mul(0) + q_mul(1);
            when 7 => step := 8;
            when 8 => step := 9;
            when others => step := 0;
      end case;
    end if;
end process;


end Behavioral;

----- COPY COMPONENT DEFINITION -----
--component albe_2_dq is
--    generic (width : integer := 32;
--             frac : integer := 16);
--    Port ( clk : in STD_LOGIC;
--           rst : in STD_LOGIC;
--           alpha_in   : in STD_LOGIC_VECTOR(width-1 downto 0);
--           beta_in    : in STD_LOGIC_VECTOR(width-1 downto 0);
--           angle      : in STD_LOGIC_VECTOR(width-1 downto 0);
--           d_out      : out STD_LOGIC_VECTOR (width-1 downto 0);
--           q_out      : out STD_LOGIC_VECTOR (width-1 downto 0));
--end component;

--ALBE_2_DQ_2_INST: albe_2_dq 
--generic map (
--        width => 64, 
--        frac => 31)
--port map (
--        clk       =>,
--        rst       =>,
        
--        alpha_in      =>,
--        beta_in      =>,
--        angle     =>,
--        d_out =>,
--        q_out  =>,
--);