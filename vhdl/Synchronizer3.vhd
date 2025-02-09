library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.numeric_std.all;

library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;
   
entity Synchronizer3 is 
    Port (
         clk        : in  std_logic;
         i_signals  : in  STD_LOGIC_VECTOR(1 downto 0);
         o_synched  : out STD_LOGIC_VECTOR(1 downto 0)
         );
end Synchronizer3;

architecture rtl of Synchronizer3 is 

    signal w_interm1  : STD_LOGIC_VECTOR(1 downto 0);
    signal w_synched  : STD_LOGIC_VECTOR(1 downto 0);
    
begin
    
        REG0 : vDFF generic map(2) port map(clk, i_signals, w_interm1);
        REG1 : vDFF generic map(2) port map(clk, w_interm1, w_synched);

    o_synched <= w_synched;
    
end rtl;

