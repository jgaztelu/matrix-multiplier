library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity matrix_multiplier_top is
  port (
  clk   : in std_logic;
  rst   : in std_logic;
  start : in std_logic;
  data_write : in std_logic;
  data_in : in std_logic_vector(7 downto 0);
  finished  : out std_logic;
  data_out  : out std_logic_vector (16 downto 0)
  );
end entity;

architecture arch of matrix_multiplier_top is
--COMPONENTS
  component matrix_multi
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    start       : in  std_logic;
    finished    : out std_logic;
    RAM_WEB     : out std_logic;
    RAM_CS      : out std_logic;
    RAM_OE      : out std_logic;
    addressRAM  : out std_logic_vector(6 downto 0);
    dataRAM     : out unsigned (15 downto 0);
    dataROM     : in  unsigned (13 downto 0);
    ROM_CS      : out std_logic;
    ROM_OE      : out std_logic;
    addressROM  : out unsigned (8 downto 0);
    in_reg      : in  unsigned (15 downto 0);
    register_OE : out std_logic
  );
  end component matrix_multi;

  component input_register
  port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    OE       : in  std_logic;
    WEB      : in  std_logic;
    data_in  : in  std_logic_vector (7 downto 0);
    data_out : out std_logic_vector (15 downto 0)
  );
  end component input_register;

  component rom_wrapper
  port (
    addr     : in  unsigned(8 downto 0);
    data_out : out unsigned(13 downto 0);
    CK       : IN  std_logic;
    CS       : IN  std_logic;
    OE       : IN  std_logic
  );
  end component rom_wrapper;

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

  --  signals

  signal RAM_WEB,RAM_CS,RAM_OE : std_logic; -- RAM control signals
  signal ROM_CS,ROM_OE         : std_logic; -- ROM control signals
  signal RAM_addr              : unsigned (6 downto 0); -- RAM address selector
  signal ROM_addr              : unsigned (8 downto 0); -- ROM address selector
  signal RAM_data              : unsigned (31 downto 0); -- Data read from the ROM
  signal ROM_data              : unsigned (13 downto 0); -- Data written to RAM
  signal register_OE            : std_logic;


begin

  matrix_multi1 : matrix_multi
  port map (
    clk         => clk,
    rst         => rst,
    start       => start,
    finished    => finished,
    RAM_WEB     => RAM_WEB,
    RAM_CS      => RAM_CS,
    RAM_OE      => RAM_OE,
    addressRAM  => RAM_addr,
    dataRAM     => RAM_data,
    dataROM     => ROM_data,
    ROM_CS      => ROM_CS,
    ROM_OE      => ROM_OE,
    addressROM  => ROM_addr,
    in_reg      => in_reg,
    register_OE => register_OE
  );


  input_register1 : input_register
  port map (
    clk      => clk,
    rst      => rst,
    OE       => register_OE,
    WEB      => data_write,
    data_in  => data_in,
    data_out => data_out
  );

  rom_wrapper1 : rom_wrapper
  port map (
    addr     => ROM_addr,
    data_out => ROM_data,
    CK       => clk,
    CS       => ROM_CS,
    OE       => ROM_OE
  );

  ram_wrapper_i : ram_wrapper
  port map (
    addr     => RAM_addr,
    data_out => data_out,
    data_in  => RAM_data,
    CK       => clk,
    CS       => RAM_CS,
    WEB      => RAM_WEB,
    OE       => RAM_OE
  );





end architecture;
