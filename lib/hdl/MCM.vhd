-- Implementation of a Multiple-Constant-Multiplier:
-- This IP multiplies an input array with CONSTANT coefficients (3D convolution kernels)
-- Each clock cycle returns a kernel_size*kernel_size matrix with the multiplicated values

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.math_real.all;
library work;
use work.cnn_types.all;

--use ieee.numeric_std.all;


entity MCM is
	generic(
		BITWIDTH 			: integer;
		DOT_PRODUCT_SIZE 	: integer; -- KERNEL_SIZE*KERNEL_SIZE
		KERNEL_VALUE 		: pixel_array
	);

	port(
		clk				: in  std_logic;
		reset_n			: in  std_logic;
		enable			: in  std_logic;
		in_data			: in  pixel_array (0 to DOT_PRODUCT_SIZE - 1);
		in_dv				: in  std_logic;
		out_data 		: out prod_array (0 to DOT_PRODUCT_SIZE - 1); -- prod_array -> 2*GENERAL_BITWIDTH = 2*8
		out_dv			: out std_logic
	);
end MCM;

architecture rtl of MCM is
	-- Generate DOT_PRODUCT_SIZE Multipliers
	signal mult : prod_array (0 to DOT_PRODUCT_SIZE - 1);

	--signal aux_kernel : std_logic_vector(7 downto 0);
	signal aux_data : std_logic_vector(7 downto 0);

begin
---------------------------------
-- Assynchronous implmentation --
---------------------------------
-- mcm_loop : for i in 0 to DOT_PRODUCT_SIZE - 1 generate
--     out_data(i) <=  KERNEL_VALUE(i) * in_data(i);
-- end generate mcm_loop;
-- out_valid <= in_valid;

---------------------------------
--  synchronous implmentation  --
---------------------------------

	process(clk)

	begin
		if(reset_n = '0') then
			out_data  <= (others => (others => '0'));
			out_dv <= '0';

		elsif (rising_edge(clk)) then
			if (enable = '1' and in_dv = '1') then

				mcm_loop : for i in 0 to DOT_PRODUCT_SIZE - 1 loop -- for i until KERNEL*KERNEL-1
					out_data(i) <= KERNEL_VALUE(i) * in_data(DOT_PRODUCT_SIZE-1-i); -- DOT_PRODUCT_SIZE = KERNEL_SIZE*KERNEL_SIZE
					
					-- nao sei se nao seria KERNEL_VALUE(KERNEL_SIZE*KERNEL_SIZE-1-i)*in_data(i), porque in_data(0) corresponde ao ultimo elemento do kernel retirado da imagem, e KERNEL_VALUE(i) corresponde ao prieiro elemento
				end loop;
				
				-- for debug
				--out_data(0)(7 downto 0) <= in_data(8); -- DOT_PRODUCT_SIZE = KERNEL_SIZE*KERNEL_SIZE

			end if; -- enable and in_dv
			
			out_dv <= in_dv;

		end if; -- clk
	end process;
end architecture;
