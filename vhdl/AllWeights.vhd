library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;

entity AllWeights is 
    Port ( 
            i_clk                           : in STD_LOGIC; 
            i_rst                           : in STD_LOGIC; 
            i_update_from_model             : in std_logic_vector(NClauses-1 downto 0);
            
            -- Input weights from pre trained model. Update in sequence clause by clause.
            -- The model allocates one byte per weight. 
            i_ModelWeightClass0  : in std_logic_vector(7 downto 0);
            i_ModelWeightClass1  : in std_logic_vector(7 downto 0);
            i_ModelWeightClass2  : in std_logic_vector(7 downto 0);
            i_ModelWeightClass3  : in std_logic_vector(7 downto 0);
            i_ModelWeightClass4  : in std_logic_vector(7 downto 0);
            i_ModelWeightClass5  : in std_logic_vector(7 downto 0);
            i_ModelWeightClass6  : in std_logic_vector(7 downto 0);
            i_ModelWeightClass7  : in std_logic_vector(7 downto 0);
            i_ModelWeightClass8  : in std_logic_vector(7 downto 0);
            i_ModelWeightClass9  : in std_logic_vector(7 downto 0);
            
            o_weightClass0  : out clause_weights;
            o_weightClass1  : out clause_weights;
            o_weightClass2  : out clause_weights;
            o_weightClass3  : out clause_weights;  
            o_weightClass4  : out clause_weights;
            o_weightClass5  : out clause_weights;
            o_weightClass6  : out clause_weights;
            o_weightClass7  : out clause_weights;
            o_weightClass8  : out clause_weights;
            o_weightClass9  : out clause_weights
            );    
end AllWeights;

architecture rtl of AllWeights is 
    
    signal w_weightClass0  : clause_weights;
    signal w_weightClass1  : clause_weights;
    signal w_weightClass2  : clause_weights;
    signal w_weightClass3  : clause_weights;
    signal w_weightClass4  : clause_weights;
    signal w_weightClass5  : clause_weights;
    signal w_weightClass6  : clause_weights;
    signal w_weightClass7  : clause_weights;
    signal w_weightClass8  : clause_weights;
    signal w_weightClass9  : clause_weights;

--------------------------------------------------------------------------------------

begin
  
  -- Generate one set of weights for each class (output):
  ALL1: FOR k in 0 to NClauses-1 GENERATE 
     
     ModuleClassWeightsPerClause : entity lib_convcotm.Clause_Weights_per_Class(rtl) 
       port map (
                 i_clk                          => i_clk, 
                 i_rst                          => i_rst, 
                 i_update_from_model            => i_update_from_model(k), 

                i_ModelWeightClass0             =>  i_ModelWeightClass0(NBitsIW-1 downto 0),
                i_ModelWeightClass1             =>  i_ModelWeightClass1(NBitsIW-1 downto 0),
                i_ModelWeightClass2             =>  i_ModelWeightClass2(NBitsIW-1 downto 0),
                i_ModelWeightClass3             =>  i_ModelWeightClass3(NBitsIW-1 downto 0),
                i_ModelWeightClass4             =>  i_ModelWeightClass4(NBitsIW-1 downto 0),
                i_ModelWeightClass5             =>  i_ModelWeightClass5(NBitsIW-1 downto 0),
                i_ModelWeightClass6             =>  i_ModelWeightClass6(NBitsIW-1 downto 0),
                i_ModelWeightClass7             =>  i_ModelWeightClass7(NBitsIW-1 downto 0),
                i_ModelWeightClass8             =>  i_ModelWeightClass8(NBitsIW-1 downto 0),
                i_ModelWeightClass9             =>  i_ModelWeightClass9(NBitsIW-1 downto 0),
                
                o_weightClass0                  =>  w_weightClass0(k),
                o_weightClass1                  =>  w_weightClass1(k),
                o_weightClass2                  =>  w_weightClass2(k),
                o_weightClass3                  =>  w_weightClass3(k),
                o_weightClass4                  =>  w_weightClass4(k),
                o_weightClass5                  =>  w_weightClass5(k),
                o_weightClass6                  =>  w_weightClass6(k),
                o_weightClass7                  =>  w_weightClass7(k),
                o_weightClass8                  =>  w_weightClass8(k),
                o_weightClass9                  =>  w_weightClass9(k)
              );
              
              ----------------------------------------------------------
                -- Connect wire signals to outputs:
                o_weightClass0(k) <= w_weightClass0(k);
                o_weightClass1(k) <= w_weightClass1(k);
                o_weightClass2(k) <= w_weightClass2(k);
                o_weightClass3(k) <= w_weightClass3(k);
                o_weightClass4(k) <= w_weightClass4(k);
                o_weightClass5(k) <= w_weightClass5(k);
                o_weightClass6(k) <= w_weightClass6(k);
                o_weightClass7(k) <= w_weightClass7(k);
                o_weightClass8(k) <= w_weightClass8(k);
                o_weightClass9(k) <= w_weightClass9(k);

    END GENERATE ALL1;

end rtl;