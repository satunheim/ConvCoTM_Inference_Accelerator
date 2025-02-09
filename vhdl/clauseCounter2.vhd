library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;   

entity clauseCounter2 is   
        Port (
             i_clk : in STD_LOGIC; 
             i_rst : in STD_LOGIC;
             i_en  : in STD_LOGIC;
             o_clauseAddress : out std_logic_vector(NBitsClauseAddr-1 downto 0)
            );
end clauseCounter2;  

architecture rtl of clauseCounter2 is 

    signal w_nxtC               : std_logic_vector(NBitsClauseAddr-1 downto 0);
    signal w_regoutC            : std_logic_vector(NBitsClauseAddr-1 downto 0);
    
    signal w_valueC             : unsigned(NBitsClauseAddr-1 downto 0);
    signal w_increment          : unsigned(NBitsClauseAddr-1 downto 0);
    signal w_valueCincremented  : unsigned(NBitsClauseAddr-1 downto 0);
 
begin

    clauseCOUNTreg: vDFF generic map(NBitsClauseAddr) port map(i_clk, w_nxtC, w_regoutC);
    
    w_valueC <= unsigned(w_regoutC);
    w_increment <= (0 => '1', others => '0');  
    w_valueCincremented <=w_valueC+w_increment;
    
    w_nxtC <=        (others=>'0') when i_rst='1' 
                else std_logic_vector(w_valueCincremented) when i_en='1'
                else w_regoutC;

    o_clauseAddress <= w_regoutC; 

end rtl;



--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
----use IEEE.std_logic_misc.all; 
--use IEEE.numeric_std.all;
--use IEEE.std_logic_unsigned.all;
--use work.FF.all;  
--use work.SETTINGS_ConvCoTM.all;
--use work.MainFSMDefinitions.all;  

---- In the inference ASIC the clause address counter is only used during loading of a model.
---- The clause counter should only increment for each ModelBytesPerClause, which is 34+20=54.
---- Thus we need to have a separate counter for this that controle the clause Counter.

--entity clauseCounter is   
--        Port (
--             i_clk : in STD_LOGIC; 
--             i_rst : in STD_LOGIC;
--             i_en : in STD_LOGIC;
--             i_MainFSMstate       : in std_logic_vector(SWIDTH-1 downto 0);
             
--             o_cCounterFinished : out STD_LOGIC;
--             o_clauseAddress : out std_logic_vector(NBitsClauseAddr-1 downto 0)
--            );
--end clauseCounter;  

--architecture rtl of clauseCounter is 

--    signal w_enablecounter      : std_logic;

--    signal w_nxtC               : std_logic_vector(NBitsClauseAddr-1 downto 0);
--    signal w_regoutC            : std_logic_vector(NBitsClauseAddr-1 downto 0);
    
--    signal w_valueC             : unsigned(NBitsClauseAddr-1 downto 0);
--    signal w_increment          : unsigned(NBitsClauseAddr-1 downto 0);
--    signal w_valueCincremented  : unsigned(NBitsClauseAddr-1 downto 0);
    
----    signal w_resetM             : std_logic;
----    signal w_Mfinished          : std_logic;
----    signal w_Mregout            : std_logic_vector(6 downto 0);
 
--begin

----    w_enablecounter <= i_en or i_rst;

--    w_enablecounter <= '1' when i_rst='1' or i_MainFSMstate=Phase1BLoadMODEL 
--                      else '0';

--    clauseCOUNTreg: vDFFce generic map(NBitsClauseAddr) port map(i_clk, w_enablecounter, w_nxtC, w_regoutC);
    
--    w_valueC <= unsigned(w_regoutC);
--    w_increment <= (0 => '1', others => '0');  
--    w_valueCincremented <=w_valueC+w_increment;
    
--    w_nxtC   <=       (others=>'0') when (i_rst='1') or (w_enablecounter='0') 
--    --w_nxtC   <=       (others=>'0') when (i_rst='1') or (i_en='0') 
--                                          --or ((to_integer(w_valueC) = (NClauses-1)) and (w_Mfinished='1'))
--                 --else std_logic_vector(w_valueCincremented) when (to_integer(w_valueC) < (NClauses-1)) else 
--                 else std_logic_vector(w_valueCincremented) when (to_integer(w_valueC) < (NClauses-1)) 
--                 --else std_logic_vector(w_valueCincremented) when ((to_integer(w_valueC) < (NClauses-1)) and (w_Mfinished='1')) 
--                 else w_regoutC;
--                 --else (others=>'0');
    
--    o_clauseAddress <= w_regoutC; 
--    o_cCounterFinished <= '1' when (to_integer(w_valueC) = (NClauses-1)) 
--                          else '0';
--    --o_cCounterFinished <= '1' when (to_integer(w_valueC) = (NClauses-1)) and (w_Mfinished='1') else '0';
    
--    -- Count NumberOfByterPerClause for each update of clause counter.
----     w_resetM <= '0'; 
     
----     InClauseCounterBytesCount: entity work.counterModelBytes(rtl) 
----        port map (
----            i_clk               => i_clk, 
----            i_rst               => i_rst,
----            i_resetM            => w_resetM,
----            i_en                => i_en,
----            o_M_counterFinished => w_Mfinished,
----            o_M_value           => w_Mregout
----            );

--end rtl;

