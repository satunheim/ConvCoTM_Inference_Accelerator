library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.numeric_std.all;

library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;

entity FSM_MAIN3 is       
     Port (
           i_clk                        : in std_logic; 
           i_rst                        : in std_logic; 
           i_start                      : in std_logic; 
           i_data_valid                 : in std_logic;
           
           o_en_generate_patches        : out std_logic;  
           o_rst_clausepool             : out std_logic;
           o_en_clausepool              : out std_logic;
           o_updateOR                   : out std_logic;
           o_BxCounterValue             : out std_logic_vector(4 downto 0); 
           o_ByCounterValue             : out std_logic_vector(4 downto 0);
           
           o_LoadNewSample              : out std_logic;
           o_LoadNewRow                 : out std_logic;
           
           o_en_adders                  : out std_logic;
           o_enFirstAdder               : out std_logic;
           o_enLastAdder                : out std_logic;
           
           o_sample_actual_class        : out std_logic;
           o_sample_predicted_class     : out std_logic; 
           
           o_intrS                      : out std_logic;
           
           o_keepClassDecision          : out std_logic      
           ); 
end FSM_MAIN3;

-----------------------------------------------------
architecture rtl of FSM_MAIN3 is 

    constant MFSMWIDTH: Integer := 10;

    constant InitialState                       : std_logic_vector(MFSMWIDTH-1 downto 0)   := "0000000001";
    constant Step1                              : std_logic_vector(MFSMWIDTH-1 downto 0)   := "0000000010";
    constant Step2                              : std_logic_vector(MFSMWIDTH-1 downto 0)   := "0000000100";
    constant Step3                              : std_logic_vector(MFSMWIDTH-1 downto 0)   := "0000001000";
    constant Inference            	        : std_logic_vector(MFSMWIDTH-1 downto 0)   := "0000010000";
    constant FinishedInf1        	        : std_logic_vector(MFSMWIDTH-1 downto 0)   := "0000100000";
    constant FinishedInf2        	        : std_logic_vector(MFSMWIDTH-1 downto 0)   := "0001000000";
    constant FinishedInf3                       : std_logic_vector(MFSMWIDTH-1 downto 0)   := "0010000000";
    constant FinishedInf4        	        : std_logic_vector(MFSMWIDTH-1 downto 0)   := "0100000000";
    constant keepClassDecision                  : std_logic_vector(MFSMWIDTH-1 downto 0)   := "1000000000";
    
    -------------------------------------------
    signal w_currentstate                       : std_logic_vector(MFSMWIDTH-1 downto 0); 
    signal w_nextstate                          : std_logic_vector(MFSMWIDTH-1 downto 0);
    signal w_next1                              : std_logic_vector(MFSMWIDTH-1 downto 0);

    signal w_resetBcounter                      : std_logic;
    signal w_resetPcounter                      : std_logic;
    signal w_enablePcounter                     : std_logic;
    signal w_PcounterFinished                   : std_logic;
    
    signal w_en_clausepool                      : std_logic;
    
begin
    
   Module_Bcounter: entity lib_convcotm.Bcounter(rtl) 
    port map
            (
            i_clk               => i_clk,
            i_resetBounter      => w_resetBcounter, 
            
            o_BxCounterValue    => o_BxCounterValue,
            o_ByCounterValue    => o_ByCounterValue,
            o_LoadNewRow        => o_LoadNewRow
            );

    w_resetBcounter         <= '1' when (w_currentstate=InitialState or w_currentstate=Step1 or w_currentstate=FinishedInf2 
                                        or w_currentstate=FinishedInf3 or w_currentstate=FinishedInf4 or w_currentstate=keepClassDecision) else '0';
                                        
    w_resetPcounter         <= '1' when (w_currentstate=InitialState or w_currentstate=Step1 or w_currentstate=Step2 or w_currentstate=FinishedInf2 
                                        or w_currentstate=FinishedInf3 or w_currentstate=FinishedInf4 or w_currentstate=keepClassDecision) else '0';  

--------------------------------------------------------------------------------------------------------- 
    w_enablePcounter <= not(w_resetPcounter);
    
    o_en_generate_patches <= '1' when (w_currentstate=Step1 or w_currentstate=Step2 or w_currentstate=Step3 or w_currentstate=Inference) else '0';  
    
    w_en_clausepool <= '1' when (w_currentstate=Step3 or w_currentstate=Inference) else '0'; 

    o_en_clausepool <= w_en_clausepool;
    
    o_rst_clausepool <=not(w_en_clausepool);
    
    o_LoadNewSample <='1' when w_currentstate=Step1 else '0'; 
    o_updateOR      <='1' when w_currentstate=Step3 else '0'; 
    
    -------------------------------------------------------------------------------------------------
    -- P-COUNTER:
    -- This is used for counting the clock cycles needed for the patch generation.
    
    patchCounter : entity lib_convcotm.Pcounter(rtl2)  
            port map(i_clk                           => i_clk,
                     i_rst                           => w_resetPcounter,
                     o_PcounterFinished              => w_PcounterFinished
                     );
    -------------------------------------------------------------------------------------------------
    
    o_en_adders                 <= '1' when (w_currentstate=FinishedInf1 or 
                                             w_currentstate=FinishedInf2 or
                                             w_currentstate=FinishedInf3)
                                    else '0'; 
                                    
    
    o_enFirstAdder              <= '1' when w_currentstate=FinishedInf1 else '0'; 
    o_enLastAdder               <= '1' when w_currentstate=FinishedInf3 else '0'; 
    
    o_sample_actual_class       <= '1' when w_currentstate=FinishedInf1 else '0'; 
    o_sample_predicted_class    <= '1' when w_currentstate=FinishedInf4 else '0'; 
    
    --------------------------------------------------------------------------------------
    --------------------------------------------------------------------------------------
    -- FSM:
    MAINSTATEREG: vDFF generic map(MFSMWIDTH) port map(i_clk, w_nextstate, w_currentstate);
    
    w_nextstate <= InitialState when i_rst='1' else w_next1;
    
      process(
              w_currentstate, 
              i_start,
              i_data_valid, 
              w_PcounterFinished 
              ) 
      begin
              
        case w_currentstate is
        
            when InitialState =>    
                    IF i_start='1' THEN 
                        w_next1 <= Step1; 
                    ELSE w_next1<=InitialState;
                    END IF;
            
            when Step1 =>    
                    w_next1<=Step2;
                    
            when Step2 =>    
                    w_next1<=Step3;
                    
            when Step3 =>    
                    w_next1<=Inference;

            when Inference =>  
                    IF w_PcounterFinished='1' THEN 
                        w_next1 <= FinishedInf1;
                    ELSE w_next1<=Inference;
                    END IF;

            when FinishedInf1 =>
                    w_next1<=FinishedInf2;
                    
            when FinishedInf2 =>
                    w_next1<=FinishedInf3;
                    
            when FinishedInf3 =>
                    w_next1<=FinishedInf4;
                    
            when FinishedInf4 =>
                        w_next1 <= keepClassDecision;
    
            when keepClassDecision =>
                    IF i_start='1' THEN 
                        w_next1 <= keepClassDecision; 
                    ELSE w_next1<=InitialState;
                    END IF;  
                         
            ---------------------------------------------------------------------------------------------
            when others =>
                   w_next1 <= InitialState;
                    
           end case;             
    end process;
    

    -- Interupt generation:
    o_intrS <= '1' when w_currentstate=keepClassDecision else '0';

    o_keepClassDecision <= '1' when w_currentstate=keepClassDecision else '0';
    
end rtl;
