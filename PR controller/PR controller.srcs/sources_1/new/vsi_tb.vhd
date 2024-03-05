----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity vsi_tb is
--  Port ( );
end vsi_tb;

architecture Behavioral of vsi_tb is
signal pwm_sync : std_logic;
signal shift : integer := 2;
signal clk_tb : std_logic := '0';
signal rst_tb,rst_two_tb : std_logic := '0';
signal div_tb : std_logic := '0';
signal clk_tb_high : std_logic := '0';

signal slow_clk : std_logic := '0';
signal sin_base, cos_base : std_logic_vector(15 downto 0);
signal a_sig,b_sig,c_sig : std_logic_vector(15 downto 0);
signal da_sig,db_sig,dc_sig : std_logic_vector(15 downto 0);

signal a_pwm : std_logic_vector(39 downto 0);
signal b_pwm, c_pwm,cmv_sig : std_logic_vector(31 downto 0);
signal da_cur, cmv_cur : std_logic_vector(31 downto 0);
signal a_sig_32, a_ref_32 : std_logic_vector(31 downto 0);
signal a_sig_64, a_ref_64, a_cur : std_logic_vector(39 downto 0);
-- COMPONENTS --
component slow_sync is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sync_sec : out STD_LOGIC);
end component;

component cordic is
    Port ( 	clk 	: in STD_LOGIC;
			rst 	: in STD_LOGIC;
			max     : in STD_LOGIC_VECTOR(11 downto 0);
			sin 	: out STD_LOGIC_VECTOR(15 downto 0);
			cos 	: out STD_LOGIC_VECTOR(15 downto 0));
end component;

component ab_abc is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           alpha : in STD_LOGIC_VECTOR (15 downto 0);
           
           a : out STD_LOGIC_VECTOR (15 downto 0);
           c : out STD_LOGIC_VECTOR (15 downto 0);
           b : out STD_LOGIC_VECTOR (15 downto 0);
           
           beta : in STD_LOGIC_VECTOR (15 downto 0));
end component;

component abc_ab is
    Port ( a : in STD_LOGIC_VECTOR (15 downto 0);
           b : in STD_LOGIC_VECTOR (15 downto 0);
           c : in STD_LOGIC_VECTOR (15 downto 0);
           
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           
           alpha : out STD_LOGIC_VECTOR (15 downto 0);
           beta  : out STD_LOGIC_VECTOR (15 downto 0));
end component;

component pwm is
    generic (width : integer := 16 );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           modulation : in STD_LOGIC_VECTOR(width-1 downto 0);
           scale   : in STD_LOGIC_VECTOR(width-1 downto 0);
           pwm_out : out STD_LOGIC_VECTOR(width-1 downto 0);
           sync    : out STD_LOGIC;
           pwm_3lvl   : out STD_LOGIC_VECTOR(1 downto 0)
           );
end component;

component LPF is
  generic (width : integer := 40;
           frac  : integer := 31);
  Port (clk       : in  STD_LOGIC;
        local_rst : in STD_LOGIC;
        sync      : in STD_LOGIC;
        clk_out   : out STD_LOGIC;
        sig_in    : in  STD_LOGIC_VECTOR(width-1 downto 0);
        sig_out   : out STD_LOGIC_VECTOR(width-1 downto 0)
   );
end component;

component cmv is
    Port ( a : in STD_LOGIC_VECTOR (15 downto 0);
           b : in STD_LOGIC_VECTOR (15 downto 0);
           c : in STD_LOGIC_VECTOR (15 downto 0);
           
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           
           cmv_out : out STD_LOGIC_VECTOR (15 downto 0));
end component;

component DPWM is
    Port ( a : in STD_LOGIC_VECTOR (15 downto 0);
           b : in STD_LOGIC_VECTOR (15 downto 0);
           c : in STD_LOGIC_VECTOR (15 downto 0);
           
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           
           da  : out STD_LOGIC_VECTOR (15 downto 0);
           db  : out STD_LOGIC_VECTOR (15 downto 0);
           dc  : out STD_LOGIC_VECTOR (15 downto 0);
           
           cmv_out : out STD_LOGIC_VECTOR (15 downto 0));
end component;

component variable_pwm is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           freq : in STD_LOGIC_VECTOR (15 downto 0);
           car : out STD_LOGIC_VECTOR (15 downto 0));
end component;

component PR_Control is
  generic (width : integer := 40;
           frac  : integer := 31);
  Port (clk       : in  STD_LOGIC;
        local_rst : in STD_LOGIC;
        sync      : in STD_LOGIC;
        clk_out   : out STD_LOGIC;
        ref_in    : in  STD_LOGIC_VECTOR(width-1 downto 0);
        sig_in    : in  STD_LOGIC_VECTOR(width-1 downto 0);
        sig_out   : out STD_LOGIC_VECTOR(width-1 downto 0)
   );
end component;
begin

rst_tb <= '0', '1' after 10 ns;
rst_two_tb <= '0', '1' after 1 ms;
-- PROCESSES --
clock: process is
begin
    clk_tb <= not clk_tb;
    wait for 5 ns;
end process;

-- PROCESSES --
SYNC: process is
begin
    div_tb <= not div_tb;
    wait for 250 ns;
end process;

clock_high: process is
begin
    clk_tb_high <= not clk_tb_high;
    wait for 1 ns;
end process;

-- BLOCKS --
MAKE_CLOCK: slow_sync port map
(
    clk => clk_tb,
    rst => rst_tb,
    sync_sec => slow_clk
);

MAKE_SIN: cordic port map
(
    clk => slow_clk,
    rst => rst_tb,
    max => b"00100_1110_000",
    sin => sin_base,
    cos => cos_base
);

MAKE_ABC: ab_abc port map
(
    clk   => clk_tb,
    rst   => rst_tb,
    alpha => cos_base,
    beta  => sin_base,
    a     => a_sig,
    b     => b_sig,
    c     => c_sig
);
 
MAKE_ALBE: abc_ab port map
(
    clk   => clk_tb,
    rst   => rst_tb,
    alpha => open,
    beta  => open,
    a     => a_sig,
    b     => b_sig,
    c     => c_sig
);
 
MAKE_PWM_A: pwm port map
(
    clk => clk_tb,
    rst => rst_tb,
    modulation => a_cur(39 downto 24),
    scale   => x"6784",
    sync    => pwm_sync,
    pwm_out => a_pwm(39 downto 24)
);

MAKE_PWM_B: pwm port map
(
    clk => clk_tb,
    rst => rst_tb,
    modulation => b_sig,
    scale   => x"6784",
    pwm_out => b_pwm(31 downto 16)
);

MAKE_PWM_C: pwm port map
(
    clk => clk_tb,
    rst => rst_tb,
    modulation => c_sig,
    scale   => x"6784",
    pwm_out => c_pwm(31 downto 16)
);


MAKE_CMV: cmv port map
(
    clk   => clk_tb,
    rst   => rst_tb,
    cmv_out => cmv_sig(31 downto 16),
    a     => a_pwm(39 downto 24),
    b     => b_pwm(31 downto 16),
    c     => c_pwm(31 downto 16)
);
cmv_sig(15 downto 0) <= (others=>'0');
a_pwm(23 downto 0) <= (others=>'0');
b_pwm(15 downto 0) <= (others=>'0');
c_pwm(15 downto 0) <= (others=>'0');
MAKE_DPWM: DPWM port map
(
    a => a_sig,
    b => b_sig,
    c => c_sig,
    clk => clk_tb,
    rst => rst_tb,
    da => da_sig,
    db => db_sig,
    dc => dc_sig,
    cmv_out => open
);
 
LPF_A: lpf generic map
(
    width => 40,
    frac => 30
)
port map
(
    clk => clk_tb,
    local_rst => rst_tb,
    sync => div_tb,
    clk_out => open,
    sig_in => a_pwm,
    sig_out => a_sig_64
);

LPF_CMV: lpf generic map
(
    width => 32,
    frac => 30
)
port map
(
    clk => clk_tb,
    local_rst => rst_tb,
    sync => div_tb,
    clk_out => open,
    sig_in => cmv_sig,
    sig_out => cmv_cur
);

process(clk_tb,rst_two_tb) is
variable step   : integer range 0 to 5;
begin
    if rst_two_tb = '0' then
        a_ref_64 <= (others=>'0');
--        a_sig_64 <= (others=>'0');  
        step := 0;
    elsif rising_edge(clk_tb) then
        case step is
            when 0 => step := 1;
                a_ref_64 <= std_logic_vector( shift_left(resize(signed(a_sig),40),19 ));
            when 1 => step := 2;
--                a_sig_64 <= std_logic_vector( shift_left(resize(signed(a_sig_32), 40),8 ));
            when others => step := 0;
        end case;
    end if;
end process;
-- a_cur <= std_logic_vector(signed(da_cur) -  shift_left(signed(cmv_cur),shift) );

PWM_VAR: variable_pwm port map
(
    clk => clk_tb,
    rst => rst_two_tb,
    freq=> a_sig,
    car => open
);

PR: PR_Control generic map
(
    width => 40,
    frac => 30
) port map (
    clk => clk_tb,
    local_rst => rst_two_tb,
    sync => pwm_sync,
    ref_in => a_ref_64,
    sig_in => a_sig_64,
    sig_out => a_cur
   );
end Behavioral;
