library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity shift_8 is
  port (
  clk      : in std_logic;
  rst      : in std_logic;
  shift    : in std_logic; -- Activate Shifter
  data_in  : in std_logic_vector (7 downto 0);
  data_out : out std_logic_vector (47 downto 0)
  );
end entity;

architecture arch of shift_8 is
signal shifted,shifted_next : std_logic_vector (47 downto 0);
begin

-- Update registers
sequential: process (clk,rst)
begin
  if rst = '1' then
    shifted <= (others => '0');
  elsif clk'event and clk = '1' then
    shifted <= shifted_next;
  end if;
end process;

-- Shift values if shift is activated
-- Store previous value if shift is not activated
shifting: process (data_in,shift,shifted)
begin
  if shift = '1' then
    shifted_next <= data_in & shifted (47 downto 8);
  else
    shifted_next <= shifted;
  end if;
end process;
data_out <= shifted;
end architecture;
