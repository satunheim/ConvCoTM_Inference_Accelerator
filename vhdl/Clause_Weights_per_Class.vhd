library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;  
  
library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;
 
entity Clause_Weights_per_Class is 
    Port (
            i_clk                           : in STD_LOGIC;
            i_rst                           : in STD_LOGIC; 
            i_update_from_model             : in STD_LOGIC;         

            i_ModelWeightClass0             : in std_logic_vector(NBitsIW-1 downto 0);
            i_ModelWeightClass1             : in std_logic_vector(NBitsIW-1 downto 0);
            i_ModelWeightClass2             : in std_logic_vector(NBitsIW-1 downto 0);
            i_ModelWeightClass3             : in std_logic_vector(NBitsIW-1 downto 0);
            i_ModelWeightClass4             : in std_logic_vector(NBitsIW-1 downto 0);
            i_ModelWeightClass5             : in std_logic_vector(NBitsIW-1 downto 0);
            i_ModelWeightClass6             : in std_logic_vector(NBitsIW-1 downto 0);
            i_ModelWeightClass7             : in std_logic_vector(NBitsIW-1 downto 0);
            i_ModelWeightClass8             : in std_logic_vector(NBitsIW-1 downto 0);
            i_ModelWeightClass9             : in std_logic_vector(NBitsIW-1 downto 0);
            
            o_weightClass0                  : out signed(NBitsIW-1 downto 0);
            o_weightClass1                  : out signed(NBitsIW-1 downto 0);
            o_weightClass2                  : out signed(NBitsIW-1 downto 0);
            o_weightClass3                  : out signed(NBitsIW-1 downto 0);
            o_weightClass4                  : out signed(NBitsIW-1 downto 0); 
            o_weightClass5                  : out signed(NBitsIW-1 downto 0);
            o_weightClass6                  : out signed(NBitsIW-1 downto 0);
            o_weightClass7                  : out signed(NBitsIW-1 downto 0);
            o_weightClass8                  : out signed(NBitsIW-1 downto 0);
            o_weightClass9                  : out signed(NBitsIW-1 downto 0)
            );     
end Clause_Weights_per_Class;

architecture rtl of Clause_Weights_per_Class is 

    type weightregister is array (0 to NClasses-1) of std_logic_vector(NBitsIW-1 downto 0); 
    type class_weights_per_clause is array (0 to NClasses-1) of signed (NBitsIW-1 downto 0);

    signal w_ModelweightClass           : class_weights_per_clause;
    signal w_nxt, w_regout              : weightregister; 
     
begin
    
    w_ModelweightClass(0) <= signed(i_ModelWeightClass0);
    w_ModelweightClass(1) <= signed(i_ModelWeightClass1);
    w_ModelweightClass(2) <= signed(i_ModelWeightClass2);
    w_ModelweightClass(3) <= signed(i_ModelWeightClass3);
    w_ModelweightClass(4) <= signed(i_ModelWeightClass4);
    w_ModelweightClass(5) <= signed(i_ModelWeightClass5);
    w_ModelweightClass(6) <= signed(i_ModelWeightClass6);
    w_ModelweightClass(7) <= signed(i_ModelWeightClass7);
    w_ModelweightClass(8) <= signed(i_ModelWeightClass8);
    w_ModelweightClass(9) <= signed(i_ModelWeightClass9);
    
-----------------------------------------------------------
    G1: FOR K in 0 to NClasses-1 GENERATE 
    
            WeightRegister: vDFF generic map(NBitsIW) port map(i_clk, w_nxt(K), w_regout(K));  
            
            w_nxt(K) <=  std_logic_vector(w_ModelweightClass(k)) when (i_rst='1' or i_update_from_model='1') 
                         else w_regout(K);   
             
        END GENERATE G1;
-----------------------------------------------------------

        o_weightClass0 <= signed(w_regout(0));
        o_weightClass1 <= signed(w_regout(1));
        o_weightClass2 <= signed(w_regout(2));
        o_weightClass3 <= signed(w_regout(3));
        o_weightClass4 <= signed(w_regout(4));
        o_weightClass5 <= signed(w_regout(5));
        o_weightClass6 <= signed(w_regout(6));
        o_weightClass7 <= signed(w_regout(7));
        o_weightClass8 <= signed(w_regout(8));
        o_weightClass9 <= signed(w_regout(9));

end rtl;
