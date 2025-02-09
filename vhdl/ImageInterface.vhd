library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.numeric_std.all; 

library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;
  
entity ImageInterface is      
    port (
         i_clk                  : in std_logic; 
         i_rst                  : in std_logic; -- active high
         i_en                   : in std_logic;
         i_en_cg                : in std_logic;
         
         -- Slave interface:
         i_data_valid           : in std_logic;
         i_image_data           : in std_logic_vector(7 downto 0);

         -- Other signals:         
         i_image_buffer_reset   : in std_logic; -- active high
         i_singlemode           : in std_logic;
         i_ByCounterValue       : in std_logic_vector(4 downto 0); 
         i_keepClassDecision    : in std_logic;
         
         --------------------------------  
         -- Output signals to PatchGenerator:               
         o_ImagevectorRow0   : out std_logic_vector(ImageSize-1 downto 0); 
         o_ImagevectorRow1   : out std_logic_vector(ImageSize-1 downto 0); 
         o_ImagevectorRow2   : out std_logic_vector(ImageSize-1 downto 0); 
         o_ImagevectorRow3   : out std_logic_vector(ImageSize-1 downto 0); 
         o_ImagevectorRow4   : out std_logic_vector(ImageSize-1 downto 0); 
         o_ImagevectorRow5   : out std_logic_vector(ImageSize-1 downto 0); 
         o_ImagevectorRow6   : out std_logic_vector(ImageSize-1 downto 0);  
         o_ImagevectorRow7   : out std_logic_vector(ImageSize-1 downto 0); 
         o_ImagevectorRow8   : out std_logic_vector(ImageSize-1 downto 0); 
         o_ImagevectorRow9   : out std_logic_vector(ImageSize-1 downto 0); 
        
         o_ImagevectorRow10  : out std_logic_vector(ImageSize-1 downto 0);  -- The 11th row. Controlled by i_ByCounterValue.
        
         o_ImageLabel        : out std_logic_vector(3 downto 0)   
        );    
                                
end ImageInterface;

--------------------------

architecture rtl2 of ImageInterface is 

    constant SWIDTH_IMAGEINT: Integer := 13; 

    constant IDLE               : std_logic_vector(SWIDTH_IMAGEINT-1 downto 0) := "0000000000001";
    constant IDLE2              : std_logic_vector(SWIDTH_IMAGEINT-1 downto 0) := "0000000000010";
    constant RD_DATA_INITIAL    : std_logic_vector(SWIDTH_IMAGEINT-1 downto 0) := "0000000000100";
    constant WAIT_INITIAL1      : std_logic_vector(SWIDTH_IMAGEINT-1 downto 0) := "0000000001000";
    constant WAIT_INITIAL2      : std_logic_vector(SWIDTH_IMAGEINT-1 downto 0) := "0000000010000";
    constant RD_DATA_B          : std_logic_vector(SWIDTH_IMAGEINT-1 downto 0) := "0000000100000";
    constant WAIT_B1            : std_logic_vector(SWIDTH_IMAGEINT-1 downto 0) := "0000001000000";
    constant WAIT_B2            : std_logic_vector(SWIDTH_IMAGEINT-1 downto 0) := "0000010000000";
    constant WAIT_B3            : std_logic_vector(SWIDTH_IMAGEINT-1 downto 0) := "0000100000000";
    constant RD_DATA_A          : std_logic_vector(SWIDTH_IMAGEINT-1 downto 0) := "0001000000000";
    constant WAIT_A1            : std_logic_vector(SWIDTH_IMAGEINT-1 downto 0) := "0010000000000";
    constant WAIT_A2            : std_logic_vector(SWIDTH_IMAGEINT-1 downto 0) := "0100000000000";
    constant WAIT_A3            : std_logic_vector(SWIDTH_IMAGEINT-1 downto 0) := "1000000000000";

--WAIT_INITIAL3

    signal w_rst : std_logic;

    signal w_ImagevectorRowA0       : std_logic_vector(ImageSize-1 downto 0);
    signal w_ImagevectorRowA1       : std_logic_vector(ImageSize-1 downto 0);
    signal w_ImagevectorRowA2       : std_logic_vector(ImageSize-1 downto 0);
    signal w_ImagevectorRowA3       : std_logic_vector(ImageSize-1 downto 0);
    signal w_ImagevectorRowA4       : std_logic_vector(ImageSize-1 downto 0);
    signal w_ImagevectorRowA5       : std_logic_vector(ImageSize-1 downto 0);
    signal w_ImagevectorRowA6       : std_logic_vector(ImageSize-1 downto 0);
    signal w_ImagevectorRowA7       : std_logic_vector(ImageSize-1 downto 0);
    signal w_ImagevectorRowA8       : std_logic_vector(ImageSize-1 downto 0);
    signal w_ImagevectorRowA9       : std_logic_vector(ImageSize-1 downto 0);
    signal w_ImagevectorRowA10      : std_logic_vector(ImageSize-1 downto 0);
    
    signal w_ImagevectorRowB0       : std_logic_vector(ImageSize-1 downto 0);
    signal w_ImagevectorRowB1       : std_logic_vector(ImageSize-1 downto 0);
    signal w_ImagevectorRowB2       : std_logic_vector(ImageSize-1 downto 0);
    signal w_ImagevectorRowB3       : std_logic_vector(ImageSize-1 downto 0);
    signal w_ImagevectorRowB4       : std_logic_vector(ImageSize-1 downto 0);
    signal w_ImagevectorRowB5       : std_logic_vector(ImageSize-1 downto 0);
    signal w_ImagevectorRowB6       : std_logic_vector(ImageSize-1 downto 0);
    signal w_ImagevectorRowB7       : std_logic_vector(ImageSize-1 downto 0);
    signal w_ImagevectorRowB8       : std_logic_vector(ImageSize-1 downto 0);
    signal w_ImagevectorRowB9       : std_logic_vector(ImageSize-1 downto 0);
    signal w_ImagevectorRowB10      : std_logic_vector(ImageSize-1 downto 0);
    
    signal w_ImageLabelA            : std_logic_vector(3 downto 0);
    signal w_ImageLabelB            : std_logic_vector(3 downto 0);
    
    signal w_imageBufferData_enwrite0 : std_logic;
    signal w_imageBufferData_enwrite1 : std_logic;
    signal w_mux_select               : std_logic;
    
    signal w_Kfinished              : std_logic;
    signal w_kregout                : std_logic_vector(6 downto 0);
    signal w_resetK                 : std_logic;
    
    type   kArray is array (0 to BytesPerImage-1) of std_logic_vector(6 downto 0);
    signal w_kAddr : kArray;
    
    signal w_next1                  : std_logic_vector(SWIDTH_IMAGEINT-1 downto 0);
    signal w_nextstate              : std_logic_vector(SWIDTH_IMAGEINT-1 downto 0);
    signal w_currentstate           : std_logic_vector(SWIDTH_IMAGEINT-1 downto 0);
    
    signal w_enablebyte_in_buffer0   : std_logic_vector(BytesPerImage-1 downto 0);
    signal w_enablebyte_in_buffer1   : std_logic_vector(BytesPerImage-1 downto 0);
    
    signal w_intr                    : std_logic;
    signal w_o_data_ready            : std_logic;
    
    signal w_reg1                    : std_logic_vector(7 downto 0);
    signal w_reg2                    : std_logic_vector(7 downto 0);
    signal w_valid                   : std_logic;
    signal w_enK                     : std_logic;
    
    signal w_buffer0_enable          : std_logic;
    signal w_buffer1_enable          : std_logic;

begin

     w_rst <=i_rst or i_image_buffer_reset;
     
     
     -- Delay Tvalid:
     DelayTValid : sDFF port map(i_clk, i_data_valid, w_valid);
     
     -- Delay input data with one clock cycles:
     InputReg1:  vDFF generic map(8) 
                    port map
                        (
                        clk     => i_clk, 
                        D       => i_image_data, 
                        Q       => w_reg1  
                        );
                        
    -- Delay input data with one clock cycles:
     InputReg2:  vDFF generic map(8) 
                    port map
                        (
                        clk     => i_clk, 
                        D       => w_reg1, 
                        Q       => w_reg2  
                        );

     ModuleImage0: entity lib_convcotm.ImageBuffer(rtl) 
        port map (
            i_clk               => i_clk, 
            i_rst               => w_rst,
            i_buffer_enable     => w_buffer0_enable, --w_imageBufferData_enwrite0,
            i_enable            => w_enablebyte_in_buffer0,
            i_ByCounterValue    => i_ByCounterValue, 
                 
            i_image_data        => w_reg2,

            o_ImagevectorRow0   => w_ImagevectorRowA0,
            o_ImagevectorRow1   => w_ImagevectorRowA1,
            o_ImagevectorRow2   => w_ImagevectorRowA2,
            o_ImagevectorRow3   => w_ImagevectorRowA3,
            o_ImagevectorRow4   => w_ImagevectorRowA4,
            o_ImagevectorRow5   => w_ImagevectorRowA5,
            o_ImagevectorRow6   => w_ImagevectorRowA6,
            o_ImagevectorRow7   => w_ImagevectorRowA7,
            o_ImagevectorRow8   => w_ImagevectorRowA8,
            o_ImagevectorRow9   => w_ImagevectorRowA9,
            
            o_ImagevectorRow10  => w_ImagevectorRowA10, -- The 11th row. Controlled by i_ByCounterValue.
            
            o_ImageLabel        => w_ImageLabelA
            );
            
    ModuleImage1: entity lib_convcotm.ImageBuffer(rtl) 
        port map (
            i_clk               => i_clk, 
            i_rst               => w_rst,
            i_buffer_enable     => w_buffer1_enable, --w_imageBufferData_enwrite1,
            i_enable            => w_enablebyte_in_buffer1,
            i_ByCounterValue    => i_ByCounterValue, 
                 
            i_image_data        => w_reg2,    
              
            o_ImagevectorRow0   => w_ImagevectorRowB0,
            o_ImagevectorRow1   => w_ImagevectorRowB1,
            o_ImagevectorRow2   => w_ImagevectorRowB2,
            o_ImagevectorRow3   => w_ImagevectorRowB3,
            o_ImagevectorRow4   => w_ImagevectorRowB4,
            o_ImagevectorRow5   => w_ImagevectorRowB5,
            o_ImagevectorRow6   => w_ImagevectorRowB6,
            o_ImagevectorRow7   => w_ImagevectorRowB7,
            o_ImagevectorRow8   => w_ImagevectorRowB8,
            o_ImagevectorRow9   => w_ImagevectorRowB9,
            
            o_ImagevectorRow10  => w_ImagevectorRowB10, -- The 11th row. Controlled by i_ByCounterValue.
            
            o_ImageLabel        => w_ImageLabelB
            );
 
    w_mux_select <=      '0' when i_singlemode='1'
                    else '0' when (w_currentstate=WAIT_INITIAL2
                    or w_currentstate=RD_DATA_B
                    or w_currentstate=WAIT_B1
                    or w_currentstate=WAIT_B2
                    or w_currentstate=WAIT_A3)
                    else '1';
    
    MUXImageData: entity lib_convcotm.MUX_imagedata(rtl) 
        port map (
            i_select             => w_mux_select, 
            
            i_ImagevectorRow0A   => w_ImagevectorRowA0,
            i_ImagevectorRow1A   => w_ImagevectorRowA1,
            i_ImagevectorRow2A   => w_ImagevectorRowA2,
            i_ImagevectorRow3A   => w_ImagevectorRowA3,
            i_ImagevectorRow4A   => w_ImagevectorRowA4, 
            i_ImagevectorRow5A   => w_ImagevectorRowA5, 
            i_ImagevectorRow6A   => w_ImagevectorRowA6,
            i_ImagevectorRow7A   => w_ImagevectorRowA7,
            i_ImagevectorRow8A   => w_ImagevectorRowA8,
            i_ImagevectorRow9A   => w_ImagevectorRowA9,
            i_ImagevectorRow10A  => w_ImagevectorRowA10,  -- The 11th row. 
            i_ImageLabelA        => w_ImageLabelA, 
                        
            i_ImagevectorRow0B   => w_ImagevectorRowB0,
            i_ImagevectorRow1B   => w_ImagevectorRowB1,
            i_ImagevectorRow2B   => w_ImagevectorRowB2,
            i_ImagevectorRow3B   => w_ImagevectorRowB3, 
            i_ImagevectorRow4B   => w_ImagevectorRowB4,
            i_ImagevectorRow5B   => w_ImagevectorRowB5,
            i_ImagevectorRow6B   => w_ImagevectorRowB6,
            i_ImagevectorRow7B   => w_ImagevectorRowB7,
            i_ImagevectorRow8B   => w_ImagevectorRowB8,
            i_ImagevectorRow9B   => w_ImagevectorRowB9,
            i_ImagevectorRow10B  => w_ImagevectorRowB10,  -- The 11th row. 
            i_ImageLabelB        => w_ImageLabelB,   
            
            o_ImagevectorRow0   => o_ImagevectorRow0, 
            o_ImagevectorRow1   => o_ImagevectorRow1, 
            o_ImagevectorRow2   => o_ImagevectorRow2, 
            o_ImagevectorRow3   => o_ImagevectorRow3, 
            o_ImagevectorRow4   => o_ImagevectorRow4, 
            o_ImagevectorRow5   => o_ImagevectorRow5, 
            o_ImagevectorRow6   => o_ImagevectorRow6, 
            o_ImagevectorRow7   => o_ImagevectorRow7, 
            o_ImagevectorRow8   => o_ImagevectorRow8, 
            o_ImagevectorRow9   => o_ImagevectorRow9, 
            o_ImagevectorRow10  => o_ImagevectorRow10,  -- The 11th row. Controlled by i_ByCounterValue.
            o_ImageLabel        => o_ImageLabel      
            );   
 
 
 -- FSM for image control:
    imageFSM: vDFF generic map(SWIDTH_IMAGEINT) port map(i_clk, w_nextstate, w_currentstate);
    
     w_nextstate <= IDLE when w_rst='1' else w_next1;  
   
      process(
              w_currentstate, 
              i_en, 
              w_Kfinished,
              w_valid,
              i_singlemode,
              i_keepClassDecision
              ) 
      begin
              
        case w_currentstate is
        
            when IDLE =>  
                    IF i_en='0' THEN
                        w_next1 <= IDLE;
                    ELSE w_next1<=IDLE2;
                    END IF;
            
            when IDLE2 =>  
                    IF w_valid='0' THEN
                        w_next1 <= IDLE2;
                    ELSE w_next1<=RD_DATA_INITIAL;
                    END IF;
                        
            when RD_DATA_INITIAL => 
                    IF w_Kfinished='1' THEN 
                        w_next1 <= WAIT_INITIAL1;
                    ELSE w_next1<=RD_DATA_INITIAL;
                    END IF;
            
            when WAIT_INITIAL1 => 
                    IF w_valid='0' and i_en='0' THEN
                        w_next1 <= WAIT_INITIAL2;
                    ELSE w_next1 <= WAIT_INITIAL1;
                    END IF;

             when WAIT_INITIAL2 => 
                    IF i_singlemode='1' THEN 
                        w_next1 <= IDLE;
                    ELSIF w_valid='1' THEN
                        w_next1 <= RD_DATA_B;    
                    ELSE w_next1 <= WAIT_INITIAL2;
                    END IF;
            
            -----
            when RD_DATA_B =>
                    IF w_Kfinished='1' THEN 
                        w_next1 <= WAIT_B1;
                    ELSE w_next1<=RD_DATA_B;
                    END IF;
             
             when WAIT_B1 => 
                    IF i_keepClassDecision='1' THEN
                        w_next1 <= WAIT_B2;
                    ELSE w_next1<=WAIT_B1;
                    END IF;
             
             when WAIT_B2 => 
                    IF w_valid='0' THEN 
                        w_next1 <= WAIT_B3;
                    ELSE w_next1<=WAIT_B2;
                    END IF;
                    
             when WAIT_B3 => 
                    IF w_valid='1' THEN
                        w_next1 <= RD_DATA_A;    
                    ELSE w_next1 <= WAIT_B3;
                    END IF;   
             
             -----       
             when RD_DATA_A =>
                    IF w_Kfinished='1' THEN 
                        w_next1 <= WAIT_A1;
                    ELSE w_next1<=RD_DATA_A;
                    END IF;
             
             when WAIT_A1 => 
                    IF i_keepClassDecision='1' THEN
                        w_next1 <= WAIT_A2;
                    ELSE w_next1<=WAIT_A1;
                    END IF;
             
             when WAIT_A2 => 
                    IF w_valid='0' THEN 
                        w_next1 <= WAIT_A3;
                    ELSE w_next1<=WAIT_A2;
                    END IF;
                    
             when WAIT_A3 => 
                    IF w_valid='1' THEN
                        w_next1 <= RD_DATA_B;    
                    ELSE w_next1 <= WAIT_A3;
                    END IF;   

            when others =>
                   w_next1 <= IDLE;
                    
           end case;             
    end process;                               
    
     w_resetK <= '1' when (w_currentstate=IDLE 
                     or w_currentstate=WAIT_INITIAL2 or w_currentstate=WAIT_B3 or w_currentstate=WAIT_A3)
                     else '0'; 
     
     w_enK <= '1' when (w_currentstate=RD_DATA_INITIAL or w_currentstate=RD_DATA_B or w_currentstate=RD_DATA_A)
                  else '0';
     
     COUNTIMAGEBYTES: entity work.ImageBytes_counter(rtl) 
        port map (
            i_clk               => i_clk, 
            i_rst               => w_resetK,
            i_en                => w_enK,
            o_k_counterFinished => w_Kfinished,
            o_k_value           => w_kregout
            );
    
        AY: FOR ja in 0 to BytesPerImage-1 GENERATE
                 w_Kaddr(ja) <= std_logic_vector(to_unsigned(ja, w_kAddr(ja)'length));   
                 w_enablebyte_in_buffer0(ja) <='1' when (w_kregout=w_Kaddr(ja) and w_imageBufferData_enwrite0='1') else '0'; 
                 w_enablebyte_in_buffer1(ja) <='1' when (w_kregout=w_Kaddr(ja) and w_imageBufferData_enwrite1='1') else '0';   
        end GENERATE AY; 


     w_imageBufferData_enwrite0 <= '1' when (w_currentstate=RD_DATA_INITIAL or w_currentstate=RD_DATA_A) 
                                    else '0';
                                    
     w_imageBufferData_enwrite1 <= '1' when (w_currentstate=RD_DATA_B) 
                                    else '0';
                                    
     w_buffer0_enable <= w_imageBufferData_enwrite0 or not(i_en_cg);
     w_buffer1_enable <= w_imageBufferData_enwrite1 or not(i_en_cg);
                                              
end rtl2;