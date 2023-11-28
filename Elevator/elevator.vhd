library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity elevator is
    port (
          clk, clk_placa: std_logic;
          reset: in bit;
          req: in bit;
          desired_floor: in unsigned(3 downto 0) := (others => '0');
          current: out unsigned(3 downto 0) := (others => '0');
          movement: out bit_vector(1 downto 0) := (others => '0'));

end elevator;

architecture behaviour of elevator is
    type states is (not_moving, rising, descending);
    signal state: states;
    signal current_floor: unsigned(3 downto 0) := (others => '0');
    signal objective_floor: unsigned(3 downto 0) := (others => '0');
    signal fixed_clock: std_logic;

    component Debouncing_Button_VHDL is
        port(
            button: in std_logic;
            clk: in std_logic;
            debounced_button: out std_logic
        );
    end component;

begin
    instance_debouncer: Debouncing_Button_VHDL
        port map (
            button => clk, clk => clk_placa,
            debounced_button => fixed_clock
        );

    process (fixed_clock)
    begin
        if (reset = '1') then
            state <= not_moving;
            current_floor <= "0000";
            current <= "0000";
            objective_floor <= "0000";
            movement <= "00";

        elsif (fixed_clock'event) and (fixed_clock = '1') then
            case state is

                when not_moving =>
                    movement <= "00";
                    if (req = '1' and desired_floor /= current_floor) then
                        objective_floor <= desired_floor;
                        if (desired_floor > current_floor) then
                            state <= rising;
                        else
                            state <= descending;
                        end if;
                    end if;

                when rising =>
                    movement <= "01";

                    current_floor <= current_floor + 1;
                    current <= current_floor +1;
                    
                    if (objective_floor = current_floor+1) then
                        state <= not_moving;
                    end if;

                when descending =>
                    movement <= "10";

                    current_floor <= current_floor - 1;
                    current <= current_floor -1;

                    if (objective_floor = current_floor-1) then
                    state <= not_moving;
                    end if;
            
            end case;
        end if;
    end process;
end behaviour;