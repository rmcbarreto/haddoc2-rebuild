------------------------------------------------------------------------------
-- Title      : neighExtractor
-- Project    : Haddoc2
------------------------------------------------------------------------------------------------------------
-- File       : neighExtractor.vhd
-- Author     : K. Abdelouahab
-- Company    : Institut Pascal
-- Last update: 2018-08-23
-------------------------------------------------------------------------------------------------------------
-- Description: Extracts a generic neighborhood from serial in_data
--
--                          ------------------
--          reset_n    --->|                  |
--          clk        --->|                  |
--          enable     --->|                  |
--                         |                  |---> out_data (pixel_array of size KERNEL_SIZE²)
--                         |  neighExtractor  |---> out_dv
--                         |                  |---> out_fv
--          in_data    --->|                  |---> out_valid
--          in_dv      --->|                  |
--          in_fv      --->|                  |
--                         |                  |
--                          ------------------

--------------------------------------------------------------------------------------------------------------

--                        out_data(0)      out_data(1)      out_data(2)
--                           ^                 ^                 ^
--                           |                 |                 |
--               -------     |     -------     |     -------     |    ---------------------------
--              |        |   |    |        |   |    |        |   |   |                           |
--  in_data --->|  p22   |---|--> |  p21   |---|--> |  p20   |---|-->|          BUFFER           |-> to_P1
--              |        |        |        |        |        |       |                           |
--               -------           -------           -------          ---------------------------
--                        out_data(3)      out_data(4)      out_data(5)
--                           ^                 ^                 ^
--                           |                 |                 |
--               -------     |     -------     |     -------     |    ---------------------------
--              |        |   |    |        |   |    |        |   |   |                           |
--  P1      --->|  p12   |---|--> |  p11   |---|--> |  p10   |---|-->|          BUFFER           |-> to_P2
--              |        |        |        |        |        |       |                           |
--               -------           -------           -------          ---------------------------
--                        out_data(6)      out_data(7)      out_data(8)
--                           ^                 ^                 ^
--                           |                 |                 |
--               -------     |     -------     |     -------     |
--              |        |   |    |        |   |    |        |   |
--  P2      --->|   p02  |---|--> |  p01   |---|--> |  p00   |---|
--              |        |        |        |        |        |
--               -------           -------           -------

-- Modified by Ricardo Barreto
-- 
-- For a image 28x28 with a kernel 3x3, this function runs for 674 clock cicles, wich is 26*26 - 2 
-- There is always - 2 in all functions (this and pooling and others...) because of some data delays
--
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.cnn_types.all;

entity neighExtractor is
	generic(
		BITWIDTH 	: integer;
		IMAGE_WIDTH : integer;
		KERNEL_SIZE : integer
	);

	port(
		clk			: in  std_logic;
		reset_n		: in  std_logic;
		enable		: in  std_logic;
		in_data		: in  std_logic_vector((BITWIDTH-1) downto 0);
		in_dv			: in  std_logic;
		out_data		: out pixel_array (0 to (KERNEL_SIZE * KERNEL_SIZE)- 1);
		out_dv		: out std_logic
		--aux_counter : out std_logic_vector(9 downto 0)
	);
end neighExtractor;

architecture rtl of neighExtractor is

	-- signals
	--signal pixel_out : pixel_array(0 to KERNEL_SIZE-1); -- elements of kernel row (3 elements)
	--signal tmp_data  : pixel_array (0 to (KERNEL_SIZE * KERNEL_SIZE)- 1); -- elements of kernel = 9
	signal s_valid   : std_logic;
	signal tmp_dv    : std_logic;
	signal taps_dv	  : std_logic;

	-- components
--	component taps
--		generic (
--			BITWIDTH 	: integer;
--			TAPS_WIDTH  : integer;
--			KERNEL_SIZE : integer
--		);
--
--		port (
--			clk			: in  std_logic;
--			reset_n		: in  std_logic;
--			enable		: in  std_logic;
--			in_data		: in  std_logic_vector (BITWIDTH-1 downto 0);
--			taps_data	: out pixel_array (0 to KERNEL_SIZE -1); -- last 3 values (kernel 3x3)
--			out_data	: out std_logic_vector (BITWIDTH-1 downto 0) -- -- oldest value of the image width (image row) (last column value of a image row)
--		);
--	end component;

	component mytaps
		generic (
			BITWIDTH 	: integer;
			IMAGE_WIDTH : integer;
			KERNEL_SIZE : integer
		);

		port (
			clk			: in  std_logic;
			reset_n		: in  std_logic;
			enable		: in  std_logic;
			taps_dv	   : in  std_logic;
			in_data		: in  std_logic_vector (BITWIDTH-1 downto 0);
			taps_data	: out pixel_array (0 to (KERNEL_SIZE * KERNEL_SIZE) - 1) -- elements of kernel = 9
		);
	end component;
	
begin

	-- All valid : Logic and
	s_valid   <= in_dv and enable;
	----------------------------------------------------
	-- Instantiates taps
	----------------------------------------------------

	-- myTaps

	taps_i : mytaps
		generic map(
			BITWIDTH 	=> BITWIDTH,
			IMAGE_WIDTH => IMAGE_WIDTH,
			KERNEL_SIZE => KERNEL_SIZE
		)
		port map(
			clk			=> clk,
			reset_n		=> reset_n,
			enable		=> s_valid,
			taps_dv		=> taps_dv,
			in_data		=> in_data,
			--taps_data => tmp_data
			taps_data	=> out_data
		);

--  taps_inst : for i in 0 to KERNEL_SIZE-1 generate
--    -- First line
--    gen_1 : if i = 0 generate
--      gen1_inst : taps
--        generic map(
--          BITWIDTH  => BITWIDTH,
--          TAPS_WIDTH  => IMAGE_WIDTH-1,
--          KERNEL_SIZE => KERNEL_SIZE
--          )
--        port map(
--          clk       => clk,
--          reset_n   => reset_n,
--          enable    => s_valid,
--          in_data   => in_data,
--          taps_data => tmp_data(0 to KERNEL_SIZE-1), -- first row of kernel, 3 elements (kernel 3x3)
--          out_data  => pixel_out(0) -- elements of kernel row (element 0) (oldest value)
--          );
--    end generate gen_1;
--
--    -- line i
--    gen_i : if i > 0 and i < KERNEL_SIZE-1 generate -- only 1 (kernel size 3x3)
--      geni_inst : taps
--        generic map(
--          BITWIDTH  => BITWIDTH,
--          TAPS_WIDTH  => IMAGE_WIDTH-1,
--          KERNEL_SIZE => KERNEL_SIZE
--          )
--        port map(
--          clk       => clk,
--          reset_n   => reset_n,
--          enable    => s_valid,
--          in_data   => pixel_out(i-1),
--          taps_data => tmp_data(i * KERNEL_SIZE to KERNEL_SIZE*(i+1)-1), -- second row of kernel, 3 elements (kernel 3x3)
--          out_data  => pixel_out(i) -- elements of kernel row (elements 1) (oldest value)
--          );
--    end generate gen_i;
--
--    -- Last line
--    gen_last : if i = (KERNEL_SIZE-1) generate
--      gen_last_inst : taps
--        generic map(
--          BITWIDTH  => BITWIDTH,
--          TAPS_WIDTH  => KERNEL_SIZE,
--          KERNEL_SIZE => KERNEL_SIZE
--          )
--        port map(
--          clk       => clk,
--          reset_n   => reset_n,
--          enable    => s_valid,
--          in_data   => pixel_out(i-1),
--          taps_data => tmp_data((KERNEL_SIZE-1) * KERNEL_SIZE to KERNEL_SIZE*KERNEL_SIZE - 1), -- third row of kernel, 3 elements (kernel 3x3)
--          out_data  => open
--          );
--    end generate gen_last;
--  end generate taps_inst;


	--------------------------------------------------------------------------
	-- Manage out_dv
	--------------------------------------------------------------------------
	-- Embrace your self : Managing the image borders is quite a pain

	dv_proc : process(clk)

		-- real data types are only used for simulation, it is not synthesis-able
		constant NBITS_DELAY : integer                           := integer(ceil(log2(real(IMAGE_WIDTH)))); -- for image_width = 28, NBITS_DELAY = 5
		variable x_cmp       : unsigned (NBITS_DELAY-1 downto 0) := (others => '0'); -- cria a variaveis com o numero de bits necessarios para a image_width
		variable y_cmp       : unsigned (NBITS_DELAY-1 downto 0) := (others => '0'); -- cria a variaveis com o numero de bits necessarios para a image_width

		constant NBITS_COUNTER : integer                           := integer(ceil(log2(real(IMAGE_WIDTH*IMAGE_WIDTH+2)))); -- for image_width = 28, NBITS_DELAY = 5
		variable counter		 : unsigned (NBITS_COUNTER-1 downto 0) := (others => '0');
		-- x_cmp sao as colunas
		-- y_cmp sao as linhas



	begin
		if (reset_n = '0') then
			x_cmp  := (others => '0');
			y_cmp  := (others => '0');
			tmp_dv <= '0';
			taps_dv <= '0';
			
			counter := (others => '0');

		elsif (rising_edge(clk)) then

			-- now it will enable the out_dv in the correct timming (when have a full 3x3 matrix of image data to multiply with the kernel in the next stage)
			if(enable = '1' and in_dv = '1') then
	---------------------------------------------------------------------------------------------------------------------------------------------------------					
				counter := counter + to_unsigned(1, NBITS_COUNTER);
				
				--=======================================================================================================================================
				-- the x_cmp starts at 1 and goes to 28				
				if (y_cmp = to_unsigned(0, NBITS_DELAY)) then -- no inicio, temos 1 ciclos de relogio a preto
					tmp_dv <= '0';

					if(x_cmp = to_unsigned(IMAGE_WIDTH, NBITS_DELAY)) then -- (debug mode: when connect 'out_data' directly to the outside, it can have some delay at the beginning. This way just add 'IMAGE_WIDTH+delay' with the necessary delay)
						x_cmp := to_unsigned(1, NBITS_DELAY);
						y_cmp := y_cmp + to_unsigned(1, NBITS_DELAY);
					else
						x_cmp := x_cmp + to_unsigned(1, NBITS_DELAY);
					end if;	  
				--=======================================================================================================================================
				elsif (y_cmp < to_unsigned(KERNEL_SIZE-1, NBITS_DELAY)) then -- y_cmp < 2 (y_cmp vai de 0 ate 1 = 2 elementos)
					tmp_dv <= '0';

					if (x_cmp = to_unsigned(IMAGE_WIDTH, NBITS_DELAY)) then -- if x_cmp == 28 (se estiver na ultima coluna, coloca a zero e soma 1 a y_cmp (muda de linha))
						x_cmp := to_unsigned(1, NBITS_DELAY);
						y_cmp := y_cmp + to_unsigned(1, NBITS_DELAY);
					else
						x_cmp := x_cmp + to_unsigned(1, NBITS_DELAY);
					end if;	  
				--=======================================================================================================================================
				elsif(y_cmp < to_unsigned(IMAGE_WIDTH, NBITS_DELAY)) then -- y_cmp between KERNEL_SIZE-1 and IMAGE_WIDTH-1
					-- Start of frame

					-- if I connect the hole wire 'out_data' to a array, it takes one more time. If I connect only 1 elemnt of out_data it dont take that 1 more clock cicle.
					-- With array: x_cmp < to_unsigned (KERNEL_SIZE, NBITS_DELAY)
					-- 				x_cmp = to_unsigned (IMAGE_WIDTH, NBITS_DELAY)
					if(x_cmp < to_unsigned (KERNEL_SIZE, NBITS_DELAY)) then -- x_cmp < 3  (de 1 a 2, 2 elementos)
						tmp_dv <= '0';
						x_cmp  := x_cmp + to_unsigned(1, NBITS_DELAY);
						
					elsif(x_cmp = to_unsigned (IMAGE_WIDTH, NBITS_DELAY)) then -- x_cmp = 28
						tmp_dv <= '1';
						
						x_cmp  := to_unsigned(1, NBITS_DELAY);
						y_cmp  := y_cmp + to_unsigned(1, NBITS_DELAY);
						
						--counter := counter + to_unsigned(1, NBITS_COUNTER);						
					else -- x_cmp entre 3 e 27 (inclusive)
						tmp_dv <= '1';
						
						x_cmp  := x_cmp + to_unsigned(1, NBITS_DELAY);
						
						--counter := counter + to_unsigned(1, NBITS_COUNTER);
					end if;
				--=======================================================================================================================================
				else -- y_cmp >= IMAGE_WIDTH
					-- this part I think is never used, because the in_dv its 0
					if(counter <= to_unsigned((IMAGE_WIDTH - KERNEL_SIZE + 1)*(IMAGE_WIDTH - KERNEL_SIZE + 1), NBITS_COUNTER)) then
						tmp_dv <= '1';
						--counter := counter + to_unsigned(1, NBITS_COUNTER);
					else
						tmp_dv <= '0';
					end if;
				end if;
	---------------------------------------------------------------------------------------------------------------------------------------------------------
			else -- enable and in_dv
				
				-- the out_data has a delay of 2 clock cycles. this way, after receive all image, its necessary to keep the out_dv at high state for 2 more clock ciles
				-- Still has a problem that the last pixel value is not new, so it repeats the 2 last value. I think its not a problem...
				if(counter = to_unsigned(IMAGE_WIDTH*IMAGE_WIDTH-1, NBITS_COUNTER)) then
					taps_dv <= '1';
					tmp_dv <= '0';
					counter := counter + to_unsigned(1, NBITS_COUNTER);
				elsif(counter > to_unsigned(IMAGE_WIDTH*IMAGE_WIDTH-1, NBITS_COUNTER) and counter <= to_unsigned(IMAGE_WIDTH*IMAGE_WIDTH+1, NBITS_COUNTER)) then
					taps_dv <= '1';
					tmp_dv <= '1';
					counter := counter + to_unsigned(1, NBITS_COUNTER);
				else
					tmp_dv <= '0';
					taps_dv <= '0';
				end if;
				
			end if;
		end if;
		
		--aux_counter <= std_logic_vector(counter);
	end process;

	--out_data(0) <= in_data;
	out_dv <= tmp_dv;
	--aux_counter <= aux_aux_counter;
end architecture;
