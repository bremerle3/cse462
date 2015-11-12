-- Leo Bremer, Jeremy Tang
-- Richard
-- CSE462M
-- 11 February 2015

-- Loopback VHDL
-- Updated 16 February 2015

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

ENTITY fsm IS
    Port ( clk_ext : in STD_LOGIC;
			  reset_ext : in std_logic;
           Data : inout STD_LOGIC_VECTOR (7 downto 0);
			  TXE_L : in STD_LOGIC;
			  RXF_L : in STD_LOGIC;
			  OE_L : out STD_LOGIC; 
			  WR_L : out STD_LOGIC; 
			  RD_L : out STD_LOGIC;
			  SIWU_L : out STD_LOGIC;
			  sigin_n : in STD_LOGIC_VECTOR(7 downto 0);
			  sigin_p : in STD_LOGIC_VECTOR(7 downto 0);
			  sigout : out STD_LOGIC_VECTOR(7 downto 0);
			  led0_out : out STD_LOGIC;
			  led1_out : out STD_LOGIC
			  );
END fsm;

ARCHITECTURE Behavioral OF fsm IS

--Constants
constant D_SIZE : INTEGER := Data'length;

--Signals
type states is (s0, s1);
signal state: states := s0;
signal nxt_state: states := s0;
signal D_int : std_logic_vector(D_SIZE - 1 downto 0);
signal eno : std_logic;
signal shift_reg_in : std_logic;
signal shift_reg_out : std_logic;
signal counter : std_logic_vector(D_SIZE - 1 downto 0);
signal count_inc : std_logic;
signal count_dec : std_logic;

-- dcm clk
signal clk_60 : std_logic;
signal clk_30 : std_logic;

--lvds signal
signal lvds_internal : std_logic_vector(sigout'RANGE);

-- LED counter
signal led_counter : std_logic_vector(25 downto 0);

-- internal reset signals
signal reset_l : std_logic;
signal reset_h : std_logic;

--FIFO signals
signal full : std_logic;
signal empty : std_logic;

component dcm
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;
  CLK_OUT2          : out    std_logic
 );
end component;

COMPONENT fifo
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END COMPONENT;

COMPONENT shift_reg
  PORT (
    d : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    clk : IN STD_LOGIC;
    q : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

BEGIN
	
  -- RESET signals
  reset_l <= not reset_ext;
  reset_h <= reset_ext;
  
  	-- tri-state buffer for data
	Data <= D_int WHEN eno = '1' else "ZZZZZZZZ";
	
	--CMOD6 LEDs
	led0_out <= '1';
	led1_out <= '1';
	
  --DCM 
 my_dcm : dcm
  port map
   (-- Clock in ports
    CLK_IN1 => clk_ext,
    -- Clock out ports
    CLK_OUT1 => clk_60,
    CLK_OUT2 => clk_30
	);
	
  --FIFO
  fifo_map : fifo
  PORT MAP (
    rst => reset_h,
    wr_clk => clk_30,
    rd_clk => clk_60,
    din => counter,
    wr_en => eno,
    rd_en => eno,
    dout => D_int,
    full => full,
    empty => empty  
  );
  
  shift_reg1 : shift_reg
  PORT MAP (
    d => shift_reg_in,
    clk => clk_30,
    q => shift_reg_out
  );
  
  --shift register process
  shift_reg_proc: PROCESS (clk_30) BEGIN
	IF (clk_30'EVENT AND clk_30='1') THEN
		IF (reset_l = '0') THEN
			counter <= (others => '0');
			shift_reg_in <= '0';
		ELSE 
			
			
	
	--process to implement the state register
	clkd: PROCESS (clk_60) BEGIN
		IF (clk_60'EVENT AND clk_60='1') THEN
			IF (reset_l = '0') THEN
				state <= s0;
			ELSE
				state <= nxt_state;
			END IF;
		END IF;
	END PROCESS clkd;
	
	-- process to determine next state
	state_trans: PROCESS (TXE_L, state) BEGIN
		nxt_state <= state ;
		CASE state IS
		WHEN s0 => -- idle, wait for txe_l = 0
			IF (TXE_L = '1') THEN
				nxt_state <= s0;
			ELSE
				nxt_state <= s1;
			END IF ;
		WHEN s1 => -- txe_l=0, output data.
			IF (TXE_L = '1') THEN
				nxt_state <= s0;
			ELSE
				nxt_state <= s1;
			END IF;
		END CASE;
	END PROCESS state_trans; 
	
	--- process to define the output values
	output: PROCESS (state)
	BEGIN
		-- default, nothing asserted
		OE_L <= '1';
		RD_L <= '1';
		WR_L <= '1';
		SIWU_L <= '1';
		eno <= '0';
			
		CASE state IS
			WHEN s1 => -- txe_l=0, output data.
				WR_L <= '0';-- after 25 ns;
				eno <= '1';
			WHEN others => -- default
		END CASE ;
	END PROCESS output ;
	
	--Instantiate LVDS receivers and LVCMOS output for each channel
	GEN_LVDS: FOR i IN sigout'RANGE GENERATE
	BEGIN
		--Input LVDS buffer
		IBUFDS_inst : IBUFDS
		generic map (DIFF_TERM => FALSE,
						 IBUF_LOW_PWR => FALSE,
						 IOSTANDARD => "DEFAULT")
		port map (O => lvds_internal(i),
					 I => sigin_p(i),
					 IB => sigin_n(i));
		
	END GENERATE GEN_LVDS;
	
	--LVCMOS output flip-flop
	lvds_Flop:PROCESS(clk_30)
	BEGIN
		IF (clk_30 = '1' AND clk_30'EVENT) THEN
			IF (reset_l = '0') THEN
				sigout <= (others => '0');
			ELSE
				sigout <= lvds_internal;
			END IF;
		END IF;
	END PROCESS lvds_Flop;
		
END Behavioral ; 
