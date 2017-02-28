library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity ram_controller is
  port (
    read_address  : in unsigned (6 downto 0);
    write_address : in unsigned (6 downto 0);
    mem_read      : in std_logic;
    mem_write     : in std_logic;
    RAM_address   : out unsigned (6 downto 0);
    RAM_WEB       : out std_logic;
    RAM_OE        : out std_logic;
    RAM_CS        : out std_logic
  );
end entity;

architecture arch of ram_controller is

begin
process (read_address,write_address,mem_read,mem_write)
begin
  if mem_write = '1' then
    RAM_address <= write_address;
    RAM_CS <= '1';
    RAM_OE <= '0';
    RAM_WEB <= '1';
  elsif mem_read = '1' then
    RAM_address <= read_address;
    RAM_CS <= '1';
    RAM_OE <= '1';
    RAM_WEB <= '0';
  else
    RAM_address <= (others => '0');
    RAM_CS <= '0';
    RAM_OE <= '0';
    RAM_WEB <= '0';
  end if;
end process;

end architecture;
