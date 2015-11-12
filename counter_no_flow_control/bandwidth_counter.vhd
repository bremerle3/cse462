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
			  led1_out : out STD_LOGIC;
			  led2_out: out STD_LOGIC;
			  led3_out: out STD_LOGIC
			  );
END bandwidth_counter;

ARCHITECTURE Behavioral OF bandwidth_counter IS

--Constants
constant D_SIZE : INTEGER := Data'length;

--Signals
type rd_states is (s0, s1, s2);
signal rd_state: rd_states := s0;
signal rd_nxt_state: rd_states := s0;
type wr_states is (t0, t1, t2);
signal wr_state: wr_states := t0;
signal wr_nxt_state: wr_states := t0;
type txe_states is (u0, u1);
signal txe_state: txe_states := u0;
signal txe_nxt_state: txe_states := u0;

signal D_int : std_logic_vector(D_SIZE - 1 downto 0);
signal D_pipe_ff : std_logic_vector(D_SIZE - 1 downto 0);
signal eni : std_logic;

-- dcm clk
signal clk_30 : std_logic;
signal clk_60 : std_logic;

-- dcm locked signal
-- signal locked : std_logic;

--lvds signal
signal lvds_internal : std_logic_vector(sigout'RANGE);

--FIFO signals
signal fifo_empty : std_logic;
signal fifo_full: std_logic;
signal fifo_wr_en: std_logic;
signal fifo_rd_en: std_logic;
signal d_fifo_out : std_logic_vector(D_SIZE - 1 downto 0);
signal fifo_reset : std_logic;

-- siwua signals
signal siwua : std_logic;
signal siwua_nxt : std_logic;

-- Counter signals
signal led_counter : std_logic_vector(25 downto 0);
signal counter : std_logic_vector(24 downto 0);
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

	--FTDI Read Signals tied high
	OE_L <= '1';
	RD_L <= '1';
	
	--FIFO write when not full
	--fifo_wr_en <= NOT(fifo_full);
	
  -- RESET signals
  reset_l <= not reset_ext;
  
  -- SIWUA
  SIWU_L <= siwua;

	-- buffer for data
	Data <= D_pipe_ff;
	
	--LED for state
	--led_state1 <= '1' WHEN (rd_state = s0) else '0';
	
	--CMOD6 LEDs
	--led0_out <= led_counter(25);
	--led1_out <= led_counter(24);		
	led0_out <= counter(24);
	led1_out <= counter(23);	
	
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
	fifo1 : fifo
  PORT MAP (
    rst => fifo_reset,
    wr_clk => clk_30,
    rd_clk => clk_60,
    din => counter(7 downto 0),
    wr_en => fifo_wr_en,
    rd_en => fifo_rd_en,
    dout => d_fifo_out,
    full => fifo_full,
    empty => fifo_empty
  );
  
  -- Pipeline flip_flop process
	pipe_flop: PROCESS(clk_60) BEGIN
		if (rising_edge(clk_60)) then
			if (reset_ext = '1') then
				D_pipe_ff <= x"AA";
			elsif (eni = '1') then 
				D_pipe_ff <= d_fifo_out;
			end if;
		end if;
	END PROCESS pipe_flop;
	
	--process to implement the rd_state register
	rd_state_proc: PROCESS (clk_60) BEGIN
		IF (clk_60'EVENT AND clk_60='1') THEN
			IF (reset_l = '0') THEN
				rd_state <= s0;
			ELSE
				rd_state <= rd_nxt_state;
			END IF;
		END IF;
	END PROCESS rd_state_proc;

	-- process to determine next rd_state
	rd_state_trans: PROCESS (RXF_L, TXE_L, fifo_empty, rd_state) BEGIN
		rd_nxt_state <= rd_state ;
		CASE rd_state IS
		WHEN s0 => -- idle, wait for rxf_l=0
			IF (RXF_L = '0') THEN
				rd_nxt_state <= s1;
			ELSE
				rd_nxt_state <= s0;
			END IF;
		WHEN s1 =>
			IF (fifo_empty = '1') THEN
				rd_nxt_state <= s1;
			ELSIF (fifo_empty = '0') THEN
				rd_nxt_state <= s2;
			END IF;
		WHEN s2 =>
			IF (fifo_empty = '0') THEN
				rd_nxt_state <= s2;
			ELSIF ((fifo_empty = '1') AND (TXE_L = '0')) THEN
				rd_nxt_state <= s1;
			END IF;
		END CASE;
	END PROCESS rd_state_trans; 

	--- process to define the output values for read clk domain fsm
	rd_output: PROCESS (rd_state, TXE_L, fifo_empty)
	BEGIN
		-- default
		eni <= '0';
		fifo_rd_en <= '0';
		--SIWU_L <= '1';
		WR_L <= '1';
		led2_out <= '1'; 
		led3_out <= '1'; 
		CASE rd_state IS
			WHEN s1 => -- grab data in next clk cycle.
				--IF (TXE_L = '1') THEN
				--	SIWU_L <= '0';
				--END IF;
				IF(fifo_empty = '0') THEN
					fifo_rd_en <= '1';
					eni <= '1';
				END IF;
				led2_out <= '1'; 
			WHEN s2 => 
				--IF (TXE_L = '1') THEN
				--	SIWU_L <= '0';
				--ELSE
				led3_out <= '1'; 
				IF (TXE_L = '0') THEN
					IF (fifo_empty = '0') THEN
						fifo_rd_en <= '1';
						eni <= '1';						
					END IF;
					WR_L <= '0';
				END IF;
			WHEN others =>  --defaults
		END CASE;
	END PROCESS rd_output;
	
	--process to implement the wr_state register
	wr_state_proc: PROCESS (clk_30) BEGIN
		IF (clk_30'EVENT AND clk_30='1') THEN
			IF (reset_l = '0') THEN
				wr_state <= t0;
			ELSE
				wr_state <= wr_nxt_state;
			END IF;
		END IF;
	END PROCESS wr_state_proc;

	-- process to determine next wr_state
	wr_state_trans: PROCESS (RXF_L, wr_state) BEGIN
		wr_nxt_state <= wr_state ;
		CASE wr_state IS
		WHEN t0 => -- idle, wait for rxf_l=0
			IF (RXF_L = '0') THEN
				wr_nxt_state <= t1;
			ELSE
				wr_nxt_state <= t0;
			END IF;
		WHEN t1 =>
			wr_nxt_state <= t2;
		WHEN t2 =>
			wr_nxt_state <= t2;
		END CASE;
	END PROCESS wr_state_trans; 

	--- process to define the output values for write fsm
	wr_output: PROCESS (wr_state, fifo_full)
	BEGIN
		-- default
		fifo_reset <= '0';
		fifo_wr_en <= '0';
		CASE wr_state IS
			WHEN t1 => -- grab data in next clk cycle.
				fifo_reset <= '1';
			WHEN t2 => 			
				fifo_wr_en <= not fifo_full;
			WHEN others =>  --defaults
		END CASE;
	END PROCESS wr_output;
		
	--txe state flop
	txe_state_proc: PROCESS (clk_60) BEGIN
		IF (clk_60'EVENT AND clk_60='1') THEN
			siwua <= siwua_nxt;
			IF (reset_l = '0') THEN
				txe_state <= u0;
			ELSE
				txe_state <= txe_nxt_state;
			END IF;
		END IF;
	END PROCESS txe_state_proc;
	
	-- process to determine next txe_state
	txe_state_trans: PROCESS (txe_state, TXE_L) BEGIN
		txe_nxt_state <= txe_state ;
		CASE txe_state IS
		WHEN u0 =>
			IF (TXE_L = '0') THEN
				txe_nxt_state <= u1;
			END IF;
		WHEN u1 =>
			IF (TXE_L = '1') THEN
				txe_nxt_state <= u0;
			END IF;
		END CASE;
	END PROCESS txe_state_trans; 
	
	--- process to define siwua
	txe_output: PROCESS (txe_state, TXE_L)
	BEGIN
		-- default
		siwua_nxt <= '1'; 
		CASE txe_state IS
			WHEN u1 => 
				IF (TXE_L = '1') THEN
					siwua_nxt <= '0';
				END IF;
			WHEN others =>  --defaults
		END CASE;
	END PROCESS txe_output;
		
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
	counter_proc:PROCESS(clk_30, wr_state)
	BEGIN
		IF (clk_30 = '1' AND clk_30'EVENT) THEN
			IF (reset_l = '0') THEN
				counter <= (others => '0');
				counter(7 downto 0) <= x"88";
			ELSIF (wr_state = t2) THEN
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
