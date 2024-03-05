----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/27/2024 02:59:09 PM
-- Design Name: 
-- Module Name: switch_mode - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity switch_mode is
    Port ( OL : in STD_LOGIC_VECTOR (15 downto 0);
           CL : in STD_LOGIC_VECTOR (15 downto 0);
           OL_ref : in STD_LOGIC_VECTOR (15 downto 0);
           CL_ref : in STD_LOGIC_VECTOR (15 downto 0);
           switch : in STD_LOGIC;
           OUT_REF : out STD_LOGIC_VECTOR (15 downto 0);
           OUT_SIG : out STD_LOGIC_VECTOR (15 downto 0));
end switch_mode;

architecture Behavioral of switch_mode is

begin

OUT_SIG <= OL when switch = '0' else
           CL;

OUT_REF <= OL_REF when switch = '0' else
           CL_REF;
end Behavioral;
