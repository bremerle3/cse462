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

ENTITY bandwidth_counter IS
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
END bandwidth_counter;

ARCHITECTURE Behavioral OF bandwidth_counter IS

--Constants
constant D_SIZE : INTEGER := Data'length;

--Signals
type states is (s0, s1, s2);
signal state: states := s0;
signal nxt_state: states := s0;
signal D_int : std_logic_vector(D_SIZE - 1 downto 0);

-- dcm clk
signal clk_30 : std_logic;
signal clk_60 : std_logic;

-- dcm locked signal
-- signal locked : std_logic;

--lvds signal
signal lvds_internal : std_logic_vector(sigout'RANGE);

--FIFO signals
signal empty : std_logic;
signal full: std_logic;
signal fifo_wr_en: std_logic;
signal fifo_rd_en: std_logic;
signal rd_en : std_logic;
signal d_tri_buf : std_logic_vector(D_SIZE - 1 downto 0);

-- Counter signals
signal led_counter : std_logic_vector(25 downto 0);
signal counter : std_logic_vector(D_SIZE - 1 downto 0);
signal counter_reset_h: std_logic;

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

BEGIN
	
  -- RESET signals
  reset_l <= not reset_ext;

	-- tri-state buffer for data
	Data <= d_tri_buf WHEN empty = '0' else "ZZZZZZZZ";
	
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
	
	--FIFO
	fifo1 : fifo
  PORT MAP (
    rst => reset_ext,
    wr_clk => clk_30,
    rd_clk => clk_60,
    din => counter,
    wr_en => fifo_wr_en,
    rd_en => rd_en,
    dout => d_tri_buf,
    full => full,
    empty => empty
  );

	--FIFO rd_en process
	fifo_rd_en_proc: PROCESS (clk_60) BEGIN
		IF (clk_60'EVENT AND clk_60='1') THEN
			rd_en <= fifo_rd_en and not(empty);
		END IF;
	END PROCESS;
	
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
			END IF;
		WHEN s1 =>
			IF (TXE_L = '0') THEN
				nxt_state <= s2;
			END IF;
		WHEN others =>
		END CASE;
	END PROCESS state_trans; 

	--- process to define the output values
	output: PROCESS (state)
	BEGIN
		-- default
		OE_L <= '1';
		RD_L <= '1';
		WR_L <= '1';
		SIWU_L <= '1';
		fifo_wr_en <= '0';
		fifo_rd_en <= '0';
		counter_reset_h <= '0';
		CASE state IS
			WHEN s1 => -- rxf_l=0, prepare data.
				counter_reset_h <= '1';-- after 25 ns;
				OE_L <= '0';
				RD_L <= '0';
				SIWU_L <= '0';
			WHEN s2 => -- grab data in next clk cycle.
				fifo_wr_en <= '1';-- after 25 ns;
				fifo_rd_en <= '1';-- after 25 ns;
				WR_L <= '0';
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
	
	--bandwidth counter
	counter_proc:PROCESS(clk_30)
	BEGIN
		IF (clk_30 = '1' AND clk_30'EVENT) THEN
			IF (counter_reset_h = '1') THEN
				counter <= (others => '0');
			ELSE 
				counter <= counter + '1';
			END IF;
		END IF;
	END PROCESS;
	
	--Counter to blink LEDs at approximatly 1Hz and 2Hz
	led_counter_proc:PROCESS(clk_60)
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
