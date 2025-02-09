library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.numeric_std.all;

library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;

entity FSM_LOADMODEL is       
     Port (
           i_clk                        : in std_logic; 
           i_rst                        : in std_logic; 
           i_load_model                  : in std_logic;
           i_data_valid                 : in std_logic;
           
           o_enable_inputregister       : out std_logic;
           o_modelbuffer_byte_update    : out std_logic_vector(ModelBytesPerClause-1 downto 0);
           o_clause_model_update        : out std_logic_vector(NClauses-1 downto 0);
           
           o_intrL                      : out std_logic
           ); 
end FSM_LOADMODEL;

architecture rtl of FSM_LOADMODEL is 

    -- Load Model:   
    constant InitialStateLoad     	                 : std_logic_vector(6 downto 0)   := "0000001";
    constant Phase0ALoadMODEL                        : std_logic_vector(6 downto 0)   := "0000010";
    constant Phase0BLoadMODEL                        : std_logic_vector(6 downto 0)   := "0000100";
    constant Phase0CLoadMODEL                        : std_logic_vector(6 downto 0)   := "0001000";
    constant LoadMODEL                               : std_logic_vector(6 downto 0)   := "0010000";
    constant Phase2ALoadMODEL                        : std_logic_vector(6 downto 0)   := "0100000";
    constant FinishedLoadMODEL                       : std_logic_vector(6 downto 0)   := "1000000";
    

    signal w_currentstate                       : std_logic_vector(6 downto 0); 
    signal w_nextstate                          : std_logic_vector(6 downto 0);
    signal w_next1                              : std_logic_vector(6 downto 0);
    
    signal w_rstCountClauses                    : std_logic;
    signal w_clausecounterenable                : std_logic;
    signal w_ClauseCounterFinished              : std_logic;  
    signal w_clauseAddress                      : std_logic_vector(NBitsClauseAddr-1 downto 0);
    
    type   kArray is array (0 to NClauses-1) of std_logic_vector(NBitsClauseAddr-1 downto 0);
    signal w_kAddr                              : kArray;
    
    type   MArray is array (0 to ModelBytesPerClause-1) of std_logic_vector(5 downto 0);
    signal w_MAddr                              : MArray;
    
    signal w_resetM                             : std_logic;
    signal w_Mfinished                          : std_logic;
    signal w_Mregout                            : std_logic_vector(5 downto 0);
    
    signal w_Mfinished2                         : std_logic;
    signal w_Mregout2                           : std_logic_vector(5 downto 0);
    signal w_enMcounter2                        : std_logic;
    
    signal w_EnModeBufferlLoad                  : std_logic;
    signal w_EnModelRegisterLoad                : std_logic;
    
begin
---------------------------------------------------------------------------------
    o_enable_inputregister <= '1' when (w_currentstate = InitialStateLoad
                            or w_currentstate = Phase0ALoadMODEL
                            or w_currentstate = Phase0BLoadMODEL
                            or w_currentstate = Phase0CLoadMODEL 
                            or w_currentstate = LoadMODEL) 
                            else '0'; 
                             
    w_EnModeBufferlLoad <= '1' when (w_currentstate = Phase0BLoadMODEL or w_currentstate = Phase0CLoadMODEL or w_currentstate = LoadMODEL) 
                               else '0'; 
                            
    w_EnModelRegisterLoad <= '1' when (w_currentstate = Phase0CLoadMODEL or w_currentstate = LoadMODEL) 
                                 else '0'; 


    w_resetM <= '0' when (w_currentstate = Phase0BLoadMODEL
                          or w_currentstate = Phase0CLoadMODEL  
                          or w_currentstate = LoadMODEL) 
                          else '1'; 
     
     -- Count bytes in input buffer register:
     ModelBytesCount: entity lib_convcotm.counterModelBytes(rtl) 
        port map (
            i_clk               => i_clk, 
            i_rst               => i_rst,
            i_resetM            => w_resetM,
            i_en                => w_EnModeBufferlLoad,
            o_M_counterFinished => w_Mfinished, -- Not used anywhere in the mainFSM module.
            o_M_value           => w_Mregout
            );
    
        AY: FOR ja in 0 to ModelBytesPerClause-1 GENERATE
                 w_Maddr(ja) <= std_logic_vector(to_unsigned(ja, w_Maddr(ja)'length));   
                 o_modelbuffer_byte_update(ja) <='1' when (w_Mregout=w_Maddr(ja) and w_EnModeBufferlLoad='1') else '0';   
        end GENERATE AY; 
   
        GY: FOR ja in 0 to NClauses-1 GENERATE
             w_kAddr(ja) <= std_logic_vector(to_unsigned(ja, w_kAddr(ja)'length));   
             o_clause_model_update(ja) <='1' when (w_clauseAddress=w_kAddr(ja) and w_EnModelRegisterLoad='1') else '0';   
        end GENERATE GY; 
   
    -------------------------------------------------------------------------------------------------
    -- CLAUSE COUNTER:
    -------------------------------------------------------------------------------------------------------------------------------------------------

    w_rstCountClauses    <= '1' when (i_rst='1' or w_currentstate=InitialStateLoad)
                                else '0'; 
    
    w_clausecounterenable <='1' when w_Mfinished2='1'
                                else '0';
    
    clauseCounter2 : entity lib_convcotm.clauseCounter2(rtl)  -- increments every ModelBytesPerClause clk cycle.
            port map(i_clk                           => i_clk,
                     i_rst                           => w_rstCountClauses,
                     i_en                            => w_clausecounterenable,
                     o_clauseAddress                 => w_clauseAddress
                     );
    
    w_ClauseCounterFinished <= '1' when ((to_integer(unsigned(w_clauseAddress))=(NClauses-1)) and (w_Mfinished2='1')) 
                                else '0';

    w_enMcounter2 <= '1' when (w_currentstate=Phase0CLoadMODEL or w_currentstate=LoadMODEL) 
                         else '0';

    InClauseCounterBytesCount: entity lib_convcotm.counterModelBytes(rtl) 
        port map (
            i_clk               => i_clk, 
            i_rst               => w_rstCountClauses,
            i_resetM            => '0',
            i_en                => w_enMcounter2,
            o_M_counterFinished => w_Mfinished2,
            o_M_value           => w_Mregout2
            );

------------------------------------------------------------------------------------------
    STATEREG_FSMLOAD: vDFF generic map(7) port map(i_clk, w_nextstate, w_currentstate);
    
    w_nextstate <= InitialStateLoad when i_rst='1' else w_next1;
    
      process(
              w_currentstate, 
              i_data_valid, 
              i_load_model,
              w_ClauseCounterFinished
              ) 
      begin
              
        case w_currentstate is
        
            when InitialStateLoad =>    
                    IF i_load_model='1' THEN 
                        w_next1 <= Phase0ALoadMODEL;
                    ELSE w_next1<=InitialStateLoad;
                    END IF;
                               
            ---------------------------------------------------------------------------------------------
            when Phase0ALoadMODEL =>
                         IF i_data_valid='1' THEN
                            w_next1 <= Phase0BLoadMODEL;
                         ELSE w_next1 <= Phase0ALoadMODEL;
                         END IF;
                         
            when Phase0BLoadMODEL =>
                         w_next1 <= Phase0CLoadMODEL;
                         
            when Phase0CLoadMODEL =>
                         w_next1 <= LoadMODEL;                        
                    
             when LoadMODEL =>  
                    IF w_ClauseCounterFinished='1' THEN
                         w_next1 <= Phase2ALoadMODEL;     
                    ELSE w_next1 <= LoadMODEL;
                    END IF;
            
            --------
            when Phase2ALoadMODEL =>
                         w_next1 <= FinishedLoadMODEL;
            
            when FinishedLoadMODEL =>   
                    IF i_load_model='1' THEN
                         w_next1 <= FinishedLoadMODEL;
                    ELSE w_next1 <= InitialStateLoad;
                    END IF; 
                         
            ---------------------------------------------------------------------------------------------
            when others =>
                   w_next1 <= InitialStateLoad;
                    
           end case;             
    end process;
    
    o_intrL <= '1' when w_currentstate=FinishedLoadMODEL
                  else '0';
    
end rtl;
