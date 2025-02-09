library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

library lib_convcotm;
use lib_convcotm.ff.all;
use lib_convcotm.SETTINGS_ConvCoTM.all;

entity BCounter is
    Port ( i_clk                    : in std_logic;
           i_resetBounter           : in std_logic;
           
           o_BxCounterValue         : out std_logic_vector(4 downto 0); 
           o_ByCounterValue         : out std_logic_vector(4 downto 0);
           o_LoadNewRow             : out STD_LOGIC
           ); 
end BCounter;   

architecture rtl of BCounter is 

    signal nxtBx, regoutBx, nxtBy, regoutBy : std_logic_vector(4 downto 0);
    
    signal BxValue, BxValueIncr             : unsigned(4 downto 0);
    signal ByValue, ByValueIncr             : unsigned(4 downto 0);
    signal incrementvector                  : unsigned(4 downto 0);
    signal w_By                             : unsigned(4 downto 0);
    signal w_Patchadr                       : unsigned(1+NBitsPatchAddr-1 downto 0);

begin  

    BXCOUNT: vDFF generic map(5) port map(I_clk, nxtBx, regoutBx);
    
    BYCOUNT: vDFF generic map(5) port map(i_clk, nxtBy, regoutBy);
    
    BxValue <= unsigned(regoutBx);
    ByValue <= unsigned(regoutBy);
    
    incrementvector <= (0 => '1', others => '0');
    BxValueIncr <= BxValue + incrementvector;
    ByValueIncr <= ByValue + incrementvector;
    
    w_By <= to_unsigned(By, w_By'length);
    
    w_Patchadr <= ByValue*w_By+BxValue;
    
    nxtBx   <=   (others=>'0') when i_resetBounter='1' else
                 std_logic_vector(BxValueIncr) when (to_integer(BxValue) < (Bx-1)) else 
                 (others=>'0');
                
    nxtBy <=    (others=>'0') when (i_resetBounter='1' or (to_integer(w_PatchAdr)=B-1)) else
                std_logic_vector(ByValueIncr) when ((to_integer(ByValue) < (By-1)) and (to_integer(BxValue)=(Bx-1))) else 
                regoutBy;
    
    o_BxCounterValue <= regoutBx;
    o_ByCounterValue <= regoutBy;
    
    o_LoadNewRow <=  '1' when (to_integer(BxValue)=Bx-1) else '0'; 

end rtl;
