library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_textio.all;

entity matrix_multi_tb is
end entity;

architecture behavioural of matrix_multi_tb is
  component matrix_multi
  port (
    clk        : in  std_logic;
    rst        : in  std_logic;
    start      : in  std_logic;
    dataROM    : in  unsigned (13 downto 0);
    in_reg     : in  unsigned (15 downto 0);
    RAM_WEB    : out std_logic;
    RAM_CS     : out std_logic;
    RAM_OE     : out std_logic;
    addressRAM : out std_logic_vector(6 downto 0);
    dataRAM    : out unsigned (15 downto 0);
    ROM_CS     : out std_logic;
    ROM_OE     : out std_logic;
    addressROM : out unsigned (8 downto 0);
    finished   : out std_logic
  );
  end component matrix_multi;

  component ram_wrapper
  port (
    addr     : in  unsigned(6 downto 0);
    data_out : out std_logic_vector(31 downto 0);
    data_in  : in  std_logic_vector(31 downto 0);
    CK       : in  std_logic;
    CS       : in  std_logic;
    WEB      : in  std_logic;
    OE       : in  std_logic
  );
  end component ram_wrapper;

  component rom_wrapper
  port (
  addr     : in  unsigned(8 downto 0);
  data_out : out unsigned(13 downto 0);
  CK       : IN  std_logic;
  CS       : IN  std_logic;
  OE       : IN  std_logic
) ;
  end component rom_wrapper;

  constant clk_period               : time :=50 ns;
  signal clk,rst,start,finished,web : std_logic;
  signal RAM_CS,RAM_OE,RAM_WEB      : std_logic;
  signal ROM_CS,ROM_OE              : std_logic;
  signal dataROM                    : unsigned (13 downto 0);
  signal RAM_out,dataRAM            : unsigned (15 downto 0);
  signal in_reg                     : unsigned (7 downto 0);
  signal out_reg                    : unsigned (15 downto 0);
  signal addressROM                 : unsigned (8 downto 0);
  signal coef1,coef2                : unsigned (6 downto 0);
  signal addressRAM                 : std_logic_vector (6 downto 0);
  signal in1,in2                    : unsigned (7 downto 0);
  signal i                          : unsigned (6 downto 0) := (others => '0');

  --file input_file                   : text open read_mode is "C:\Javier\Uni\M1\IC Project 1\assignment_resources\input_stimuli.txt";

begin
--  matrix_multi_1 : matrix_multi
--  port map (
--    clk        => clk,
--    rst        => rst,
--    start      => start,
--    dataROM    => dataROM,
--    in_reg     => in_reg,
--    RAM_WEB    => RAM_WEB,
--    RAM_CS     => RAM_CS,
--    RAM_OE     => RAM_OE,
--    addressRAM => addressRAM,
--    dataRAM    => dataRAM,
--    ROM_CS     => ROM_CS,
--    ROM_OE     => ROM_OE,
--    addressROM => addressROM,
--    finished   => finished
--  );


--  ram_wrapper_1 : ram_wrapper
--  port map (
--    addr     => addressRAM,
--    data_out => RAM_out,
--    data_in  => dataRAM,
--    CK       => clk,
--    CS       => RAM_CS,
--    WEB      => RAM_WEB,
--    OE       => RAM_OE
--  );

--  rom_wrapper_1 : rom_wrapper
--  port map (
--  addr     => addressROM,
--  data_out => dataROM,
--  CK       => clk,
--  CS       => ROM_CS,
--  OE       => ROM_OE
--  );

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
    wait for clk_period;
    rst <= '0';
    start <= '1';
    wait for clk_period;
    start <= '0';
    wait;-- for clk_period;
  end process;

--  data_process: process
--  begin
--    i <= i+1;
--    coef1 <= i;
--    coef2 <= i;
--    in1 <= '0'&i;
--    in2 <= '0'&i;
--    dataROM <= coef1&coef2;
--    in_reg <= in1&in2;
--    wait for clk_period;
--  end process;

--  ram_process: process
--  begin
--    wait for clk_period;
--    RAM_CS<='1';
--    RAM_OE<='0';
--    RAM_WEB <= '0';
--    addressRAM <= "0000001";
--    dataRAM <= "01010101010101010101010101010101";
--    wait for clk_period;
--    RAM_CS<='1';
--    RAM_OE<='1';
--    RAM_WEB <= '1';
--    addressRAM <= "0000001";
--    dataRAM <= "01010101010101010101010101010101";
--    wait;
--  end process;
--  rom_process: process
--  begin
--    ROM_CS <='1';
--    ROM_OE <= '1';
--    addressROM <= "000000011";
--    wait;
--  end process;




end architecture;
