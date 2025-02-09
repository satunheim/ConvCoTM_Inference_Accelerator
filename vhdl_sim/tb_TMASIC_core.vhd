library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_misc.all;

library lib_convcotm; 
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;
   
use std.textio.all;     
use IEEE.std_logic_textio.all; 

entity tb_TMASIC_core is
end tb_TMASIC_core;

architecture test of tb_TMASIC_core is

	component TMASIC_core  -- mixed verilog/VHDL simulations by xcelium (Cadence) requires the DUT described in VHDL to be defined by "component"
	   port(
           	  i_clks     : in std_logic;
		      i_clkl     : in std_logic;
            
              i_rst      : in std_logic;
		      i_rst_imbuf: in std_logic;
	          i_en_image : in std_logic;
	        
              i_start    : in std_logic;

	          i_load     : in std_logic;

		      i_single   : in std_logic;
		      i_test     : in std_logic;
		      i_en_cg    : in std_logic;

              i_data_valid : in std_logic; 
              i_data     : in std_logic_vector(7 downto 0); 
             
                -- Interrupts and label/prediction:
              o_intrs    : out std_logic; 
	          o_intrl    : out std_logic; 
              o_result   : out std_logic_vector(7 downto 0) 
		   );		
	end component;

    -- INPUTS:
    signal axi_clk              : std_logic;
    signal clk_asicS            : std_logic;
    signal clk_asicL            : std_logic;

    signal w_reset              : std_logic;
    signal w_reset_imbuf        : std_logic;
    signal w_en_image           : std_logic;
    signal w_start              : std_logic;
    
    signal w_load               : std_logic;
    
    signal w_singlemode         : std_logic;
    signal w_test               : std_logic;
    signal w_en_cg              : std_logic;
    
    signal w_i_data_valid       : std_logic;
    signal w_i_data             : std_logic_vector(7 downto 0); 
           
    -- Interrupts:
    signal w_intrL               : std_logic; 
    signal w_intrS               : std_logic; 
    
    -- OUTPUTS:
    signal w_result             : std_logic_vector(7 downto 0);
    
    -- Housekeeping:
    signal samplecount          : integer;
    signal errors               : integer;
    signal noTestSamples        : integer;    
    signal w_repeated_test      : std_logic;

    signal w_mode_load		    : std_logic;
    signal w_mode_inference     : std_logic;

    --------------------------------------------------------------------------------------------------------------    

begin
           
    DUT: TMASIC_core    
        port map(
            i_clkS                   => clk_asicS, 
            i_clkL                   => clk_asicL, 
            
            i_rst                    => w_reset,
            i_rst_imbuf              => w_reset_imbuf,
            i_en_image               => w_en_image,
            i_start                  => w_start,
        
            i_load                   => w_load,
        
            i_single                 => w_singlemode,
            i_test                   => w_test,
            i_en_cg                  => w_en_cg,
    
                 
            -- Slave interface:
            i_data_valid             => w_i_data_valid,
            
            i_data                   => w_i_data,
            
            -- Outputs:
            o_intrS                  => w_intrS,
            o_intrL                  => w_intrL,
            o_result                 => w_result
        );
        
    noTestSamples  <= 10000;
    
    process begin
        axi_clk <= '0'; wait for 100 ns;
        axi_clk <= '1'; wait for 100 ns;
    end process;

    clk_asicS <= axi_clk and w_mode_inference;
    clk_asicL <= axi_clk and w_mode_load;
    
-------------------------------------------------------
    process
          
          --MNIST images : test dataset (10k samples)
          file text_file2 : text open read_mode is "C:\Users\satun\OneDrive\Dokumenter\TMASIC4\MNIST_data\MNIST_test_10ksamples.txt";
          variable text_line2 : line;
          variable var_imagedata2 : std_logic_vector(7 downto 0);
          
          -- Model files: Includes/Excludes + 10 sets of weights (one per class)
          file modelfile_ie : text open read_mode is "C:\Users\satun\OneDrive\Dokumenter\TMASIC4\model_128_MNIST\ie.txt";
          variable line_ie : line;
          variable var_ie : std_logic_vector(7 downto 0);
          
          file modelfile_wclass0 : text open read_mode is "C:\Users\satun\OneDrive\Dokumenter\TMASIC4\model_128_MNIST\wclass0.txt";
          variable line_wclass0  : line;
          variable var_wclass0   : std_logic_vector(7 downto 0);
          
          file modelfile_wclass1 : text open read_mode is "C:\Users\satun\OneDrive\Dokumenter\TMASIC4\model_128_MNIST\wclass1.txt";
          variable line_wclass1  : line;
          variable var_wclass1   : std_logic_vector(7 downto 0);
          
          file modelfile_wclass2 : text open read_mode is "C:\Users\satun\OneDrive\Dokumenter\TMASIC4\model_128_MNIST\wclass2.txt";
          variable line_wclass2  : line;
          variable var_wclass2   : std_logic_vector(7 downto 0);
          
          file modelfile_wclass3 : text open read_mode is "C:\Users\satun\OneDrive\Dokumenter\TMASIC4\model_128_MNIST\wclass3.txt";
          variable line_wclass3  : line;
          variable var_wclass3   : std_logic_vector(7 downto 0);
          
          file modelfile_wclass4 : text open read_mode is "C:\Users\satun\OneDrive\Dokumenter\TMASIC4\model_128_MNIST\wclass4.txt";
          variable line_wclass4  : line;
          variable var_wclass4   : std_logic_vector(7 downto 0);
          
          file modelfile_wclass5 : text open read_mode is "C:\Users\satun\OneDrive\Dokumenter\TMASIC4\model_128_MNIST\wclass5.txt";
          variable line_wclass5  : line;
          variable var_wclass5   : std_logic_vector(7 downto 0);
          
          file modelfile_wclass6 : text open read_mode is "C:\Users\satun\OneDrive\Dokumenter\TMASIC4\model_128_MNIST\wclass6.txt";
          variable line_wclass6  : line;
          variable var_wclass6   : std_logic_vector(7 downto 0);
          
          file modelfile_wclass7 : text open read_mode is "C:\Users\satun\OneDrive\Dokumenter\TMASIC4\model_128_MNIST\wclass7.txt";
          variable line_wclass7  : line;
          variable var_wclass7   : std_logic_vector(7 downto 0);
          
          file modelfile_wclass8 : text open read_mode is "C:\Users\satun\OneDrive\Dokumenter\TMASIC4\model_128_MNIST\wclass8.txt";
          variable line_wclass8  : line;
          variable var_wclass8   : std_logic_vector(7 downto 0);
          
          file modelfile_wclass9 : text open read_mode is "C:\Users\satun\OneDrive\Dokumenter\TMASIC4\model_128_MNIST\wclass9.txt";
          variable line_wclass9  : line;
          variable var_wclass9   : std_logic_vector(7 downto 0);
  
    begin

        samplecount <= 0;
        errors <= 0;  
        w_singlemode <= '1';
        w_repeated_test <='0';

	    w_mode_load <='1';
	    w_mode_inference <='1';
            
            --------------------------------------------------------------------
            
        w_load <='0';
        w_start <='0'; 
        w_test <= '1';
        w_en_cg <= '1';
        w_en_image <='0';
        
        -----------------------------------------------------------------------
        
        w_i_data_valid <='0';
        w_i_data <= ( others => '0' );

        w_reset_imbuf <='0'; -- active high
        w_reset <='0'; -- active high
        
        wait until rising_edge(axi_clk);
        wait for 70ns;
        w_reset_imbuf <='1'; -- active high
        w_reset <='1'; -- active high

        for a in 0 to 20 loop
            wait until rising_edge(axi_clk);
        end loop;
        
        wait for 70 ns;
        w_reset <='0';
        wait for 170 ns;
        w_reset_imbuf <='0';
        
       for a in 0 to 20 loop
            wait until rising_edge(axi_clk);
       end loop;

       --------------------------------------------------------
       -- LOAD model
       wait for 2037 ns;
       wait until rising_edge(axi_clk);
       wait for 13 ns;
       w_load <='1';
       wait until rising_edge(axi_clk); 

       wait for 1322 ns; 
       w_i_data_valid <='1'; 
           
           
           for i in 0 to NClauses-1 loop
           
               -- Read 34 bytes of includes/excludes - per clause
               for a in 0 to 33 loop
                   readline(modelfile_ie, line_ie);
                   read(line_ie, var_ie);  
                   wait for 1 ns;
                   w_i_data <= var_ie;  
                   wait until rising_edge(axi_clk);   
               end loop;
               
               -- Read the weights - from different files - per clause:
               
               readline(modelfile_wclass0, line_wclass0);
               read(line_wclass0, var_wclass0);  
               wait for 1 ns;
               w_i_data <= var_wclass0; 
               wait until rising_edge(axi_clk);
           
               readline(modelfile_wclass1, line_wclass1);
               read(line_wclass1, var_wclass1);  
               wait for 1 ns;
               w_i_data <= var_wclass1;  
               wait until rising_edge(axi_clk);
                          
               readline(modelfile_wclass2, line_wclass2);
               read(line_wclass2, var_wclass2);  
               wait for 1 ns;
               w_i_data <= var_wclass2; 
               wait until rising_edge(axi_clk);           
           
               readline(modelfile_wclass3, line_wclass3);
               read(line_wclass3, var_wclass3);  
               wait for 1 ns;
               w_i_data <= var_wclass3; 
               wait until rising_edge(axi_clk);
           
               readline(modelfile_wclass4, line_wclass4);
               read(line_wclass4, var_wclass4);  
               wait for 1 ns;
               w_i_data <= var_wclass4;  
               wait until rising_edge(axi_clk);

               readline(modelfile_wclass5, line_wclass5);
               read(line_wclass5, var_wclass5);  
               wait for 1 ns;
               w_i_data <= var_wclass5; 
               wait until rising_edge(axi_clk); 

               readline(modelfile_wclass6, line_wclass6);
               read(line_wclass6, var_wclass6);  
               wait for 1 ns;
               w_i_data <= var_wclass6; 
               wait until rising_edge(axi_clk);

               readline(modelfile_wclass7, line_wclass7);
               read(line_wclass7, var_wclass7);  
               wait for 1 ns;
               w_i_data <= var_wclass7; 
               wait until rising_edge(axi_clk); 

               readline(modelfile_wclass8, line_wclass8);
               read(line_wclass8, var_wclass8);  
               wait for 1 ns;
               w_i_data <= var_wclass8; 
               wait until rising_edge(axi_clk);

               readline(modelfile_wclass9, line_wclass9);
               read(line_wclass9, var_wclass9);  
               wait for 1 ns;
               w_i_data <= var_wclass9; 
               wait until rising_edge(axi_clk);  
                        
           end loop;  
           
       wait for 17 ns;
       w_i_data_valid <='0';
       wait for 91 ns;
       w_i_data <= "00000000"; 

       wait until rising_edge(w_intrL); 
       wait for 1730 ns;
       wait for 1222 ns;
       wait until rising_edge(axi_clk);  
       wait for 111 ns;
       w_load <= '0';
       wait for 1047 ns;

       for a in 0 to 20 loop
            wait until rising_edge(axi_clk);
       end loop;

	   w_mode_load <='0';
 
            ---------------------------------------------------------------------------------------------------

                -- TESTING:            
                for j in 0 to 29 loop 
                
                    wait for 1317 ns;
                    wait until rising_edge(axi_clk);
                    wait for 27 ns;
                    w_en_image <='1';
                    wait until rising_edge(axi_clk);
                    wait for 29 ns;
                    w_i_data_valid <='1'; 
                    for i in 0 to 98 loop
                        readline(text_file2, text_line2);
                        read(text_line2, var_imagedata2);  
                        wait for 17 ns;
                        w_i_data <= var_imagedata2;
                        wait until rising_edge(axi_clk);                      
                    end loop;  
                    wait for 31 ns;
                    w_i_data_valid <='0';
                    w_en_image <='0';
                    w_i_data <= "00000000"; 
                    
                    wait for 2309 ns;
                    wait until rising_edge(axi_clk); 
                    wait for 211 ns;
                    w_start <='1'; 
                    wait until rising_edge(w_intrS);
                    wait for 3564 ns;
                    samplecount <= samplecount + 1;
                    IF w_result(7 downto 4) /= w_result(3 downto 0) THEN
                             errors <= errors+1;
                    END IF;
                    wait until rising_edge(axi_clk); 
                    wait for 21 ns;
                    w_start <='0';
                    wait for 2378 ns;
                    
                    IF w_repeated_test='1' THEN
                        --Repeated testing of the same image:
                        wait for 17181 ns;
                        wait until rising_edge(axi_clk); 
                        wait for 1 ns;
                        w_start <='1'; 
                        wait until rising_edge(w_intrS);
                        wait for 1768 ns;
                        samplecount <= samplecount + 1;
                        IF w_result(7 downto 4) /= w_result(3 downto 0) THEN
                                 errors <= errors+1;
                        END IF;
                        wait until rising_edge(axi_clk); 
                        wait for 1 ns;
                        w_start <='0';
                        wait for 2199 ns;
                     END IF;      
               end loop;
               
           --std.env.stop(0);
           
           for a in 0 to 100 loop
                wait until rising_edge(axi_clk);
           end loop;
           w_singlemode <= '0';
           
           for a in 0 to 100 loop
                wait until rising_edge(axi_clk);
           end loop;
           wait for 17 ns;
           w_reset_imbuf <='1';
           
           for a in 0 to 100 loop
                wait until rising_edge(axi_clk);
           end loop;
           wait for 41 ns;
           w_reset_imbuf <='0'; 
           
           for a in 0 to 100 loop
                wait until rising_edge(axi_clk);
           end loop;
           
           -- TESTING inn continuous mode:            
                wait for 1231 ns;
                w_en_image <='1';
                
                wait until rising_edge(axi_clk);
                wait until rising_edge(axi_clk);
                
                wait until rising_edge(axi_clk);
                for i in 0 to 98 loop
                    readline(text_file2, text_line2);
                    read(text_line2, var_imagedata2);  
                    wait until rising_edge(axi_clk);
                    wait for 17 ns;
                    w_i_data <= var_imagedata2; 
                    w_i_data_valid <='1';                       
                end loop;  
                wait until rising_edge(axi_clk); 
                wait for 31 ns;
                w_i_data_valid <='0';
                w_i_data <= "00000000"; 
                w_en_image <='0';
                wait until rising_edge(axi_clk);
                
                wait for 9171 ns;
                
                  ------------------------------------------------------------
                 for j in 0 to 10000-30 loop
                    
                    w_en_image <='1';
                    wait until rising_edge(axi_clk);
                    wait until rising_edge(axi_clk);
                    w_start <='1'; 
                    wait for 8213 ns;
                    wait until rising_edge(axi_clk);
                    for i in 0 to 98 loop
                        readline(text_file2, text_line2);
                        read(text_line2, var_imagedata2);  
                        wait until rising_edge(axi_clk);
                        wait for 12 ns;
                        w_i_data <= var_imagedata2; 
                        w_i_data_valid <='1';              
                    end loop;  
                    wait until rising_edge(axi_clk); 
                    wait for 21 ns;
                    w_i_data_valid <='0';
                    w_i_data <= "00000000"; 
                    w_en_image <='0';
                    wait until rising_edge(w_intrS);
                    wait for 1217 ns;
                    samplecount <= samplecount + 1;
                    IF w_result(7 downto 4) /= w_result(3 downto 0) THEN
                             errors <= errors+1;
                    END IF;
                    w_start <='0';
                    wait for 1171 ns;
                 end loop; 
                 
                 -- Process the last sample:
                 w_start <='1'; 
                 wait until rising_edge(w_intrS); 
                 wait for 1213 ns;
                 samplecount <= samplecount + 1;
                 IF w_result(7 downto 4) /= w_result(3 downto 0) THEN
                           errors <= errors+1;
                 END IF; 
            
                wait for 21032 ns; 
                w_start <='0';
             
            wait for 15007 ns;
                        
            std.env.stop(0);
    
    end process;

end test;