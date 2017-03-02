library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity ram_tb is

end entity;

architecture arch of ram_tb is
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

  signal address : unsigned (6 downto 0);
  signal data_out : std_logic_vector (31 downto 0);
  signal data_in : std_logic_vector (31 downto 0);
  signal clk    : std_logic;
  signal RAM_CS,RAM_WEB,RAM_OE : std_logic;
  signal counter : unsigned (6 downto 0);
  constant clk_period      : time := 200 ns;
begin

RAM_process: process
begin
  address <= (others => '0');
  data_in <= (others => '0');
  RAM_CS <= '0';
  RAM_WEB <= '0';
  RAM_OE <= '0';
  counter <= (others => '0');
  data_in (31 downto 14) <= (others => '0');
  wait for clk_period;
  while counter < 10 loop
    RAM_CS  <= '1';
    RAM_WEB <= '1';
    RAM_OE <= '0';
    address <= counter;
    data_in (13 downto 0) <= std_logic_vector(2*counter);  
    wait for 4*clk_period;
    address <= counter -1;
    RAM_WEB <= '0';
    RAM_CS <= '1';
    RAM_OE <= '1';
    counter <= counter +1;
    wait for 4*clk_period;
  end loop;
  wait;
end process;

  clk_process: process
  begin
    clk<='1';
    wait for clk_period/2;
    clk<='0';
    wait for clk_period/2;
  end process;



  ram_wrapper1 : ram_wrapper
  port map (
    addr     => address,
    data_out => data_out,
    data_in  => data_in,
    CK       => clk,
    CS       => RAM_CS,
    WEB      => RAM_WEB,
    OE       => RAM_OE
  );
end architecture;
