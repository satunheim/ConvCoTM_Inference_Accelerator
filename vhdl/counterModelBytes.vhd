library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;
 
entity counterModelBytes is   
        Port (
             i_clk                  : in STD_LOGIC; 
             i_rst                  : in STD_LOGIC; 
             i_resetM               : in std_logic;
             i_en                   : in STD_LOGIC;
             
             o_M_counterFinished    : out STD_LOGIC;
             o_M_value              : out std_logic_vector(5 downto 0) 
                                      -- 000000 to 111111 = 0 to 63.
                                      -- Must be able to count from 0 to 43 (the amount of model bytes required per clause)                                  
            );
end counterModelBytes ;  

architecture rtl of counterModelBytes is 

    signal w_nxtM               : std_logic_vector(5 downto 0);
    signal w_regoutM            : std_logic_vector(5 downto 0);
    
    signal w_valueM             : unsigned(5 downto 0);
    signal w_increment          : unsigned(5 downto 0);
    signal w_valueMincremented  : unsigned(5 downto 0);
 
begin

    McountREG: vDFF generic map(6) port map(i_clk, w_nxtM, w_regoutM);
    
    w_valueM <= unsigned(w_regoutM);
    w_increment <= "000001";
    w_valueMincremented <=w_valueM+w_increment;
    
    w_nxtM   <= (others=>'0') when (i_rst='1' or i_resetM='1' or (to_integer(w_valueM) >= ModelBytesPerClause-1 and i_en='1'))
                else std_logic_vector(w_valueMincremented) when (to_integer(w_valueM) < ModelBytesPerClause-1 and i_en='1')
                else w_regoutM;
    
    o_M_value <= w_regoutM; 
    
    o_M_counterFinished <= '1' when (to_integer(w_valueM) = ModelBytesPerClause-1) else '0';

end rtl;

