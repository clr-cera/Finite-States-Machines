--fpga4student.com: FPGA projects, Verilog projects, VHDL projects
-- VHDL project: VHDL code for debouncing buttons on FPGA
-- Generate Slow clock enable for debouncing buttons 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clock_enable_debouncing_button is

port(
 clk: in std_logic; -- input clock on FPGA 100Mhz
                           -- Change counter threshold accordingly
 slow_clk_enable: out std_logic
);

end clock_enable_debouncing_button;


architecture Behavioral of clock_enable_debouncing_button is
signal counter: std_logic_vector(27 downto 0):=(others => '0');
begin

process(clk)
begin
if(rising_edge(clk)) then
  counter <= counter + x"0000001"; 
  if(counter>=x"003D08F") then -- reduce this number for simulation
   counter <=  (others => '0');
  end if;
 end if;
end process;
 slow_clk_enable <= '1' when counter=x"003D08F" else '0'; -- reduce this number for simulation
end Behavioral;





--fpga4student.com: FPGA projects, Verilog projects, VHDL projects
-- VHDL project: VHDL code for debouncing buttons on FPGA
-- VHDL D-flip-flop with clock enable signal for debouncing buttons 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity DFF_Debouncing_Button is
port(
 clk: in std_logic;
 clock_enable: in std_logic;
 D: in std_logic;
 Q: out std_logic:='0'
);
end DFF_Debouncing_Button;
architecture Behavioral of DFF_Debouncing_Button is
begin
process(clk)
begin
 if(rising_edge(clk)) then
  if(clock_enable='1') then
   Q <= D;
  end if;
 end if;
end process;
end Behavioral;
--fpga4student.com: FPGA projects, Verilog projects, VHDL projects
-- VHDL project: VHDL code for debouncing buttons on FPGA
-- VHDL code for button debouncing on FPGA 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity Debouncing_Button_VHDL is
port(
 button: in std_logic;
 clk: in std_logic;
 debounced_button: out std_logic
);
end Debouncing_Button_VHDL;
architecture Behavioral of Debouncing_Button_VHDL is
signal slow_clk_enable: std_logic;
signal Q1,Q2,Q2_bar,Q0: std_logic;
begin

clock_enable_generator: entity work.clock_enable_debouncing_button PORT MAP 
      ( clk => clk,
        slow_clk_enable => slow_clk_enable
      );
Debouncing_FF0: entity work.DFF_Debouncing_Button PORT MAP 
      ( clk => clk,
        clock_enable => slow_clk_enable,
        D => button,
        Q => Q0
      ); 

Debouncing_FF1: entity work.DFF_Debouncing_Button PORT MAP 
      ( clk => clk,
        clock_enable => slow_clk_enable,
        D => Q0,
        Q => Q1
      );      
Debouncing_FF2: entity work.DFF_Debouncing_Button PORT MAP 
      ( clk => clk,
        clock_enable => slow_clk_enable,
        D => Q1,
        Q => Q2
      ); 
 Q2_bar <= not Q2;
 debounced_button <= Q1 and Q2_bar;
end Behavioral;