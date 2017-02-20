library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_textio.all;
  use std.textio.all;

entity matrix_multi_tb is
end entity;

architecture behavioural of matrix_multi_tb is
  -- DUT
  component matrix_multiplier_top
  port (
    clk        : in  std_logic;
    rst        : in  std_logic;
    start      : in  std_logic;
    data_write : in  std_logic;
    data_in    : in  std_logic_vector(7 downto 0);
    finished   : out std_logic;
    data_out   : out std_logic_vector (31 downto 0)
  );
  end component matrix_multiplier_top;

  -- DUT SIGNALS
  signal    clk            : std_logic;
  signal rst               : std_logic;
  signal start             : std_logic;
  signal data_write        : std_logic;
  signal  data_in          : std_logic_vector (7 downto 0);
  signal finished          : std_logic;
  signal data_out          : std_logic_vector (31 downto 0);
  -- TB SIGNALS
  constant clk_period      : time := 50 ns;
  shared variable row      : line;
  shared variable row_data : std_logic_vector(7 downto 0);
  file input_file          : text open read_mode is "input_stimuli_Jaume.txt";
  signal row_counter : integer:=0;
begin

  clk_process: process
  begin
    clk<='1';
    wait for clk_period/2;
    clk<='0';
    wait for clk_period/2;
  end process;

  stim_process: process
  begin
    rst <= '1';
    wait for clk_period*1.5;
    rst <= '0';
    start <= '0';
    data_write <= '1';
    wait for clk_period * 24;-- for clk_period;
    data_write <= '0';
    start <= '1';
    wait for clk_period;
    start <= '0';
    wait;
  end process;

  file_process: process
  begin
      wait for clk_period;
      while not endfile(input_file) and row_counter < 25 loop
          row_counter <= row_counter +1;
          readline(input_file,row);
          read (row,row_data);
          data_in <= row_data;
          wait for clk_period;
      end loop;
      wait;
  end process;

  matrix_multiplier_top1 : matrix_multiplier_top
  port map (
    clk        => clk,
    rst        => rst,
    start      => start,
    data_write => data_write,
    data_in    => data_in,
    finished   => finished,
    data_out   => data_out
  );

end architecture;
