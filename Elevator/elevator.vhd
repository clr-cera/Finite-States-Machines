library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity elevator is
    port (clk, reset : in bit;
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

begin
    process (clk)
    begin
        if (reset = '1') then
            state <= not_moving;
            current_floor <= "0000";
            objective_floor <= "0000";

        elsif (clk'event) and (clk = '1') then
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

                    if (objective_floor = current_floor) then
                        state <= not_moving;
                    else
                    current_floor <= current_floor + 1;
                    end if;

                when descending =>
                    movement <= "10";

                    if (objective_floor = current_floor) then
                        state <= not_moving;
                    else
                    current_floor <= current_floor - 1;
                    end if;
            
            end case;
        end if;
        current <= current_floor;
    end process;
end behaviour;