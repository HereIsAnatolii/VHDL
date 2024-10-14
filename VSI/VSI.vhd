----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/13/2024 07:34:12 PM
-- Design Name: 
-- Module Name: VSI - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VSI is
    generic (width : integer := 32;
             frac  : integer := 16);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sampling : in STD_LOGIC;
           sync     : in STD_LOGIC;
           
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
end VSI;

architecture Behavioral of VSI is
component RL_filter is
    generic (width : integer := 32;
             frac : integer := 16);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           sync : in STD_LOGIC;
           
           sig_in    : in STD_LOGIC_VECTOR(width-1 downto 0);
           Ts_over_L : in STD_LOGIC_VECTOR(width-1 downto 0);
           R         : in STD_LOGIC_VECTOR(width-1 downto 0);
           lpf_out   : out STD_LOGIC_VECTOR (width-1 downto 0));
end component;

component CM_current is
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
end component;

--        Ts_over_L => x"0000_0034",      --  0.04 us / 50u
--        R         => x"0011_0000",      -- 17 Ohm
signal lpf_A, lpf_B, lpf_C, I_A_SIG, I_B_SIG, I_C_SIG : std_logic_vector(width-1 downto 0);
signal sync_sig : std_logic_vector(1 downto 0);
begin

I_a <= I_A_SIG;
I_b <= I_B_SIG;
I_c <= I_C_SIG;

RL_INST_A: rl_filter 
port map (
        clk => clk,
        rst => rst,
        sync => sampling,
        
        sig_in    => pwm_A,
        Ts_over_L => Ts_over_L,
        R         => R_value,
        lpf_out   => lpf_A
);
RL_INST_B: rl_filter 
port map (
        clk => clk,
        rst => rst,
        sync => sampling,
        
        sig_in    => pwm_B,
        Ts_over_L => Ts_over_L,
        R         => R_value,
        lpf_out   => lpf_B
);
RL_INST_C: rl_filter 
port map (
        clk => clk,
        rst => rst,
        sync => sampling,
        
        sig_in    => pwm_C,
        Ts_over_L => Ts_over_L,
        R         => R_value,
        lpf_out   => lpf_C
);

CMI : CM_current 
port map (
        clk => clk,
        rst => rst,
        sync => sampling,
        
        A_in => lpf_A,
        B_in => lpf_B,
        C_in => lpf_C,
        A_out => I_A_SIG,
        B_out => I_B_SIG,
        C_out => I_C_SIG
);

process(clk,rst) is
begin
    if rst = '1' then
        sync_sig <= b"00";
    elsif rising_edge(clk) then
        sync_sig(1) <= sync_sig(0);
        sync_sig(0) <= sync;
        if (sync_sig(1) = '0' and sync_sig(0) = '1') then
            I_a_mes <= I_A_SIG;
            I_b_mes <= I_B_SIG;
            I_c_mes <= I_C_SIG;
        end if;
    end if;
end process;
end Behavioral;
