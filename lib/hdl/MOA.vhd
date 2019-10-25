-- Design of a Multi-Operand-Adder block
-- This is a naive implementation with binary adder trees
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
library work;
use work.cnn_types.all;

entity MOA is
	generic(
		BITWIDTH 		: integer;
		SUM_WIDTH 		: integer; -- 3*8 -> 3*bitwidth
		NUM_OPERANDS 	: integer; -- KERNEL_SIZE*KERNEL_SIZE
		BIAS_VALUE 		: std_logic_vector -- value of bias
	);

	port(
		clk 			: in  std_logic;
		reset_n 		: in  std_logic;
		enable 		: in  std_logic;
		in_data 		: in  prod_array (0 to NUM_OPERANDS - 1); -- prod_array -> 2*GENERAL_BITWIDTH = 2*8
		in_dv 		: in  std_logic;
		out_data 	: out std_logic_vector (SUM_WIDTH-1 downto 0); -- SUM_WIDTH = 3*GENERAL_BITWIDTH = 3*8 -> 23 downto 0 - 24 bits
		out_dv 		: out std_logic
	);
end MOA;


architecture rtl of MOA is
-- Implementation of Multi Operand Adder with Adder trees

-----------------------------------
-- Removing MOA to Evaluate FMax --
-----------------------------------
-- begin
-- out_valid <= in_valid;
-- out_data  <= "00000000" & in_data(0);
-- end architecture;

--=================================================================================================
---------------------------------
-- Assynchronous implmentation --
---------------------------------
signal s_acc   : std_logic_vector (SUM_WIDTH-1 downto 0);
--signal pip_acc : prod_array (0 to NUM_OPERANDS - 1);

begin
	add_process : process(clk)
		variable v_acc : std_logic_vector (SUM_WIDTH-1 downto 0) := (others => '0');
		
	begin
		if (reset_n = '0') then
			v_acc		:= (others => '0');
			out_dv	<= '0';

		elsif (rising_edge(clk)) then
			if (enable = '1' and in_dv = '1') then
				
				acc_loop : for i in 0 to NUM_OPERANDS-1 loop
					v_acc := v_acc + in_data(i);
				end loop acc_loop;
				
				v_acc := v_acc + BIAS_VALUE;
			end if;
			
			s_acc		<= v_acc;
			v_acc		:= (others => '0');
			out_dv	<= in_dv;
		end if;
	end process;
	
	out_data <= s_acc;

--=================================================================================================
-----------------------------
-- Pipelined implmentation --
-----------------------------
--signal pip_acc : sum_array (0 to NUM_OPERANDS - 1) := (others => (others => '0'));
---- NUM_OPERANDS : -- KERNEL_SIZE*KERNEL_SIZE
---- sum_array -> SUM_WIDTH = 3*GENERAL_BITWIDTH = 3*8 - cada elemetno tem 3*8 bits
--
--begin
--	process(clk)
--
--	begin
--		if (reset_n = '0') then
--			pip_acc   <= (others => (others => '0'));
--			out_dv <= '0';
--
--		elsif(rising_edge(clk)) then
--			if (enable = '1' and in_dv = '1') then
--
--				pip_acc(0)(2*BITWIDTH-1 downto 0) <= in_data(0);
--
--				-- sum the last value with the new value and saves it in the matrix. The last value of the matrix corresponds to the sum of all values
--				acc_loop : for i in 1 to NUM_OPERANDS-1 loop
--					pip_acc(i) <= pip_acc(i-1) + in_data(i);
--				end loop acc_loop;
--
--			-- dont know if this else and its content is necessary...
--			else
--				pip_acc   <= (others => (others => '0'));
--			end if; -- enable and in_dv
--
--			-- depends on the timming, because initialy, it has to wait 9 clock cycles (kernel) to start sending (to get the first 9 values sum correspondig to the kernel)
--			out_data <= pip_acc(NUM_OPERANDS-1) + BIAS_VALUE;
--			out_dv <= in_dv;
--
--		end if; -- clk
--	end process;
--=================================================================================================
end architecture;
