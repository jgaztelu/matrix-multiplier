library ieee;
  use ieee.std_logic_1164.all;
  --use foc0l_a33_t33_generic_io.all;

entity matrix_multiplier_top_p is
    generic(N_in:integer:=8;
	    N_out:integer:=18);
    port (
    clk   : in std_logic;
    rst   : in std_logic;
    start : in std_logic;
    data_write : in std_logic;
    data_in : in std_logic_vector(7 downto 0);
    finished  : out std_logic;
    data_out  : out std_logic_vector (17 downto 0)
  );
end entity;

architecture matrix_multiplier_top_p of matrix_multiplier_top_p is
  component XMLB
    port( I :  in std_logic;
          O : out std_logic;
         PU :  in std_logic;
         PD :  in std_logic;
        SMT :  in std_logic );
  end component;

  component YA28SLB
    port( O : out std_logic;
          I :  in std_logic;
          E :  in std_logic;
         E2 :  in std_logic;
         E4 :  in std_logic;
         SR :  in std_logic );
  end component;

    component matrix_multiplier_top
      port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        start      : in  std_logic;
        data_write : in  std_logic;
        data_in    : in  std_logic_vector(7 downto 0);
        finished   : out std_logic;
        data_out   : out std_logic_vector (17 downto 0)
  );
  end component matrix_multiplier_top;


  signal clk_i : std_logic;
  signal rst_i : std_logic;
  signal start_i : std_logic;
  signal data_write_i : std_logic;
  signal data_in_i : std_logic_vector (7 downto 0);
  signal finished_i : std_logic;
  signal data_out_i : std_logic_vector (17 downto 0);

  signal HIGH, LOW : std_logic;
begin
  HIGH <= '1';
  LOW  <= '0';

  InPads : for i in 0 to N_in-1 generate
    InPad : XMLB
      port map( I => data_in(i), O => data_in_i(i), PU  => LOW, PD  => LOW, SMT => LOW);
  end generate InPads;

  clkpad : XMLB
    port map (I => clk, O => clk_i, PU => LOW, PD => LOW, SMT => LOW);
  rstpad : XMLB
    port map (I => rst, O => rst_i, PU => LOW, PD => LOW, SMT => LOW);
  startpad : XMLB
    port map (I => start, O => start_i, PU => LOW, PD => LOW, SMT => LOW);
  writepad : XMLB
    port map (I => data_write, O => data_write_i, PU => LOW, PD => LOW, SMT => LOW);

  OutPads : for i in 0 to N_out-1 generate
    OutPad : YA28SLB
      port map(O => data_out(i), I => data_out_i(i),
               E => HIGH, E2 => LOW, E4 => LOW, SR => LOW);
  end generate OutPads;
  Finishedpad : YA28SLB
    port map(O => finished, I => finished_i,E => HIGH, E2 => LOW, E4 => LOW, SR => LOW);

  matrix_multiplier_top_i : matrix_multiplier_top
  port map (
    clk        => clk_i,
    rst        => rst_i,
    start      => start_i,
    data_write => data_write_i,
    data_in    => data_in_i,
    finished   => finished_i,
    data_out   => data_out_i
  );


end architecture;
