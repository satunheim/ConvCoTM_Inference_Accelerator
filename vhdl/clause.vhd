library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.numeric_std.all;  
use IEEE.std_logic_misc.all;

library lib_convcotm;
use lib_convcotm.SETTINGS_ConvCoTM.all;
   
entity clause is    
        Port (
              i_literals            : in STD_LOGIC_VECTOR (2*FSize-1 downto 0);
              i_include             : in STD_LOGIC_VECTOR (2*FSize-1 downto 0); 
                                     -- NOTE: i_include(k)='1' IMPLIES that literal k is INCLUDED.   
              o_clause_out          : out STD_LOGIC
              ); 
end clause;

----------------------------------------------------------------------
architecture rtl3 of clause is
   
    signal or_outputs : std_logic_vector (2*FSize-1 downto 0); 

    signal f1andout : std_logic_vector (67 downto 0); 
    signal f2andout : std_logic_vector (16 downto 0); 
    signal f3andout : std_logic_vector (3 downto 0); 
    signal f4andout : std_logic;
    
    signal g1orout : std_logic_vector (67 downto 0); 
    signal g2orout : std_logic_vector (16 downto 0); 
    signal g3orout : std_logic_vector (3 downto 0);  
    signal g4orout : std_logic;
    
    signal w_clause_out : std_logic;
    
begin

    GenORSignals: FOR ka in 0 to 2*FSize-1 GENERATE                                                                         
        or_outputs(ka) <= i_literals(ka) or not(i_include(ka));                         
    end GENERATE GenORSignals;

----------------------------------------------------------------------
 -- The Or_outputs (272 signals) have to be ANDed together. We perform this by a balanced AND tree.
 -- We start with 4-input AND gates.

    F1: FOR kb in 0 to 67 GENERATE                                                                         
        f1andout(kb) <= or_outputs(kb*4) and or_outputs(kb*4+1) and or_outputs(kb*4+2) and or_outputs(kb*4+3); 
        g1orout(kb) <= i_include(kb*4) or i_include(kb*4+1) or i_include(kb*4+2) or i_include(kb*4+3);                          
    end GENERATE F1;
----------------------------------------------------------------------
    F2: FOR kc in 0 to 16 GENERATE                                                                         
        f2andout(kc) <= f1andout(kc*4) and f1andout(kc*4+1) and f1andout(kc*4+2) and f1andout(kc*4+3);
        g2orout(kc) <= g1orout(kc*4) or g1orout(kc*4+1) or g1orout(kc*4+2) or g1orout(kc*4+3);                            
    end GENERATE F2;
----------------------------------------------------------------------
    F3: FOR kd in 0 to 3 GENERATE                                                                          
        f3andout(kd) <= f2andout(kd*4) and f2andout(kd*4+1) and f2andout(kd*4+2) and f2andout(kd*4+3); 
        g3orout(kd) <= g2orout(kd*4) or g2orout(kd*4+1) or g2orout(kd*4+2) or g2orout(kd*4+3);                            
    end GENERATE F3;
    
    -- f2andout(16) is not included here. Will be ANDed in the next step.
    -- g2orout(16) is not included here. Will be ORed in the next step.
    
----------------------------------------------------------------------
        f4andout <= f3andout(0) and f3andout(1) and f3andout(2) and f3andout(3) and f2andout(16);
        
        g4orout <= g3orout(0) or g3orout(1) or g3orout(2) or g3orout(3) or g2orout(16);  
        -- If no literals are included, this signal will be 0. Otherwise it will be 1.

----------------------------------------------------------------------
-- When training:  Clause output should be 1 if no literal is included.
-- When inference: Clause output should be 0 if no literal is included.

    w_clause_out <= f4andout and g4orout;
    o_clause_out <= w_clause_out;

end rtl3; 
