library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_misc.all; 

library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;

entity TMASIC4_core is
    Port ( 
            i_clks                      : in std_logic; -- to inference part
            i_clkl                      : in std_logic; -- to model part
            
            i_rst                       : in std_logic;
            i_rst_imbuf                 : in std_logic;
            i_en_image                  : in std_logic;
            i_start                     : in std_logic;
            
            i_load                      : in std_logic;
            
            i_single                    : in std_logic;
            i_test                      : in std_logic; -- not implemented
            i_en_cg                     : in std_logic; -- active high

            -- Slave interface:
            i_data_valid                : in std_logic; -- connected to synchronizer2 module
            i_data                      : in std_logic_vector(7 downto 0); 
                                                        -- connected to synchronizer2 module
             
            -- Interrupts:
            o_intrs                     : out std_logic; -- Inference finished
            o_intrl                     : out std_logic; -- Load model finished
            
            -- Actual and predicted classes:
            o_result                    : out std_logic_vector(7 downto 0) 
            );
end TMASIC4_core;
-----------------------------------------------------------------------------------------------------

architecture rtl of TMASIC4_core is
    
    signal w_in_sync1s                          : std_logic_vector(3 downto 0);
    signal w_out_sync1s                         : std_logic_vector(3 downto 0);
    
    signal w_in_sync2l                          : std_logic_vector(1 downto 0);
    signal w_out_sync2l                         : std_logic_vector(1 downto 0);
    
--  Main control signals (synchronized):      
    signal w_rstS                               : std_logic; 
    signal w_reset_imbuf                        : std_logic;
    signal w_start                              : std_logic;
    signal w_en_image                           : std_logic;
    
    signal w_rstL                               : std_logic; 
    signal w_load_model                         : std_logic;
    
    -- AXI Stream interface (synchronized):
    signal w_data_validL                        : std_logic;
    signal w_dataL                              : std_logic_vector(7 downto 0);
    
    signal w_data_validS                        : std_logic;
    signal w_dataS                              : std_logic_vector(7 downto 0);
 
    -- Model signals:
    signal w_incexcl_signals                    : include_exclude_signals;
    
    signal w_weightClass0                       : clause_weights;
    signal w_weightClass1                       : clause_weights;
    signal w_weightClass2                       : clause_weights;
    signal w_weightClass3                       : clause_weights;
    signal w_weightClass4                       : clause_weights;
    signal w_weightClass5                       : clause_weights;
    signal w_weightClass6                       : clause_weights;
    signal w_weightClass7                       : clause_weights;
    signal w_weightClass8                       : clause_weights;
    signal w_weightClass9                       : clause_weights;    

----------------------------------------------------------------------------
begin 

    w_in_sync1s <= i_start & i_en_image & i_rst_imbuf & i_rst;
    
    w_in_sync2l <= i_load & i_rst;

    SYNCH_1S : entity lib_convcotm.Synchronizer(rtl) 
        Port map 
            (
             clk         => i_clkS, 
             i_signals   => w_in_sync1s,
             o_synched   => w_out_sync1s
           );
           
    SYNCH_2L : entity lib_convcotm.Synchronizer3(rtl) 
        Port map 
            (
             clk         => i_clkL, 
             i_signals   => w_in_sync2l,
             o_synched   => w_out_sync2l
           ); 
    
    w_rstS          <= w_out_sync1s(0);
    w_reset_imbuf   <= w_out_sync1s(1);
    w_en_image      <= w_out_sync1s(2);
    w_start         <= w_out_sync1s(3);
    
    w_rstL          <= w_out_sync2l(0);
    w_load_model    <= w_out_sync2l(1);
    

    SYNCH_AXI_S : entity lib_convcotm.Synchronizer2(rtl) -- synch axi signals
        Port map (
            clk                => i_clkS,
            i_data             => i_data,
            i_data_valid       => i_data_valid,
            
            o_synch_data       => w_dataS,
            o_synch_data_valid => w_data_validS
            );
     
    SYNCH_AXI_L : entity lib_convcotm.Synchronizer2(rtl) -- synch axi signals
        Port map (
            clk                => i_clkL,
            i_data             => i_data,
            i_data_valid       => i_data_valid,
            
            o_synch_data       => w_dataL,
            o_synch_data_valid => w_data_validL
            );
 
     INFERENCE: entity lib_convcotm.InferenceCore(rtl)
        Port map(
                i_clk             => i_clkS,
               
                i_rst             => w_rstS,
                i_rst_imbuf       => w_reset_imbuf,
                i_en_image        => w_en_image,
                i_start           => w_start,
                
                i_single          => i_single,
                i_test            => i_test,  -- not implemented
                i_en_cg           => i_en_cg, -- active high
                
                -- Slave interface:
                i_data_valid        => w_data_validS,
                i_data              => w_dataS,
                
                -- Model:
                i_incexcl_signals   => w_incexcl_signals,
                i_weightClass0      => w_weightClass0,
                i_weightClass1      => w_weightClass1,
                i_weightClass2      => w_weightClass2,
                i_weightClass3      => w_weightClass3,
                i_weightClass4      => w_weightClass4,
                i_weightClass5      => w_weightClass5,
                i_weightClass6      => w_weightClass6,
                i_weightClass7      => w_weightClass7,
                i_weightClass8      => w_weightClass8,
                i_weightClass9      => w_weightClass9,
                
                -- Interrupt and prediction result:
                o_intrS             => o_intrS,
                o_Result            => o_Result
                );

        MODELTM: entity lib_convcotm.ModelConvCoTM(rtl)
            Port map(
                    i_clk           => i_clkL,
                    i_rst           => w_rstL,
                    i_load_model    => w_load_model,
        
                    i_data_valid    => w_data_validL,
                    i_data          => w_dataL,
        
                    o_intrL         => o_intrL,
                    o_InclExcl      => w_incexcl_signals, -- TA action signals
                    o_weightClass0  => w_weightClass0,
                    o_weightClass1  => w_weightClass1,
                    o_weightClass2  => w_weightClass2,
                    o_weightClass3  => w_weightClass3,
                    o_weightClass4  => w_weightClass4,
                    o_weightClass5  => w_weightClass5,
                    o_weightClass6  => w_weightClass6,
                    o_weightClass7  => w_weightClass7,
                    o_weightClass8  => w_weightClass8,
                    o_weightClass9  => w_weightClass9     
                    );               
end rtl;
