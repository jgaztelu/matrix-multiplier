library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity matrix_multiplier_top is
port (

  )
end entity;

architecture arch of matrix_multiplier_top is
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

begin
  matrix_multi_1: matrix_multi
  port map (
    clk        => clk,
    rst        => rst,
    start      => start,
    dataROM    => dataROM,
    in_reg     => in_reg,
    RAM_WEB    => RAM_WEB,
    RAM_CS     => RAM_CS,
    RAM_OE     => RAM_OE,
    addressRAM => addressRAM,
    dataRAM    => dataRAM,
    ROM_CS     => ROM_CS,
    ROM_OE     => ROM_OE,
    addressROM => addressROM,
    finished   => finished
  );

end architecture;
