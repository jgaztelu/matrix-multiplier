library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_textio.all;
  use std.textio.all;

entity input_register_tb is
end entity;

architecture arch of input_register_tb is

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

constant clk_period : time := 50 ns;
-- DUT signals
signal clk      : std_logic;
signal rst      : std_logic;
signal OE       : std_logic;
signal WEB      : std_logic;
signal data_in  : std_logic_vector(7 downto 0);
signal data_out : std_logic_vector (15 downto 0);
signal data1, data2 : std_logic_vector(7 downto 0);
-- Input data file
file input_data : text open read_mode is in "input_stimuli_Jaume.txt";

signal row_counter : integer:=0;
shared variable row         : line;
shared variable row_data    : std_logic_vector(7 downto 0);
begin

clk_process: process
begin
  clk <= '1';
  wait for clk_period/2;
  clk <= '0';
  wait for clk_period/2;
end process;

stim_process: process
begin
  rst <= '1';
  WEB <= '0';
  OE <= '0';
  wait for clk_period;
  rst <= '0';
  WEB <= '1';
  OE <= '0';
  wait for 24*clk_period;
  WEB <= '0';
  OE  <= '1';
  wait;
end process;

file_process: process
begin
    wait for clk_period;
    while not endfile(input_data) and row_counter < 25 loop
        row_counter <= row_counter +1;
        readline(input_data,row);
        read (row,row_data);
        data_in <= row_data;
        wait for clk_period;
    end loop;
    wait;
end process;
data1 <= data_out (7 downto 0);
data2 <= data_out (15 downto 8);

input_register_i : input_register
port map (
  clk      => clk,
  rst      => rst,
  OE       => OE,
  WEB      => WEB,
  data_in  => data_in,
  data_out => data_out
);

end architecture;
