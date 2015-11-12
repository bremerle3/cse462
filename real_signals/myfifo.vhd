LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL ; 
USE IEEE.STD_LOGIC_ARITH.ALL ;
USE IEEE.STD_LOGIC_UNSIGNED.ALL ; 
Library UNISIM;
use UNISIM.vcomponents.all;

ENTITY myfifo IS
 PORT(
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
END myfifo ;

ARCHITECTURE mine of myfifo IS

COMPONENT fifo
 PORT(
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

myfifol : fifo
 PORT MAP (
  rst => rst,
  wr_clk => wr_clk, 
  rd_clk => rd_clk, 
  din => din,
  wr_en => wr_en, 
  rd_en => rd_en, 
  dout => dout,
  full => full,
  empty => empty
 );

END mine ;