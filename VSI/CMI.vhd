----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/12/2024 04:12:51 PM
-- Design Name: 
-- Module Name: CMI - Behavioral
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

entity CM_current is
    generic (width : integer := 32;
             frac : integer := 16);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sync : in STD_LOGIC;
           
           A_in : in STD_LOGIC_VECTOR(width-1 downto 0);
           B_in : in STD_LOGIC_VECTOR(width-1 downto 0);
           C_in : in STD_LOGIC_VECTOR(width-1 downto 0);
           
           A_out : out STD_LOGIC_VECTOR(width-1 downto 0);
           B_out : out STD_LOGIC_VECTOR(width-1 downto 0);
           C_out : out STD_LOGIC_VECTOR(width-1 downto 0));
end entity;

architecture Behavioral of CM_current is
signal sync_sig : std_logic_vector(1 downto 0);
signal A_sig, B_sig, C_sig : signed(width-1 downto 0);
signal summ : signed(width-1 downto 0);
signal cmi : signed(2*width-1 downto 0);
begin

process(rst,clk) is
variable step : integer range 0 to 10 := 0;
variable one_third : signed(width-1 downto 0) := x"0000_5555";
begin
    if rst = '1' then
        sync_sig <= b"00";
        summ <= (others => '0');
        A_out <= (others => '0');
        B_out <= (others => '0');
        C_out <= (others => '0');
        cmi <= (others => '0');
                    
        A_sig <= (others => '0');
        B_sig <= (others => '0');
        C_sig <= (others => '0');
             
    elsif rising_edge(clk) then
        sync_sig(1) <= sync_sig(0);
        sync_sig(0) <= sync;
        if (sync_sig(1) = '0' and sync_sig(0) = '1') then
            step := 0;            
            A_sig <= signed(A_in);
            B_sig <= signed(B_in);
            C_sig <= signed(C_in);
        end if;
        
        case step is
            when 0 => step := 1;
                summ <= A_sig + B_sig;
            when 1 => step := 2;
                summ <= summ +  C_sig;
            when 2 => step := 3;
                cmi <= summ * one_third;
            when 3 => step := 4;
                A_out <= std_logic_vector(A_sig - cmi(width+frac-1 downto frac));
                B_out <= std_logic_vector(B_sig - cmi(width+frac-1 downto frac));
                C_out <= std_logic_vector(C_sig - cmi(width+frac-1 downto frac));
            when others => step := 6;
      end case;
        
    end if;
end process;
end Behavioral;
