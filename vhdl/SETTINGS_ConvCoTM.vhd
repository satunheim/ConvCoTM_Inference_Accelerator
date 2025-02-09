-- The Convolutional Coalesced TM (ConvCoTM) Structure

-- Literals = Features & not(Features)  (defined in component AllClauses)

-- States: 
-- 1 to N=> Exclude 
-- N+1 to 2N => Include
 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

package SETTINGS_ConvCoTM is

	constant ImageSize: Integer := 28; 
	-- Assuming quadratic images, i.e. ImageSize x ImageSize

    constant BytesPerImage: Integer := (ImageSize*ImageSize/8)+1; 
	-- With 28x28 booleanized images, and one byte for the label BytesPerImage=99

	constant WSize: Integer := 10; 	 	
	-- Window (patch) size. Assuming quadratic patch 

    constant pixelResolution: Integer :=1; 
    -- Set to 1 for booleanized images
    -- Set to 8 for Cifar-10 with 8 bit pixel resolution

	constant d: Integer := 1; 	 	
	-- Window step size 
	
	constant Bx: Integer := ((ImageSize-WSize)/d)+1;
	constant By: Integer := ((ImageSize-WSize)/d)+1;
	-- Bx and By are the number of times the Window is moved in x and y directions respectively.
	
	constant B: Integer := Bx*By;
	-- B is the number of patches
	
	constant NBitsPatchAddr: Integer := 9;
	-- Number of bits used for the Patch Address. 
	
	constant FSize: Integer := WSize*WSize*pixelResolution+(ImageSize-WSize)+(ImageSize-WSize);
	
	constant NClauses: Integer := 128;	 
	
	constant NBitsClauseAddr: Integer := 7;
	-- Number of bits used for the Clause Address. MUST equal 2**NBitsClauseAddr=NClauses

	constant Pcounterbits: Integer := 9;	
	-- Number of bits in the P-counter (patch counter).

	constant NClasses: Integer :=10;		
	-- Number of Classes
    
    constant NBitsIW: Integer := 8;
	-- Number of bits used for the Integer Weights (for the clauses).
	-- This includes a sign bit, as the weights are in 2's complement format

	--constant NBsum: Integer :=NBitsIW+NBitsClauseAddr;	
	constant NBsum: Integer :=11;		
	-- Number of bits in sum outputs of the first column of adders for the clauses
	-- The theoretical maximum class sum is NClauses*Max(weight)
	-- For 128 clauses and 9 bit weights (incl sign bit) this equals:
	-- 32640. This is "0111111110000000" in binary format.
	-- With 15 bits just for the unsigned part there should be sufficient range. 
	-- NBitsIW+NBitsClauseAddr = 16 bits in this case. 
    
    type clause_weights is array (0 to NClauses-1) of signed(NBitsIW-1 downto 0);
    
    type array32ofClauseWeights is array (0 to 31) of signed(NBitsIW-1 downto 0);
    type array16ofClauseWeights is array (0 to 15) of signed(NBitsIW-1 downto 0);
    type array4ofClauseWeights is array (0 to 3) of signed(NBitsIW-1 downto 0);

    type include_exclude_signals is array (0 to NClauses-1) of std_logic_vector(2*FSize-1 downto 0);
    
    constant c_AdderPipelineStages : Integer := 3;
    
    constant ModelBytesPerClause: Integer := 34 + 10;
    constant ModelBitsPerClause : Integer := 34*8 + 8*10;
        -- 34 bytes are the include/exclude signals for the 272 literals
        -- 1*10 byte is for 1 byte per weight per class.
        -- Per clause we need 44 bytes.
        -- Per clause we thus need 34*8+10*8=44*8=272+80=352 bits.
        -- The total model size is: 128*352=45056 bits = 5632 byte. We need DFFs for these. They should be clock gated. 
    
    type bufferarray is array(0 to BytesPerImage-1) of std_logic_vector(7 downto 0);
    
end package;
