--------------------------------------------------------------------------------
-- Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: P.49d
--  \   \         Application: netgen
--  /   /         Filename: fsm_synthesis.vhd
-- /___/   /\     Timestamp: Sun Mar 22 16:59:48 2015
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -ar Structure -tm fsm -w -dir netgen/synthesis -ofmt vhdl -sim fsm.ngc fsm_synthesis.vhd 
-- Device	: xc6slx4-2-cpg196
-- Input file	: fsm.ngc
-- Output file	: \\warehouse2\home\lbremer\cse462\Loopback_FSM\netgen\synthesis\fsm_synthesis.vhd
-- # of Entities	: 1
-- Design Name	: fsm
-- Xilinx	: C:\Xilinx\14.4\ISE_DS\ISE\
--             
-- Purpose:    
--     This VHDL netlist is a verification model and uses simulation 
--     primitives which may not represent the true implementation of the 
--     device, however the netlist is functionally correct and should not 
--     be modified. This file cannot be synthesized and should only be used 
--     with supported simulation tools.
--             
-- Reference:  
--     Command Line Tools User Guide, Chapter 23
--     Synthesis and Simulation Design Guide, Chapter 6
--             
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VPKG.ALL;

entity fsm is
  port (
    clk_ext : in STD_LOGIC := 'X'; 
    reset_l : in STD_LOGIC := 'X'; 
    TXE_L : in STD_LOGIC := 'X'; 
    RXF_L : in STD_LOGIC := 'X'; 
    OE_L : out STD_LOGIC; 
    WR_L : out STD_LOGIC; 
    RD_L : out STD_LOGIC; 
    SIWU_L : out STD_LOGIC; 
    Data : inout STD_LOGIC_VECTOR ( 7 downto 0 ) 
  );
end fsm;

architecture Structure of fsm is
  signal reset_l_IBUF_1 : STD_LOGIC; 
  signal TXE_L_IBUF_2 : STD_LOGIC; 
  signal RXF_L_IBUF_3 : STD_LOGIC; 
  signal clk : STD_LOGIC; 
  signal reset_l_INV_3_o : STD_LOGIC; 
  signal OE_L_OBUF_6 : STD_LOGIC; 
  signal RD_L_OBUF_7 : STD_LOGIC; 
  signal state_FSM_FFd6_8 : STD_LOGIC; 
  signal state_FSM_FFd3_9 : STD_LOGIC; 
  signal WR_L_OBUF_10 : STD_LOGIC; 
  signal SIWU_L_OBUF_11 : STD_LOGIC; 
  signal N0 : STD_LOGIC; 
  signal my_dcm_clkfx : STD_LOGIC; 
  signal my_dcm_clk0 : STD_LOGIC; 
  signal my_dcm_clkin1 : STD_LOGIC; 
  signal state_FSM_FFd8_In : STD_LOGIC; 
  signal state_FSM_FFd6_In : STD_LOGIC; 
  signal state_FSM_FFd4_In : STD_LOGIC; 
  signal state_FSM_FFd1_In : STD_LOGIC; 
  signal state_FSM_FFd8_36 : STD_LOGIC; 
  signal state_FSM_FFd5_37 : STD_LOGIC; 
  signal state_FSM_FFd4_38 : STD_LOGIC; 
  signal state_FSM_FFd1_39 : STD_LOGIC; 
  signal N2 : STD_LOGIC; 
  signal N3 : STD_LOGIC; 
  signal N4 : STD_LOGIC; 
  signal N5 : STD_LOGIC; 
  signal N6 : STD_LOGIC; 
  signal N7 : STD_LOGIC; 
  signal N8 : STD_LOGIC; 
  signal N9 : STD_LOGIC; 
  signal state_FSM_FFd7_rstpot_55 : STD_LOGIC; 
  signal state_FSM_FFd3_rstpot_56 : STD_LOGIC; 
  signal NLW_my_dcm_clkout2_buf_O_UNCONNECTED : STD_LOGIC; 
  signal NLW_my_dcm_dcm_sp_inst_CLK2X180_UNCONNECTED : STD_LOGIC; 
  signal NLW_my_dcm_dcm_sp_inst_CLK2X_UNCONNECTED : STD_LOGIC; 
  signal NLW_my_dcm_dcm_sp_inst_CLK180_UNCONNECTED : STD_LOGIC; 
  signal NLW_my_dcm_dcm_sp_inst_CLK270_UNCONNECTED : STD_LOGIC; 
  signal NLW_my_dcm_dcm_sp_inst_CLKFX180_UNCONNECTED : STD_LOGIC; 
  signal NLW_my_dcm_dcm_sp_inst_CLKDV_UNCONNECTED : STD_LOGIC; 
  signal NLW_my_dcm_dcm_sp_inst_PSDONE_UNCONNECTED : STD_LOGIC; 
  signal NLW_my_dcm_dcm_sp_inst_CLK90_UNCONNECTED : STD_LOGIC; 
  signal NLW_my_dcm_dcm_sp_inst_LOCKED_UNCONNECTED : STD_LOGIC; 
  signal NLW_my_dcm_dcm_sp_inst_STATUS_7_UNCONNECTED : STD_LOGIC; 
  signal NLW_my_dcm_dcm_sp_inst_STATUS_6_UNCONNECTED : STD_LOGIC; 
  signal NLW_my_dcm_dcm_sp_inst_STATUS_5_UNCONNECTED : STD_LOGIC; 
  signal NLW_my_dcm_dcm_sp_inst_STATUS_4_UNCONNECTED : STD_LOGIC; 
  signal NLW_my_dcm_dcm_sp_inst_STATUS_3_UNCONNECTED : STD_LOGIC; 
  signal NLW_my_dcm_dcm_sp_inst_STATUS_2_UNCONNECTED : STD_LOGIC; 
  signal NLW_my_dcm_dcm_sp_inst_STATUS_1_UNCONNECTED : STD_LOGIC; 
  signal NLW_my_dcm_dcm_sp_inst_STATUS_0_UNCONNECTED : STD_LOGIC; 
  signal D_int : STD_LOGIC_VECTOR ( 7 downto 0 ); 
begin
  XST_GND : GND
    port map (
      G => N0
    );
  D_int_0 : FDE
    port map (
      C => clk,
      CE => state_FSM_FFd6_8,
      D => N9,
      Q => D_int(0)
    );
  D_int_1 : FDE
    port map (
      C => clk,
      CE => state_FSM_FFd6_8,
      D => N8,
      Q => D_int(1)
    );
  D_int_2 : FDE
    port map (
      C => clk,
      CE => state_FSM_FFd6_8,
      D => N7,
      Q => D_int(2)
    );
  D_int_3 : FDE
    port map (
      C => clk,
      CE => state_FSM_FFd6_8,
      D => N6,
      Q => D_int(3)
    );
  D_int_4 : FDE
    port map (
      C => clk,
      CE => state_FSM_FFd6_8,
      D => N5,
      Q => D_int(4)
    );
  D_int_5 : FDE
    port map (
      C => clk,
      CE => state_FSM_FFd6_8,
      D => N4,
      Q => D_int(5)
    );
  D_int_6 : FDE
    port map (
      C => clk,
      CE => state_FSM_FFd6_8,
      D => N3,
      Q => D_int(6)
    );
  D_int_7 : FDE
    port map (
      C => clk,
      CE => state_FSM_FFd6_8,
      D => N2,
      Q => D_int(7)
    );
  state_FSM_FFd8 : FDS
    generic map(
      INIT => '1'
    )
    port map (
      C => clk,
      D => state_FSM_FFd8_In,
      S => reset_l_INV_3_o,
      Q => state_FSM_FFd8_36
    );
  state_FSM_FFd4 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => state_FSM_FFd4_In,
      R => reset_l_INV_3_o,
      Q => state_FSM_FFd4_38
    );
  state_FSM_FFd6 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => state_FSM_FFd6_In,
      R => reset_l_INV_3_o,
      Q => state_FSM_FFd6_8
    );
  state_FSM_FFd2 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => state_FSM_FFd3_9,
      R => reset_l_INV_3_o,
      Q => state_FSM_FFd1_In
    );
  state_FSM_FFd5 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => state_FSM_FFd6_8,
      R => reset_l_INV_3_o,
      Q => state_FSM_FFd5_37
    );
  state_FSM_FFd1 : FDR
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => state_FSM_FFd1_In,
      R => reset_l_INV_3_o,
      Q => state_FSM_FFd1_39
    );
  my_dcm_clkout2_buf : BUFG
    port map (
      O => NLW_my_dcm_clkout2_buf_O_UNCONNECTED,
      I => my_dcm_clkfx
    );
  my_dcm_clkout1_buf : BUFG
    port map (
      O => clk,
      I => my_dcm_clk0
    );
  my_dcm_dcm_sp_inst : DCM_SP
    generic map(
      CLKDV_DIVIDE => 2.000000,
      CLKFX_DIVIDE => 1,
      CLKFX_MULTIPLY => 4,
      CLKIN_DIVIDE_BY_2 => FALSE,
      CLKIN_PERIOD => 16.666000,
      CLKOUT_PHASE_SHIFT => "NONE",
      CLK_FEEDBACK => "1X",
      DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS",
      DFS_FREQUENCY_MODE => "LOW",
      DLL_FREQUENCY_MODE => "LOW",
      DSS_MODE => "NONE",
      DUTY_CYCLE_CORRECTION => TRUE,
      FACTORY_JF => X"0000",
      PHASE_SHIFT => 0,
      STARTUP_WAIT => FALSE
    )
    port map (
      CLK2X180 => NLW_my_dcm_dcm_sp_inst_CLK2X180_UNCONNECTED,
      PSCLK => N0,
      CLK2X => NLW_my_dcm_dcm_sp_inst_CLK2X_UNCONNECTED,
      CLKFX => my_dcm_clkfx,
      CLK180 => NLW_my_dcm_dcm_sp_inst_CLK180_UNCONNECTED,
      CLK270 => NLW_my_dcm_dcm_sp_inst_CLK270_UNCONNECTED,
      RST => reset_l_IBUF_1,
      PSINCDEC => N0,
      CLKIN => my_dcm_clkin1,
      CLKFB => clk,
      PSEN => N0,
      CLK0 => my_dcm_clk0,
      CLKFX180 => NLW_my_dcm_dcm_sp_inst_CLKFX180_UNCONNECTED,
      CLKDV => NLW_my_dcm_dcm_sp_inst_CLKDV_UNCONNECTED,
      PSDONE => NLW_my_dcm_dcm_sp_inst_PSDONE_UNCONNECTED,
      CLK90 => NLW_my_dcm_dcm_sp_inst_CLK90_UNCONNECTED,
      LOCKED => NLW_my_dcm_dcm_sp_inst_LOCKED_UNCONNECTED,
      DSSEN => N0,
      STATUS(7) => NLW_my_dcm_dcm_sp_inst_STATUS_7_UNCONNECTED,
      STATUS(6) => NLW_my_dcm_dcm_sp_inst_STATUS_6_UNCONNECTED,
      STATUS(5) => NLW_my_dcm_dcm_sp_inst_STATUS_5_UNCONNECTED,
      STATUS(4) => NLW_my_dcm_dcm_sp_inst_STATUS_4_UNCONNECTED,
      STATUS(3) => NLW_my_dcm_dcm_sp_inst_STATUS_3_UNCONNECTED,
      STATUS(2) => NLW_my_dcm_dcm_sp_inst_STATUS_2_UNCONNECTED,
      STATUS(1) => NLW_my_dcm_dcm_sp_inst_STATUS_1_UNCONNECTED,
      STATUS(0) => NLW_my_dcm_dcm_sp_inst_STATUS_0_UNCONNECTED
    );
  my_dcm_clkin1_buf : IBUFG
    generic map(
      CAPACITANCE => "DONT_CARE",
      IBUF_DELAY_VALUE => "0",
      IBUF_LOW_PWR => TRUE,
      IOSTANDARD => "DEFAULT"
    )
    port map (
      I => clk_ext,
      O => my_dcm_clkin1
    );
  state_n0041_0_1 : LUT2
    generic map(
      INIT => X"1"
    )
    port map (
      I0 => state_FSM_FFd6_In,
      I1 => state_FSM_FFd6_8,
      O => OE_L_OBUF_6
    );
  state_FSM_FFd8_In1 : LUT3
    generic map(
      INIT => X"F8"
    )
    port map (
      I0 => RXF_L_IBUF_3,
      I1 => state_FSM_FFd8_36,
      I2 => state_FSM_FFd1_39,
      O => state_FSM_FFd8_In
    );
  state_FSM_FFd4_In1 : LUT3
    generic map(
      INIT => X"EC"
    )
    port map (
      I0 => TXE_L_IBUF_2,
      I1 => state_FSM_FFd5_37,
      I2 => state_FSM_FFd4_38,
      O => state_FSM_FFd4_In
    );
  reset_l_IBUF : IBUF
    port map (
      I => reset_l,
      O => reset_l_IBUF_1
    );
  TXE_L_IBUF : IBUF
    port map (
      I => TXE_L,
      O => TXE_L_IBUF_2
    );
  RXF_L_IBUF : IBUF
    port map (
      I => RXF_L,
      O => RXF_L_IBUF_3
    );
  Data_7_IOBUF : IOBUF
    port map (
      I => D_int(7),
      T => WR_L_OBUF_10,
      O => N2,
      IO => Data(7)
    );
  Data_6_IOBUF : IOBUF
    port map (
      I => D_int(6),
      T => WR_L_OBUF_10,
      O => N3,
      IO => Data(6)
    );
  Data_5_IOBUF : IOBUF
    port map (
      I => D_int(5),
      T => WR_L_OBUF_10,
      O => N4,
      IO => Data(5)
    );
  Data_4_IOBUF : IOBUF
    port map (
      I => D_int(4),
      T => WR_L_OBUF_10,
      O => N5,
      IO => Data(4)
    );
  Data_3_IOBUF : IOBUF
    port map (
      I => D_int(3),
      T => WR_L_OBUF_10,
      O => N6,
      IO => Data(3)
    );
  Data_2_IOBUF : IOBUF
    port map (
      I => D_int(2),
      T => WR_L_OBUF_10,
      O => N7,
      IO => Data(2)
    );
  Data_1_IOBUF : IOBUF
    port map (
      I => D_int(1),
      T => WR_L_OBUF_10,
      O => N8,
      IO => Data(1)
    );
  Data_0_IOBUF : IOBUF
    port map (
      I => D_int(0),
      T => WR_L_OBUF_10,
      O => N9,
      IO => Data(0)
    );
  OE_L_OBUF : OBUF
    port map (
      I => OE_L_OBUF_6,
      O => OE_L
    );
  WR_L_OBUF : OBUF
    port map (
      I => WR_L_OBUF_10,
      O => WR_L
    );
  RD_L_OBUF : OBUF
    port map (
      I => RD_L_OBUF_7,
      O => RD_L
    );
  SIWU_L_OBUF : OBUF
    port map (
      I => SIWU_L_OBUF_11,
      O => SIWU_L
    );
  state_FSM_FFd7 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => state_FSM_FFd7_rstpot_55,
      Q => state_FSM_FFd6_In
    );
  state_FSM_FFd3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => clk,
      D => state_FSM_FFd3_rstpot_56,
      Q => state_FSM_FFd3_9
    );
  state_FSM_FFd7_rstpot : LUT3
    generic map(
      INIT => X"40"
    )
    port map (
      I0 => RXF_L_IBUF_3,
      I1 => reset_l_IBUF_1,
      I2 => state_FSM_FFd8_36,
      O => state_FSM_FFd7_rstpot_55
    );
  state_FSM_FFd3_rstpot : LUT3
    generic map(
      INIT => X"40"
    )
    port map (
      I0 => TXE_L_IBUF_2,
      I1 => reset_l_IBUF_1,
      I2 => state_FSM_FFd4_38,
      O => state_FSM_FFd3_rstpot_56
    );
  reset_l_INV_3_o1_INV_0 : INV
    port map (
      I => reset_l_IBUF_1,
      O => reset_l_INV_3_o
    );
  WR_L1_INV_0 : INV
    port map (
      I => state_FSM_FFd3_9,
      O => WR_L_OBUF_10
    );
  state_n0041_5_1_INV_0 : INV
    port map (
      I => state_FSM_FFd1_39,
      O => SIWU_L_OBUF_11
    );
  state_n0041_1_1_INV_0 : INV
    port map (
      I => state_FSM_FFd6_8,
      O => RD_L_OBUF_7
    );

end Structure;

