library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.numeric_std.all;

library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;
   
entity Synchronizer2 is 
    Port (
         clk                : in std_logic;
         i_data             : in STD_LOGIC_VECTOR(7 downto 0);
         i_data_valid       : in std_logic;
         
         o_synch_data       : out STD_LOGIC_VECTOR(7 downto 0);
         o_synch_data_valid : out std_logic
         );
end Synchronizer2;

architecture rtl of Synchronizer2 is 

    signal w_interm1  : STD_LOGIC_VECTOR(7 downto 0);
    signal w_synched1  : STD_LOGIC_VECTOR(7 downto 0);
    
    signal w_interm2   : std_logic;
    signal w_synched2  : std_logic;
    
    
begin
    
        REG0 : vDFF generic map(8) port map(clk, i_data, w_interm1);
        REG1 : vDFF generic map(8) port map(clk, w_interm1, w_synched1);

        SingleDelay1 : sDFF port map(clk, i_data_valid, w_interm2);  
        SingleDelay2 : sDFF port map(clk, w_interm2, w_synched2);  

    o_synch_data <= w_synched1;
    o_synch_data_valid <= w_synched2;
    
end rtl;