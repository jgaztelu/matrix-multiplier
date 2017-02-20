library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
entity multiplier is
  port (
  clk         : in std_logic;
  rst         : in std_logic;
  mult_zero   : in std_logic;
  coef1,coef2 : in unsigned (6 downto 0);
  in1,in2     : in unsigned (7 downto 0);
  result      : out unsigned (17 downto 0)
  );
end entity;

architecture arch of multiplier is
signal sum_out_prev,sum_out : unsigned (17 downto 0);

begin

registers: process(clk,rst,mult_zero)
begin
  if rst = '1' or mult_zero = '1' then
    sum_out_prev <= (others =>'0');
  elsif clk'event and clk='1' then
    sum_out_prev <= sum_out;
  end if;
end process;

multiplier: process(coef1,coef2,in1,in2,sum_out_prev)
begin
  sum_out<= sum_out_prev+(coef1*in1)+(coef2*in2);
end process;
result       <= sum_out;
end architecture;
