library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;

-- This register is organized as follows:
-- There are NClauses registers, one for each clause.
-- Each register consists of 2*FSize SINGLE BITS.
-- All these output signals will be available simultaneously.
-- E.g., REGISTER(5) is the register containing the 2*FSize TA action signals for clause no. 5.  
-- It is only possible to update a single register one at a time. 

entity IEreg is       
  Port (
        i_clk                   : in STD_LOGIC;
        i_rst                   : in STD_LOGIC;
        i_update                : in std_logic_vector(NClauses-1 downto 0);
        i_InputMSBsMODEL        : in std_logic_vector(2*FSize-1 downto 0); -- from MODEL (for a given clause) 
        o_InclExcl              : out include_exclude_signals
        );  
end IEreg; 

architecture rtl of IEreg is 
    
    signal w_currentstate : include_exclude_signals;
    signal w_nxtstate :  include_exclude_signals;
    
begin
    
    A1: FOR k in 0 to NClauses-1 GENERATE                                                                         

        w_nxtstate(k) <=    (others=>'0') when i_rst='1' 
                            else i_InputMSBsMODEL when i_update(k)='1' 
                            else w_currentstate(k);
                    
        MSBregister: vDFF generic map(2*FSize) port map(i_clk, w_nxtstate(k), w_currentstate(k));
        
        o_InclExcl(k) <= w_currentstate(k);
                          
    end GENERATE A1;
        
                       
end rtl;