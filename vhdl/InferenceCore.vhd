library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_misc.all; 

library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;

entity InferenceCore is
    Port (
            i_clk             : in std_logic; 
            
            i_rst             : in std_logic;
            i_rst_imbuf       : in std_logic;
            i_en_image        : in std_logic;
            i_start           : in std_logic;
            
            i_single          : in std_logic;
            i_test            : in std_logic;
            i_en_cg           : in std_logic;

            -- Slave interface:
            i_data_valid      : in std_logic; 
            i_data            : in std_logic_vector(7 downto 0); 
            
            -- Model:
            i_incexcl_signals : include_exclude_signals;
            i_weightClass0    : clause_weights;
            i_weightClass1    : clause_weights;
            i_weightClass2    : clause_weights;
            i_weightClass3    : clause_weights;
            i_weightClass4    : clause_weights;
            i_weightClass5    : clause_weights;
            i_weightClass6    : clause_weights;
            i_weightClass7    : clause_weights;
            i_weightClass8    : clause_weights;
            i_weightClass9    : clause_weights;
            
            -- Interrupt:
            o_intrS           : out std_logic; -- Finished Inference
            o_Result          : out std_logic_vector(7 downto 0) 
            );
end InferenceCore;
-----------------------------------------------------------------------------------------------------

architecture rtl of InferenceCore is

    --For FSM_Main:

    signal w_en_generate_patches                : std_logic; 
    signal w_rst_clausepool                     : std_logic;
    signal w_en_clausepool                      : std_logic;     
    
    signal w_en_adders                          : std_logic;
    signal w_enFirstAdder                       : std_logic;
    signal w_enLastAdder                        : std_logic;
    
    signal w_sample_actual_class                : std_logic;
    signal w_sample_predicted_class             : std_logic;
    
    signal w_keepClassDecision                  : std_logic;
 
    ------------------------------
    -- For ImageBuffer:
    signal w_ImageLabel                         : std_logic_vector(3 downto 0);
    
    -- For Patch Generation:
    signal w_ImagevectorRow0                    : std_logic_vector(ImageSize-1 downto 0); 
    signal w_ImagevectorRow1                    : std_logic_vector(ImageSize-1 downto 0); 
    signal w_ImagevectorRow2                    : std_logic_vector(ImageSize-1 downto 0); 
    signal w_ImagevectorRow3                    : std_logic_vector(ImageSize-1 downto 0); 
    signal w_ImagevectorRow4                    : std_logic_vector(ImageSize-1 downto 0); 
    signal w_ImagevectorRow5                    : std_logic_vector(ImageSize-1 downto 0); 
    signal w_ImagevectorRow6                    : std_logic_vector(ImageSize-1 downto 0); 
    signal w_ImagevectorRow7                    : std_logic_vector(ImageSize-1 downto 0); 
    signal w_ImagevectorRow8                    : std_logic_vector(ImageSize-1 downto 0); 
    signal w_ImagevectorRow9                    : std_logic_vector(ImageSize-1 downto 0); 
    signal w_ImagevectorRow10                   : std_logic_vector(ImageSize-1 downto 0); 
    
    -- For Bcounter:
    signal w_BxCounterValue                     : std_logic_vector(4 downto 0);
    signal w_ByCounterValue                     : std_logic_vector(4 downto 0);
    --signal w_PatchAddress                       : std_logic_vector(NBitsPatchAddr-1 downto 0); 
    signal w_LoadNewSample                      : std_logic;
    signal w_LoadNewRow                         : std_logic;
    --signal w_PcounterFinished                   : std_logic; 

    -- For AllClauses:
    signal w_patchliterals                      : std_logic_vector(2*FSize-1 downto 0);

    -- For ClauseOutputInferenceRegister:
    signal w_updateSeqOR                        : std_logic; 
    signal w_clauseOutputsSeqORed               : std_logic_vector(NClauses-1 downto 0);
 
    
    -- For ClassSums:
    signal w_sumClass0                          : signed(NBsum-1 downto 0);
    signal w_sumClass1                          : signed(NBsum-1 downto 0);
    signal w_sumClass2                          : signed(NBsum-1 downto 0);
    signal w_sumClass3                          : signed(NBsum-1 downto 0);
    signal w_sumClass4                          : signed(NBsum-1 downto 0);
    signal w_sumClass5                          : signed(NBsum-1 downto 0);
    signal w_sumClass6                          : signed(NBsum-1 downto 0);
    signal w_sumClass7                          : signed(NBsum-1 downto 0);
    signal w_sumClass8                          : signed(NBsum-1 downto 0);
    signal w_sumClass9                          : signed(NBsum-1 downto 0);
    
--  For "DecideClass":
    signal w_classPredict                       : unsigned(3 downto 0);
    
--  For "ModuleEvaluateResults":
    --signal w_reset_evaluate                     : std_logic;
    --signal w_result                             : std_logic_vector(7 downto 0);

-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
begin 

    INFFSM : entity lib_convcotm.FSM_MAIN3(rtl)
        port map(  
           i_clk                        => i_clk,                    
           i_rst                        => i_rst,
           i_start                      => i_start,   
           i_data_valid                 => i_data_valid,
           
           ----
           o_en_generate_patches        => w_en_generate_patches,
           o_rst_clausepool             => w_rst_clausepool,
           o_en_clausepool              => w_en_clausepool,
           o_updateOR                   => w_updateSeqOR,
           o_BxCounterValue             => w_BxCounterValue,
           o_ByCounterValue             => w_ByCounterValue,
           
           o_LoadNewSample              => w_LoadNewSample,
           o_LoadNewRow                 => w_LoadNewRow,
           
           o_en_adders                  => w_en_adders,
           o_enFirstAdder               => w_enFirstAdder,
           o_enLastAdder                => w_enLastAdder,
           o_sample_actual_class        => w_sample_actual_class,
           o_sample_predicted_class     => w_sample_predicted_class,
           
           o_intrS                      => o_intrS,
           o_keepClassDecision          => w_keepClassDecision
           );

    
    IMAGEINTERFACE: entity lib_convcotm.ImageInterface(rtl2)      
        port map (
             -- AXI INTERFACE:
             i_clk                  => i_clk,
             i_rst                  => i_rst, 
             i_en                   => i_en_image,
             i_en_cg                => i_en_cg,
             
             -- Slave interface:
             i_data_valid           => i_data_valid,
             i_image_data           => i_data,
             
             -------------------------------------------------------------
             -- Other signals:         
             i_image_buffer_reset   => i_rst_imbuf,
             i_singlemode           => i_single,
            
             i_ByCounterValue       => w_ByCounterValue,
             i_keepClassDecision    => w_keepClassDecision,
             
             --------------------------------  
             -- Output signals to PatchGenerator:               
             o_ImagevectorRow0   => w_ImagevectorRow0,
             o_ImagevectorRow1   => w_ImagevectorRow1,
             o_ImagevectorRow2   => w_ImagevectorRow2,
             o_ImagevectorRow3   => w_ImagevectorRow3,
             o_ImagevectorRow4   => w_ImagevectorRow4,
             o_ImagevectorRow5   => w_ImagevectorRow5,
             o_ImagevectorRow6   => w_ImagevectorRow6, 
             o_ImagevectorRow7   => w_ImagevectorRow7,
             o_ImagevectorRow8   => w_ImagevectorRow8,
             o_ImagevectorRow9   => w_ImagevectorRow9,
             o_ImagevectorRow10  => w_ImagevectorRow10, -- The 11th row. 
             
             o_ImageLabel        => w_ImageLabel   
             );   
            
      GENPATCH3 : entity lib_convcotm.GeneratePatches3(rtl)
         port map 
           (
           i_clk                => i_clk,
           i_rst                => i_rst,
           i_en                 => w_en_generate_patches,
           i_start              => i_start,
           
           i_LoadNewSample      => w_LoadNewSample,
           i_LoadNewRow         => w_LoadNewRow,
           i_BxCounterValue     => w_BxCounterValue,
           i_ByCounterValue     => w_ByCounterValue,
           
           i_ImagevectorRow0    => w_ImagevectorRow0,
           i_ImagevectorRow1    => w_ImagevectorRow1,
           i_ImagevectorRow2    => w_ImagevectorRow2,
           i_ImagevectorRow3    => w_ImagevectorRow3,
           i_ImagevectorRow4    => w_ImagevectorRow4,
           i_ImagevectorRow5    => w_ImagevectorRow5,
           i_ImagevectorRow6    => w_ImagevectorRow6,
           i_ImagevectorRow7    => w_ImagevectorRow7,
           i_ImagevectorRow8    => w_ImagevectorRow8,
           i_ImagevectorRow9    => w_ImagevectorRow9,
           i_ImagevectorRow10   => w_ImagevectorRow10,

           o_PatchLiterals      => w_patchliterals
          );
    
            
     CLAUSEPOOL : entity lib_convcotm.ClausePool(rtl)    
        Port map (
               i_literals           => w_patchliterals, 
               i_includeSignals     => i_incexcl_signals, 
               i_test_mode0         => i_test,
               
               i_clk                => i_clk,
               i_rst                => w_rst_clausepool,
               i_update             => w_updateSeqOR,
               i_en                 => w_en_clausepool,

               o_ClauseregOutputs    => w_clauseOutputsSeqORed
               );


    CLASSSUMS : entity lib_convcotm.ClassSums(rtl) 
        port map(
            i_clk                       => i_clk, 
            i_rst                       => i_rst, 
            i_en_adders                 => w_en_adders,
            i_en_cg                     => i_en_cg,
            i_enFirstAdder              => w_enFirstAdder,
            i_enLastAdder               => w_enLastAdder,

            i_inputsFromSeqORedClauses  => w_clauseOutputsSeqORed,  
            
            i_weightClass0              => i_weightClass0,
            i_weightClass1              => i_weightClass1, 
            i_weightClass2              => i_weightClass2,
            i_weightClass3              => i_weightClass3,
            i_weightClass4              => i_weightClass4,
            i_weightClass5              => i_weightClass5,
            i_weightClass6              => i_weightClass6,
            i_weightClass7              => i_weightClass7,
            i_weightClass8              => i_weightClass8,
            i_weightClass9              => i_weightClass9,
            
            o_sumClass0                 => w_sumClass0,
            o_sumClass1                 => w_sumClass1,
            o_sumClass2                 => w_sumClass2,
            o_sumClass3                 => w_sumClass3,
            o_sumClass4                 => w_sumClass4,
            o_sumClass5                 => w_sumClass5,
            o_sumClass6                 => w_sumClass6,
            o_sumClass7                 => w_sumClass7,
            o_sumClass8                 => w_sumClass8,
            o_sumClass9                 => w_sumClass9
            );
            
    DECIDE : entity lib_convcotm.ClassDecision(rtl2) 
    -- architecture rtl implements argmax with selection of the greatest class index if equal class sums
    -- architecture rtl2 implements argmax with selection of the smallest class index if equal class sums
        port map(
            i_classSum0         => w_sumClass0,
            i_classSum1         => w_sumClass1,
            i_classSum2         => w_sumClass2,
            i_classSum3         => w_sumClass3,
            i_classSum4         => w_sumClass4,
            i_classSum5         => w_sumClass5,
            i_classSum6         => w_sumClass6,
            i_classSum7         => w_sumClass7,
            i_classSum8         => w_sumClass8,
            i_classSum9         => w_sumClass9,
            --
            o_classPredict      => w_classPredict -- suitable for up to 16 class systems 
            );
    
     EVAL : entity lib_convcotm.EvaluateResults(rtl)
         port map(
                i_clk               => i_clk,
                --i_rst               => i_rst,
                i_sample_actual     => w_sample_actual_class,
                i_sample_predict    => w_sample_predicted_class,
                i_classActual       => unsigned(w_ImageLabel),
                i_classPredict      => w_classPredict,
--                i_FinishedInference => w_FinishedInference,
                --
                o_result             => o_result 
            );
               
end rtl;
