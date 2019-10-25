library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity poolV is
	generic(
		BITWIDTH 	: integer;
		IMAGE_WIDTH : integer;
		KERNEL_SIZE : integer
	);
	port(
		clk      : in  std_logic;
		reset_n  : in  std_logic;
		enable   : in  std_logic;
		in_data  : in  std_logic_vector (BITWIDTH - 1 downto 0);
		in_dv    : in  std_logic;
		out_data : out std_logic_vector (BITWIDTH - 1 downto 0);
		out_dv   : out std_logic
	);
end entity;

architecture rtl of poolV is
--------------------------------------------------------------------------
-- Signals
--------------------------------------------------------------------------
	type buffer_data_type is array (integer range <>) of signed (BITWIDTH-1 downto 0);

	signal buffer_line      : buffer_data_type (IMAGE_WIDTH - 1 downto 0); -- to diferent kernels -> (IMAGE_WIDTH*(KERNEL_SIZE-1))-1
	signal buffer_data      : buffer_data_type (KERNEL_SIZE - 1 downto 0);
	signal max_value_signal : signed (BITWIDTH - 1 downto 0);
	signal tmp_dv           : std_logic := '0';

begin
	process (clk)
	-- mexi aqui
	variable x_cmp : unsigned (15 downto 0) := (others => '0');

	begin
		if (reset_n = '0') then
			tmp_dv           <= '0';
			buffer_data      <= (others => (others => '0'));
			buffer_line      <= (others => (others => '0'));
			max_value_signal <= (others => '0');
			x_cmp            := (others => '0');

		elsif (rising_edge(clk)) then
			if (enable = '1' and in_dv = '1') then
				-- Bufferize line --------------------------------------------------------
				buffer_line(IMAGE_WIDTH - 1) <= signed(in_data);
				-- shift using for loop
				BUFFER_LOOP : for i in (IMAGE_WIDTH - 1) downto 1 loop -- to diferent kernels -> (IMAGE_WIDTH*(KERNEL_SIZE-1))-1
					buffer_line(i-1) <= buffer_line(i);
				end loop;

				buffer_data(0) <= signed(in_data);
				buffer_data(1) <= buffer_line(0);
				-- the value in buffer_line(0) is the value 24 columns before the last value entered, that means that is the value just down (seeing the image as a matrix) of the input value
				-- This way, the program saves the buffer_lie(0) value in buffer_data(1), and does a shift register of the buffer_line, and introduces the new value in buffer_line(23)


				-- Compute max : Case2 , just a comparator --------------------------------
				-- this dosen't work with kernels bigger than 2. Maybe separate the part where it does the comparision to assyncronous, and compare the 3 values, and adjust the timings
				if (buffer_data(0) > buffer_data(1)) then
					max_value_signal <= buffer_data(0);
				else
					max_value_signal <= buffer_data(1);
				end if;

				-- V Subsample -------------------------------------------------------------
				-- x_cmp -> auxiliar variable to manage image borders

				-- saves the fist lines
				if (x_cmp <= to_unsigned(IMAGE_WIDTH, 16)) then -- to diferent kernels -> (IMAGE_WIDTH*(KERNEL_SIZE-1))
					tmp_dv <= '0';
					x_cmp  := x_cmp + to_unsigned(1, 16);

				-- after processing, puts the values at zero and starts a new wave of processing
				elsif (x_cmp > to_unsigned(IMAGE_WIDTH + IMAGE_WIDTH, 16)) then -- to diferent kernels -> (IMAGE_WIDTH*KERNEL_SIZE)
					tmp_dv <= '0';
					x_cmp  := to_unsigned(2, 16);	-- x_cmp = 2 - porque ao passar o tmp_dv a zero, perde 1 ciclo de relogio e depois para compensar isso o x_cmp comeca em 2
				else -- o out_dv so fica a 1 quando x_cmp > IMAGE_WIDTH e quando o x_cmp = 49 o out_dv volta a ficar a zero
					tmp_dv <= '1';
					x_cmp  := x_cmp + to_unsigned(1, 16);
				end if;
			--------------------------------------------------------------------------
			else -- in_dv == 0
				-- Data is not valid
				tmp_dv <= '0';

			end if; -- enable and in_dv
		end if; -- clk
	end process;

	out_data <= std_logic_vector(max_value_signal);
	out_dv   <= tmp_dv;
end architecture;
