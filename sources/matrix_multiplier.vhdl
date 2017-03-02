library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity matrix_multi is
  port (
  clk         : in std_logic;
  rst         : in std_logic;
  start       : in std_logic;
  finished    : out std_logic;
  -- RAM signals
  addressRAM  : out unsigned (6 downto 0);
  dataRAM     : out unsigned (31 downto 0);
  RAM_WEB     : out std_logic;
  RAM_CS      : out std_logic;
  RAM_OE      : out std_logic;
    -- ROM signals
  dataROM     : in unsigned (13 downto 0);
  ROM_CS      : out std_logic;
  ROM_OE      : out std_logic;
  addressROM  : out unsigned (8 downto 0);
  -- Register signals
  in_reg      : in unsigned (15 downto 0);
  register_OE : out std_logic

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
    result : out unsigned (17 downto 0)
  );
  end component multiplier;

  type state is (idle,multiply,save);
  signal current_state,next_state   : state;
  signal coef1,coef2                : unsigned (6 downto 0);
  signal in1,in2                    : unsigned(7 downto 0);
  signal counter,counter_next       : unsigned (1 downto 0);
  signal prod_count,prod_count_next : unsigned (4 downto 0);
  signal addressROM_sig,addressROM_sig_next       : unsigned (8 downto 0);
  signal addressRAM_sig,addressRAM_sig_prev       : unsigned (6 downto 0);
  signal baseROM                    : unsigned (7 downto 0);
  signal result, result_out         : unsigned (17 downto 0);
  signal mult_zero                  : std_logic;
  signal reg_enable,reg_enable_next : std_logic;
  signal finished_sig               : std_logic;
begin
  --Update registers
  registers: process (clk,rst)
  begin
    if rst='1' then
      current_state <= idle;
      counter <="00";
      prod_count <= (others=>'0');
      addressROM_sig <= (others =>'0'); -- Initialize ROM address to 1
      addressRAM_sig_prev <= (others =>'0');
      reg_enable <= '0';
      result_out  <= (others => '0');
    elsif clk'event and clk ='1' then
      current_state <= next_state;
      counter       <= counter_next;
      prod_count    <= prod_count_next;
      addressROM_sig       <= addressROM_sig_next;
      addressRAM_sig_prev <= addressRAM_sig;
      reg_enable    <= reg_enable_next;
      result_out  <= result;
    end if;
  end process;
  -- Combinational case
  combinational: process (current_state,start,counter,addressROM_sig,addressRAM_sig_prev,prod_count,result_out)
  begin
    -- Set memory signals to default
    RAM_WEB <= '0';
    RAM_OE <= '0';
    RAM_CS <= '0';
    ROM_CS  <= '1';
    ROM_OE  <= '1';
    finished_sig <= '0';
    addressRAM_sig <= addressRAM_sig_prev;

  case current_state is
      --Initial state
      when idle =>
        mult_zero <='0';
        counter_next <= "00";
        prod_count_next <= (others => '0');
        if start='1' then
          next_state <= multiply;
          addressROM_sig_next <= addressROM_sig + 1; -- Update next ROM address in the cycle previous to multiplying state to compensate ROM delay.
        else
          addressROM_sig_next <= (others => '0');
          next_state <= idle;
        end if;
      --Send data to multiplier
      when multiply =>
        RAM_OE <= '1';
        RAM_CS <= '1';
        mult_zero <= '0';
        counter_next <= counter + 1;
        prod_count_next <= prod_count;
        if counter = 2 then
          next_state <= save;
          addressROM_sig_next <= (others => '0');
          prod_count_next <= prod_count + 1;
          addressRAM_sig <= addressRAM_sig_prev + 1; -- Update RAM address
        else
          next_state <= multiply;
          addressROM_sig_next <= addressROM_sig + 1;
        end if;
      when save =>
        -- Assign RAM signals for writing
        RAM_CS <= '1';
        RAM_WEB <= '1';
        RAM_OE <= '1';
        counter_next    <= "00";
        dataRAM (17 downto 0) <= result_out;            -- Save data in RAM
        addressROM_sig_next <= addressROM_sig + 1;
        mult_zero       <= '1'; -- Zero the multiplier units
        if prod_count = 16 then
          next_state    <= idle;
          finished_sig  <= '1';
        else
          next_state    <= multiply;
          finished_sig  <= '0';
        end if;
    end case;
  end process;
  -- Process to set the reg_enable signal for the input register.
  -- Output is set when start signal arrives
  -- Output is reset when finished_sig arrives
  in_reg_enable: process (start,finished_sig,reg_enable)
  begin
    if start = '1' and finished_sig = '0' then
      reg_enable_next <= '1';
    elsif finished_sig = '1' then
      reg_enable_next <= '0';
    else
      reg_enable_next <= reg_enable;
    end if;
  end process;

  rom_base_address: process (prod_count)
  begin
    if prod_count <= x"03" then
      baseROM <= (others => '0');
    elsif prod_count <= x"07" then
      baseROM <= x"03"; --3
    elsif prod_count <= x"0B" then
      baseROM <= x"06"; -- 6
    else
      baseROM <= x"09"; -- 9
    end if;
  end process;

-- Assign signals to module I/O
    addressROM             <= addressROM_sig + baseROM;
    addressRAM             <= addressRAM_sig;
    coef1                  <= dataROM (6 downto 0);
    coef2                  <= dataROM (13 downto 7);
    in1                    <= in_reg (7 downto 0);
    in2                    <= in_reg (15 downto 8);
    register_OE            <= reg_enable;
    finished               <= finished_sig;
    dataRAM (31 downto 18) <= (others => '0');

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
