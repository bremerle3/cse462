----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:13:22 04/14/2015 
-- Design Name: 
-- Module Name:    shift_reg_sim - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL ; 
USE IEEE.STD_LOGIC_ARITH.ALL ;
USE IEEE.STD_LOGIC_UNSIGNED.ALL ; 
Library UNISIM;
use UNISIM.vcomponents.all;

entity shift_reg_sim is
PORT (
    d : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    clk : IN STD_LOGIC;
	 sclr : IN STD_LOGIC;
    q : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
end shift_reg_sim;

architecture Behavioral of shift_reg_sim is

COMPONENT my_shift_reg
  PORT (
    d : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    clk : IN STD_LOGIC;
    sclr : IN STD_LOGIC;
    q : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END COMPONENT;

begin
  
  inst_shift_reg : my_shift_reg
  PORT MAP (
    d => d,
    clk => clk,
    sclr => sclr,
    q => q
  );

end Behavioral;

