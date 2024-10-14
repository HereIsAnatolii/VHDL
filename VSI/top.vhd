----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/08/2024 08:39:12 PM
-- Design Name: 
-- Module Name: top - Behavioral
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

entity top is
--  Port ( );
end top;

architecture Behavioral of top is

----------------------------- COMPONENTS DEFINITION -------------------------------
----------------------------------------------------------------------------------
component clk_rst is
    Port ( clk_100 : out STD_LOGIC;
           rst : out STD_LOGIC;
           samp : out STD_LOGIC;
           angle : out STD_LOGIC_VECTOR (31 downto 0));
end component;
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
component dq_2_albe is
    generic (width : integer := 32;
             frac : integer := 16);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           
           d_in      : in STD_LOGIC_VECTOR(width-1 downto 0);
           q_in      : in STD_LOGIC_VECTOR(width-1 downto 0);
           angle     : in STD_LOGIC_VECTOR(width-1 downto 0);
           alpha_out : out STD_LOGIC_VECTOR (width-1 downto 0);
           beta_out  : out STD_LOGIC_VECTOR (width-1 downto 0));
end component;
component albe_2_dq is
    generic (width : integer := 32;
             frac : integer := 16);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           alpha_in   : in STD_LOGIC_VECTOR(width-1 downto 0);
           beta_in    : in STD_LOGIC_VECTOR(width-1 downto 0);
           angle      : in STD_LOGIC_VECTOR(width-1 downto 0);
           d_out      : out STD_LOGIC_VECTOR (width-1 downto 0);
           q_out      : out STD_LOGIC_VECTOR (width-1 downto 0));
end component;
component alphabeta_2_abc is
    generic (width : integer := 32;
             frac  : integer := 16);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           alpha : in STD_LOGIC_VECTOR (width-1 downto 0);
           beta : in STD_LOGIC_VECTOR (width-1 downto 0);
           
           a : out STD_LOGIC_VECTOR (width-1 downto 0);
           b : out STD_LOGIC_VECTOR (width-1 downto 0);
           c : out STD_LOGIC_VECTOR (width-1 downto 0)
           );
end component ;
component abc_2_alphabeta is
    generic (width : integer := 32;
             frac  : integer := 16);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           A : in STD_LOGIC_VECTOR (width-1 downto 0);
           B : in STD_LOGIC_VECTOR (width-1 downto 0);
           C : in STD_LOGIC_VECTOR (width-1 downto 0);
           
           alpha : out STD_LOGIC_VECTOR (width-1 downto 0);
           beta  : out STD_LOGIC_VECTOR (width-1 downto 0)
           );
end component ;
component DPWM is
    generic (width : integer := 32;
             frac  : integer := 16);
    Port ( a : in STD_LOGIC_VECTOR (width-1 downto 0);
           b : in STD_LOGIC_VECTOR (width-1 downto 0);
           c : in STD_LOGIC_VECTOR (width-1 downto 0);
           
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           
           da  : out STD_LOGIC_VECTOR (width-1 downto 0);
           db  : out STD_LOGIC_VECTOR (width-1 downto 0);
           dc  : out STD_LOGIC_VECTOR (width-1 downto 0);
           
           cmv_out : out STD_LOGIC_VECTOR (width-1 downto 0));
end component;
component SVPWM is
    generic (width : integer := 32;
             frac  : integer := 16);
    Port ( a : in STD_LOGIC_VECTOR (width-1 downto 0);
           b : in STD_LOGIC_VECTOR (width-1 downto 0);
           c : in STD_LOGIC_VECTOR (width-1 downto 0);
           
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           
           sa  : out STD_LOGIC_VECTOR (width-1 downto 0);
           sb  : out STD_LOGIC_VECTOR (width-1 downto 0);
           sc  : out STD_LOGIC_VECTOR (width-1 downto 0);
           
           cmv_out : out STD_LOGIC_VECTOR (width-1 downto 0));
end component;
component pwm is
    generic (width : integer := 32 );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           modulation : in STD_LOGIC_VECTOR(width-1 downto 0);
           car_lim   : in STD_LOGIC_VECTOR(width-1 downto 0);
           scale     : in STD_LOGIC_VECTOR(width-1 downto 0);
           carrier   : out STD_LOGIC_VECTOR(width-1 downto 0);
           pwm_out   : out STD_LOGIC_VECTOR(width-1 downto 0);
           sync_out  : out STD_LOGIC
           );
end component;

component VSI is
    generic (width : integer := 32;
             frac  : integer := 16);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sampling : in STD_LOGIC;
           sync : in STD_LOGIC;
           
           Ts_over_L : in STD_LOGIC_VECTOR (width-1 downto 0);
           R_value   : in STD_LOGIC_VECTOR (width-1 downto 0);
           PWM_a : in STD_LOGIC_VECTOR (width-1 downto 0);
           PWM_b : in STD_LOGIC_VECTOR (width-1 downto 0);
           PWM_c : in STD_LOGIC_VECTOR (width-1 downto 0);
           
           I_a : out STD_LOGIC_VECTOR (width-1 downto 0);
           I_b : out STD_LOGIC_VECTOR (width-1 downto 0);
           I_c : out STD_LOGIC_VECTOR (width-1 downto 0);
           
           I_a_mes : out STD_LOGIC_VECTOR (width-1 downto 0);
           I_b_mes : out STD_LOGIC_VECTOR (width-1 downto 0);
           I_c_mes : out STD_LOGIC_VECTOR (width-1 downto 0)
           );
end component;

----------------------------- SIGNALS DEFINITION -------------------------------
----------------------------------------------------------------------------------
signal clk_sig, rst_sig, sync_sig, sampling : std_logic;
signal angle_sig : std_logic_vector(31 downto 0);
signal alpha_sig, beta_sig, a_sig, b_sig, c_sig, da_sig, db_sig, dc_sig : std_logic_vector(31 downto 0);
signal alpha_in, beta_in, d_in, q_in : std_logic_vector(31 downto 0);
signal pwm_A, pwm_B, pwm_C, I_a_mes, I_b_mes, I_c_mes : std_logic_vector(31 downto 0);
signal lpf_A, lpf_B, lpf_C, Current_A, Current_B, Current_C : std_logic_vector(31 downto 0);
begin
------------------------------ INSTANCE DEFINITION -------------------------------
----------------------------------------------------------------------------------
CLK_RST_INST: clk_rst port map
    (
        clk_100 => clk_sig,
        rst => rst_sig,
        samp => sampling,
        angle => angle_sig
    );
DQ_2_AB_INST: dq_2_albe 
generic map (
        width => 32, 
        frac => 16)
port map (
        clk       => clk_sig,
        rst       => rst_sig,
        
        d_in      => x"0000_CF5C",
        q_in      => (others=>'0'),
        angle     => angle_sig,
        alpha_out => alpha_sig,
        beta_out  => beta_sig
        );
CLARKE_INST: alphabeta_2_abc port map
    (
        clk   => clk_sig,
        rst   => rst_sig,
        alpha => alpha_sig,
        beta  => beta_sig,
        
        a     => a_sig,
        b     => b_sig,
        c     => c_sig
    );
SVPWM_INST: SVPWM port map
    (
        clk   => clk_sig,
        rst   => rst_sig,
        a     => a_sig,
        b     => b_sig,
        c     => c_sig,
        sa    => da_sig,
        sb    => db_sig,
        sc    => dc_sig,
        cmv_out => open
    );
PWM_INST_A: pwm port map
    (
        clk   => clk_sig,
        rst   => rst_sig,
        modulation  => da_sig,
        car_lim     => x"0000_FFFF",
        scale       => x"0190_0000",    -- 400 V
        carrier => open,
        pwm_out => pwm_A,
        sync_out => sync_sig
    );
PWM_INST_B: pwm port map
    (
        clk   => clk_sig,
        rst   => rst_sig,
        modulation  => db_sig,
        car_lim     => x"0000_FFFF",
        scale       => x"0190_0000",    -- 400 V
        carrier => open,
        pwm_out => pwm_B,
        sync_out => sync_sig
    );
PWM_INST_C: pwm port map
    (
        clk   => clk_sig,
        rst   => rst_sig,
        modulation  => dc_sig,
        car_lim     => x"0000_FFFF",
        scale       => x"0190_0000",    -- 400 V
        carrier => open,
        pwm_out => pwm_C,
        sync_out => sync_sig
    );
    
-- IMPLEMENT THE COMPARATOR, LPF and CMV 
VSI_INST: VSI port map
    (
        clk   => clk_sig,
        rst   => rst_sig,
        sampling => sampling,
        sync  => sync_sig,
        Ts_over_L => x"0000_0034",
        R_value   => x"0011_0000",
        PWM_A => pwm_A,
        PWM_B => pwm_B,
        PWM_C => pwm_C,
       
        I_a => Current_A, 
        I_b => Current_B,
        I_c => Current_C,
        
        I_a_mes => I_a_mes,
        I_b_mes => I_b_mes,
        I_c_mes => I_c_mes
    );

CLARKE_REVERSE_INST: abc_2_alphabeta
port map
    (
        clk   => clk_sig,
        rst   => rst_sig,
        A     => I_a_mes,
        B     => I_b_mes,
        C     => I_c_mes,
        
        alpha => alpha_in,
        beta  => beta_in
        
    );
PARK_REVERSE_INST: albe_2_dq 
generic map (
        width => 32, 
        frac => 16)
port map (
        clk => clk_sig,
        rst => rst_sig,
        
        alpha_in => alpha_in,
        beta_in  =>  beta_in,
        angle    =>  angle_sig,
        d_out    => d_in,
        q_out    => q_in
);
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
end Behavioral;
