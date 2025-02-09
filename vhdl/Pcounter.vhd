library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;
   
entity Pcounter is    
    Port ( i_clk              : in STD_LOGIC; 
           i_rst              : in STD_LOGIC; 
           o_PcounterFinished : out STD_LOGIC
           );
end Pcounter;


architecture rtl2 of Pcounter is

    signal w_nxtP       : std_logic_vector(Pcounterbits-1 downto 0);
    signal w_regoutP    : std_logic_vector(Pcounterbits-1 downto 0);   
    signal w_valueP     : unsigned(Pcounterbits-1 downto 0);
    signal w_incrementP : unsigned(Pcounterbits-1 downto 0);
    signal w_valuePincremented : unsigned(Pcounterbits-1 downto 0);
    signal w_CountT1    : std_logic_vector(Pcounterbits-1 downto 0);

begin
    
        ModulePcounter: vDFF generic map(Pcounterbits) port map(i_clk, w_nxtP, w_regoutP);
        
        w_valueP<=unsigned(w_regoutP);
        w_incrementP <= (0 => '1', others => '0');
        w_valuePincremented <= w_valueP + w_incrementP;
                
        w_nxtP <=  (others=>'0') when i_rst='1' 
                   else std_logic_vector(w_valuePincremented);

        w_CountT1 <= std_logic_vector(to_unsigned(Bx*By-1, w_CountT1'length));  

        o_PCounterFinished <= '1' when w_regoutP=w_CountT1 else '0';    

end rtl2;
