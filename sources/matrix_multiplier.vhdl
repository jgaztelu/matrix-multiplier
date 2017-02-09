library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity matrix_multi is
  port (
  clk          : in std_logic;
  rst          : in std_logic;
  start        : in std_logic;
  rom_addr_rst : in std_logic;
  dataROM      : in unsigned (13 downto 0);
  in_reg       : in unsigned (15 downto 0);
  RAM_WEB      : out std_logic;
  RAM_CS       : out std_logic;
  RAM_OE       : out std_logic;
  addressRAM   : out std_logic_vector(6 downto 0);
  dataRAM      : out unsigned (15 downto 0);
  -- ROM signals
  ROM_CS       : out std_logic;
  ROM_OE       : out std_logic;
  addressROM   : out unsigned (8 downto 0);
  register_OE  : out std_logic;
  finished     : out std_logic

  );
end entity;

architecture arch of matrix_multi is
  component multiplier
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    mult_zero : in std_logic;
    coef1,coef2  : in  unsigned (6 downto 0);
    in1,in2    : in  unsigned (7 downto 0);
    result : out unsigned (15 downto 0)
  );
  end component multiplier;

  type state is (idle,multiply,save);
  signal current_state,next_state   : state;
  signal coef1,coef2                : unsigned (6 downto 0);
  signal in1,in2                    : unsigned(7 downto 0);
  signal counter,counter_next       : unsigned (1 downto 0);
  signal prod_count,prod_count_next : unsigned (3 downto 0);
  signal address,address_next       : unsigned (7 downto 0);
  signal result                     : unsigned (15 downto 0);
  signal mult_zero                  : std_logic;

begin
  --Update registers
  registers: process (clk,rst)
  begin
    if rst='1' then
      current_state <= idle;
      counter <="00";
      prod_count <= (others=>'0');
      address <= (others =>'0');
    elsif clk'event and clk ='1' then
      current_state <= next_state;
      counter       <= counter_next;
      prod_count    <= prod_count_next;
      address       <= address_next;
    end if;
  end process;
  -- Combinational case
  combinational: process (current_state,start,counter,address,prod_count,result,prod_count)
  begin
    RAM_WEB <= '0';
    finished <= '0';
  case current_state is
      --Initial state
      when idle =>
        mult_zero <='0';
        counter_next <= "00";
        prod_count_next <= (others => '0');
        address_next <= (others =>'0');
        if start='1' then
          next_state <= multiply;
        else
          next_state <= idle;
        end if;
      --Send data to multiplier
      when multiply =>
        mult_zero <= '0';
        counter_next <= counter + 1;
        address_next <= address + 1;
        prod_count_next <= prod_count;
        if counter = 2 then
          next_state <= save;
        else
          next_state <= multiply;
        end if;
      when save =>
        mult_zero       <= '1';
        RAM_WEB         <= '1';
        finished        <= '1';
        dataRAM         <= result;
        counter_next    <= "00";
        prod_count_next <= prod_count + 1;
        if prod_count = 15 then
          next_state    <= idle;
        else
          next_state    <= multiply;
        end if;
    end case;
  end process;
    coef1 <= dataROM (6 downto 0);
    coef2 <= dataROM (13 downto 7);
    in1   <= in_reg (7 downto 0);
    in2   <= in_reg (15 downto 8);
  multiplier_1 : multiplier
  port map (
    clk    => clk,
    rst    => rst,
    coef1  => coef1,
    coef2  => coef2,
    in1    => in1,
    in2    => in2,
    result => result,
    mult_zero => mult_zero
  );

end architecture;
