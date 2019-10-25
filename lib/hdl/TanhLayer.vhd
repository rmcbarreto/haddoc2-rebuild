library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.cnn_types.all;

entity TanhLayer is
	generic(
		BITWIDTH 	: integer;
		SUM_WIDTH 	: integer
	);
	port(
		in_data		: in  std_logic_vector (SUM_WIDTH-1 downto 0);
		out_data	: out std_logic_vector (BITWIDTH-1 downto 0)
	);
end entity;

architecture Bhv of TanhLayer is
-- Piecewise implementation of TanH

begin
	--sum_s    <= signed(in_data);
  
	-- SCALE_FACTOR = 2^(GENERAL_BITWIDTH-1) - 1 = 127
	--
	-- V2 = SCALE_FACTOR - 10 = 117
	-- T2 = SCALE_FACTOR * SCALE_FACTOR * 5/4 = 127*127*1.25 = 20161.25 ~= 20161
	--
	-- out_data = 	-117 quando (in_data < -20161) else
	--					 117 quando (in_data >  20161) else
	--					shift right 8 bits in_data
	--
	out_data <= std_logic_vector(to_signed(-V2, BITWIDTH)) when (signed(in_data) < to_signed(-T2, SUM_WIDTH)) else
					std_logic_vector(to_signed( V2, BITWIDTH)) when (signed(in_data) > to_signed( T2, SUM_WIDTH)) else
					std_logic_vector(SHIFT_RIGHT(signed(in_data),BITWIDTH)(BITWIDTH-1 downto 0));
	
end architecture;
