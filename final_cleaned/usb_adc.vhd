-- Leo Bremer, Jeremy Tang
-- Richard
-- CSE462M
-- 11 February 2015

-- Loopback VHDL
-- Updated 22 April 2015

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.all;
Library UNISIM;
use UNISIM.vcomponents.all;

ENTITY usb_adc IS
    Port ( clk_ext : in STD_LOGIC;
			  reset_ext : in std_logic;
			  switch_channel: in std_logic;
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
END usb_adc;

ARCHITECTURE Behavioral OF usb_adc IS

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
type shift_reg_states is (v0, v1, v2);
signal shift_reg_state: shift_reg_states := v0;
signal shift_reg_nxt_state: shift_reg_states := v0;
signal detect_rxf : std_logic;
signal detect_rxf_prev : std_logic;

signal D_pipe_ff : std_logic_vector(D_SIZE - 1 downto 0);
signal eni : std_logic;

signal counter_pipeline_ff : std_logic_vector(D_SIZE - 1 downto 0);

signal SR_sclr : std_logic;
signal rxf_local : std_logic;


-- dcm clk
signal clk_10 : std_logic;
signal clk_60 : std_logic;
signal clk_240 : std_logic;

-- dcm locked signal
-- signal locked : std_logic;

--lvds signals
signal lvds_internal : std_logic_vector(sigout'RANGE);  --wire
signal lvds_internal_ff: STD_LOGIC_VECTOR(7 downto 0);  --flip flop
--signal shift_reg_sum : std_logic_vector(sigout'RANGE);  --flip flop
--signal shift_reg_out : std_logic;  --wire
signal shift_reg_delay_cnt : std_logic_vector(7 downto 0);  --count for filter delay
type shift_reg_array is array (0 to 7) of std_logic_vector(7 downto 0);
signal shift_reg_sum: shift_reg_array;
type shift_reg_out_array is array (0 to 7) of std_logic;
signal shift_reg_out: shift_reg_out_array;
signal channel_select: std_logic_vector(2 downto 0);
signal current_channel : std_logic_vector(sigout'RANGE); 

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

-- internal reset signals
signal reset_l : std_logic;

--debouncer signals
 signal Q0, Q1, Q2 : std_logic := '0';
 signal switch_channel_int: std_logic := '0';

component dcm
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;
  CLK_OUT2          : out    std_logic;
  CLK_OUT3          : out    std_logic

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

COMPONENT my_shift_reg
  PORT (
    d : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    clk : IN STD_LOGIC;
    sclr : IN STD_LOGIC;
    q : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END COMPONENT;

BEGIN

	

	--FTDI Read Signals tied high
	OE_L <= '1';
	RD_L <= '1';
	
  -- RESET signals
  reset_l <= not reset_ext;
  
  -- SIWUA
  SIWU_L <= siwua;

	-- buffer for data
	Data <= D_pipe_ff;
	
	--feedback for delta-sigma
	sigout <= lvds_internal_ff;
	
	--LED for state
	--led_state1 <= '1' WHEN (rd_state = s0) else '0';
	
	--CMOD6 LEDs
	--led0_out <= led_counter(25);
	--led1_out <= led_counter(24);		
	led0_out <= channel_select(0);
	led1_out <= channel_select(1);
	led2_out <= channel_select(2);
	led3_out <= led_counter(25);	

	
  --DCM 
  my_dcm : dcm
  port map
   (-- Clock in ports
    CLK_IN1 => clk_ext,
    -- Clock out ports
    CLK_OUT1 => clk_60,
    CLK_OUT2 => clk_10,
	 CLK_OUT3 => clk_240
	);
	
	--FIFO
	fifo1 : fifo
  PORT MAP (
    rst => fifo_reset,
    wr_clk => clk_10,
    rd_clk => clk_60,
    din => counter_pipeline_ff,
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
		CASE rd_state IS
			WHEN s1 => -- grab data in next clk cycle.
				IF(fifo_empty = '0') THEN
					fifo_rd_en <= '1';
					eni <= '1';
				END IF;
			WHEN s2 => 
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
	wr_state_proc: PROCESS (clk_10) BEGIN
		IF (clk_10'EVENT AND clk_10='1') THEN
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
	
	--process to detect change in rxf_l
	detect_rxf_proc: PROCESS (clk_60) BEGIN
		IF (clk_60'EVENT AND clk_60='1') THEN
			rxf_local <= RXF_L;
			detect_rxf_prev <= rxf_local;
		--detect_rxf <= detect_rxf_prev and not RXF_L;
		END IF;
	END PROCESS detect_rxf_proc;
	
	--combinatorial logic to detect falling edge
	detect_rxf <= detect_rxf_prev and not rxf_local;

	--shift_reg_fsm
	shift_reg_fsm_proc: PROCESS (clk_240) BEGIN
		IF (clk_240'EVENT AND clk_240='1') THEN
			IF (reset_ext = '1') THEN
				shift_reg_state <= v0;
			ELSE
				shift_reg_state <= shift_reg_nxt_state;
			END IF;
		END IF;
	END PROCESS shift_reg_fsm_proc;
	
	-- process to determine next shift_reg_fsm state
	shift_reg_fsm_trans: PROCESS (shift_reg_state, shift_reg_delay_cnt, detect_rxf) BEGIN
		shift_reg_nxt_state <= shift_reg_state ;
		CASE shift_reg_state IS
		WHEN v0 =>
			IF (detect_rxf = '1') THEN  --detected rxf_l just dropped low
				shift_reg_nxt_state <= v1;
			ELSE
				shift_reg_nxt_state <= v0;
			END IF;
		WHEN v1 =>
			IF (shift_reg_delay_cnt = x"C8") THEN  --all delay has been shifted out of shift reg
				shift_reg_nxt_state <= v2;
			ELSIF (detect_rxf = '1') THEN --detected rxf_l just dropped low
				shift_reg_nxt_state <= v1;
			ELSE
				shift_reg_nxt_state <= v1; --wait longer for counter 
			END IF;
		WHEN v2 =>
			IF (detect_rxf = '1') THEN  --detected rxf_l just dropped low
				shift_reg_nxt_state <= v1;
			ELSE
				shift_reg_nxt_state <= v2; --continue shifting in data
			END IF;
		END CASE;
	END PROCESS shift_reg_fsm_trans; 
	
	--- process to define shift_reg_fsm outputs
	shift_reg_fsm_output: PROCESS (shift_reg_state, clk_240)
	BEGIN
		-- default
		SR_sclr <= '1';
		CASE shift_reg_state IS
			WHEN v2 => 
				SR_sclr <= '0';				
			WHEN others =>  --defaults
		END CASE;
	END PROCESS shift_reg_fsm_output;
		
	--Instantiate LVDS receivers and LVCMOS output for each channel
	GEN_LVDS: FOR i IN 0 to 7 GENERATE
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
	
	--LVDS internal flip-flop
	lvds_Flop:PROCESS(clk_240)
	BEGIN
		IF (clk_240 = '1' AND clk_240'EVENT) THEN
			IF (SR_sclr = '1') THEN
				lvds_internal_ff <= (others => '0');
			ELSE
				lvds_internal_ff <= lvds_internal;
			END IF;
		END IF;
	END PROCESS lvds_Flop;
	
	--shift register
	GEN_SR: FOR i IN 0 to 7 GENERATE
	
	inst_shift_reg : my_shift_reg
  PORT MAP (
    d(0) => lvds_internal_ff(i),
    clk  => clk_240,
	 sclr => SR_sclr,
    q(0) => shift_reg_out(i)
  );
	
	--shift register FIR
	filter_flop:PROCESS(clk_240)
	BEGIN
		IF (clk_240 = '1' AND clk_240'EVENT) THEN
			IF (fifo_reset = '1') THEN
				shift_reg_sum(i) <= (others => '0');
			ELSIF (lvds_internal_ff(i) = '1' and shift_reg_out(i) = '0') THEN
				shift_reg_sum(i) <= shift_reg_sum(i) + '1';
			ELSIF (lvds_internal_ff(i) = '0' and shift_reg_out(i) = '1') THEN
				shift_reg_sum(i) <= shift_reg_sum(i) - '1';
			END IF;
		END IF;
	END PROCESS filter_flop;
	
	END GENERATE GEN_SR;
	
	multiplex_channels_proc:PROCESS(clk_60)
	BEGIN
		IF (clk_60 = '1' AND clk_60'EVENT) THEN
			IF(reset_ext = '1') THEN
				channel_select <= (others => '0');
			ELSIF (switch_channel_int = '1') THEN
				channel_select <= channel_select + '1';
			END IF;
		END IF;
	END PROCESS multiplex_channels_proc;
	
	
	PROCESS (channel_select,shift_reg_sum)
	BEGIN
		CASE channel_select IS 
							 WHEN "000" => current_channel <= shift_reg_sum(0);
						    WHEN "001" => current_channel <= shift_reg_sum(1);
							 WHEN "010" => current_channel <= shift_reg_sum(2);
							 WHEN "011" => current_channel <= shift_reg_sum(3);
							 WHEN "100" => current_channel <= shift_reg_sum(4);
						    WHEN "101" => current_channel <= shift_reg_sum(5);
							 WHEN "110" => current_channel <= shift_reg_sum(6);
							 WHEN "111" => current_channel <= shift_reg_sum(7);
							 WHEN OTHERS => current_channel <= shift_reg_sum(0);
		END CASE;
	END PROCESS;
	
	--debouncer process
	process (clk_60)  
	begin 
		if (clk_60'event and clk_60 = '1') then  
			Q0 <= switch_channel; 
			Q1 <= Q0; 
			Q2 <= Q1; 
		end if; 
	end process;
	
	switch_channel_int <= Q0 and Q1 and (not Q2);
	
	--counter pipeline flip-flop
	counter_pipeline_ff_proc:PROCESS(clk_10)
	BEGIN
		IF (clk_10 = '1' AND clk_10'EVENT) THEN
			IF (fifo_reset = '1') THEN
				counter_pipeline_ff <= (others => '0');
			ELSE
				counter_pipeline_ff <= current_channel;
			END IF;
		END IF;
	END PROCESS counter_pipeline_ff_proc;
	
	--shift reg delay counter
	shift_reg_delay_counter_proc:PROCESS(clk_240, shift_reg_state)
	BEGIN
		IF (clk_240 = '1' AND clk_240'EVENT) THEN
			IF (reset_l = '0') THEN
				shift_reg_delay_cnt <= (others => '0');
			ELSIF (shift_reg_state = v1) THEN
				shift_reg_delay_cnt <= shift_reg_delay_cnt + '1';
			END IF;
		END IF;
	END PROCESS;
	
	--bandwidth counter
	counter_proc:PROCESS(clk_10, wr_state)
	BEGIN
		IF (clk_10 = '1' AND clk_10'EVENT) THEN
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
