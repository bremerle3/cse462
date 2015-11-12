--------------------------------------------------------------------------------
--    This file is owned and controlled by Xilinx and must be used solely     --
--    for design, simulation, implementation and creation of design files     --
--    limited to Xilinx devices or technologies. Use with non-Xilinx          --
--    devices or technologies is expressly prohibited and immediately         --
--    terminates your license.                                                --
--                                                                            --
--    XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" SOLELY    --
--    FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY    --
--    PROVIDING THIS DESIGN, CODE, OR INFORMATION AS ONE POSSIBLE             --
--    IMPLEMENTATION OF THIS FEATURE, APPLICATION OR STANDARD, XILINX IS      --
--    MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION IS FREE FROM ANY      --
--    CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE FOR OBTAINING ANY       --
--    RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY       --
--    DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE   --
--    IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR          --
--    REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF         --
--    INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A   --
--    PARTICULAR PURPOSE.                                                     --
--                                                                            --
--    Xilinx products are not intended for use in life support appliances,    --
--    devices, or systems.  Use in such applications are expressly            --
--    prohibited.                                                             --
--                                                                            --
--    (c) Copyright 1995-2015 Xilinx, Inc.                                    --
--    All rights reserved.                                                    --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- You must compile the wrapper file shift_reg.vhd when simulating
-- the core, shift_reg. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "CORE Generator Help".

-- The synthesis directives "translate_off/translate_on" specified
-- below are supported by Xilinx, Mentor Graphics and Synplicity
-- synthesis tools. Ensure they are correct for your synthesis tool(s).

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- synthesis translate_off
LIBRARY XilinxCoreLib;
-- synthesis translate_on
ENTITY shift_reg IS
  PORT (
    d : IN STD_LOGIC_VECTOR(199 DOWNTO 0);
    clk : IN STD_LOGIC;
    q : OUT STD_LOGIC_VECTOR(199 DOWNTO 0)
  );
END shift_reg;

ARCHITECTURE shift_reg_a OF shift_reg IS
-- synthesis translate_off
COMPONENT wrapped_shift_reg
  PORT (
    d : IN STD_LOGIC_VECTOR(199 DOWNTO 0);
    clk : IN STD_LOGIC;
    q : OUT STD_LOGIC_VECTOR(199 DOWNTO 0)
  );
END COMPONENT;

-- Configuration specification
  FOR ALL : wrapped_shift_reg USE ENTITY XilinxCoreLib.c_shift_ram_v11_0(behavioral)
    GENERIC MAP (
      c_addr_width => 4,
      c_ainit_val => "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      c_default_data => "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      c_depth => 1,
      c_has_a => 0,
      c_has_ce => 0,
      c_has_sclr => 0,
      c_has_sinit => 0,
      c_has_sset => 0,
      c_mem_init_file => "no_coe_file_loaded",
      c_opt_goal => 0,
      c_parser_type => 0,
      c_read_mif => 0,
      c_reg_last_bit => 1,
      c_shift_type => 0,
      c_sinit_val => "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      c_sync_enable => 0,
      c_sync_priority => 1,
      c_verbosity => 0,
      c_width => 200,
      c_xdevicefamily => "spartan6"
    );
-- synthesis translate_on
BEGIN
-- synthesis translate_off
U0 : wrapped_shift_reg
  PORT MAP (
    d => d,
    clk => clk,
    q => q
  );
-- synthesis translate_on

END shift_reg_a;
