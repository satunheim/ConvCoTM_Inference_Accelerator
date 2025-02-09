library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.numeric_std.all; 

library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;

entity GeneratePatches3 is      
    port (
        i_clk              : in std_logic; 
        i_rst              : in std_logic; 
        i_en               : in std_logic; 
        i_start            : in std_logic;  
        
        i_LoadNewSample    : in std_logic;
        i_LoadNewRow       : in std_logic;
          
        i_BxCounterValue   : in std_logic_vector(4 downto 0);
        i_ByCounterValue   : in std_logic_vector(4 downto 0);  
                    
        i_ImagevectorRow0  : in std_logic_vector(ImageSize-1 downto 0); 
        i_ImagevectorRow1  : in std_logic_vector(ImageSize-1 downto 0);
        i_ImagevectorRow2  : in std_logic_vector(ImageSize-1 downto 0);
        i_ImagevectorRow3  : in std_logic_vector(ImageSize-1 downto 0);
        i_ImagevectorRow4  : in std_logic_vector(ImageSize-1 downto 0);
        i_ImagevectorRow5  : in std_logic_vector(ImageSize-1 downto 0);
        i_ImagevectorRow6  : in std_logic_vector(ImageSize-1 downto 0);
        i_ImagevectorRow7  : in std_logic_vector(ImageSize-1 downto 0);
        i_ImagevectorRow8  : in std_logic_vector(ImageSize-1 downto 0);
        i_ImagevectorRow9  : in std_logic_vector(ImageSize-1 downto 0);
        i_ImagevectorRow10 : in std_logic_vector(ImageSize-1 downto 0); -- The 11th row.
           
        o_PatchLiterals    : out std_logic_vector(2*FSize-1 downto 0)
        );   
                                
end GeneratePatches3;

architecture rtl of GeneratePatches3 is
---------------------------------------------------------------------------------------------
-- SIGNAL declarations: 
---------------------------------------------------------------------------------------------
    
    constant SWIDTH_Moving_Window: Integer := 20; 
    -- (=(28-10)/1 +1 = 18+1=19=Bx
    
    -- The states are one-hot encoded:
    constant MWstate0     : std_logic_vector(SWIDTH_Moving_Window-1 downto 0)   := "00000000000000000001";
    constant MWstate1     : std_logic_vector(SWIDTH_Moving_Window-1 downto 0)   := "00000000000000000010";
    constant MWstate2     : std_logic_vector(SWIDTH_Moving_Window-1 downto 0)   := "00000000000000000100";
    constant MWstate3     : std_logic_vector(SWIDTH_Moving_Window-1 downto 0)   := "00000000000000001000";
    constant MWstate4     : std_logic_vector(SWIDTH_Moving_Window-1 downto 0)   := "00000000000000010000";
    constant MWstate5     : std_logic_vector(SWIDTH_Moving_Window-1 downto 0)   := "00000000000000100000";
    constant MWstate6     : std_logic_vector(SWIDTH_Moving_Window-1 downto 0)   := "00000000000001000000";
    constant MWstate7     : std_logic_vector(SWIDTH_Moving_Window-1 downto 0)   := "00000000000010000000";
    constant MWstate8     : std_logic_vector(SWIDTH_Moving_Window-1 downto 0)   := "00000000000100000000";
    constant MWstate9     : std_logic_vector(SWIDTH_Moving_Window-1 downto 0)   := "00000000001000000000";
    constant MWstate10    : std_logic_vector(SWIDTH_Moving_Window-1 downto 0)   := "00000000010000000000";
    constant MWstate11    : std_logic_vector(SWIDTH_Moving_Window-1 downto 0)   := "00000000100000000000";
    constant MWstate12    : std_logic_vector(SWIDTH_Moving_Window-1 downto 0)   := "00000001000000000000";
    constant MWstate13    : std_logic_vector(SWIDTH_Moving_Window-1 downto 0)   := "00000010000000000000";
    constant MWstate14    : std_logic_vector(SWIDTH_Moving_Window-1 downto 0)   := "00000100000000000000";
    constant MWstate15    : std_logic_vector(SWIDTH_Moving_Window-1 downto 0)   := "00001000000000000000";
    constant MWstate16    : std_logic_vector(SWIDTH_Moving_Window-1 downto 0)   := "00010000000000000000";
    constant MWstate17    : std_logic_vector(SWIDTH_Moving_Window-1 downto 0)   := "00100000000000000000";
    constant MWstate18    : std_logic_vector(SWIDTH_Moving_Window-1 downto 0)   := "01000000000000000000";
    constant MWstate19    : std_logic_vector(SWIDTH_Moving_Window-1 downto 0)   := "10000000000000000000";
     
    signal w_PositionX : std_logic_vector(Bx-2 downto 0);
    signal w_PositionY : std_logic_vector(By-2 downto 0);
     
    signal w_BxCounterValue : unsigned(4 downto 0);
    signal w_ByCounterValue : unsigned(4 downto 0);
    
    -- This reflects a 10x10 window, i.e. we use 10 rows.
    signal w_rownextstate0, w_rowcurrentstate0, w_nextR0 : std_logic_vector(ImageSize-1 downto 0); 
    signal w_rownextstate1, w_rowcurrentstate1, w_nextR1 : std_logic_vector(ImageSize-1 downto 0); 
    signal w_rownextstate2, w_rowcurrentstate2, w_nextR2 : std_logic_vector(ImageSize-1 downto 0);  
    signal w_rownextstate3, w_rowcurrentstate3, w_nextR3 : std_logic_vector(ImageSize-1 downto 0); 
    signal w_rownextstate4, w_rowcurrentstate4, w_nextR4 : std_logic_vector(ImageSize-1 downto 0);  
    signal w_rownextstate5, w_rowcurrentstate5, w_nextR5 : std_logic_vector(ImageSize-1 downto 0); 
    signal w_rownextstate6, w_rowcurrentstate6, w_nextR6 : std_logic_vector(ImageSize-1 downto 0);  
    signal w_rownextstate7, w_rowcurrentstate7, w_nextR7 : std_logic_vector(ImageSize-1 downto 0); 
    signal w_rownextstate8, w_rowcurrentstate8, w_nextR8 : std_logic_vector(ImageSize-1 downto 0); 
    signal w_rownextstate9, w_rowcurrentstate9, w_nextR9 : std_logic_vector(ImageSize-1 downto 0); 

    -- A new row from the image sample is loaded into the lowest row (no.9) when one horizontal traversal has been completed. 

    signal w_WindowPatchFeatures : std_logic_vector(WSize*WSize-1 downto 0); 
    
    signal w_nxtPatchReg : std_logic_vector(FSize-1 downto 0); 
    signal w_PatchReg    : std_logic_vector(FSize-1 downto 0);  
    
    
        --For the "FSMWindow":
    signal w_nextMW_FSMstate, w_currentMW_FSMstate, w_nextQ :  std_logic_vector(SWIDTH_Moving_Window-1 downto 0); 
    
    signal w_en_ROW : std_logic;     

begin
   
         w_BxCounterValue <=unsigned(i_BxCounterValue);
         w_ByCounterValue <=unsigned(i_ByCounterValue);
          
--------------------------------------------------------------------              
         w_en_ROW <= i_en or i_rst;
----------------------------------------------------------------------------------------
         ROW0: vDFF generic map(ImageSize) port map(i_clk, w_rownextstate0, w_rowcurrentstate0);        
         ROW1: vDFF generic map(ImageSize) port map(i_clk, w_rownextstate1, w_rowcurrentstate1);          
         ROW2: vDFF generic map(ImageSize) port map(i_clk, w_rownextstate2, w_rowcurrentstate2);  
         ROW3: vDFF generic map(ImageSize) port map(i_clk, w_rownextstate3, w_rowcurrentstate3);    
         ROW4: vDFF generic map(ImageSize) port map(i_clk, w_rownextstate4, w_rowcurrentstate4); 
         ROW5: vDFF generic map(ImageSize) port map(i_clk, w_rownextstate5, w_rowcurrentstate5); 
         ROW6: vDFF generic map(ImageSize) port map(i_clk, w_rownextstate6, w_rowcurrentstate6); 
         ROW7: vDFF generic map(ImageSize) port map(i_clk, w_rownextstate7, w_rowcurrentstate7); 
         ROW8: vDFF generic map(ImageSize) port map(i_clk, w_rownextstate8, w_rowcurrentstate8); 
         ROW9: vDFF generic map(ImageSize) port map(i_clk, w_rownextstate9, w_rowcurrentstate9);   
    
         w_rownextstate0 <= (others => '0') when i_rst='1' else w_nextR0;
         w_rownextstate1 <= (others => '0') when i_rst='1' else w_nextR1;
         w_rownextstate2 <= (others => '0') when i_rst='1' else w_nextR2;
         w_rownextstate3 <= (others => '0') when i_rst='1' else w_nextR3;
         w_rownextstate4 <= (others => '0') when i_rst='1' else w_nextR4;
         w_rownextstate5 <= (others => '0') when i_rst='1' else w_nextR5;
         w_rownextstate6 <= (others => '0') when i_rst='1' else w_nextR6;
         w_rownextstate7 <= (others => '0') when i_rst='1' else w_nextR7;
         w_rownextstate8 <= (others => '0') when i_rst='1' else w_nextR8;
         w_rownextstate9 <= (others => '0') when i_rst='1' else w_nextR9;
         
         w_nextR0 <=   i_ImagevectorRow0 when (i_LoadNewSample='1' and w_en_ROW='1') else
                       w_rowcurrentstate1 when (i_LoadNewRow='1' and w_en_ROW='1') else
                       w_rowcurrentstate0;
                                   
         w_nextR1 <=   i_ImagevectorRow1 when (i_LoadNewSample='1' and w_en_ROW='1') else 
                       w_rowcurrentstate2 when (i_LoadNewRow='1' and w_en_ROW='1') else
                       w_rowcurrentstate1;
         
         w_nextR2 <=   i_ImagevectorRow2 when (i_LoadNewSample='1' and w_en_ROW='1') else 
                       w_rowcurrentstate3 when (i_LoadNewRow='1' and w_en_ROW='1') else
                       w_rowcurrentstate2;
                       
         w_nextR3 <=   i_ImagevectorRow3 when (i_LoadNewSample='1' and w_en_ROW='1') else 
                       w_rowcurrentstate4 when (i_LoadNewRow='1' and w_en_ROW='1') else
                       w_rowcurrentstate3;
                       
         w_nextR4 <=   i_ImagevectorRow4 when (i_LoadNewSample='1' and w_en_ROW='1') else
                       w_rowcurrentstate5 when (i_LoadNewRow='1' and w_en_ROW='1') else
                       w_rowcurrentstate4;
                                   
         w_nextR5 <=   i_ImagevectorRow5 when (i_LoadNewSample='1' and w_en_ROW='1') else 
                       w_rowcurrentstate6 when (i_LoadNewRow='1' and w_en_ROW='1') else
                       w_rowcurrentstate5;
         
         w_nextR6 <=   i_ImagevectorRow6 when (i_LoadNewSample='1' and w_en_ROW='1') else 
                       w_rowcurrentstate7 when (i_LoadNewRow='1' and w_en_ROW='1') else
                       w_rowcurrentstate6;
                       
         w_nextR7 <=   i_ImagevectorRow7 when (i_LoadNewSample='1' and w_en_ROW='1') else 
                       w_rowcurrentstate8 when (i_LoadNewRow='1' and w_en_ROW='1') else
                       w_rowcurrentstate7;
                       
         w_nextR8 <=   i_ImagevectorRow8 when (i_LoadNewSample='1' and w_en_ROW='1') else 
                       w_rowcurrentstate9 when (i_LoadNewRow='1' and w_en_ROW='1') else
                       w_rowcurrentstate8;
                       
         w_nextR9 <=   i_ImagevectorRow9 when (i_LoadNewSample='1' and w_en_ROW='1') else 
                       i_ImagevectorRow10 when (i_LoadNewRow='1' and w_en_ROW='1') else
                       w_rowcurrentstate9; -- This signal is the 11th row.
                                           -- New rows should just be loaded continuously "up" from dataram, into ROW9.       

-------------------------------------------------------------------------------------------------------
           -- Thermometer encoding of the X-psition of the patch
           
           with i_BxCounterValue select
               w_PositionX <= "000000000000000000" when "00000", 
                              "100000000000000000" when "00001", 
                              "110000000000000000" when "00010", 
                              "111000000000000000" when "00011", 
                              "111100000000000000" when "00100", 
                              "111110000000000000" when "00101", 
                              "111111000000000000" when "00110", 
                              "111111100000000000" when "00111", 
                              "111111110000000000" when "01000", 
                              "111111111000000000" when "01001", 
                              "111111111100000000" when "01010", 
                              "111111111110000000" when "01011", 
                              "111111111111000000" when "01100", 
                              "111111111111100000" when "01101", 
                              "111111111111110000" when "01110", 
                              "111111111111111000" when "01111", 
                              "111111111111111100" when "10000", 
                              "111111111111111110" when "10001", 
                              "111111111111111111" when "10010", 
                              "000000000000000000" when others;
            
             -- Thermometer encoding of the Y-psition of the patch
             with i_ByCounterValue select
               w_PositionY <= "000000000000000000" when "00000", 
                              "100000000000000000" when "00001", 
                              "110000000000000000" when "00010", 
                              "111000000000000000" when "00011", 
                              "111100000000000000" when "00100", 
                              "111110000000000000" when "00101", 
                              "111111000000000000" when "00110", 
                              "111111100000000000" when "00111", 
                              "111111110000000000" when "01000", 
                              "111111111000000000" when "01001", 
                              "111111111100000000" when "01010", 
                              "111111111110000000" when "01011", 
                              "111111111111000000" when "01100", 
                              "111111111111100000" when "01101", 
                              "111111111111110000" when "01110", 
                              "111111111111111000" when "01111", 
                              "111111111111111100" when "10000", 
                              "111111111111111110" when "10001", 
                              "111111111111111111" when "10010", 
                              "000000000000000000" when others;

      -----------------------------------------------------------------------------------------------------------
      -- The FSM for the "Sliding Window" function:
              
         w_nextMW_FSMstate  <= MWstate0 when (i_rst='1' or i_start='0') else w_nextQ;  
         
         FSMWindow: vDFF generic map(SWIDTH_Moving_Window) port map(i_clk, w_nextMW_FSMstate, w_currentMW_FSMstate);
         
         process(
                   w_currentMW_FSMstate, 
                   i_en, 
                   w_BxCounterValue 
                    )  
                   begin        
            
              case w_currentMW_FSMstate is
                
                when MWstate0 =>         
                              IF i_en='0' THEN w_nextQ <= MWstate0;
                                        ELSE w_nextQ <= MWstate1;
                              END IF;
                
                when MWstate1 =>                 
                            IF to_integer(w_BxCounterValue)=Bx-1 THEN w_nextQ <= MWstate2;
                                ELSE w_nextQ <= MWstate1;
                            END IF;
                            
                when MWstate2 =>                     
                            IF to_integer(w_BxCounterValue)=Bx-1 THEN w_nextQ <= MWstate3;
                                ELSE w_nextQ <= MWstate2;                      
                            END IF;
                
                when MWstate3 =>           
                            IF to_integer(w_BxCounterValue)=Bx-1 THEN w_nextQ <= MWstate4;
                                ELSE w_nextQ <= MWstate3;
                            END IF; 
                            
                when MWstate4 =>
                            IF to_integer(w_BxCounterValue)=Bx-1 THEN w_nextQ <= MWstate5;
                                ELSE w_nextQ <= MWstate4;
                            END IF;    
                            
               when MWstate5 =>
                            IF to_integer(w_BxCounterValue)=Bx-1 THEN w_nextQ <= MWstate6;
                                ELSE w_nextQ <= MWstate5;
                            END IF;
                            
                when MWstate6 =>
                            IF to_integer(w_BxCounterValue)=Bx-1 THEN w_nextQ <= MWstate7;
                                ELSE w_nextQ <= MWstate6;
                            END IF;
                
                when MWstate7 =>
                            IF to_integer(w_BxCounterValue)=Bx-1 THEN w_nextQ <= MWstate8;
                                ELSE w_nextQ <= MWstate7;
                            END IF; 
                            
                when MWstate8 =>
                            IF to_integer(w_BxCounterValue)=Bx-1 THEN w_nextQ <= MWstate9;
                                ELSE w_nextQ <= MWstate8;
                            END IF;
                            
                when MWstate9 =>
                            IF to_integer(w_BxCounterValue)=Bx-1 THEN w_nextQ <= MWstate10;
                                ELSE w_nextQ <= MWstate9;
                            END IF;
                
                when MWstate10 =>
                            IF to_integer(w_BxCounterValue)=Bx-1 THEN w_nextQ <= MWstate11;
                                ELSE w_nextQ <= MWstate10;
                            END IF; 
                            
                when MWstate11 =>
                            IF to_integer(w_BxCounterValue)=Bx-1 THEN w_nextQ <= MWstate12;
                                ELSE w_nextQ <= MWstate11;
                            END IF;    
                            
               when MWstate12 =>
                            IF to_integer(w_BxCounterValue)=Bx-1 THEN w_nextQ <= MWstate13;
                                ELSE w_nextQ <= MWstate12;
                            END IF;
                            
                when MWstate13 =>
                            IF to_integer(w_BxCounterValue)=Bx-1 THEN w_nextQ <= MWstate14;
                                ELSE w_nextQ <= MWstate13;
                            END IF;
                
                when MWstate14 =>
                            IF to_integer(w_BxCounterValue)=Bx-1 THEN w_nextQ <= MWstate15;
                                ELSE w_nextQ <= MWstate14;
                            END IF; 
                            
                when MWstate15 =>
                            IF to_integer(w_BxCounterValue)=Bx-1 THEN w_nextQ <= MWstate16;
                                ELSE w_nextQ <= MWstate15;
                            END IF;
                            
                when MWstate16 =>
                            IF to_integer(w_BxCounterValue)=Bx-1 THEN w_nextQ <= MWstate17;
                                ELSE w_nextQ <= MWstate16;
                            END IF;
                            
                when MWstate17 =>
                            IF to_integer(w_BxCounterValue)=Bx-1 THEN w_nextQ <= MWstate18;
                                ELSE w_nextQ <= MWstate17;
                            END IF;
                
                when MWstate18 =>
                                IF to_integer(w_BxCounterValue)=Bx-1 THEN w_nextQ <= MWstate19;
                                      ELSE w_nextQ <= MWstate18;
                                END IF; 
                            
                when MWstate19 =>  
                            IF to_integer(w_BxCounterValue)=Bx-1 THEN w_nextQ <= MWstate1; -- Note: Special: Return and start next row.
                                                                 ELSE w_nextQ <= MWstate19;
                            END IF;    

               when others =>    w_nextQ <= MWstate0;
    
            end case;             
        end process;
        
        
        with i_BxCounterValue select
        
                w_WindowPatchFeatures <=
                            
                              (w_rowcurrentstate0(9 downto 0) 
                            & w_rowcurrentstate1(9 downto 0)
                            & w_rowcurrentstate2(9 downto 0)
                            & w_rowcurrentstate3(9 downto 0)
                            & w_rowcurrentstate4(9 downto 0)
                            & w_rowcurrentstate5(9 downto 0)
                            & w_rowcurrentstate6(9 downto 0)
                            & w_rowcurrentstate7(9 downto 0)
                            & w_rowcurrentstate8(9 downto 0)
                            & w_rowcurrentstate9(9 downto 0)) when "10010",                            
                            
                              (w_rowcurrentstate0(10 downto 1) 
                            & w_rowcurrentstate1(10 downto 1)
                            & w_rowcurrentstate2(10 downto 1)
                            & w_rowcurrentstate3(10 downto 1)
                            & w_rowcurrentstate4(10 downto 1)
                            & w_rowcurrentstate5(10 downto 1)
                            & w_rowcurrentstate6(10 downto 1)
                            & w_rowcurrentstate7(10 downto 1)
                            & w_rowcurrentstate8(10 downto 1)
                            & w_rowcurrentstate9(10 downto 1)) when "10001",
                            
                              (w_rowcurrentstate0(11 downto 2) 
                            & w_rowcurrentstate1(11 downto 2)
                            & w_rowcurrentstate2(11 downto 2)
                            & w_rowcurrentstate3(11 downto 2)
                            & w_rowcurrentstate4(11 downto 2)
                            & w_rowcurrentstate5(11 downto 2)
                            & w_rowcurrentstate6(11 downto 2)
                            & w_rowcurrentstate7(11 downto 2)
                            & w_rowcurrentstate8(11 downto 2)
                            & w_rowcurrentstate9(11 downto 2)) when "10000",
                            
                              (w_rowcurrentstate0(12 downto 3) 
                            & w_rowcurrentstate1(12 downto 3)
                            & w_rowcurrentstate2(12 downto 3)
                            & w_rowcurrentstate3(12 downto 3)
                            & w_rowcurrentstate4(12 downto 3)
                            & w_rowcurrentstate5(12 downto 3)
                            & w_rowcurrentstate6(12 downto 3)
                            & w_rowcurrentstate7(12 downto 3)
                            & w_rowcurrentstate8(12 downto 3)
                            & w_rowcurrentstate9(12 downto 3)) when "01111",
                            
                              (w_rowcurrentstate0(13 downto 4) 
                            & w_rowcurrentstate1(13 downto 4)
                            & w_rowcurrentstate2(13 downto 4)
                            & w_rowcurrentstate3(13 downto 4)
                            & w_rowcurrentstate4(13 downto 4)
                            & w_rowcurrentstate5(13 downto 4)
                            & w_rowcurrentstate6(13 downto 4)
                            & w_rowcurrentstate7(13 downto 4)
                            & w_rowcurrentstate8(13 downto 4)
                            & w_rowcurrentstate9(13 downto 4)) when "01110",

                              (w_rowcurrentstate0(14 downto 5) 
                            & w_rowcurrentstate1(14 downto 5)
                            & w_rowcurrentstate2(14 downto 5)
                            & w_rowcurrentstate3(14 downto 5)
                            & w_rowcurrentstate4(14 downto 5)
                            & w_rowcurrentstate5(14 downto 5)
                            & w_rowcurrentstate6(14 downto 5)
                            & w_rowcurrentstate7(14 downto 5)
                            & w_rowcurrentstate8(14 downto 5)
                            & w_rowcurrentstate9(14 downto 5)) when "01101",
                            
                              (w_rowcurrentstate0(15 downto 6) 
                            & w_rowcurrentstate1(15 downto 6)
                            & w_rowcurrentstate2(15 downto 6)
                            & w_rowcurrentstate3(15 downto 6)
                            & w_rowcurrentstate4(15 downto 6)
                            & w_rowcurrentstate5(15 downto 6)
                            & w_rowcurrentstate6(15 downto 6)
                            & w_rowcurrentstate7(15 downto 6)
                            & w_rowcurrentstate8(15 downto 6)
                            & w_rowcurrentstate9(15 downto 6)) when "01100",
                            
                              (w_rowcurrentstate0(16 downto 7) 
                            & w_rowcurrentstate1(16 downto 7)
                            & w_rowcurrentstate2(16 downto 7)
                            & w_rowcurrentstate3(16 downto 7)
                            & w_rowcurrentstate4(16 downto 7)
                            & w_rowcurrentstate5(16 downto 7)
                            & w_rowcurrentstate6(16 downto 7)
                            & w_rowcurrentstate7(16 downto 7)
                            & w_rowcurrentstate8(16 downto 7)
                            & w_rowcurrentstate9(16 downto 7)) when "01011",
                            
                              (w_rowcurrentstate0(17 downto 8) 
                            & w_rowcurrentstate1(17 downto 8)
                            & w_rowcurrentstate2(17 downto 8)
                            & w_rowcurrentstate3(17 downto 8)
                            & w_rowcurrentstate4(17 downto 8)
                            & w_rowcurrentstate5(17 downto 8)
                            & w_rowcurrentstate6(17 downto 8)
                            & w_rowcurrentstate7(17 downto 8)
                            & w_rowcurrentstate8(17 downto 8)
                            & w_rowcurrentstate9(17 downto 8)) when "01010",
                            
                              (w_rowcurrentstate0(18 downto 9) 
                            & w_rowcurrentstate1(18 downto 9)
                            & w_rowcurrentstate2(18 downto 9)
                            & w_rowcurrentstate3(18 downto 9)
                            & w_rowcurrentstate4(18 downto 9)
                            & w_rowcurrentstate5(18 downto 9)
                            & w_rowcurrentstate6(18 downto 9)
                            & w_rowcurrentstate7(18 downto 9)
                            & w_rowcurrentstate8(18 downto 9)
                            & w_rowcurrentstate9(18 downto 9)) when "01001",
                            
                              (w_rowcurrentstate0(19 downto 10) 
                            & w_rowcurrentstate1(19 downto 10)
                            & w_rowcurrentstate2(19 downto 10)
                            & w_rowcurrentstate3(19 downto 10)
                            & w_rowcurrentstate4(19 downto 10)
                            & w_rowcurrentstate5(19 downto 10)
                            & w_rowcurrentstate6(19 downto 10)
                            & w_rowcurrentstate7(19 downto 10)
                            & w_rowcurrentstate8(19 downto 10)
                            & w_rowcurrentstate9(19 downto 10)) when "01000",
                            
                              (w_rowcurrentstate0(20 downto 11) 
                            & w_rowcurrentstate1(20 downto 11)
                            & w_rowcurrentstate2(20 downto 11)
                            & w_rowcurrentstate3(20 downto 11)
                            & w_rowcurrentstate4(20 downto 11)
                            & w_rowcurrentstate5(20 downto 11)
                            & w_rowcurrentstate6(20 downto 11)
                            & w_rowcurrentstate7(20 downto 11)
                            & w_rowcurrentstate8(20 downto 11)
                            & w_rowcurrentstate9(20 downto 11)) when "00111",
                            
                              (w_rowcurrentstate0(21 downto 12) 
                            & w_rowcurrentstate1(21 downto 12)
                            & w_rowcurrentstate2(21 downto 12)
                            & w_rowcurrentstate3(21 downto 12)
                            & w_rowcurrentstate4(21 downto 12)
                            & w_rowcurrentstate5(21 downto 12)
                            & w_rowcurrentstate6(21 downto 12)
                            & w_rowcurrentstate7(21 downto 12)
                            & w_rowcurrentstate8(21 downto 12)
                            & w_rowcurrentstate9(21 downto 12)) when "00110",
                            
                              (w_rowcurrentstate0(22 downto 13) 
                            & w_rowcurrentstate1(22 downto 13)
                            & w_rowcurrentstate2(22 downto 13)
                            & w_rowcurrentstate3(22 downto 13)
                            & w_rowcurrentstate4(22 downto 13)
                            & w_rowcurrentstate5(22 downto 13)
                            & w_rowcurrentstate6(22 downto 13)
                            & w_rowcurrentstate7(22 downto 13)
                            & w_rowcurrentstate8(22 downto 13)
                            & w_rowcurrentstate9(22 downto 13)) when "00101",
                            
                              (w_rowcurrentstate0(23 downto 14) 
                            & w_rowcurrentstate1(23 downto 14)
                            & w_rowcurrentstate2(23 downto 14)
                            & w_rowcurrentstate3(23 downto 14)
                            & w_rowcurrentstate4(23 downto 14)
                            & w_rowcurrentstate5(23 downto 14)
                            & w_rowcurrentstate6(23 downto 14)
                            & w_rowcurrentstate7(23 downto 14)
                            & w_rowcurrentstate8(23 downto 14)
                            & w_rowcurrentstate9(23 downto 14)) when "00100",
                            
                              (w_rowcurrentstate0(24 downto 15) 
                            & w_rowcurrentstate1(24 downto 15)
                            & w_rowcurrentstate2(24 downto 15)
                            & w_rowcurrentstate3(24 downto 15)
                            & w_rowcurrentstate4(24 downto 15)
                            & w_rowcurrentstate5(24 downto 15)
                            & w_rowcurrentstate6(24 downto 15)
                            & w_rowcurrentstate7(24 downto 15)
                            & w_rowcurrentstate8(24 downto 15)
                            & w_rowcurrentstate9(24 downto 15)) when "00011",
                            
                              (w_rowcurrentstate0(25 downto 16) 
                            & w_rowcurrentstate1(25 downto 16)
                            & w_rowcurrentstate2(25 downto 16)
                            & w_rowcurrentstate3(25 downto 16)
                            & w_rowcurrentstate4(25 downto 16)
                            & w_rowcurrentstate5(25 downto 16)
                            & w_rowcurrentstate6(25 downto 16)
                            & w_rowcurrentstate7(25 downto 16)
                            & w_rowcurrentstate8(25 downto 16)
                            & w_rowcurrentstate9(25 downto 16)) when "00010",
                            
                              (w_rowcurrentstate0(26 downto 17) 
                            & w_rowcurrentstate1(26 downto 17)
                            & w_rowcurrentstate2(26 downto 17)
                            & w_rowcurrentstate3(26 downto 17)
                            & w_rowcurrentstate4(26 downto 17)
                            & w_rowcurrentstate5(26 downto 17)
                            & w_rowcurrentstate6(26 downto 17)
                            & w_rowcurrentstate7(26 downto 17)
                            & w_rowcurrentstate8(26 downto 17)
                            & w_rowcurrentstate9(26 downto 17)) when "00001",
                            
                              (w_rowcurrentstate0(27 downto 18) 
                            & w_rowcurrentstate1(27 downto 18)
                            & w_rowcurrentstate2(27 downto 18)
                            & w_rowcurrentstate3(27 downto 18)
                            & w_rowcurrentstate4(27 downto 18)
                            & w_rowcurrentstate5(27 downto 18)
                            & w_rowcurrentstate6(27 downto 18)
                            & w_rowcurrentstate7(27 downto 18)
                            & w_rowcurrentstate8(27 downto 18)
                            & w_rowcurrentstate9(27 downto 18)) when "00000",
                            
                              ("0000000000" 
                            & "0000000000" 
                            & "0000000000" 
                            & "0000000000" 
                            & "0000000000" 
                            & "0000000000" 
                            & "0000000000" 
                            & "0000000000" 
                            & "0000000000" 
                            & "0000000000")  when others;
                            
      --------------------------------------------------------------------------                 
      w_nxtPatchReg <= w_PositionY & w_PositionX & w_WindowPatchFeatures;                  

      PATCHREG: vDFF generic map(FSize) port map(i_clk, w_nxtPatchReg, w_PatchReg);

      o_PatchLiterals <= w_PatchReg & not(w_PatchReg);
         
                                                       
end rtl;
