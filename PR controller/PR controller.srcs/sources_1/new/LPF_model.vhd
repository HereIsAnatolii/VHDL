                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       ----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LPF_model is
  generic (width : integer := 40;
           frac  : integer := 31);
  Port (clk       : in  STD_LOGIC;
        local_rst : in STD_LOGIC;
        sync      : in STD_LOGIC;
        load_ch   : in STD_LOGIC;
        clk_out   : out STD_LOGIC;
        sig_in    : in  STD_LOGIC_VECTOR(width-1 downto 0);
        sig_out   : out STD_LOGIC_VECTOR(width-1 downto 0)
   );
end entity;

architecture Behavioral of LPF_model is
signal clk_div : std_logic := '0';

signal lpf_out : std_logic_vector(width-1 downto 0) := (others=>'0');
signal y0 : signed(width-1 downto 0) := (others=>'0');
signal y1 : signed(width-1 downto 0) := (others=>'0');
signal x0 : signed(width-1 downto 0) := (others=>'0');

signal product_x, product_y : signed(2*width-1 downto 0) := (others=>'0');
signal sum_xy, shifted : signed(2*width-1 downto 0) := (others=>'0');
signal div_xy : signed(2*width-1 downto 0) := (others=>'0');
signal DIV : STD_LOGIC_VECTOR(11 downto 0) := x"009";
signal data_rdy : std_logic;
signal sync_sig : std_logic_vector(1 downto 0);

signal K1  : signed(width-1 downto 0); --b"000000_0000_0100_0000_0100_0000_0100_00";     -- K1 = Ts/(R*Ts+L)    Ts = 2usec wc = 2*pi*100kHz
signal K2  : signed(width-1 downto 0); -- := x"3ffbe7b0"; -- b"000111_1101_0111_1101_0111_1101_0111_11";     -- K2 = L/(R*Ts+L) -- 1 = 2^31

begin

sig_out <= lpf_out;




process(clk,local_rst) is
begin
    if local_rst = '0' then
        K1(31 downto 0) <= x"0141_4141";
        K2(31 downto 0) <= x"3ebe_bebe";
        
        K1(width-1 downto 32) <= (others=>'0'); 
        K2(width-1 downto 32) <= (others=>'0');
    elsif rising_edge(clk) then
        if load_ch = '0' then
            K1(31 downto 0) <= x"0141_4141";  --  Ts = 1e-6 L = 100e-6 R = 5 : K1=Ts/(R*Ts+L)*2^30
            K2(31 downto 0) <= x"3ebe_bebe";  --  Ts = 1e-6 L = 100e-6 R = 5 : K2=L/(R*Ts+L)*2^30
        else
             K1(31 downto 0) <= x"0041_465f"; --  Ts = 1e-6 L = 100e-6 R = 2 : K2=L/(R*Ts+L)*2^30
             K2(31 downto 0) <= x"3fbe_b9a0"; --  Ts = 1e-6 L = 100e-6 R = 2 : K2=L/(R*Ts+L)*2^30
        end if;
    end if;
end process;

process(clk,local_rst) is
variable step : integer range 0 to 15 := 0;

-- y[0] = x[0]*Ts  +  y[1]*L
--       --------    --------
--       (R*Ts+L)    (R*Ts+L)

begin
    if local_rst = '0' then
--        K1(31 downto 0) := x"0020_a330";               --  Ts = 1e-6 L = 100e-6 R = 10 : K1=Ts/(R*Ts+L)*2^30      
--        K2(31 downto 0) := x"3f5d_c83c";             --  Ts = 1e-6 L = 100e-6 R = 10 : K1=L/(R*Ts+L)*2^30     
        x0 <= (others=>'0');
        y0 <= (others=>'0');
        y1 <= (others=>'0');
        data_rdy <= '0';
        step := 10;
        sync_sig <= "00";
    elsif rising_edge(clk) then
        sync_sig(0) <= sync;
        if (sync_sig(1) = '0' and sync_sig(0) = '1') then
            step := 0;
            lpf_out <= std_logic_vector(y0);
        end if;
        case step is
            when 0 => step := 1;
                x0 <= signed(sig_in);
            when 1 => step := 2;
                product_x <= x0*K1;
            when 2 => step := 3;
                product_y <= y1*K2;
            when 3 => step := 4;
                sum_xy <= product_x + product_y;
            when 4 => step := 5;
--                y0 <= resize(sum_xy,width);
                shifted <= shift_left(sum_xy, width-frac);
            when 5 => step := 6;
                y0 <= shifted(2*width-1 downto width);
--                y0 <= resize(sum_xy, width);
            when 6 => step := 7;
                y1 <= y0;
            when others => step := 8;
      end case;
    end if;
end process;


--SYNC_TO_CLK: process(local_rst,clk) is
--variable sync : std_logic_vector(2 downto 0);
--begin
--    if local_rst = '0' then
--        sig_out <= (others => '0');
--        sync := (others => '0');
--    elsif rising_edge(clk) then
--        sync(0) := data_rdy;
--        sync(1) := sync(0);
--        sync(2) := sync(1);
--        if sync(2) /= sync(1) then
--            sig_out <= std_logic_vector(y0);
--        end if;
--    end if;
--end process;
            
end Behavioral;
