library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_misc.all; 

library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;

entity ModelConvCoTM is
    Port (
        i_clk            : in std_logic; 
        i_rst            : in std_logic;
        i_load_model     : in std_logic;
        

        i_data_valid     : in std_logic; 
        i_data           : in std_logic_vector(7 downto 0); 

        -----------
        o_intrL          : out std_logic; 
        
        o_InclExcl       : out include_exclude_signals;
        
        o_weightClass0   : out clause_weights;
        o_weightClass1   : out clause_weights;
        o_weightClass2   : out clause_weights;
        o_weightClass3   : out clause_weights;  
        o_weightClass4   : out clause_weights;
        o_weightClass5   : out clause_weights;
        o_weightClass6   : out clause_weights;
        o_weightClass7   : out clause_weights;
        o_weightClass8   : out clause_weights;
        o_weightClass9   : out clause_weights

        );
end ModelConvCoTM;
-----------------------------------------------------------------------------------------------------

architecture rtl of ModelConvCoTM is

    signal w_clause_IEbits                       : std_logic_vector(2*FSize-1 downto 0); 
    
    signal w_clause_WeightClass0                  : std_logic_vector(7 downto 0); 
    signal w_clause_WeightClass1                  : std_logic_vector(7 downto 0);
    signal w_clause_WeightClass2                  : std_logic_vector(7 downto 0);
    signal w_clause_WeightClass3                  : std_logic_vector(7 downto 0);
    signal w_clause_WeightClass4                  : std_logic_vector(7 downto 0);
    signal w_clause_WeightClass5                  : std_logic_vector(7 downto 0);
    signal w_clause_WeightClass6                  : std_logic_vector(7 downto 0);
    signal w_clause_WeightClass7                  : std_logic_vector(7 downto 0);
    signal w_clause_WeightClass8                  : std_logic_vector(7 downto 0);
    signal w_clause_WeightClass9                  : std_logic_vector(7 downto 0);
 

    signal w_enablebyte_in_buffer               : std_logic_vector(ModelBytesPerClause-1 downto 0);
    signal w_enable_inputregister               : std_logic;
    signal w_load_model_per_clause              : std_logic_vector(NClauses-1 downto 0); 

-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
begin 

        FSMLOAD : entity lib_convcotm.FSM_LOADMODEL(rtl)
            port map(  
               i_clk                        => i_clk,                    
               i_rst                        => i_rst,
 
               i_load_model                 => i_load_model,
               i_data_valid                 => i_data_valid,
               
               o_enable_inputregister       => w_enable_inputregister,
               o_modelbuffer_byte_update    => w_enablebyte_in_buffer,
               o_clause_model_update        => w_load_model_per_clause, 
               
               o_intrL                      => o_intrL
     
               );
         
     MODELINBUF: entity lib_convcotm.Model_input_buffer(rtl)
        port map
 (
            i_clk                   => i_clk,
            i_rst                   => i_rst,

            i_enable_inputregister  => w_enable_inputregister,
            i_enablebyte_in_buffer  => w_enablebyte_in_buffer,
            i_data                  => i_data,
            
            --Model bits per clause: 
            o_Model_IEbits      => w_clause_IEbits,              -- 2*FSize bits
            o_ModelWeightClass0 => w_clause_WeightClass0,         -- 8 bits
            o_ModelWeightClass1 => w_clause_WeightClass1,
            o_ModelWeightClass2 => w_clause_WeightClass2,
            o_ModelWeightClass3 => w_clause_WeightClass3,
            o_ModelWeightClass4 => w_clause_WeightClass4,
            o_ModelWeightClass5 => w_clause_WeightClass5,
            o_ModelWeightClass6 => w_clause_WeightClass6,
            o_ModelWeightClass7 => w_clause_WeightClass7,
            o_ModelWeightClass8 => w_clause_WeightClass8,
            o_ModelWeightClass9 => w_clause_WeightClass9
            );
    
    IEREG: entity lib_convcotm.IEreg(rtl) -- Register for TA action bits
        port map (
            i_clk                   => i_clk, 
            i_rst                   => i_rst, 
            i_update                => w_load_model_per_clause, 
            i_InputMSBsMODEL        => w_clause_IEbits, 
            --------
            o_InclExcl              => o_InclExcl
            );    
         
     WEIGHTS : entity lib_convcotm.AllWeights(rtl) -- Register for clause weights per class
         port map(
            i_clk                           => i_clk, 
            i_rst                           => i_rst, 
            i_update_from_model             => w_load_model_per_clause, 
            
            i_ModelWeightClass0             => w_clause_WeightClass0,
            i_ModelWeightClass1             => w_clause_WeightClass1,
            i_ModelWeightClass2             => w_clause_WeightClass2,
            i_ModelWeightClass3             => w_clause_WeightClass3,
            i_ModelWeightClass4             => w_clause_WeightClass4,
            i_ModelWeightClass5             => w_clause_WeightClass5,
            i_ModelWeightClass6             => w_clause_WeightClass6,
            i_ModelWeightClass7             => w_clause_WeightClass7,
            i_ModelWeightClass8             => w_clause_WeightClass8,
            i_ModelWeightClass9             => w_clause_WeightClass9,
            
            -------
            o_weightClass0                  => o_weightClass0,
            o_weightClass1                  => o_weightClass1,
            o_weightClass2                  => o_weightClass2,
            o_weightClass3                  => o_weightClass3,
            o_weightClass4                  => o_weightClass4,
            o_weightClass5                  => o_weightClass5,
            o_weightClass6                  => o_weightClass6,
            o_weightClass7                  => o_weightClass7,
            o_weightClass8                  => o_weightClass8,
            o_weightClass9                  => o_weightClass9
            );
               
end rtl;
