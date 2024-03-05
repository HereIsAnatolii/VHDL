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

entity tx is
    Port ( clk     : in   STD_LOGIC;
           pData   : in   STD_LOGIC_VECTOR (15 downto 0);
           trig    : in   STD_LOGIC;
           tx_clk  : out  STD_LOGIC;
           tx_data : out  STD_LOGIC );
end tx;

architecture Behavioral of tx is

signal data   : std_logic_vector(15 downto 0);

begin

SPI: Process (CLK)
	
        variable step    : integer range 0 to 20 := 0;
        variable counter : integer range 0 to 10 := 0;

    Begin
       if rising_edge(CLK) then
          if sync = b"01" then
            counter := 1;
          end if;
          case counter is
          when 0 => counter := 1;
                         tx_clk <= '0';			 
                 case step is
                 when 18 => step := 0;
                         data <= pData;
                 when 17 => step := 18;
                            tx_data <= data(0);
                 when 16 => step := 17;
                            tx_data <= data(1);
                 when 15 => step := 16;
                            tx_data <= data(0);
                 when 14 => step := 15;
                            tx_data <= data(1);
                 when 13 => step := 14;
                            tx_data <= data(2);
                 when 12 => step := 13;
                            tx_data <= data(3);
                 when 11 => step := 12;
                            tx_data <= data(4);
                 when 10 => step := 11;
                            tx_data <= data(5);
                 when 9  => step := 10;
                            tx_data <= data(6);
                 when 8  => step := 9;
                            tx_data <= data(7);
                 when 7  => step := 8;
                            tx_data <= data(8);
                 when 6  => step := 7;
                            tx_data <= data(9);
                 when 5  => step := 6;
                            tx_data <= data(10);
                 when 4  => step := 5;
                            tx_data <= data(11);
                 when 3  => step := 4;
                            tx_data <= data(12);
                 when 2  => step := 3;
                            tx_data <= data(13);
                 when 1  => step := 2; 
                            tx_data <= data(14);
                 when 0  => step := 1; 
                            tx_data <= data(15);
                 when others => step := 0;
                end case;       
             when 1 => counter := 0;
							  tx_clk <= '1';
             when others => counter := 2;
           end case;
         end if;

     End Process;

end Behavioral;
