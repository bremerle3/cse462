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
type states is (s0, s1, s2, s3, s4, s5, s6, s7);
signal state: states := s0;
signal nxt_state: states := s0;
signal D_int : std_logic_vector(D_SIZE - 1 downto 0);
signal eno : std_logic;
signal eni : std_logic;

-- dcm clk
signal clk_30 : std_logic;
signal clk_60 : std_logic;

-- dcm locked signal
-- signal locked : std_logic;

--lvds signal
signal lvds_internal : std_logic_vector(sigout'RANGE);

-- LED counter
signal led_counter : std_logic_vector(25 downto 0);

-- internal reset signals
signal reset_l : std_logic;

component dcm
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;
  CLK_OUT2          : out    std_logic
 );
end component;

BEGIN
	
  -- RESET signals
  reset_l <= not reset_ext;

	-- tri-state buffer for data
	Data <= D_int WHEN eno = '1' else "ZZZZZZZZ";
	
	--CMOD6 LEDs
	led0_out <= led_counter(25);
	led1_out <= led_counter(24);
		
  --DCM 
  my_dcm : dcm
  port map
   (-- Clock in ports
    CLK_IN1 => clk_ext,
    -- Clock out ports
    CLK_OUT1 => clk_30,
    CLK_OUT2 => clk_60
	);

	-- Data flip-flop process
	flip_flop: PROCESS(clk_60) BEGIN
		if (rising_edge(clk_60)) then
			if (eni = '1') then
				D_int <= Data;
			end if;
		end if;
	END PROCESS flip_flop;

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
	state_trans: PROCESS (RXF_L, TXE_L, state) BEGIN
		nxt_state <= state ;
		CASE state IS
		WHEN s0 => -- idle, wait for rxf_l=0
			IF (RXF_L = '1') THEN
				nxt_state <= s0;
			ELSE
				nxt_state <= s1;
			END IF ;
		WHEN s1 => -- rxf_l=0, prepare data.
			nxt_state <= s2;
		WHEN s2 => -- grab data in next clk cycle.
			nxt_state <= s3;
		WHEN s3 => -- grab data, turnaround cycle.
			nxt_state <= s4;
		WHEN s4 => -- wait for txe_l=0
			IF (TXE_L = '0') THEN
				nxt_state <= s5;
			END IF;
		WHEN s5 => -- txe_l=0, output data.
			nxt_state <= s6;
		WHEN s6 => -- finish write
			nxt_state <= s7;
		WHEN s7 => -- drop siwua, send immediate
			nxt_state <= s0;
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
		eni <= '0';
		eno <= '0';
		--OE_L <= '1' after 25 ns;
		--RD_L <= '1' after 25 ns;
		--WR_L <= '1' after 25 ns;
		--SIWU_L <= '1' after 25 ns;
		--eni <= '0' after 25 ns;
		--eno <= '0' after 25 ns;
			
		CASE state IS
			WHEN s1 => -- rxf_l=0, prepare data.
				OE_L <= '0';-- after 25 ns;
			WHEN s2 => -- grab data in next clk cycle.
				OE_L <= '0';-- after 25 ns;
				RD_L <= '0';-- after 25 ns;
				eni <= '1';-- after 25 ns;
			WHEN s5 => -- txe_l=0, output data.
				eno <= '1';-- after 25 ns;
				WR_L <= '0';-- after 25 ns;
			WHEN s7 => -- drop siwua, send immediate
				SIWU_L <= '0';-- after 25 ns;
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
	
	--Counter to blink LEDs at approximatly 1Hz and 2Hz
	counter:PROCESS(clk_60)
	BEGIN
		IF (clk_60 = '1' AND clk_60'EVENT) THEN
			IF (reset_l = '0') THEN
				led_counter <= (others => '0');
			ELSE 
				led_counter <= led_counter + '1';
			END IF;
		END IF;
	END PROCESS;
		
END Behavioral ; 
