------------------------------------------------------------------------------
-- Title      : taps
-- Project    : Haddoc2
------------------------------------------------------------------------------
-- File       : taps.vhd
-- Author     : Ricardo Barreto
-- Company    : ISR
-- Last update: 2019-08-08
------------------------------------------------------------------------------
-- Description: Shift registers used in neighExtractor design.

--                        taps_data(0)                            taps_data(KERNEL_SIZE-1)
--                           ^                                       ^
--                           |                                       |
--               -------     |     -------               -------     |    ---------------------------
--              |        |   |    |        |            |        |   |   |                           |
--  in_data --->|        |---|--> |        |--  ...  -> |        |---|-->|          BUFFER           |
--              |        |        |        |            |        |       |  SIZE =(TAPS_WIDTH-KERNEL)|
--              |        |        |        |            |        |       |                           |
--               -------           -------               -------          ---------------------------
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


library work;
use work.cnn_types.all;


entity myTaps is
	generic (
		BITWIDTH 		: integer;
		IMAGE_WIDTH 	: integer; -- image width = 28
		KERNEL_SIZE 	: integer
);

	port (
		clk			: in  std_logic;
		reset_n		: in  std_logic;
		enable		: in  std_logic;
		taps_dv		: in  std_logic;
		in_data		: in  std_logic_vector (BITWIDTH-1 downto 0);
		taps_data	: out pixel_array (0 to (KERNEL_SIZE * KERNEL_SIZE) - 1) -- elements of kernel = 9
);
end myTaps;


architecture bhv of myTaps is

	signal cell : pixel_array (0 to (IMAGE_WIDTH*(KERNEL_SIZE-1) + KERNEL_SIZE - 1)); -- array with the size of image width

begin
	process(clk)
		variable i : integer := 0;

	begin

		if (reset_n = '0') then
			cell      <= (others => (others => '0'));
			taps_data <= (others => (others => '0'));

		elsif (rising_edge(clk)) then
			if (enable = '1' or taps_dv = '1') then -- only when ((in_dv and enable) or taps_dv) == 1

				cell(0) <= in_data;

				-- shift right values
				for i in 1 to (IMAGE_WIDTH*(KERNEL_SIZE-1) + KERNEL_SIZE - 1) loop
					cell(i) <= cell(i-1);
				end loop;

				for i in 0 to (KERNEL_SIZE - 1) loop
					taps_data(i * KERNEL_SIZE to (KERNEL_SIZE*(i+1)) - 1) <= cell(IMAGE_WIDTH*i to (IMAGE_WIDTH*i) + KERNEL_SIZE - 1);
				end loop;

				-- before shift
				--
				-- cell(0) -> cell(1) -> cell(2) -> ... -> cell(image_width - 2) -> cell(image_width - 1) 
				--
				-- after shift:
				--
				-- in_data 					-> cell(0) -> cell(1) -> ... -> cell(image_width - 2)
				-- cell(image_width - 1) -> ...
				--

			end if;
		end if;
	end process;
end bhv;
