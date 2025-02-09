library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.numeric_std.all;

library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;
  
entity Model_input_buffer is      
    port (
        i_clk               : in std_logic; 
        i_rst               : in std_logic; 
        
        i_enable_inputregister : in std_logic;
        i_enablebyte_in_buffer : in std_logic_vector(ModelBytesPerClause-1 downto 0);       
        i_data               : in std_logic_vector(7 downto 0);         
        
        o_Model_IEbits       : out std_logic_vector(2*FSize-1 downto 0);
        o_ModelWeightClass0  : out std_logic_vector(7 downto 0); -- one byte per weight
        o_ModelWeightClass1  : out std_logic_vector(7 downto 0);
        o_ModelWeightClass2  : out std_logic_vector(7 downto 0);
        o_ModelWeightClass3  : out std_logic_vector(7 downto 0);
        o_ModelWeightClass4  : out std_logic_vector(7 downto 0);
        o_ModelWeightClass5  : out std_logic_vector(7 downto 0);
        o_ModelWeightClass6  : out std_logic_vector(7 downto 0);
        o_ModelWeightClass7  : out std_logic_vector(7 downto 0);
        o_ModelWeightClass8  : out std_logic_vector(7 downto 0);
        o_ModelWeightClass9  : out std_logic_vector(7 downto 0)
                                
        );   
                                
end Model_input_buffer;

architecture rtl of Model_input_buffer is  
    
    -- For each byte in the model buffer:
    type bufferarrayModel is array(0 to ModelBytesPerClause-1) of std_logic_vector(7 downto 0);
    signal w_next8                   : bufferarrayModel;
    signal w_current8                : bufferarrayModel;
    
    --Input register:
    signal w_current_inputreg1          : std_logic_vector(7 downto 0);
    
begin

-- Delay input data with one clock cycle:

        InputRegister1:  vDFF generic map(8) 
                                port map
                                    (
                                    clk     => i_clk, 
                                    D       => i_data, 
                                    Q       => w_current_inputreg1  
                                    );

-- 44 Bytes that contain the model data per clause:     
     MODELBUFFER: FOR j in 0 to ModelBytesPerClause-1 GENERATE  
 
        bufferModelByte:  vDFF generic map(8) 
                                port map
                                    (
                                    clk     => i_clk, 
                                    D       => w_next8(j), 
                                    Q       => w_current8(j)  
                                    );
          
         w_next8(j) <= (others => '0') when i_rst='1' 
                        else w_current_inputreg1 when i_enablebyte_in_buffer(j)='1' 
                        else w_current8(j);
            
      END GENERATE MODELBUFFER;
     
        o_Model_IEbits       <= w_current8(0) & w_current8(1) & w_current8(2) & w_current8(3) & w_current8(4) & w_current8(5) & 
                                w_current8(6) & w_current8(7) & w_current8(8) & w_current8(9) & w_current8(10) & w_current8(11) &
                                w_current8(12) & w_current8(13) & w_current8(14) & w_current8(15) & w_current8(16) & w_current8(17) &
                                w_current8(18) & w_current8(19) & w_current8(20) & w_current8(21) & w_current8(22) & w_current8(23) &
                                w_current8(24) & w_current8(25) & w_current8(26) & w_current8(27) & w_current8(28) & w_current8(29) &
                                w_current8(30) & w_current8(31) & w_current8(32) & w_current8(33); 

        
        o_ModelWeightClass0  <= w_current8(34); -- one byte per weight
        o_ModelWeightClass1  <= w_current8(35);
        o_ModelWeightClass2  <= w_current8(36);
        o_ModelWeightClass3  <= w_current8(37);
        o_ModelWeightClass4  <= w_current8(38);
        o_ModelWeightClass5  <= w_current8(39);
        o_ModelWeightClass6  <= w_current8(40);
        o_ModelWeightClass7  <= w_current8(41);
        o_ModelWeightClass8  <= w_current8(42);
        o_ModelWeightClass9  <= w_current8(43);
                
end rtl;             