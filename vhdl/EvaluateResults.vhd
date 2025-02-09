library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
   
library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;
 
entity EvaluateResults is 
    Port (
        i_clk               : in STD_LOGIC;
        i_sample_actual     : in std_logic;
        i_sample_predict    : in std_logic;    
        i_classActual       : in unsigned(3 downto 0);  
        i_classPredict      : in unsigned(3 downto 0);  
        o_result             : out std_logic_vector(7 downto 0) 
        );
         
end EvaluateResults;

architecture rtl of EvaluateResults is

    signal w_Next               : std_logic_vector(7 downto 0);
    signal w_Reg                : std_logic_vector(7 downto 0);

begin

    SampledResultandActual :  vDFF generic map(8) port map(i_clk, w_Next, w_Reg);
              
    w_Next <=  std_logic_vector(i_classActual) & w_Reg(3 downto 0) when i_sample_actual='1' 
          else w_Reg(7 downto 4) & std_logic_vector(i_classPredict) when i_sample_predict='1'
          else w_Reg;             

    o_result <= w_Reg; 

end rtl;