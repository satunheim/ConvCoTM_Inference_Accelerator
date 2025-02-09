library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;

entity ImageBytes_counter is   
        Port (
             i_clk               : in STD_LOGIC; 
             i_rst               : in STD_LOGIC; 
             --i_resetK            : in std_logic;
             i_en                : in STD_LOGIC;
             
             o_k_counterFinished : out STD_LOGIC;
             o_k_value           : out std_logic_vector(6 downto 0)
            );
end ImageBytes_counter ;  

architecture rtl of ImageBytes_counter is 

    signal w_nxtK               : std_logic_vector(6 downto 0);
    signal w_regoutK            : std_logic_vector(6 downto 0);
    
    signal w_valueK             : unsigned(6 downto 0);
    signal w_increment          : unsigned(6 downto 0);
    signal w_valueKincremented  : unsigned(6 downto 0);
 
begin

    KREG: vDFFce generic map(7) port map(i_clk, '1', w_nxtK, w_regoutK);
    
    w_valueK <= unsigned(w_regoutK);
    w_increment <= "0000001";
    w_valueKincremented <=w_valueK+w_increment;
    
    w_nxtK   <= (others=>'0') when i_rst='1' 
                else std_logic_vector(w_valueKincremented) when ((to_integer(w_valueK) <= BytesPerImage-1) and i_en='1')
                else w_regoutK;
    
    o_k_value <= w_regoutK; 
    o_k_counterFinished <= '1' when (to_integer(w_valueK) = BytesPerImage-1) else '0';

end rtl;

