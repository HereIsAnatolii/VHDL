----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity vsi_module is
Port ( 
    clk : in STD_LOGIC;
    rst : in STD_LOGIC
);
end vsi_module;

architecture Behavioral of vsi_module is
signal shift : integer := 2;

signal sin_base, cos_base : std_logic_vector(15 downto 0);
signal a_sig,b_sig,c_sig : std_logic_vector(15 downto 0);
signal da_sig,db_sig,dc_sig : std_logic_vector(15 downto 0);

signal a_pwm, b_pwm, c_pwm,cmv_sig : std_logic_vector(31 downto 0);
signal a_cur, da_cur, cmv_cur : std_logic_vector(31 downto 0);
signal div_tb, slow_clk : std_logic;
-- COMPONENTS --
component slow_sync is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sync_sec : out STD_LOGIC);
end component;

component cordic is
    Port ( 	clk 	: in STD_LOGIC;
			rst 	: in STD_LOGIC;
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
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           modulation : in STD_LOGIC_VECTOR(15 downto 0);
           pwm_out : out STD_LOGIC_VECTOR(15 downto 0));
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
begin

-- PROCESSES --
SYNC: process(clk,rst) is
begin
    if rst = '0' then
        div_tb <= '0';
    elsif rising_edge(clk) then
        div_tb <= not div_tb;
    end if;
end process;

-- BLOCKS --
MAKE_CLOCK: slow_sync port map
(
    clk => clk,
    rst => rst,
    sync_sec => slow_clk
);

MAKE_SIN: cordic port map
(
    clk => slow_clk,
    rst => rst,
    sin => sin_base,
    cos => cos_base
);

MAKE_ABC: ab_abc port map
(
    clk   => clk,
    rst   => rst,
    alpha => cos_base,
    beta  => sin_base,
    a     => a_sig,
    b     => b_sig,
    c     => c_sig
);
 
MAKE_ALBE: abc_ab port map
(
    clk   => clk,
    rst   => rst,
    alpha => open,
    beta  => open,
    a     => a_sig,
    b     => b_sig,
    c     => c_sig
);
 
MAKE_PWM_A: pwm port map
(
    clk => clk,
    rst => rst,
    modulation => a_sig,
    pwm_out => a_pwm(31 downto 16)
);

MAKE_PWM_B: pwm port map
(
    clk => clk,
    rst => rst,
    modulation => b_sig,
    pwm_out => b_pwm(31 downto 16)
);

MAKE_PWM_C: pwm port map
(
    clk => clk,
    rst => rst,
    modulation => c_sig,
    pwm_out => c_pwm(31 downto 16)
);


MAKE_CMV: cmv port map
(
    clk   => clk,
    rst   => rst,
    cmv_out => cmv_sig(31 downto 16),
    a     => a_pwm(31 downto 16),
    b     => b_pwm(31 downto 16),
    c     => c_pwm(31 downto 16)
);
cmv_sig(15 downto 0) <= (others=>'0');
a_pwm(15 downto 0) <= (others=>'0');
b_pwm(15 downto 0) <= (others=>'0');
c_pwm(15 downto 0) <= (others=>'0');
MAKE_DPWM: DPWM port map
(
    a => a_sig,
    b => b_sig,
    c => c_sig,
    clk => clk,
    rst => rst,
    da => da_sig,
    db => db_sig,
    dc => dc_sig,
    cmv_out => open
);
 
LPF_A: lpf generic map
(
    width => 32,
    frac => 30
)
port map
(
    clk => clk,
    local_rst => rst,
    sync => div_tb,
    clk_out => open,
    sig_in => a_pwm,
    sig_out => da_cur
);

LPF_CMV: lpf generic map
(
    width => 32,
    frac => 30
)
port map
(
    clk => clk,
    local_rst => rst,
    sync => div_tb,
    clk_out => open,
    sig_in => cmv_sig,
    sig_out => cmv_cur
);

a_cur <= std_logic_vector(signed(da_cur) -  shift_left(signed(cmv_cur),shift) );

end Behavioral;
