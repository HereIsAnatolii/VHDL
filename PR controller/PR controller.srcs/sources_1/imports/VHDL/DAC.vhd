----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:13:58 08/04/2017 
-- Design Name: 
-- Module Name:    spiDAC - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spiDAC16b is
    Port ( clk    : in   STD_LOGIC;
           pData  : in   STD_LOGIC_VECTOR (15 downto 0);
           
           spiLD  : out  STD_LOGIC;
           spiCS  : out  STD_LOGIC;
           spiCLK : out  STD_LOGIC;
           sData  : out  STD_LOGIC );
end spiDAC16b;

architecture Behavioral of spiDAC16b is

signal data   : std_logic_vector(15 downto 0);

begin

SPI: Process (CLK)
	
        variable step    : integer range 0 to 20 := 0;
        variable counter : integer range 0 to 10 := 0;

    Begin

       if rising_edge(CLK) then
          case counter is
          when 0 => counter := 1;
                         spiCLK <= '0';			 
                 case step is
                 when 18 => step := 0;
                         data <= pData;
                         spiCS <= '1';
                         spiLD <= '0';
                 when 17 => step := 18;
                            sData <= data(0);
                 when 16 => step := 17;
                            sData <= data(1);
                 when 15 => step := 16;
                            sData <= data(2);
                 when 14 => step := 15;
                            sData <= data(3);
                 when 13 => step := 14;
                            sData <= data(4);
                 when 12 => step := 13;
                            sData <= data(5);
                 when 11 => step := 12;
                            sData <= data(6);
                 when 10 => step := 11;
                            sData <= data(7);
                 when 9  => step := 10;
                            sData <= data(8);
                 when 8  => step := 9;
                            sData <= data(9);
                 when 7  => step := 8;
                            sData <= data(10);
                 when 6  => step := 7;
                            sData <= data(11);
                 when 5  => step := 6;
                            sData <= data(12);
                 when 4  => step := 5;
                            sData <= data(13);
                 when 3  => step := 4;
                            sData <= data(14);
                 when 2  => step := 3;
                            sData <= data(15);
                 when 1  => step := 2; 
                            spiCS <= '0';
                            spiLD <= '1';
                 when 0  => step := 1; 
                            spiCS <= '1';
                            spiLD <= '0';
                 when others => step := 0;
                end case;       
             when 1 => counter := 0;
							  spiCLK <= '1';
             when others => counter := 0;
           end case;
         end if;

     End Process;

end Behavioral;
