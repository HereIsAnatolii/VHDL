library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CIC_filter is
    generic(width : integer := 32);
    port(DSIN, CLK, RST  : in std_logic;
         SYNC   : in std_logic;
         DS_OUT : out std_logic;
         FLT_OUT : out std_logic_vector(width-1 downto 0));
end entity;

architecture RTL of CIC_filter is
    signal CNR, MOUT : std_logic;
    signal DN0, DN1, DN3, DN5 : signed(width-1 downto 0);
    signal CN1, CN2, CN3, CN4,CN5 : signed(width-1 downto 0);
    signal DSOUT : signed(width-1 downto 0);
    signal DELTA1,DELTA2  : signed(width-1 downto 0);
    signal DSYNC   : std_logic_vector(2 downto 0);
    signal DS_SYNC :std_logic;
    signal clk_ds  : std_logic := '0';
    
begin

DS_OUT <= clk_ds;

process(CLK, RST)
variable cnt : integer range 0 to 100 := 0;
variable sync_sig : std_logic_vector(1 downto 0);
begin
    if RST = '0' then
        clk_ds <= '0';
        sync_sig := b"00";
    elsif rising_edge(CLK) then
        sync_sig(1) := sync_sig(0);
        sync_sig(0) := SYNC;
        
        if sync_sig = b"01" then
            clk_ds <= not clk_ds;
        end if;
    end if;
end process;

process(CLK, RST)
variable cnt : integer range 0 to width+1 := 0;
variable sync_sig : std_logic_vector(1 downto 0);
begin
    if RST = '0' then
        CNR <= '0';
        cnt := 0;
        sync_sig := b"00";
        
    elsif rising_edge(CLK) then
    -- cnt > 5 gives 6x2 = 12 times the main clock
        sync_sig(1) := sync_sig(0);
        sync_sig(0) := SYNC;
        
        if sync_sig = b"01" then
            if cnt > width-2 then
                CNR <= not CNR;
                cnt := 0;
            else
                cnt := cnt + 1;
            end if;
        end if;
    end if;
end process;

process(CLK, RST)
variable out_inv : signed(width-1 downto 0);
variable max     : signed(width-1 downto 0);
variable sync_sig : std_logic_vector(1 downto 0);
begin
    if RST = '0' then
        DSYNC <= (others => '0');
        out_inv := (others => '0');
        max(width-2 downto 0) := (others => '1');
        max(width-1) := '0';
        sync_sig := b"00";
    elsif rising_edge(CLK) then
        sync_sig(1) := sync_sig(0);
        sync_sig(0) := SYNC;
        
        if sync_sig = b"01" then
            DSYNC(0) <= DS_SYNC;
            DSYNC(1) <= DSYNC(0);
            DSYNC(2) <= DSYNC(1);
            if DSYNC(2) /= DSYNC(1) then
                out_inv := max - CN5;
                FLT_OUT <= std_logic_vector(out_inv);
            end if;
        end if;
    end if;
end process;

process(CLK, RST)
variable sync_sig: std_logic_vector(1 downto 0);
begin
    if RST = '0' then
        sync_sig := b"00";
        DELTA1 <= (others => '0');
    elsif rising_edge(CLK) then
        sync_sig(1) := sync_sig(0);
        sync_sig(0) := SYNC;
        
        if sync_sig = b"01" then
            if DS_SYNC = '1' then
                DELTA1 <= DELTA1 + 1;
            end if;
        end if;
    end if;
end process;

process(CLK, RST)
variable sync_sig: std_logic_vector(1 downto 0);
begin
    if RST = '0' then
        sync_sig := b"00";
        DELTA2 <= (others => '0');
    elsif rising_edge(CLK) then
        sync_sig(1) := sync_sig(0);
        sync_sig(0) := SYNC;
        
        if sync_sig = b"01" then
            if DSIN = '1' then
                DELTA2 <= DELTA2 + 1;
            end if;
        end if;
    end if;
end process;

process(RST, CLK)
variable sync_sig: std_logic_vector(1 downto 0);
begin
    if RST = '0' then
        sync_sig := b"00";
        CN1 <= (others => '0');
        CN2 <= (others => '0');
    elsif rising_edge(CLK) then
        sync_sig(1) := sync_sig(0);
        sync_sig(0) := SYNC;
        
        if sync_sig = b"01" then
            CN1 <= CN1 + DELTA2;
            CN2 <= CN2 + CN1;
        end if;
    end if;
end process;

process(RST, CNR)
variable sync_sig: std_logic_vector(1 downto 0);
begin
    if RST = '0' then
        sync_sig := b"00";
        DN0 <= (others => '0');
        DN1 <= (others => '0');
        DN3 <= (others => '0');
        DN5 <= (others => '0');
        DS_SYNC <= '0';
    elsif rising_edge(CNR) then
        sync_sig(1) := sync_sig(0);
        sync_sig(0) := SYNC;
        
        if sync_sig = b"01" then
            DN0 <= CN2;
            DN1 <= DN0;
            DN3 <= CN3;
            DN5 <= CN4;
            DS_SYNC <= not DS_SYNC;
        end if;
    end if;
end process;

CN3 <= DN0 - DN1;
CN4 <= CN3 - DN3;
CN5 <= CN4 - DN5;

end RTL; 
