library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity input_register is
  port (
  clk          : in std_logic;
  rst          : in std_logic;
  OE           : in std_logic; -- Output enable
  WEB          : in std_logic; -- Write enable
  data_in      : in std_logic_vector (7 downto 0);
  data_out     : out std_logic_vector (15 downto 0)
  );
end entity;

architecture behavioural of input_register is

  component shift_8
  port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    shift    : in  std_logic;
    data_in  : in  std_logic_vector (7 downto 0);
    data_out : out std_logic_vector (47 downto 0)
  );
  end component shift_8;

signal reg1, reg2, reg3, reg4                     : std_logic_vector (47 downto 0);
signal in_counter,in_counter_next                 : std_logic_vector (1 downto 0);
signal reg_select_counter,reg_select_counter_next : std_logic_vector (1 downto 0);
signal reg_word_counter,reg_word_counter_next     : std_logic_vector (1 downto 0);
signal reg_out                                    : std_logic_vector (47 downto 0);
signal shift_enable                               : std_logic_vector (3 downto 0);

begin
-- Update registers and counters
sequential: process (clk,rst)
begin
  if rst = '1' then
    reg_select_counter <= (others => '0');
    reg_word_counter <= (others => '0');
    in_counter <= (others =>'0');
  elsif clk'event and clk = '1' then
    reg_select_counter <= reg_select_counter_next;
    reg_word_counter <= reg_word_counter_next;
    in_counter <= in_counter_next;
  end if;

end process;

-- Update input counter and select register to shift
in_mux: process (data_in,in_counter,WEB)
begin
  if WEB = '0' then
    shift_enable <="0000";
    in_counter_next <="00";
  else
    case in_counter is
      when "00" =>
        in_counter_next <= "01";
        shift_enable <= "0001";
      when "01" =>
        in_counter_next <= "10";
        shift_enable <= "0010";
      when "10" =>
        in_counter_next <= "11";
        shift_enable <= "0100";
      when "11" =>
        in_counter_next <= "00";
        shift_enable <= "1000";
      when others =>
        null;
    end case;
  end if;
end process;


reg_select_mux: process (reg1,reg2,reg3,reg4,reg_select_counter)
begin
  case reg_select_counter is
    when "00" =>
      reg_out <= reg1;
    when "01" =>
      reg_out <= reg2;
    when "10" =>
      reg_out <= reg3;
    when "11" =>
      reg_out <= reg4;
    when others =>
      null;
   end case;
 end process;

word_select_mux: process (reg_out,reg_word_counter,reg_select_counter,OE)
begin
  reg_word_counter_next <= reg_word_counter;
  reg_select_counter_next <= reg_select_counter;
  if OE = '1' then
    case reg_word_counter is
      when "00" =>
        data_out <= reg_out(15 downto 0);
        reg_word_counter_next <= "01";
      when "01" =>
        data_out <= reg_out(31 downto 16);
        reg_word_counter_next <= "10";
      when "10" =>
        data_out <= reg_out (47 downto 32);
        reg_word_counter_next <= "11";
        if reg_select_counter = "11" then
          reg_select_counter_next <= "00";
        else
          reg_select_counter_next <=std_logic_vector(unsigned(reg_select_counter)+1);
        end if;
      when "11" =>
        reg_word_counter_next <= "00"; -- This case introduces an extra clock cycle delay to account for the Save state of the multiplier
        data_out <= reg_out (47 downto 32);
    when others =>
         reg_word_counter_next <= reg_word_counter;
         reg_select_counter_next <= reg_select_counter;
         data_out <= (others =>'0');
    end case;
  else
    data_out <= (others => '0');
  end if;
end process;

shift_row1 : shift_8
port map (
  clk      => clk,
  rst      => rst,
  shift    => shift_enable (0),
  data_in  => data_in,
  data_out => reg1
);

shift_row2 : shift_8
port map (
  clk      => clk,
  rst      => rst,
  shift    => shift_enable (1),
  data_in  => data_in,
  data_out => reg2
);

shift_row3 : shift_8
port map (
  clk      => clk,
  rst      => rst,
  shift    => shift_enable (2),
  data_in  => data_in,
  data_out => reg3
);

shift_row4 : shift_8
port map (
  clk      => clk,
  rst      => rst,
  shift    => shift_enable (3),
  data_in  => data_in,
  data_out => reg4
);

end architecture;
