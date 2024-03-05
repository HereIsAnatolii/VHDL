----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clk_div is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk_ds : out STD_LOGIC;
           clk_flt : out STD_LOGIC;
           div_ds : in STD_LOGIC_VECTOR (7 downto 0);
           div_flt : in STD_LOGIC_VECTOR (7 downto 0));
end clk_div;

architecture Behavioral of clk_div is
signal clk_ds_sig, clk_flt_sig : std_logic := '0';
signal cnt_ds, cnt_flt : unsigned(7 downto 0) := x"00"; 
begin

clk_ds <= clk_ds_sig;
clk_flt <= clk_flt_sig;

process(clk,rst) is
variable cnt : unsigned(7 downto 0) := x"0F";
begin
    if rst = '0' then
        cnt := x"00";
        clk_ds_sig <=  '0';
    elsif rising_edge(clk) then
        if cnt > unsigned(div_ds) then
            cnt := x"00";
            clk_ds_sig <= not clk_ds_sig;
        else
            cnt := cnt + 1;
        end if;
    end if;
    
end process;

process(clk,rst) is
variable cnt : unsigned(7 downto 0) := x"0F";
begin
    if rst = '0' then
        cnt := x"00";
        clk_flt_sig <= '0';
    elsif rising_edge(clk) then
        if cnt > unsigned(div_flt) then
            cnt := x"00";
            clk_flt_sig <= not clk_flt_sig;
        else
            cnt := cnt + 1;
        end if;
    end if;
    
end process;

end Behavioral;
