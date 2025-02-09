library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;
     
entity ClausePool is     
    Port ( i_literals           : in STD_LOGIC_VECTOR (2*FSize-1 downto 0);
           i_includeSignals     : in include_exclude_signals;
           i_test_mode0         : in std_logic; -- Not implemented
           
           i_clk                : in std_logic;
           i_rst                : in std_logic; 
           i_update             : in std_logic;
           i_en                 : in std_logic;
           
           o_ClauseregOutputs    : out std_logic_vector(NClauses-1 downto 0)
           ); 
end ClausePool;
 
architecture rtl of ClausePool is
    
    signal w_ClauseOutput   : std_logic_vector(NClauses-1 downto 0);
    signal w_nextstate      : std_logic_vector(NClauses-1 downto 0);
    signal w_all0           : std_logic_vector(NClauses-1 downto 0);
    signal w_currentstate   : std_logic_vector(NClauses-1 downto 0);

begin  

    w_all0 <= (others => '0');  

    GENCLAUSES: FOR k in 0 to NClauses-1 GENERATE 
        
        clause : entity lib_convcotm.clause(rtl3) 
                            port map (
                                i_literals          => i_literals, 
                                i_include           => i_includeSignals(k),
                                o_clause_out        => w_ClauseOutput(k) 
                                );
         
    END GENERATE GENCLAUSES;
    
    ClauseInfReg: vDFF generic map(NClauses) port map(i_clk, w_nextstate, w_currentstate);  
     
    w_nextstate <= (others => '0') when i_rst='1'
                    else (w_all0 OR w_ClauseOutput) when (i_update='1' and i_en='1')
                    else (w_currentstate OR w_ClauseOutput) when i_en='1'
                    else w_currentstate;    
     
    o_ClauseregOutputs <= w_currentstate;
                                                                                                                 
end rtl;