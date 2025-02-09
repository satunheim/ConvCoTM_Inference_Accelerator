library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all; 

library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;

entity ClassSums is   
    Port (
          i_clk           : in std_logic;
          i_rst           : in std_logic;
          i_en_adders     : in std_logic;
          i_en_cg         : in std_logic; -- active high
          i_enFirstAdder  : in std_logic; 
          i_enLastAdder   : in std_logic;
          
          i_inputsFromSeqORedClauses : in STD_LOGIC_VECTOR (NClauses-1 downto 0); 
          
          i_weightClass0 : in clause_weights;
          i_weightClass1 : in clause_weights; 
          i_weightClass2 : in clause_weights;
          i_weightClass3 : in clause_weights; 
          i_weightClass4 : in clause_weights;
          i_weightClass5 : in clause_weights; 
          i_weightClass6 : in clause_weights;
          i_weightClass7 : in clause_weights; 
          i_weightClass8 : in clause_weights;
          i_weightClass9 : in clause_weights;       
          
	      o_sumClass0    : out signed(NBsum-1 downto 0);  
	      o_sumClass1    : out signed(NBsum-1 downto 0);
	      o_sumClass2    : out signed(NBsum-1 downto 0);
	      o_sumClass3    : out signed(NBsum-1 downto 0);
	      o_sumClass4    : out signed(NBsum-1 downto 0);
	      o_sumClass5    : out signed(NBsum-1 downto 0); 
	      o_sumClass6    : out signed(NBsum-1 downto 0);
	      o_sumClass7    : out signed(NBsum-1 downto 0);
	      o_sumClass8    : out signed(NBsum-1 downto 0);
	      o_sumClass9    : out signed(NBsum-1 downto 0)
	      ); 
	      
end ClassSums; 

architecture rtl of ClassSums is
    
    signal w_sumClass0 : signed(NBsum-1 downto 0);
    signal w_sumClass1 : signed(NBsum-1 downto 0);
    signal w_sumClass2 : signed(NBsum-1 downto 0);
    signal w_sumClass3 : signed(NBsum-1 downto 0);
    signal w_sumClass4 : signed(NBsum-1 downto 0);
    signal w_sumClass5 : signed(NBsum-1 downto 0);
    signal w_sumClass6 : signed(NBsum-1 downto 0);
    signal w_sumClass7 : signed(NBsum-1 downto 0);
    signal w_sumClass8 : signed(NBsum-1 downto 0);
    signal w_sumClass9 : signed(NBsum-1 downto 0);
    
    signal w_enable_adders : std_logic;

begin
     
    w_enable_adders <= i_en_adders or not(i_en_cg);
                                                                                                                                                       
    SingleModuleClassSum0: entity lib_convcotm.GenerateClassSum128pipe3(rtl_ce) 
            port map(
                i_clk               => i_clk,
                i_rst               => i_rst, 
                i_en_adders         => w_enable_adders,
                i_enFirstAdder      => i_enFirstAdder,
                i_enLastAdder       => i_enLastAdder,
                i_clauseWeights     => i_weightClass0, 
                i_inputsFromClauses => i_inputsFromSeqORedClauses, 
                o_sum               => w_sumClass0
                ); 
                
       SingleModuleClassSum1: entity lib_convcotm.GenerateClassSum128pipe3(rtl_ce) 
            port map(
                i_clk               => i_clk,
                i_rst               => i_rst, 
                i_en_adders         => w_enable_adders,
                i_enFirstAdder      => i_enFirstAdder,
                i_enLastAdder       => i_enLastAdder,
                i_clauseWeights     => i_weightClass1, 
                i_inputsFromClauses => i_inputsFromSeqORedClauses, 
                o_sum               => w_sumClass1
                );                      

       SingleModuleClassSum2: entity lib_convcotm.GenerateClassSum128pipe3(rtl_ce) 
            port map(
                i_clk               => i_clk,
                i_rst               => i_rst, 
                i_en_adders         => w_enable_adders,
                i_enFirstAdder      => i_enFirstAdder,
                i_enLastAdder       => i_enLastAdder,
                i_clauseWeights     => i_weightClass2, 
                i_inputsFromClauses => i_inputsFromSeqORedClauses, 
                o_sum               => w_sumClass2
                ); 
                
       SingleModuleClassSum3: entity lib_convcotm.GenerateClassSum128pipe3(rtl_ce) 
            port map(
                i_clk               => i_clk,
                i_rst               => i_rst, 
                i_en_adders         => w_enable_adders,
                i_enFirstAdder      => i_enFirstAdder,
                i_enLastAdder       => i_enLastAdder,
                i_clauseWeights     => i_weightClass3, 
                i_inputsFromClauses => i_inputsFromSeqORedClauses, 
                o_sum               => w_sumClass3 
                );    

       SingleModuleClassSum4: entity lib_convcotm.GenerateClassSum128pipe3(rtl_ce) 
            port map(
                i_clk               => i_clk,
                i_rst               => i_rst, 
                i_en_adders         => w_enable_adders,
                i_enFirstAdder      => i_enFirstAdder,
                i_enLastAdder       => i_enLastAdder,
                i_clauseWeights     => i_weightClass4, 
                i_inputsFromClauses => i_inputsFromSeqORedClauses, 
                o_sum               => w_sumClass4
                );  
                
       SingleModuleClassSum5: entity lib_convcotm.GenerateClassSum128pipe3(rtl_ce) 
            port map(
                i_clk               => i_clk,
                i_rst               => i_rst, 
                i_en_adders         => w_enable_adders,
                i_enFirstAdder      => i_enFirstAdder,
                i_enLastAdder       => i_enLastAdder, 
                i_clauseWeights     => i_weightClass5, 
                i_inputsFromClauses => i_inputsFromSeqORedClauses, 
                o_sum               => w_sumClass5 
                ); 
                
       SingleModuleClassSum6: entity lib_convcotm.GenerateClassSum128pipe3(rtl_ce) 
            port map(
                i_clk               => i_clk,
                i_rst               => i_rst, 
                i_en_adders         => w_enable_adders,
                i_enFirstAdder      => i_enFirstAdder,
                i_enLastAdder       => i_enLastAdder,
                i_clauseWeights     => i_weightClass6, 
                i_inputsFromClauses => i_inputsFromSeqORedClauses, 
                o_sum               => w_sumClass6
                );                      

       SingleModuleClassSum7: entity lib_convcotm.GenerateClassSum128pipe3(rtl_ce) 
            port map(
                i_clk               => i_clk,
                i_rst               => i_rst, 
                i_en_adders         => w_enable_adders,
                i_enFirstAdder      => i_enFirstAdder,
                i_enLastAdder       => i_enLastAdder,
                i_clauseWeights     => i_weightClass7, 
                i_inputsFromClauses => i_inputsFromSeqORedClauses, 
                o_sum               => w_sumClass7 
                ); 
                
       SingleModuleClassSum8: entity lib_convcotm.GenerateClassSum128pipe3(rtl_ce) 
            port map(
                i_clk               => i_clk,
                i_rst               => i_rst, 
                i_en_adders         => w_enable_adders,
                i_enFirstAdder      => i_enFirstAdder,
                i_enLastAdder       => i_enLastAdder,
                i_clauseWeights     => i_weightClass8, 
                i_inputsFromClauses => i_inputsFromSeqORedClauses, 
                o_sum               => w_sumClass8
                );    

       SingleModuleClassSum9: entity lib_convcotm.GenerateClassSum128pipe3(rtl_ce) 
            port map(
                i_clk               => i_clk,
                i_rst               => i_rst, 
                i_en_adders         => w_enable_adders,
                i_enFirstAdder      => i_enFirstAdder,
                i_enLastAdder       => i_enLastAdder,
                i_clauseWeights     => i_weightClass9, 
                i_inputsFromClauses => i_inputsFromSeqORedClauses, 
                o_sum               => w_sumClass9 
                );  

        -- Connect wires to outputs:
        o_sumClass0 <= w_sumClass0;
        o_sumClass1 <= w_sumClass1;
        o_sumClass2 <= w_sumClass2;
        o_sumClass3 <= w_sumClass3;
        o_sumClass4 <= w_sumClass4;
        o_sumClass5 <= w_sumClass5;
        o_sumClass6 <= w_sumClass6;
        o_sumClass7 <= w_sumClass7;
        o_sumClass8 <= w_sumClass8;
        o_sumClass9 <= w_sumClass9;

end rtl;