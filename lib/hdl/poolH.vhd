library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity poolH is
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

architecture rtl of poolH is
--------------------------------------------------------------------------
-- Signals
--------------------------------------------------------------------------
	type buffer_data_type is array (integer range <>) of signed (BITWIDTH-1 downto 0);

	signal buffer_data      : buffer_data_type (KERNEL_SIZE - 1 downto 0); -- buffer_data(2-1 downto 0)
	signal max_value_signal : signed(BITWIDTH-1 downto 0);
	signal tmp_dv           : std_logic := '0';

begin

	process (clk)
	--variable x_cmp : unsigned (15 downto 0) := (others => '0');
	variable x_cmp : unsigned (15 downto 0) := to_unsigned(0, 16);

	begin
		if (reset_n = '0') then
			tmp_dv           <= '0';
			buffer_data      <= (others => (others => '0'));
			max_value_signal <= (others => '0');
			x_cmp            := (others => '0');

		elsif (rising_edge(clk)) then
			if (enable = '1' and in_dv = '1') then
				-- Bufferize data --------------------------------------------------------
				buffer_data(KERNEL_SIZE - 1) <= signed(in_data);
				-- shift using for loop
				BUFFER_LOOP : for i in (KERNEL_SIZE - 1) downto 1 loop
					buffer_data(i-1) <= buffer_data(i);
				end loop;

				-- Compute max -----------------------------------------------------------
				if (buffer_data(0) > buffer_data(1)) then
					max_value_signal <= buffer_data(0);
				else
					max_value_signal <= buffer_data(1);
				end if;

				-- H Subsample -------------------------------------------------------------
				if (x_cmp = to_unsigned(KERNEL_SIZE, 16)) then -- if x_cmp == 2
					tmp_dv <= '1';
					x_cmp  := to_unsigned(1, 16);
				else
					tmp_dv <= '0';
					x_cmp  := x_cmp + to_unsigned(1, 16);
				end if;
			--------------------------------------------------------------------------
			else -- in_dv = 0
				-- Data is not valid
				tmp_dv <= '0';

			end if; -- enable and in_dv
		end if; -- clk
	end process;

	out_data <= std_logic_vector(max_value_signal);
	out_dv   <= tmp_dv;
end architecture;
